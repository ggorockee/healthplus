import uuid
from sqlalchemy import Column, String, Boolean, DateTime, func, ForeignKey, Integer, Numeric, Date, Time
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.infrastructure.database.session import Base


class Medication(Base):
    """약물 정보를 저장하는 ORM 모델"""
    __tablename__ = "medications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    name = Column(String, nullable=False)
    image_path = Column(String, nullable=True)
    daily_dosage_count = Column(Integer, nullable=False)
    dosage_times = Column(String, nullable=False) # 클라이언트에서 List[str]을 JSON 문자열로 변환하여 저장
    form = Column(String, nullable=False)
    single_dosage_amount = Column(Numeric, nullable=False)
    dosage_unit = Column(String, nullable=False)
    has_meal_relation = Column(Boolean, default=True)
    meal_relation = Column(String, nullable=True)
    is_continuous = Column(Boolean, default=True)
    memo = Column(String, nullable=True)

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # User 모델과의 관계 설정
    user = relationship("User", back_populates="medications")
    # MedicationRecord 모델과의 관계 설정
    records = relationship("MedicationRecord", back_populates="medication", cascade="all, delete-orphan")


class MedicationRecord(Base):
    """약물 복용 기록을 저장하는 ORM 모델"""
    __tablename__ = "medication_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    medication_id = Column(UUID(as_uuid=True), ForeignKey("medications.id"), nullable=False, index=True)

    date = Column(Date, nullable=False)
    time = Column(Time, nullable=False)
    status = Column(String, nullable=False) # 'taken', 'skipped'
    delay_reason = Column(String, nullable=True)
    taken_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime, server_default=func.now())

    # User 모델과의 관계 설정
    user = relationship("User", back_populates="medication_records")
    # Medication 모델과의 관계 설정
    medication = relationship("Medication", back_populates="records")
