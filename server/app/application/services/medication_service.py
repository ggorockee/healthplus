import asyncio
from datetime import datetime, date
from typing import List, Optional
from supabase import Client

from app.core.database import get_service_supabase
from app.core.exceptions import NotFoundError, ValidationError
from app.schemas.medication import (
    MedicationCreate, MedicationUpdate, MedicationResponse,
    MedicationRecordCreate, MedicationRecordUpdate,
    DailyMedicationRecord, MedicationDoseResponse,
    MonthlyStatistics, MedicationStatus
)


class MedicationService:
    """약물 관리 서비스"""

    async def create_medication(self, user_id: str, medication_data: MedicationCreate) -> MedicationResponse:
        """약물 등록"""
        client = get_service_supabase()

        medication_dict = medication_data.model_dump()
        medication_dict.update({
            "user_id": user_id,
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat()
        })

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medications").insert(medication_dict).execute()
        )

        if not response.data:
            raise ValidationError("약물 등록에 실패했습니다")

        return MedicationResponse(**response.data[0])

    async def get_medications(self, user_id: str) -> List[MedicationResponse]:
        """사용자의 약물 목록 조회"""
        client = get_service_supabase()

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medications")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .execute()
        )

        return [MedicationResponse(**item) for item in response.data]

    async def get_medication(self, user_id: str, medication_id: str) -> MedicationResponse:
        """특정 약물 조회"""
        client = get_service_supabase()

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medications")
            .select("*")
            .eq("user_id", user_id)
            .eq("id", medication_id)
            .single()
            .execute()
        )

        if not response.data:
            raise NotFoundError("약물을 찾을 수 없습니다")

        return MedicationResponse(**response.data)

    async def update_medication(
        self,
        user_id: str,
        medication_id: str,
        medication_data: MedicationUpdate
    ) -> MedicationResponse:
        """약물 정보 업데이트"""
        client = get_service_supabase()

        # 업데이트할 데이터만 추출
        update_data = {
            k: v for k, v in medication_data.model_dump(exclude_unset=True).items()
            if v is not None
        }
        update_data["updated_at"] = datetime.utcnow().isoformat()

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medications")
            .update(update_data)
            .eq("user_id", user_id)
            .eq("id", medication_id)
            .execute()
        )

        if not response.data:
            raise NotFoundError("약물을 찾을 수 없습니다")

        return MedicationResponse(**response.data[0])

    async def delete_medication(self, user_id: str, medication_id: str) -> bool:
        """약물 삭제"""
        client = get_service_supabase()

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medications")
            .delete()
            .eq("user_id", user_id)
            .eq("id", medication_id)
            .execute()
        )

        return len(response.data) > 0

    async def create_medication_record(
        self,
        user_id: str,
        record_data: MedicationRecordCreate
    ) -> MedicationDoseResponse:
        """복용 기록 생성"""
        client = get_service_supabase()

        record_dict = record_data.model_dump()
        record_dict.update({
            "user_id": user_id,
            "date": record_data.date.date().isoformat(),
            "taken_at": datetime.utcnow().isoformat() if record_data.status == MedicationStatus.TAKEN else None,
            "created_at": datetime.utcnow().isoformat()
        })

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medication_records").insert(record_dict).execute()
        )

        if not response.data:
            raise ValidationError("복용 기록 생성에 실패했습니다")

        # 약물 이름 가져오기
        medication = await self.get_medication(user_id, record_data.medication_id)

        return MedicationDoseResponse(
            id=response.data[0]["id"],
            medication_name=medication.name,
            time=record_data.time,
            status=record_data.status,
            delay_reason=record_data.delay_reason,
            taken_at=datetime.fromisoformat(response.data[0]["taken_at"]) if response.data[0]["taken_at"] else None
        )

    async def get_daily_records(self, user_id: str, target_date: date) -> DailyMedicationRecord:
        """특정 날짜의 복용 기록 조회"""
        client = get_service_supabase()

        date_str = target_date.isoformat()

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medication_records")
            .select("""
                *,
                medications(name, dosage_unit, single_dosage_amount)
            """)
            .eq("user_id", user_id)
            .eq("date", date_str)
            .order("time")
            .execute()
        )

        doses = []
        for record in response.data:
            doses.append(MedicationDoseResponse(
                id=record["id"],
                medication_name=record["medications"]["name"],
                time=record["time"],
                status=MedicationStatus(record["status"]),
                delay_reason=record.get("delay_reason"),
                taken_at=datetime.fromisoformat(record["taken_at"]) if record.get("taken_at") else None
            ))

        # 완료율 계산
        total_doses = len(doses)
        completed_doses = len([d for d in doses if d.status == MedicationStatus.TAKEN])
        completion_rate = completed_doses / total_doses if total_doses > 0 else 0.0

        # 전체 상태 결정
        if completion_rate == 1.0:
            overall_status = MedicationStatus.TAKEN
        elif completion_rate == 0.0:
            overall_status = MedicationStatus.MISSED
        else:
            overall_status = MedicationStatus.DELAYED

        return DailyMedicationRecord(
            date=datetime.combine(target_date, datetime.min.time()),
            doses=doses,
            completion_rate=completion_rate,
            overall_status=overall_status
        )

    async def update_medication_record(
        self,
        user_id: str,
        record_id: str,
        update_data: MedicationRecordUpdate
    ) -> MedicationDoseResponse:
        """복용 기록 업데이트"""
        client = get_service_supabase()

        update_dict = update_data.model_dump()
        update_dict["taken_at"] = datetime.utcnow().isoformat() if update_data.status == MedicationStatus.TAKEN else None

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medication_records")
            .update(update_dict)
            .eq("user_id", user_id)
            .eq("id", record_id)
            .execute()
        )

        if not response.data:
            raise NotFoundError("복용 기록을 찾을 수 없습니다")

        record = response.data[0]

        # 약물 정보 가져오기
        medication_response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medications")
            .select("name")
            .eq("id", record["medication_id"])
            .single()
            .execute()
        )

        return MedicationDoseResponse(
            id=record["id"],
            medication_name=medication_response.data["name"],
            time=record["time"],
            status=MedicationStatus(record["status"]),
            delay_reason=record.get("delay_reason"),
            taken_at=datetime.fromisoformat(record["taken_at"]) if record.get("taken_at") else None
        )

    async def get_monthly_statistics(self, user_id: str, year: int, month: int) -> MonthlyStatistics:
        """월간 통계 조회"""
        client = get_service_supabase()

        # 해당 월의 시작일과 종료일
        start_date = date(year, month, 1)
        if month == 12:
            end_date = date(year + 1, 1, 1)
        else:
            end_date = date(year, month + 1, 1)

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("medication_records")
            .select("status, date, time")
            .eq("user_id", user_id)
            .gte("date", start_date.isoformat())
            .lt("date", end_date.isoformat())
            .execute()
        )

        records = response.data
        total_records = len(records)

        if total_records == 0:
            return MonthlyStatistics(
                average_completion_rate=0.0,
                consecutive_days=0,
                best_time="아침",
                total_days=0,
                completed_days=0
            )

        # 완료된 기록 수
        completed_records = len([r for r in records if r["status"] == "taken"])
        average_completion_rate = completed_records / total_records

        # 연속 복용일 계산 (간단한 버전)
        date_status = {}
        for record in records:
            record_date = record["date"]
            if record_date not in date_status:
                date_status[record_date] = []
            date_status[record_date].append(record["status"])

        consecutive_days = 0
        for record_date in sorted(date_status.keys(), reverse=True):
            day_statuses = date_status[record_date]
            if all(status == "taken" for status in day_statuses):
                consecutive_days += 1
            else:
                break

        # 가장 많이 복용한 시간대
        time_counts = {}
        for record in records:
            if record["status"] == "taken":
                time_key = record["time"]
                time_counts[time_key] = time_counts.get(time_key, 0) + 1

        best_time = "아침"
        if time_counts:
            most_common_time = max(time_counts.keys(), key=lambda k: time_counts[k])
            hour = int(most_common_time.split(":")[0])
            if 6 <= hour < 12:
                best_time = "아침"
            elif 12 <= hour < 18:
                best_time = "점심"
            else:
                best_time = "저녁"

        return MonthlyStatistics(
            average_completion_rate=average_completion_rate,
            consecutive_days=consecutive_days,
            best_time=best_time,
            total_days=len(date_status),
            completed_days=len([d for d, statuses in date_status.items()
                              if all(s == "taken" for s in statuses)])
        )


medication_service = MedicationService()