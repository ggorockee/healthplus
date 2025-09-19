import uuid
from sqlalchemy import Column, String, Boolean, DateTime, func, ForeignKey, Integer, Numeric, Date, Time, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.types import TypeDecorator, CHAR

from app.infrastructure.database.session import Base


class GUID(TypeDecorator):
    """SQLite 호환 UUID 타입"""
    impl = CHAR
    cache_ok = True

    def load_dialect_impl(self, dialect):
        if dialect.name == 'postgresql':
            return dialect.type_descriptor(UUID())
        else:
            return dialect.type_descriptor(CHAR(36))

    def process_bind_param(self, value, dialect):
        if value is None:
            return value
        elif dialect.name == 'postgresql':
            return str(value)
        else:
            if not isinstance(value, uuid.UUID):
                return str(uuid.UUID(value))
            return str(value)

    def process_result_value(self, value, dialect):
        if value is None:
            return value
        else:
            if not isinstance(value, uuid.UUID):
                return uuid.UUID(value)
            return value


class Medication(Base):
    """약물 정보를 저장하는 ORM 모델 (API 명세서 기준)"""
    __tablename__ = "medications"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID(), ForeignKey("users.id"), nullable=False, index=True)
    
    # API 명세서 기준 필드들
    name = Column(String, nullable=False, comment="약물명")
    dosage = Column(String, nullable=False, comment="복용량 (예: 1정, 2캡슐)")
    
    # 알림 시간 설정 (API 명세서 기준)
    notification_hour = Column(Integer, nullable=False, comment="알림 시간 (시)")
    notification_minute = Column(Integer, nullable=False, comment="알림 시간 (분)")
    
    # 반복 요일 설정 (API 명세서 기준: 1=월요일, 2=화요일, ..., 7=일요일)
    repeat_days = Column(JSON, nullable=False, comment="반복 요일 배열 [1,2,3,4,5]")
    
    # 활성 상태 (API 명세서 기준)
    is_active = Column(Boolean, default=True, comment="약물 활성 상태")
    
    # 기존 필드들 (호환성을 위해 유지)
    image_path = Column(String, nullable=True, comment="약물 이미지 경로")
    daily_dosage_count = Column(Integer, nullable=True, comment="일일 복용 횟수")
    dosage_times = Column(String, nullable=True, comment="복용 시간들 (JSON 문자열)")
    form = Column(String, nullable=True, comment="약물 형태")
    single_dosage_amount = Column(Numeric, nullable=True, comment="단일 복용량")
    dosage_unit = Column(String, nullable=True, comment="복용량 단위")
    has_meal_relation = Column(Boolean, default=True, comment="식사 관련 여부")
    meal_relation = Column(String, nullable=True, comment="식사 관련 정보")
    is_continuous = Column(Boolean, default=True, comment="지속 복용 여부")
    memo = Column(String, nullable=True, comment="메모")

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # User 모델과의 관계 설정
    user = relationship("User", back_populates="medications")
    # MedicationRecord 모델과의 관계 설정
    records = relationship("MedicationRecord", back_populates="medication", cascade="all, delete-orphan")
    # Reminder 모델과의 관계 설정
    reminders = relationship("Reminder", back_populates="medication", cascade="all, delete-orphan")


class MedicationRecord(Base):
    """약물 복용 기록을 저장하는 ORM 모델 (API 명세서 기준)"""
    __tablename__ = "medication_records"

    id = Column(GUID(), primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID(), ForeignKey("users.id"), nullable=False, index=True)
    medication_id = Column(GUID(), ForeignKey("medications.id"), nullable=False, index=True)

    # API 명세서 기준 필드들
    taken_at = Column(DateTime, nullable=False, comment="복용 시간")
    is_taken = Column(Boolean, nullable=False, comment="복용 여부")
    note = Column(String, nullable=True, comment="복용 메모")
    
    # 기존 필드들 (호환성을 위해 유지)
    date = Column(Date, nullable=True, comment="복용 날짜")
    time = Column(Time, nullable=True, comment="복용 시간")
    status = Column(String, nullable=True, comment="복용 상태 ('taken', 'skipped')")
    delay_reason = Column(String, nullable=True, comment="지연 사유")

    created_at = Column(DateTime, server_default=func.now())

    # User 모델과의 관계 설정
    user = relationship("User", back_populates="medication_records")
    # Medication 모델과의 관계 설정
    medication = relationship("Medication", back_populates="records")
