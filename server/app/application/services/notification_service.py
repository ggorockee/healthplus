from datetime import datetime, timedelta
from typing import List, Optional
import uuid
import asyncio
from enum import Enum

from app.core.exceptions import NotFoundError, ValidationError
from app.core.error_codes import ErrorCode
from app.application.repositories.reminder_repository import IReminderRepository, INotificationLogRepository
from app.application.schemas.reminders import (
    ReminderCreate, ReminderUpdate, ReminderResponse, ReminderListResponse,
    NotificationLogListResponse, NotificationStatsResponse, NotificationStats,
    ReminderTime, NotificationStatus, NotificationType
)


class NotificationService:
    """알림 서비스 (API 명세서 기준)"""

    def __init__(
        self, 
        reminder_repo: IReminderRepository,
        notification_log_repo: INotificationLogRepository
    ):
        self.reminder_repo = reminder_repo
        self.notification_log_repo = notification_log_repo

    async def create_reminder(self, user_id: uuid.UUID, reminder_data: ReminderCreate) -> ReminderResponse:
        """알림 설정 생성 (API 명세서 기준)"""
        reminder = await self.reminder_repo.create_reminder(
            user_id=user_id,
            medication_id=uuid.UUID(reminder_data.medication_id),
            reminder_hour=reminder_data.reminder_time.hour,
            reminder_minute=reminder_data.reminder_time.minute,
            is_enabled=reminder_data.is_enabled,
            notification_type=reminder_data.notification_type.value
        )
        return self._convert_reminder_to_response(reminder)

    async def get_reminders(self, user_id: uuid.UUID) -> ReminderListResponse:
        """알림 설정 목록 조회 (API 명세서 기준)"""
        reminders = await self.reminder_repo.get_reminders_by_user_id(user_id)
        reminder_responses = [self._convert_reminder_to_response(rem) for rem in reminders]
        return ReminderListResponse(
            reminders=reminder_responses,
            total=len(reminder_responses)
        )

    async def get_reminder(self, user_id: uuid.UUID, reminder_id: uuid.UUID) -> ReminderResponse:
        """특정 알림 설정 조회 (API 명세서 기준)"""
        reminder = await self.reminder_repo.get_reminder_by_id(user_id, reminder_id)
        if not reminder:
            raise NotFoundError("알림 설정을 찾을 수 없습니다", ErrorCode.SYS_NOTIFICATION_NOT_FOUND)
        return self._convert_reminder_to_response(reminder)

    async def update_reminder(
        self, 
        user_id: uuid.UUID, 
        reminder_id: uuid.UUID, 
        update_data: ReminderUpdate
    ) -> ReminderResponse:
        """알림 설정 수정 (API 명세서 기준)"""
        update_dict = {}
        
        if update_data.reminder_time is not None:
            update_dict["reminder_hour"] = update_data.reminder_time.hour
            update_dict["reminder_minute"] = update_data.reminder_time.minute
        if update_data.is_enabled is not None:
            update_dict["is_enabled"] = update_data.is_enabled
        if update_data.notification_type is not None:
            update_dict["notification_type"] = update_data.notification_type.value

        updated_reminder = await self.reminder_repo.update_reminder(user_id, reminder_id, **update_dict)
        if not updated_reminder:
            raise NotFoundError("알림 설정을 찾을 수 없습니다", ErrorCode.SYS_NOTIFICATION_NOT_FOUND)
        return self._convert_reminder_to_response(updated_reminder)

    async def delete_reminder(self, user_id: uuid.UUID, reminder_id: uuid.UUID) -> bool:
        """알림 설정 삭제 (API 명세서 기준)"""
        return await self.reminder_repo.delete_reminder(user_id, reminder_id)

    async def get_notification_logs(
        self,
        user_id: uuid.UUID,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
        status: Optional[str] = None
    ) -> NotificationLogListResponse:
        """알림 로그 조회"""
        start_dt = None
        end_dt = None
        
        if start_date:
            try:
                start_dt = datetime.fromisoformat(start_date)
            except ValueError:
                raise ValidationError("Invalid start_date format. Use YYYY-MM-DD format.")
        
        if end_date:
            try:
                end_dt = datetime.fromisoformat(end_date)
            except ValueError:
                raise ValidationError("Invalid end_date format. Use YYYY-MM-DD format.")
        
        logs = await self.notification_log_repo.get_notification_logs(
            user_id=user_id,
            start_date=start_dt,
            end_date=end_dt,
            status=status
        )
        
        # 로그를 응답 형식으로 변환
        log_responses = []
        for log in logs:
            log_responses.append({
                "id": str(log.id),
                "reminder_id": str(log.reminder_id),
                "medication_id": str(log.medication_id),
                "medication_name": log.medication.name if log.medication else "Unknown",
                "scheduled_time": log.scheduled_time,
                "sent_time": log.sent_time,
                "status": log.status.value,
                "notification_type": log.notification_type.value,
                "error_message": log.error_message
            })
        
        return NotificationLogListResponse(
            logs=log_responses,
            total=len(log_responses),
            start_date=start_date,
            end_date=end_date
        )

    async def get_notification_stats(
        self,
        user_id: uuid.UUID,
        period: str = "week"
    ) -> NotificationStatsResponse:
        """알림 통계 조회"""
        # 기간별 날짜 범위 설정
        end_date = datetime.now()
        if period == "week":
            start_date = end_date - timedelta(days=7)
        elif period == "month":
            start_date = end_date - timedelta(days=30)
        elif period == "year":
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=7)

        # 알림 로그 조회
        logs = await self.notification_log_repo.get_notification_logs(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date
        )

        # 통계 계산
        total_sent = len([log for log in logs if log.status == NotificationStatus.SENT])
        total_delivered = len([log for log in logs if log.status == NotificationStatus.DELIVERED])
        total_failed = len([log for log in logs if log.status == NotificationStatus.FAILED])
        
        delivery_rate = (total_delivered / total_sent * 100) if total_sent > 0 else 0.0
        
        # 평균 전송 시간 계산
        delivered_logs = [log for log in logs if log.status == NotificationStatus.DELIVERED and log.sent_time]
        average_delivery_time = None
        if delivered_logs:
            delivery_times = [
                (log.sent_time - log.scheduled_time).total_seconds() 
                for log in delivered_logs
            ]
            average_delivery_time = sum(delivery_times) / len(delivery_times)

        stats = NotificationStats(
            total_sent=total_sent,
            total_delivered=total_delivered,
            total_failed=total_failed,
            delivery_rate=round(delivery_rate, 1),
            average_delivery_time=average_delivery_time
        )

        return NotificationStatsResponse(
            stats=stats,
            period=period,
            start_date=start_date.strftime("%Y-%m-%d"),
            end_date=end_date.strftime("%Y-%m-%d")
        )

    async def schedule_notifications(self, user_id: uuid.UUID) -> int:
        """알림 스케줄링 (백그라운드 작업용)"""
        # 활성화된 알림 설정 조회
        active_reminders = await self.reminder_repo.get_active_reminders(user_id)
        
        scheduled_count = 0
        current_time = datetime.now()
        
        for reminder in active_reminders:
            # 오늘의 알림 시간 계산
            today = current_time.date()
            notification_time = datetime.combine(
                today, 
                datetime.min.time().replace(
                    hour=reminder.reminder_hour, 
                    minute=reminder.reminder_minute
                )
            )
            
            # 이미 지난 시간이면 내일로 설정
            if notification_time <= current_time:
                notification_time += timedelta(days=1)
            
            # 이미 해당 시간에 알림이 스케줄되어 있는지 확인
            existing_logs = await self.notification_log_repo.get_notification_logs(
                user_id=user_id,
                start_date=notification_time.replace(hour=0, minute=0),
                end_date=notification_time.replace(hour=23, minute=59)
            )
            
            # 같은 약물의 같은 시간에 이미 스케줄된 알림이 있는지 확인
            already_scheduled = any(
                log.medication_id == reminder.medication_id and 
                log.scheduled_time.date() == notification_time.date()
                for log in existing_logs
            )
            
            if not already_scheduled:
                await self.notification_log_repo.create_notification_log(
                    user_id=user_id,
                    reminder_id=reminder.id,
                    medication_id=reminder.medication_id,
                    scheduled_time=notification_time,
                    notification_type=reminder.notification_type.value,
                    status=NotificationStatus.PENDING.value
                )
                scheduled_count += 1
        
        return scheduled_count

    async def process_pending_notifications(self) -> int:
        """대기 중인 알림 처리 (백그라운드 작업용)"""
        current_time = datetime.now()
        pending_notifications = await self.notification_log_repo.get_pending_notifications(current_time)
        
        processed_count = 0
        
        for notification in pending_notifications:
            try:
                # 실제 알림 전송 로직 (여기서는 시뮬레이션)
                await self._send_notification(notification)
                
                # 성공적으로 전송된 경우 로그 업데이트
                await self.notification_log_repo.update_notification_log(
                    log_id=notification.id,
                    status=NotificationStatus.SENT.value,
                    sent_time=current_time
                )
                processed_count += 1
                
            except Exception as e:
                # 전송 실패 시 로그 업데이트
                await self.notification_log_repo.update_notification_log(
                    log_id=notification.id,
                    status=NotificationStatus.FAILED.value,
                    sent_time=current_time,
                    error_message=str(e)
                )
        
        return processed_count

    async def _send_notification(self, notification):
        """실제 알림 전송 (시뮬레이션)"""
        # 실제 구현에서는 Firebase, APNs, FCM 등을 사용
        # 여기서는 단순히 비동기 작업 시뮬레이션
        await asyncio.sleep(0.1)  # 네트워크 지연 시뮬레이션
        
        # 90% 확률로 성공, 10% 확률로 실패 (테스트용)
        import random
        if random.random() < 0.1:
            raise Exception("알림 전송 실패 (시뮬레이션)")

    # 헬퍼 메서드들

    def _convert_reminder_to_response(self, reminder) -> ReminderResponse:
        """Reminder 모델을 ReminderResponse로 변환"""
        return ReminderResponse(
            id=str(reminder.id),
            medication_id=str(reminder.medication_id),
            medication_name=reminder.medication.name if reminder.medication else "Unknown",
            reminder_time=ReminderTime(
                hour=reminder.reminder_hour,
                minute=reminder.reminder_minute
            ),
            is_enabled=reminder.is_enabled,
            notification_type=NotificationType(reminder.notification_type),
            created_at=reminder.created_at,
            updated_at=reminder.updated_at
        )
