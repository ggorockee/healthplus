from datetime import datetime
from typing import List, Optional
import uuid
from abc import ABC, abstractmethod

from app.application.schemas.reminders import ReminderCreate, ReminderUpdate


class IReminderRepository(ABC):
    """알림 설정 리포지토리 인터페이스"""

    @abstractmethod
    async def create_reminder(
        self,
        user_id: uuid.UUID,
        medication_id: uuid.UUID,
        reminder_hour: int,
        reminder_minute: int,
        is_enabled: bool = True,
        notification_type: str = "push"
    ):
        """알림 설정 생성"""
        pass

    @abstractmethod
    async def get_reminders_by_user_id(self, user_id: uuid.UUID) -> List:
        """사용자의 알림 설정 목록 조회"""
        pass

    @abstractmethod
    async def get_reminder_by_id(self, user_id: uuid.UUID, reminder_id: uuid.UUID):
        """특정 알림 설정 조회"""
        pass

    @abstractmethod
    async def update_reminder(
        self,
        user_id: uuid.UUID,
        reminder_id: uuid.UUID,
        **update_data
    ):
        """알림 설정 업데이트"""
        pass

    @abstractmethod
    async def delete_reminder(self, user_id: uuid.UUID, reminder_id: uuid.UUID) -> bool:
        """알림 설정 삭제"""
        pass

    @abstractmethod
    async def get_active_reminders(self, user_id: uuid.UUID) -> List:
        """활성화된 알림 설정 목록 조회"""
        pass


class INotificationLogRepository(ABC):
    """알림 로그 리포지토리 인터페이스"""

    @abstractmethod
    async def create_notification_log(
        self,
        user_id: uuid.UUID,
        reminder_id: uuid.UUID,
        medication_id: uuid.UUID,
        scheduled_time: datetime,
        notification_type: str,
        status: str = "pending"
    ):
        """알림 로그 생성"""
        pass

    @abstractmethod
    async def get_notification_logs(
        self,
        user_id: uuid.UUID,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        status: Optional[str] = None
    ) -> List:
        """알림 로그 조회"""
        pass

    @abstractmethod
    async def update_notification_log(
        self,
        log_id: uuid.UUID,
        status: str,
        sent_time: Optional[datetime] = None,
        error_message: Optional[str] = None
    ):
        """알림 로그 업데이트"""
        pass

    @abstractmethod
    async def get_pending_notifications(self, current_time: datetime) -> List:
        """전송 대기 중인 알림 조회"""
        pass
