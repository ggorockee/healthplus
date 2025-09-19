from datetime import datetime
from typing import List, Optional
import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from sqlalchemy.orm import selectinload

from app.application.repositories.reminder_repository import IReminderRepository, INotificationLogRepository
from app.infrastructure.database.models.reminders import Reminder, NotificationLog
from app.infrastructure.database.models.medications import Medication
from app.application.schemas.reminders import NotificationStatus


class ReminderRepository(IReminderRepository):
    """알림 설정 리포지토리 구현체"""

    def __init__(self, db: AsyncSession):
        self.db = db

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
        reminder = Reminder(
            user_id=user_id,
            medication_id=medication_id,
            reminder_hour=reminder_hour,
            reminder_minute=reminder_minute,
            is_enabled=is_enabled,
            notification_type=notification_type
        )
        self.db.add(reminder)
        await self.db.commit()
        await self.db.refresh(reminder)
        
        # Eagerly load the medication relationship
        result = await self.db.execute(
            select(Reminder)
            .options(selectinload(Reminder.medication))
            .where(Reminder.id == reminder.id)
        )
        return result.scalar_one()

    async def get_reminders_by_user_id(self, user_id: uuid.UUID) -> List:
        """사용자의 알림 설정 목록 조회"""
        result = await self.db.execute(
            select(Reminder)
            .options(selectinload(Reminder.medication))
            .where(Reminder.user_id == user_id)
            .order_by(Reminder.created_at.desc())
        )
        return result.scalars().all()

    async def get_reminder_by_id(self, user_id: uuid.UUID, reminder_id: uuid.UUID):
        """특정 알림 설정 조회"""
        result = await self.db.execute(
            select(Reminder)
            .options(selectinload(Reminder.medication))
            .where(
                and_(
                    Reminder.id == reminder_id,
                    Reminder.user_id == user_id
                )
            )
        )
        return result.scalar_one_or_none()

    async def update_reminder(
        self,
        user_id: uuid.UUID,
        reminder_id: uuid.UUID,
        **update_data
    ):
        """알림 설정 업데이트"""
        result = await self.db.execute(
            select(Reminder)
            .where(
                and_(
                    Reminder.id == reminder_id,
                    Reminder.user_id == user_id
                )
            )
        )
        reminder = result.scalar_one_or_none()
        
        if not reminder:
            return None

        for key, value in update_data.items():
            if hasattr(reminder, key):
                setattr(reminder, key, value)

        await self.db.commit()
        await self.db.refresh(reminder)
        
        # Eagerly load the medication relationship
        result = await self.db.execute(
            select(Reminder)
            .options(selectinload(Reminder.medication))
            .where(Reminder.id == reminder.id)
        )
        return result.scalar_one()

    async def delete_reminder(self, user_id: uuid.UUID, reminder_id: uuid.UUID) -> bool:
        """알림 설정 삭제"""
        result = await self.db.execute(
            select(Reminder)
            .where(
                and_(
                    Reminder.id == reminder_id,
                    Reminder.user_id == user_id
                )
            )
        )
        reminder = result.scalar_one_or_none()
        
        if not reminder:
            return False

        await self.db.delete(reminder)
        await self.db.commit()
        return True

    async def get_active_reminders(self, user_id: uuid.UUID) -> List:
        """활성화된 알림 설정 목록 조회"""
        result = await self.db.execute(
            select(Reminder)
            .options(selectinload(Reminder.medication))
            .where(
                and_(
                    Reminder.user_id == user_id,
                    Reminder.is_enabled == True
                )
            )
            .order_by(Reminder.reminder_hour, Reminder.reminder_minute)
        )
        return result.scalars().all()


class NotificationLogRepository(INotificationLogRepository):
    """알림 로그 리포지토리 구현체"""

    def __init__(self, db: AsyncSession):
        self.db = db

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
        log = NotificationLog(
            user_id=user_id,
            reminder_id=reminder_id,
            medication_id=medication_id,
            scheduled_time=scheduled_time,
            notification_type=notification_type,
            status=status
        )
        self.db.add(log)
        await self.db.commit()
        await self.db.refresh(log)
        return log

    async def get_notification_logs(
        self,
        user_id: uuid.UUID,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        status: Optional[str] = None
    ) -> List:
        """알림 로그 조회"""
        query = select(NotificationLog).options(
            selectinload(NotificationLog.medication),
            selectinload(NotificationLog.reminder)
        ).where(NotificationLog.user_id == user_id)

        if start_date:
            query = query.where(NotificationLog.scheduled_time >= start_date)
        if end_date:
            query = query.where(NotificationLog.scheduled_time <= end_date)
        if status:
            query = query.where(NotificationLog.status == status)

        query = query.order_by(NotificationLog.scheduled_time.desc())

        result = await self.db.execute(query)
        return result.scalars().all()

    async def update_notification_log(
        self,
        log_id: uuid.UUID,
        status: str,
        sent_time: Optional[datetime] = None,
        error_message: Optional[str] = None
    ):
        """알림 로그 업데이트"""
        result = await self.db.execute(
            select(NotificationLog).where(NotificationLog.id == log_id)
        )
        log = result.scalar_one_or_none()
        
        if not log:
            return None

        log.status = status
        if sent_time:
            log.sent_time = sent_time
        if error_message:
            log.error_message = error_message

        await self.db.commit()
        await self.db.refresh(log)
        return log

    async def get_pending_notifications(self, current_time: datetime) -> List:
        """전송 대기 중인 알림 조회"""
        result = await self.db.execute(
            select(NotificationLog)
            .options(
                selectinload(NotificationLog.medication),
                selectinload(NotificationLog.reminder)
            )
            .where(
                and_(
                    NotificationLog.status == NotificationStatus.PENDING,
                    NotificationLog.scheduled_time <= current_time
                )
            )
            .order_by(NotificationLog.scheduled_time)
        )
        return result.scalars().all()
