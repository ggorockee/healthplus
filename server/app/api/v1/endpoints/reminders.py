import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query

from app.application.schemas.reminders import (
    ReminderCreate, ReminderUpdate, ReminderResponse, ReminderListResponse,
    NotificationLogListResponse, NotificationStatsResponse
)
from app.application.services.notification_service import NotificationService
from app.application.repositories.reminder_repository import IReminderRepository, INotificationLogRepository
from app.infrastructure.repositories.reminder_repository import ReminderRepository, NotificationLogRepository
from app.api.v1.deps import get_current_user_id, get_db
from app.core.exceptions import NotFoundError, ValidationError
from app.core.error_codes import ErrorCode
from sqlalchemy.ext.asyncio import AsyncSession


router = APIRouter(prefix="/reminders", tags=["알림 및 리마인더"])


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


@router.get("", response_model=ReminderListResponse)
async def get_reminders(
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 설정 조회 (API 명세서 기준)"""
    return await notification_service.get_reminders(user_id)


@router.post("", response_model=ReminderResponse)
async def create_reminder(
    reminder_data: ReminderCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 설정 추가 (API 명세서 기준)"""
    try:
        return await notification_service.create_reminder(user_id, reminder_data)
    except ValidationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/{reminder_id}", response_model=ReminderResponse)
async def get_reminder(
    reminder_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """특정 알림 설정 조회 (API 명세서 기준)"""
    try:
        return await notification_service.get_reminder(user_id, reminder_id)
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.put("/{reminder_id}", response_model=ReminderResponse)
async def update_reminder(
    reminder_id: uuid.UUID,
    update_data: ReminderUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 설정 수정 (API 명세서 기준)"""
    try:
        return await notification_service.update_reminder(user_id, reminder_id, update_data)
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.delete("/{reminder_id}", status_code=200)
async def delete_reminder(
    reminder_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 설정 삭제 (API 명세서 기준)"""
    success = await notification_service.delete_reminder(user_id, reminder_id)
    if not success:
        raise HTTPException(status_code=404, detail="알림 설정을 찾을 수 없습니다")
    return {"message": "알림 설정이 삭제되었습니다."}


@router.get("/logs", response_model=NotificationLogListResponse)
async def get_notification_logs(
    start_date: Optional[str] = Query(None, description="시작 날짜 (YYYY-MM-DD)"),
    end_date: Optional[str] = Query(None, description="종료 날짜 (YYYY-MM-DD)"),
    status: Optional[str] = Query(None, description="알림 상태 (pending, sent, delivered, failed)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 로그 조회"""
    return await notification_service.get_notification_logs(
        user_id=user_id,
        start_date=start_date,
        end_date=end_date,
        status=status
    )


@router.get("/stats", response_model=NotificationStatsResponse)
async def get_notification_stats(
    period: str = Query("week", description="기간 (week, month, year)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 통계 조회"""
    return await notification_service.get_notification_stats(user_id, period)


@router.post("/schedule", status_code=200)
async def schedule_notifications(
    user_id: uuid.UUID = Depends(get_current_user_id),
    notification_service: NotificationService = Depends(get_notification_service)
):
    """알림 스케줄링 (수동 실행)"""
    scheduled_count = await notification_service.schedule_notifications(user_id)
    return {
        "message": f"{scheduled_count}개의 알림이 스케줄되었습니다.",
        "scheduled_count": scheduled_count
    }


@router.post("/process", status_code=200)
async def process_notifications(
    notification_service: NotificationService = Depends(get_notification_service)
):
    """대기 중인 알림 처리 (수동 실행)"""
    processed_count = await notification_service.process_pending_notifications()
    return {
        "message": f"{processed_count}개의 알림이 처리되었습니다.",
        "processed_count": processed_count
    }
