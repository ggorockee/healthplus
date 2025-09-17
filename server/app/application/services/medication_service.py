from datetime import datetime, date
from typing import List, Optional
import uuid
from collections import Counter

from app.core.exceptions import NotFoundError, ValidationError
from app.application.repositories.medication_repository import IMedicationRepository
from app.application.schemas.medication import (
    MedicationCreate, MedicationUpdate, MedicationResponse,
    MedicationRecordCreate, MedicationRecordUpdate,
    DailyMedicationRecord, MedicationDoseResponse,
    MonthlyStatistics, MedicationStatus
)


class MedicationService:
    """약물 관리 비즈니스 로직"""

    def __init__(self, med_repo: IMedicationRepository):
        self.med_repo = med_repo

    async def create_medication(self, user_id: uuid.UUID, medication_data: MedicationCreate) -> MedicationResponse:
        medication = await self.med_repo.create_medication(user_id, medication_data)
        return MedicationResponse.model_validate(medication)

    async def get_medications(self, user_id: uuid.UUID) -> List[MedicationResponse]:
        medications = await self.med_repo.get_medications_by_user_id(user_id)
        return [MedicationResponse.model_validate(med) for med in medications]

    async def get_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID) -> MedicationResponse:
        medication = await self.med_repo.get_medication_by_id(user_id, medication_id)
        if not medication:
            raise NotFoundError("약물을 찾을 수 없습니다")
        return MedicationResponse.model_validate(medication)

    async def update_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID, medication_data: MedicationUpdate) -> MedicationResponse:
        updated_medication = await self.med_repo.update_medication(user_id, medication_id, medication_data)
        if not updated_medication:
            raise NotFoundError("약물을 찾을 수 없습니다")
        return MedicationResponse.model_validate(updated_medication)

    async def delete_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID) -> bool:
        return await self.med_repo.delete_medication(user_id, medication_id)

    async def create_medication_record(self, user_id: uuid.UUID, record_data: MedicationRecordCreate) -> MedicationDoseResponse:
        record = await self.med_repo.create_medication_record(user_id, record_data)
        medication = await self.med_repo.get_medication_by_id(user_id, record.medication_id)
        if not medication:
            raise NotFoundError("연관된 약물을 찾을 수 없습니다")

        return MedicationDoseResponse(
            id=str(record.id),
            medication_name=medication.name,
            time=record.time.strftime('%H:%M:%S'),
            status=record.status,
            delay_reason=record.delay_reason,
            taken_at=record.taken_at
        )

    async def get_daily_records(self, user_id: uuid.UUID, target_date: date) -> DailyMedicationRecord:
        records = await self.med_repo.get_daily_records_by_date(user_id, target_date)
        
        doses = [
            MedicationDoseResponse(
                id=str(r.id),
                medication_name=r.medication.name, # Eager loading으로 접근 가능
                time=r.time.strftime('%H:%M:%S'),
                status=r.status,
                delay_reason=r.delay_reason,
                taken_at=r.taken_at
            ) for r in records
        ]

        total_doses = len(doses)
        completed_doses = len([d for d in doses if d.status == MedicationStatus.TAKEN])
        completion_rate = completed_doses / total_doses if total_doses > 0 else 0.0

        if completion_rate == 1.0:
            overall_status = MedicationStatus.TAKEN
        elif completed_doses > 0:
            overall_status = MedicationStatus.DELAYED # 일부만 복용해도 delayed로 처리
        else:
            overall_status = MedicationStatus.MISSED

        return DailyMedicationRecord(
            date=datetime.combine(target_date, datetime.min.time()),
            doses=doses,
            completion_rate=completion_rate,
            overall_status=overall_status
        )

    async def update_medication_record(self, user_id: uuid.UUID, record_id: uuid.UUID, update_data: MedicationRecordUpdate) -> MedicationDoseResponse:
        updated_record = await self.med_repo.update_medication_record(user_id, record_id, update_data)
        if not updated_record:
            raise NotFoundError("복용 기록을 찾을 수 없습니다")
        
        medication = await self.med_repo.get_medication_by_id(user_id, updated_record.medication_id)
        if not medication:
            raise NotFoundError("연관된 약물을 찾을 수 없습니다")

        return MedicationDoseResponse(
            id=str(updated_record.id),
            medication_name=medication.name,
            time=updated_record.time.strftime('%H:%M:%S'),
            status=updated_record.status,
            delay_reason=updated_record.delay_reason,
            taken_at=updated_record.taken_at
        )

    async def get_monthly_statistics(self, user_id: uuid.UUID, year: int, month: int) -> MonthlyStatistics:
        records = await self.med_repo.get_records_by_month(user_id, year, month)
        if not records:
            return MonthlyStatistics(average_completion_rate=0.0, consecutive_days=0, best_time="-", total_days=0, completed_days=0)

        # 통계 계산 로직
        daily_statuses = {}
        for r in records:
            daily_statuses.setdefault(r.date, []).append(r.status == MedicationStatus.TAKEN)

        total_days = len(daily_statuses)
        completed_days = sum(1 for statuses in daily_statuses.values() if all(statuses))
        average_completion_rate = completed_days / total_days if total_days > 0 else 0.0

        # 연속 복용일 계산
        consecutive_days = 0
        current_streak = 0
        sorted_dates = sorted(daily_statuses.keys())
        for i, day in enumerate(sorted_dates):
            if all(daily_statuses[day]):
                current_streak += 1
            else:
                current_streak = 0
            if i > 0 and (day - sorted_dates[i-1]).days > 1:
                current_streak = 1 if all(daily_statuses[day]) else 0
            consecutive_days = max(consecutive_days, current_streak)

        # 가장 많이 복용한 시간대
        taken_times = [r.time.hour for r in records if r.status == MedicationStatus.TAKEN]
        if not taken_times:
            best_time = "-"
        else:
            time_counts = Counter(taken_times)
            most_common_hour = time_counts.most_common(1)[0][0]
            if 6 <= most_common_hour < 12: best_time = "아침"
            elif 12 <= most_common_hour < 18: best_time = "점심"
            else: best_time = "저녁"

        return MonthlyStatistics(
            average_completion_rate=average_completion_rate,
            consecutive_days=consecutive_days,
            best_time=best_time,
            total_days=total_days,
            completed_days=completed_days
        )
