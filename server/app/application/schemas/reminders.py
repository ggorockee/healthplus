from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field
from enum import Enum


class NotificationType(str, Enum):
    """알림 타입"""
    PUSH = "push"
    EMAIL = "email"
    SMS = "sms"


class ReminderTime(BaseModel):
    """알림 시간"""
    hour: int = Field(..., ge=0, le=23, description="시간 (0-23)")
    minute: int = Field(..., ge=0, le=59, description="분 (0-59)")


class ReminderCreate(BaseModel):
    """알림 설정 생성 요청 (API 명세서 기준)"""
    medication_id: str = Field(..., description="약물 ID")
    reminder_time: ReminderTime = Field(..., description="알림 시간")
    is_enabled: bool = Field(True, description="알림 활성화 여부")
    notification_type: NotificationType = Field(NotificationType.PUSH, description="알림 타입")


class ReminderUpdate(BaseModel):
    """알림 설정 수정 요청 (API 명세서 기준)"""
    reminder_time: Optional[ReminderTime] = None
    is_enabled: Optional[bool] = None
    notification_type: Optional[NotificationType] = None


class ReminderResponse(BaseModel):
    """알림 설정 응답 (API 명세서 기준)"""
    id: str
    medication_id: str
    medication_name: str
    reminder_time: ReminderTime
    is_enabled: bool
    notification_type: NotificationType
    created_at: datetime
    updated_at: Optional[datetime] = None


class ReminderListResponse(BaseModel):
    """알림 설정 목록 응답 (API 명세서 기준)"""
    reminders: List[ReminderResponse]
    total: int


class NotificationStatus(str, Enum):
    """알림 상태"""
    PENDING = "pending"
    SENT = "sent"
    FAILED = "failed"
    DELIVERED = "delivered"


class NotificationLog(BaseModel):
    """알림 로그"""
    id: str
    reminder_id: str
    medication_id: str
    medication_name: str
    scheduled_time: datetime
    sent_time: Optional[datetime] = None
    status: NotificationStatus
    notification_type: NotificationType
    error_message: Optional[str] = None


class NotificationLogListResponse(BaseModel):
    """알림 로그 목록 응답"""
    logs: List[NotificationLog]
    total: int
    start_date: Optional[str] = None
    end_date: Optional[str] = None


class NotificationStats(BaseModel):
    """알림 통계"""
    total_sent: int
    total_delivered: int
    total_failed: int
    delivery_rate: float = Field(..., ge=0.0, le=100.0)
    average_delivery_time: Optional[float] = None  # 초 단위


class NotificationStatsResponse(BaseModel):
    """알림 통계 응답"""
    stats: NotificationStats
    period: str
    start_date: str
    end_date: str
