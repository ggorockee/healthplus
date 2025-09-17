from typing import List, Optional
import uuid
from datetime import date, datetime, time

from sqlalchemy import select, and_, extract
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.application.repositories.medication_repository import IMedicationRepository
from app.infrastructure.database.models.medications import Medication, MedicationRecord
from app.application.schemas.medication import MedicationCreate, MedicationUpdate, MedicationRecordCreate, MedicationRecordUpdate


class SQLAlchemyMedicationRepository(IMedicationRepository):
    """SQLAlchemy를 사용한 약물 리포지토리 구현체"""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def create_medication(self, user_id: uuid.UUID, medication_data: MedicationCreate) -> Medication:
        medication = Medication(
            user_id=user_id,
            **medication_data.model_dump()
        )
        self.session.add(medication)
        await self.session.commit()
        await self.session.refresh(medication)
        return medication

    async def get_medications_by_user_id(self, user_id: uuid.UUID) -> List[Medication]:
        stmt = select(Medication).where(Medication.user_id == user_id).order_by(Medication.created_at.desc())
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_medication_by_id(self, user_id: uuid.UUID, medication_id: uuid.UUID) -> Optional[Medication]:
        stmt = select(Medication).where(and_(Medication.id == medication_id, Medication.user_id == user_id))
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def update_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID, medication_data: MedicationUpdate) -> Optional[Medication]:
        medication = await self.get_medication_by_id(user_id, medication_id)
        if not medication:
            return None
        
        update_values = medication_data.model_dump(exclude_unset=True)
        for key, value in update_values.items():
            setattr(medication, key, value)
            
        self.session.add(medication)
        await self.session.commit()
        await self.session.refresh(medication)
        return medication

    async def delete_medication(self, user_id: uuid.UUID, medication_id: uuid.UUID) -> bool:
        medication = await self.get_medication_by_id(user_id, medication_id)
        if not medication:
            return False
        
        await self.session.delete(medication)
        await self.session.commit()
        return True

    async def create_medication_record(self, user_id: uuid.UUID, record_data: MedicationRecordCreate) -> MedicationRecord:
        record = MedicationRecord(
            user_id=user_id,
            medication_id=record_data.medication_id,
            date=record_data.date.date(),
            time=datetime.strptime(record_data.time, '%H:%M:%S').time(),
            status=record_data.status.value,
            delay_reason=record_data.delay_reason,
            taken_at=datetime.utcnow() if record_data.status == 'taken' else None
        )
        self.session.add(record)
        await self.session.commit()
        await self.session.refresh(record)
        return record

    async def get_daily_records_by_date(self, user_id: uuid.UUID, target_date: date) -> List[MedicationRecord]:
        stmt = (
            select(MedicationRecord)
            .where(and_(MedicationRecord.user_id == user_id, MedicationRecord.date == target_date))
            .options(selectinload(MedicationRecord.medication)) # 연관된 약물 정보 함께 로드
            .order_by(MedicationRecord.time)
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def get_record_by_id(self, user_id: uuid.UUID, record_id: uuid.UUID) -> Optional[MedicationRecord]:
        stmt = select(MedicationRecord).where(and_(MedicationRecord.id == record_id, MedicationRecord.user_id == user_id))
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def update_medication_record(self, user_id: uuid.UUID, record_id: uuid.UUID, update_data: MedicationRecordUpdate) -> Optional[MedicationRecord]:
        record = await self.get_record_by_id(user_id, record_id)
        if not record:
            return None

        update_values = update_data.model_dump(exclude_unset=True)
        for key, value in update_values.items():
            setattr(record, key, value.value if isinstance(value, MedicationStatus) else value)

        if update_data.status == 'taken' and 'taken_at' not in update_values:
            record.taken_at = datetime.utcnow()

        self.session.add(record)
        await self.session.commit()
        await self.session.refresh(record)
        return record

    async def get_records_by_month(self, user_id: uuid.UUID, year: int, month: int) -> List[MedicationRecord]:
        stmt = select(MedicationRecord).where(
            and_(
                MedicationRecord.user_id == user_id,
                extract('year', MedicationRecord.date) == year,
                extract('month', MedicationRecord.date) == month
            )
        )
        result = await self.session.execute(stmt)
        return result.scalars().all()
