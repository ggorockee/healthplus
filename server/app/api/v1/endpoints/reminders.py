import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query

from app.application.schemas.reminders import (
    ReminderCreate, ReminderUpdate, ReminderResponse, ReminderListResponse,
    NotificationLogListResponse, NotificationStatsResponse
)
from app.application.schemas.common import APIResponse
from app.application.services.notification_service import NotificationService
from app.application.repositories.reminder_repository import IReminderRepository, INotificationLogRepository
from app.infrastructure.repositories.reminder_repository import ReminderRepository, NotificationLogRepository
from app.api.v1.deps import get_current_user_id, get_db
from app.core.exceptions import NotFoundError, ValidationError
from app.core.error_codes import ErrorCode
from sqlalchemy.ext.asyncio import AsyncSession


router = APIRouter(tags=["알림 및 리마인더"])


def get_reminder_repository(db: AsyncSession = Depends(get_db)) -> IReminderRepository:
    """알림 설정 리포지토리 의존성"""
    return ReminderRepository(db)


def get_notification_log_repository(db: AsyncSession = Depends(get_db)) -> INotificationLogRepository:
    """알림 로그 리포지토리 의존성"""
    return NotificationLogRepository(db)


def get_notification_service(
    reminder_repo: IReminderRepository = Depends(get_reminder_repository),
    notification_log_repo: INotificationLogRepository = Depends(get_notification_log_repository)
) -> NotificationService:
    """알림 서비스 의존성"""
    return NotificationService(reminder_repo, notification_log_repo)


@router.get("")
async def get_reminders(
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 설정 조회 (API 명세서 기준)"""
    try:
        reminders = await notification_service.get_reminders(user_id)
        return APIResponse(
            success=True,
            data=reminders.model_dump(),
            message="알림 설정 조회 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get reminders: {str(e)}")


@router.post("")
async def create_reminder(
    reminder_data: ReminderCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 설정 추가 (API 명세서 기준)"""
    try:
        reminder = await notification_service.create_reminder(user_id, reminder_data)
        return APIResponse(
            success=True,
            data=reminder.model_dump(),
            message="알림 설정이 성공적으로 추가되었습니다"
        )
    except ValidationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/logs")
async def get_notification_logs(
    start_date: Optional[str] = Query(None, description="시작 날짜 (YYYY-MM-DD)"),
    end_date: Optional[str] = Query(None, description="종료 날짜 (YYYY-MM-DD)"),
    status: Optional[str] = Query(None, description="알림 상태 (pending, sent, delivered, failed)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 로그 조회"""
    try:
        logs = await notification_service.get_notification_logs(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date,
            status=status
        )
        return APIResponse(
            success=True,
            data=logs.model_dump(),
            message="알림 로그 조회 성공"
        )
    except ValidationError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get notification logs: {str(e)}")


@router.get("/stats")
async def get_notification_stats(
    period: str = Query("week", description="기간 (week, month, year)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 통계 조회"""
    try:
        stats = await notification_service.get_notification_stats(user_id, period)
        return APIResponse(
            success=True,
            data=stats.model_dump(),
            message="알림 통계 조회 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get notification stats: {str(e)}")


@router.get("/{reminder_id}")
async def get_reminder(
    reminder_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """특정 알림 설정 조회 (API 명세서 기준)"""
    try:
        reminder = await notification_service.get_reminder(user_id, reminder_id)
        return APIResponse(
            success=True,
            data=reminder.model_dump(),
            message="알림 설정 조회 성공"
        )
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.put("/{reminder_id}")
async def update_reminder(
    reminder_id: uuid.UUID,
    update_data: ReminderUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 설정 수정 (API 명세서 기준)"""
    try:
        reminder = await notification_service.update_reminder(user_id, reminder_id, update_data)
        return APIResponse(
            success=True,
            data=reminder.model_dump(),
            message="알림 설정이 성공적으로 수정되었습니다"
        )
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.delete("/{reminder_id}")
async def delete_reminder(
    reminder_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 설정 삭제 (API 명세서 기준)"""
    try:
        success = await notification_service.delete_reminder(user_id, reminder_id)
        if not success:
            raise HTTPException(status_code=404, detail="알림 설정을 찾을 수 없습니다")
        return APIResponse(
            success=True,
            data=None,
            message="알림 설정이 성공적으로 삭제되었습니다"
        )
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.post("/schedule")
async def schedule_notifications(
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 스케줄링 (수동 실행)"""
    try:
        scheduled_count = await notification_service.schedule_notifications(user_id)
        return APIResponse(
            success=True,
            data={"scheduled_count": scheduled_count},
            message=f"{scheduled_count}개의 알림이 스케줄되었습니다"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to schedule notifications: {str(e)}")


@router.post("/process")
async def process_notifications(
    notification_service: NotificationService = Depends(get_notification_service)
):
    """대기 중인 알림 처리 (수동 실행)"""
    try:
        processed_count = await notification_service.process_pending_notifications()
        return APIResponse(
            success=True,
            data={"processed_count": processed_count},
            message=f"{processed_count}개의 알림이 처리되었습니다"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process notifications: {str(e)}")
