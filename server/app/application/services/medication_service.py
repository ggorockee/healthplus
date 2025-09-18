from datetime import datetime, date
from typing import List, Optional
import uuid
from collections import Counter

from app.core.exceptions import NotFoundError, ValidationError
from app.core.error_codes import ErrorCode
from app.application.repositories.medication_repository import IMedicationRepository
from app.application.schemas.medication import (
    MedicationCreate, MedicationUpdate, MedicationResponse, MedicationListResponse,
    MedicationLogCreate, MedicationLogUpdate, MedicationLogResponse, MedicationLogListResponse,
    TodayMedicationResponse, NotificationTime,
    # 기존 호환성 스키마들
    MedicationRecordCreate, MedicationRecordUpdate,
    DailyMedicationRecord, MedicationDoseResponse,
    MonthlyStatistics, MedicationStatus
)


class MedicationService:
    """약물 관리 비즈니스 로직 (API 명세서 기준)"""

    def __init__(self, med_repo: IMedicationRepository):
        self.med_repo = med_repo

    # API 명세서 기준 메서드들

    async def create_medication(self, user_id: uuid.UUID, medication_data: MedicationCreate) -> MedicationResponse:
        """약물 등록 (API 명세서 기준)"""
        medication = await self.med_repo.create_medication(
            user_id=user_id,
            name=medication_data.name,
            dosage=medication_data.dosage,
            notification_hour=medication_data.notification_time.hour,
            notification_minute=medication_data.notification_time.minute,
            repeat_days=medication_data.repeat_days,
            is_active=True,
            # 기존 필드들
            image_path=medication_data.image_path,
            daily_dosage_count=medication_data.daily_dosage_count,
            dosage_times=medication_data.dosage_times,
            form=medication_data.form,
            single_dosage_amount=medication_data.single_dosage_amount,
            dosage_unit=medication_data.dosage_unit,
            has_meal_relation=medication_data.has_meal_relation,
            meal_relation=medication_data.meal_relation,
            is_continuous=medication_data.is_continuous,
            memo=medication_data.memo
        )
        return self._convert_to_response(medication)

    async def get_medications(self, user_id: uuid.UUID) -> MedicationListResponse:
        """약물 목록 조회 (API 명세서 기준)"""
        medications = await self.med_repo.get_medications_by_user_id(user_id)
        medication_responses = [self._convert_to_response(med) for med in medications]
        return MedicationListResponse(
            medications=medication_responses,
            total=len(medication_responses)
        )

    async def get_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID) -> MedicationResponse:
        """특정 약물 조회 (API 명세서 기준)"""
        medication = await self.med_repo.get_medication_by_id(user_id, medication_id)
        if not medication:
            raise NotFoundError("약물을 찾을 수 없습니다", ErrorCode.MED_MEDICATION_NOT_FOUND)
        return self._convert_to_response(medication)

    async def update_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID, medication_data: MedicationUpdate) -> MedicationResponse:
        """약물 정보 업데이트 (API 명세서 기준)"""
        update_data = {}
        
        if medication_data.name is not None:
            update_data["name"] = medication_data.name
        if medication_data.dosage is not None:
            update_data["dosage"] = medication_data.dosage
        if medication_data.notification_time is not None:
            update_data["notification_hour"] = medication_data.notification_time.hour
            update_data["notification_minute"] = medication_data.notification_time.minute
        if medication_data.repeat_days is not None:
            update_data["repeat_days"] = medication_data.repeat_days
        if medication_data.is_active is not None:
            update_data["is_active"] = medication_data.is_active
        
        # 기존 필드들
        if medication_data.image_path is not None:
            update_data["image_path"] = medication_data.image_path
        if medication_data.daily_dosage_count is not None:
            update_data["daily_dosage_count"] = medication_data.daily_dosage_count
        if medication_data.dosage_times is not None:
            update_data["dosage_times"] = medication_data.dosage_times
        if medication_data.form is not None:
            update_data["form"] = medication_data.form
        if medication_data.single_dosage_amount is not None:
            update_data["single_dosage_amount"] = medication_data.single_dosage_amount
        if medication_data.dosage_unit is not None:
            update_data["dosage_unit"] = medication_data.dosage_unit
        if medication_data.has_meal_relation is not None:
            update_data["has_meal_relation"] = medication_data.has_meal_relation
        if medication_data.meal_relation is not None:
            update_data["meal_relation"] = medication_data.meal_relation
        if medication_data.is_continuous is not None:
            update_data["is_continuous"] = medication_data.is_continuous
        if medication_data.memo is not None:
            update_data["memo"] = medication_data.memo

        updated_medication = await self.med_repo.update_medication(user_id, medication_id, **update_data)
        if not updated_medication:
            raise NotFoundError("약물을 찾을 수 없습니다", ErrorCode.MED_MEDICATION_NOT_FOUND)
        return self._convert_to_response(updated_medication)

    async def delete_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID) -> bool:
        """약물 삭제 (API 명세서 기준)"""
        return await self.med_repo.delete_medication(user_id, medication_id)

    async def get_today_medications(self, user_id: uuid.UUID) -> TodayMedicationResponse:
        """오늘의 약물 목록 (API 명세서 기준)"""
        today = date.today()
        medications = await self.med_repo.get_medications_by_user_id(user_id)
        
        # 오늘 요일에 해당하는 약물들만 필터링
        today_weekday = today.weekday() + 1  # 월요일=1, 일요일=7
        today_medications = [
            med for med in medications 
            if med.is_active and today_weekday in med.repeat_days
        ]
        
        medication_responses = [self._convert_to_response(med) for med in today_medications]
        return TodayMedicationResponse(
            medications=medication_responses,
            date=today.strftime("%Y-%m-%d"),
            total=len(medication_responses)
        )

    # 복용 로그 관련 메서드들 (API 명세서 기준)

    async def create_medication_log(self, user_id: uuid.UUID, log_data: MedicationLogCreate) -> MedicationLogResponse:
        """복용 로그 기록 (API 명세서 기준)"""
        log = await self.med_repo.create_medication_record(
            user_id=user_id,
            medication_id=uuid.UUID(log_data.medication_id),
            taken_at=log_data.taken_at,
            is_taken=log_data.is_taken,
            note=log_data.note
        )
        return self._convert_log_to_response(log)

    async def get_medication_logs(
        self, 
        user_id: uuid.UUID, 
        medication_id: Optional[str] = None,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None
    ) -> MedicationLogListResponse:
        """복용 로그 조회 (API 명세서 기준)"""
        logs = await self.med_repo.get_medication_logs(
            user_id=user_id,
            medication_id=uuid.UUID(medication_id) if medication_id else None,
            start_date=datetime.fromisoformat(start_date) if start_date else None,
            end_date=datetime.fromisoformat(end_date) if end_date else None
        )
        
        log_responses = [self._convert_log_to_response(log) for log in logs]
        return MedicationLogListResponse(
            logs=log_responses,
            total=len(log_responses),
            start_date=start_date,
            end_date=end_date
        )

    async def update_medication_log(self, user_id: uuid.UUID, log_id: uuid.UUID, update_data: MedicationLogUpdate) -> MedicationLogResponse:
        """복용 로그 수정 (API 명세서 기준)"""
        update_dict = {}
        if update_data.is_taken is not None:
            update_dict["is_taken"] = update_data.is_taken
        if update_data.note is not None:
            update_dict["note"] = update_data.note

        updated_log = await self.med_repo.update_medication_record(user_id, log_id, **update_dict)
        if not updated_log:
            raise NotFoundError("복용 로그를 찾을 수 없습니다", ErrorCode.LOG_LOG_NOT_FOUND)
        return self._convert_log_to_response(updated_log)

    async def delete_medication_log(self, user_id: uuid.UUID, log_id: uuid.UUID) -> bool:
        """복용 로그 삭제 (API 명세서 기준)"""
        return await self.med_repo.delete_medication_record(user_id, log_id)

    # 헬퍼 메서드들

    def _convert_to_response(self, medication) -> MedicationResponse:
        """Medication 모델을 MedicationResponse로 변환"""
        return MedicationResponse(
            id=str(medication.id),
            name=medication.name,
            dosage=medication.dosage,
            notification_time=NotificationTime(
                hour=medication.notification_hour,
                minute=medication.notification_minute
            ),
            repeat_days=medication.repeat_days,
            is_active=medication.is_active,
            created_at=medication.created_at,
            # 기존 필드들
            image_path=medication.image_path,
            daily_dosage_count=medication.daily_dosage_count,
            dosage_times=medication.dosage_times,
            form=medication.form,
            single_dosage_amount=medication.single_dosage_amount,
            dosage_unit=medication.dosage_unit,
            has_meal_relation=medication.has_meal_relation,
            meal_relation=medication.meal_relation,
            is_continuous=medication.is_continuous,
            memo=medication.memo,
            updated_at=medication.updated_at
        )

    def _convert_log_to_response(self, log) -> MedicationLogResponse:
        """MedicationRecord 모델을 MedicationLogResponse로 변환"""
        return MedicationLogResponse(
            id=str(log.id),
            medication_id=str(log.medication_id),
            taken_at=log.taken_at,
            is_taken=log.is_taken,
            note=log.note
        )
