import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, Integer, DateTime, ForeignKey, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.infrastructure.database.session import Base
from app.application.schemas.reminders import NotificationType, NotificationStatus


class Reminder(Base):
    """알림 설정 모델"""
    __tablename__ = "reminders"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    medication_id = Column(UUID(as_uuid=True), ForeignKey("medications.id"), nullable=False)
    reminder_hour = Column(Integer, nullable=False)
    reminder_minute = Column(Integer, nullable=False)
    is_enabled = Column(Boolean, default=True, nullable=False)
    notification_type = Column(SQLEnum(NotificationType), default=NotificationType.PUSH, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # 관계 설정
    medication = relationship("Medication", back_populates="reminders")


class NotificationLog(Base):
    """알림 로그 모델"""
    __tablename__ = "notification_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    reminder_id = Column(UUID(as_uuid=True), ForeignKey("reminders.id"), nullable=False)
    medication_id = Column(UUID(as_uuid=True), ForeignKey("medications.id"), nullable=False)
    scheduled_time = Column(DateTime(timezone=True), nullable=False)
    sent_time = Column(DateTime(timezone=True), nullable=True)
    status = Column(SQLEnum(NotificationStatus), default=NotificationStatus.PENDING, nullable=False)
    notification_type = Column(SQLEnum(NotificationType), nullable=False)
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # 관계 설정
    reminder = relationship("Reminder")
    medication = relationship("Medication")
