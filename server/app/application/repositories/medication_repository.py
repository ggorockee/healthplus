from abc import ABC, abstractmethod
from typing import List, Optional
import uuid
from datetime import date

from app.infrastructure.database.models.medications import Medication, MedicationRecord
from app.application.schemas.medication import MedicationCreate, MedicationUpdate, MedicationRecordCreate, MedicationRecordUpdate


class IMedicationRepository(ABC):
    """약물 및 복용 기록 리포지토리 인터페이스"""

    @abstractmethod
    async def create_medication(self, user_id: uuid.UUID, medication_data: MedicationCreate) -> Medication:
        """새 약물을 생성합니다."""
        raise NotImplementedError

    @abstractmethod
    async def get_medications_by_user_id(self, user_id: uuid.UUID) -> List[Medication]:
        """사용자의 모든 약물 목록을 조회합니다."""
        raise NotImplementedError

    @abstractmethod
    async def get_medication_by_id(self, user_id: uuid.UUID, medication_id: uuid.UUID) -> Optional[Medication]:
        """특정 약물을 조회합니다."""
        raise NotImplementedError

    @abstractmethod
    async def update_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID, medication_data: MedicationUpdate) -> Optional[Medication]:
        """약물 정보를 업데이트합니다."""
        raise NotImplementedError

    @abstractmethod
    async def delete_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID) -> bool:
        """약물을 삭제합니다."""
        raise NotImplementedError

    @abstractmethod
    async def create_medication_record(self, user_id: uuid.UUID, record_data: MedicationRecordCreate) -> MedicationRecord:
        """복용 기록을 생성합니다."""
        raise NotImplementedError

    @abstractmethod
    async def get_daily_records_by_date(self, user_id: uuid.UUID, target_date: date) -> List[MedicationRecord]:
        """특정 날짜의 모든 복용 기록을 조회합니다."""
        raise NotImplementedError

    @abstractmethod
    async def get_record_by_id(self, user_id: uuid.UUID, record_id: uuid.UUID) -> Optional[MedicationRecord]:
        """ID로 특정 복용 기록을 조회합니다."""
        raise NotImplementedError

    @abstractmethod
    async def update_medication_record(self, user_id: uuid.UUID, record_id: uuid.UUID, update_data: MedicationRecordUpdate) -> Optional[MedicationRecord]:
        """복용 기록을 업데이트합니다."""
        raise NotImplementedError

    @abstractmethod
    async def get_records_by_month(self, user_id: uuid.UUID, year: int, month: int) -> List[MedicationRecord]:
        """특정 월의 모든 복용 기록을 조회합니다."""
        raise NotImplementedError
