from datetime import datetime, date, timedelta
from typing import List, Optional, Dict, Any
import uuid
from collections import Counter, defaultdict

from app.core.exceptions import NotFoundError, ValidationError
from app.core.error_codes import ErrorCode
from app.application.repositories.medication_repository import IMedicationRepository
from app.application.schemas.analytics import (
    MedicationStatsResponse, ComplianceRateResponse, MedicationHistoryResponse,
    MedicationStats, DailyStats, HistoryEntry, WeeklyStats, MonthlyStats, 
    YearlyStats, AnalyticsSummaryResponse
)


class AnalyticsService:
    """통계 및 분석 비즈니스 로직 (API 명세서 기준)"""

    def __init__(self, med_repo: IMedicationRepository):
        self.med_repo = med_repo

    async def get_medication_stats(
        self, 
        user_id: uuid.UUID, 
        start_date: Optional[str] = None,
        end_date: Optional[str] = None
    ) -> MedicationStatsResponse:
        """약물 복용 통계 조회 (API 명세서 기준)"""
        # 날짜 범위 설정
        if start_date:
            try:
                start_dt = datetime.fromisoformat(start_date)
            except ValueError:
                raise ValidationError("Invalid start_date format. Use YYYY-MM-DD format.", ErrorCode.VALIDATION_ERROR)
        else:
            start_dt = datetime.now() - timedelta(days=30)  # 기본 30일
        
        if end_date:
            try:
                end_dt = datetime.fromisoformat(end_date)
            except ValueError:
                raise ValidationError("Invalid end_date format. Use YYYY-MM-DD format.", ErrorCode.VALIDATION_ERROR)
        else:
            end_dt = datetime.now()

        # 약물 목록 조회
        medications = await self.med_repo.get_medications_by_user_id(user_id)
        
        # 복용 로그 조회
        logs = await self.med_repo.get_records_by_date_range(
            user_id=user_id,
            start_date=start_dt,
            end_date=end_dt
        )

        # 통계 계산
        total_medications = len(medications)
        total_logs = len(logs)
        
        # 복용 준수율 계산
        taken_logs = [log for log in logs if log.is_taken]
        compliance_rate = (len(taken_logs) / total_logs * 100) if total_logs > 0 else 0.0

        # 가장 많이 복용한 약물
        medication_counts = Counter(log.medication_id for log in taken_logs)
        most_taken_medication = None
        if medication_counts:
            most_med_id, count = medication_counts.most_common(1)[0]
            most_med = next((m for m in medications if str(m.id) == most_med_id), None)
            if most_med:
                most_taken_medication = MedicationStats(
                    id=str(most_med.id),
                    name=most_med.name,
                    count=count
                )

        # 일별 통계
        daily_stats = self._calculate_daily_stats(logs, start_dt, end_dt)

        return MedicationStatsResponse(
            total_medications=total_medications,
            total_logs=total_logs,
            compliance_rate=round(compliance_rate, 1),
            most_taken_medication=most_taken_medication,
            daily_stats=daily_stats
        )

    async def get_compliance_rate(
        self,
        user_id: uuid.UUID,
        medication_id: Optional[str] = None,
        period: str = "month"
    ) -> ComplianceRateResponse:
        """복용 준수율 조회 (API 명세서 기준)"""
        # 기간별 날짜 범위 설정
        start_date, end_date = self._get_period_range(period)
        
        # 약물 조회
        if medication_id:
            medication = await self.med_repo.get_medication_by_id(user_id, uuid.UUID(medication_id))
            if not medication:
                raise NotFoundError("약물을 찾을 수 없습니다", ErrorCode.MED_MEDICATION_NOT_FOUND)
            medications = [medication]
        else:
            medications = await self.med_repo.get_medications_by_user_id(user_id)

        # 복용 로그 조회
        logs = await self.med_repo.get_records_by_date_range(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            medication_id=uuid.UUID(medication_id) if medication_id else None
        )

        # 예상 복용 횟수 계산 (약물별로)
        total_expected = 0
        for med in medications:
            # 반복 요일에 따른 예상 복용 횟수 계산
            days_in_period = (end_date - start_date).days + 1
            
            # repeat_days를 안전하게 처리
            try:
                if isinstance(med.repeat_days, str):
                    # JSON 문자열인 경우 파싱
                    import json
                    repeat_days = json.loads(med.repeat_days)
                elif isinstance(med.repeat_days, list):
                    repeat_days = med.repeat_days
                else:
                    continue
                    
                expected_count = sum(1 for day in range(days_in_period) 
                                  if (start_date + timedelta(days=day)).weekday() + 1 in repeat_days)
                total_expected += expected_count
            except (json.JSONDecodeError, TypeError):
                # JSON 파싱 실패 시 건너뛰기
                continue

        # 실제 복용 횟수
        total_taken = len([log for log in logs if log.is_taken])
        missed_count = total_expected - total_taken
        compliance_rate = (total_taken / total_expected * 100) if total_expected > 0 else 0.0

        medication_name = medications[0].name if medications else "전체"
        med_id = medication_id if medication_id else "all"

        return ComplianceRateResponse(
            medication_id=med_id,
            medication_name=medication_name,
            period=period,
            compliance_rate=round(compliance_rate, 1),
            total_expected=total_expected,
            total_taken=total_taken,
            missed_count=missed_count
        )

    async def get_medication_history(
        self,
        user_id: uuid.UUID,
        medication_id: Optional[str] = None,
        period: str = "week"
    ) -> MedicationHistoryResponse:
        """복용 히스토리 조회 (API 명세서 기준)"""
        # 기간별 날짜 범위 설정
        start_date, end_date = self._get_period_range(period)
        
        # 약물 조회
        if medication_id:
            medication = await self.med_repo.get_medication_by_id(user_id, uuid.UUID(medication_id))
            if not medication:
                raise NotFoundError("약물을 찾을 수 없습니다", ErrorCode.MED_MEDICATION_NOT_FOUND)
            medication_name = medication.name
        else:
            medication_name = "전체"

        # 복용 로그 조회
        logs = await self.med_repo.get_records_by_date_range(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            medication_id=uuid.UUID(medication_id) if medication_id else None
        )

        # 히스토리 엔트리 생성
        history = []
        for log in logs:
            history.append(HistoryEntry(
                date=log.date.strftime("%Y-%m-%d") if log.date else log.taken_at.strftime("%Y-%m-%d"),
                taken_at=log.taken_at,
                is_taken=log.is_taken,
                note=log.note
            ))

        # 날짜순 정렬
        history.sort(key=lambda x: x.date)

        med_id = medication_id if medication_id else "all"

        return MedicationHistoryResponse(
            medication_id=med_id,
            medication_name=medication_name,
            period=period,
            history=history,
            total_entries=len(history)
        )

    async def get_analytics_summary(self, user_id: uuid.UUID) -> AnalyticsSummaryResponse:
        """분석 요약 조회"""
        # 최근 30일 데이터 조회
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)

        # 약물 및 로그 조회
        medications = await self.med_repo.get_medications_by_user_id(user_id)
        logs = await self.med_repo.get_medication_logs(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date
        )

        # 기본 통계
        total_medications = len(medications)
        active_medications = len([m for m in medications if m.is_active])
        total_logs = len(logs)
        taken_logs = [log for log in logs if log.is_taken]
        
        # 전체 준수율
        overall_compliance_rate = (len(taken_logs) / total_logs * 100) if total_logs > 0 else 0.0

        # 연속 복용일 계산
        streak_days = self._calculate_streak_days(logs)

        # 마지막 복용일
        last_taken_date = None
        if taken_logs:
            last_log = max(taken_logs, key=lambda x: x.taken_at)
            last_taken_date = last_log.taken_at.strftime("%Y-%m-%d")

        # 가장 활발한 시간대
        most_active_time = self._get_most_active_time(taken_logs)

        return AnalyticsSummaryResponse(
            overall_compliance_rate=round(overall_compliance_rate, 1),
            total_medications=total_medications,
            active_medications=active_medications,
            total_logs=total_logs,
            streak_days=streak_days,
            last_taken_date=last_taken_date,
            most_active_time=most_active_time
        )

    # 헬퍼 메서드들

    def _get_period_range(self, period: str) -> tuple[datetime, datetime]:
        """기간에 따른 날짜 범위 반환"""
        end_date = datetime.now()
        
        if period == "week":
            start_date = end_date - timedelta(days=7)
        elif period == "month":
            start_date = end_date - timedelta(days=30)
        elif period == "year":
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=30)  # 기본값
        
        return start_date, end_date

    def _calculate_daily_stats(self, logs: List, start_date: datetime, end_date: datetime) -> List[DailyStats]:
        """일별 통계 계산"""
        daily_stats = defaultdict(lambda: {"total": 0, "taken": 0, "missed": 0})
        
        # 로그별 통계 계산
        for log in logs:
            date_str = log.taken_at.strftime("%Y-%m-%d")
            daily_stats[date_str]["total"] += 1
            if log.is_taken:
                daily_stats[date_str]["taken"] += 1
            else:
                daily_stats[date_str]["missed"] += 1

        # 결과 리스트 생성
        result = []
        current_date = start_date.date()
        end_date_only = end_date.date()
        
        while current_date <= end_date_only:
            date_str = current_date.strftime("%Y-%m-%d")
            stats = daily_stats[date_str]
            result.append(DailyStats(
                date=date_str,
                total=stats["total"],
                taken=stats["taken"],
                missed=stats["missed"]
            ))
            current_date += timedelta(days=1)
        
        return result

    def _calculate_streak_days(self, logs: List) -> int:
        """연속 복용일 계산"""
        if not logs:
            return 0
        
        # 날짜별로 그룹화
        daily_logs = defaultdict(list)
        for log in logs:
            date_key = log.taken_at.date()
            daily_logs[date_key].append(log)
        
        # 날짜순 정렬
        sorted_dates = sorted(daily_logs.keys(), reverse=True)
        
        streak = 0
        for date_key in sorted_dates:
            day_logs = daily_logs[date_key]
            # 해당 날짜에 복용한 로그가 있는지 확인
            if any(log.is_taken for log in day_logs):
                streak += 1
            else:
                break
        
        return streak

    def _get_most_active_time(self, logs: List) -> Optional[str]:
        """가장 활발한 시간대 반환"""
        if not logs:
            return None
        
        hour_counts = Counter(log.taken_at.hour for log in logs)
        if not hour_counts:
            return None
        
        most_common_hour = hour_counts.most_common(1)[0][0]
        
        if 6 <= most_common_hour < 12:
            return "morning"
        elif 12 <= most_common_hour < 18:
            return "afternoon"
        else:
            return "evening"
