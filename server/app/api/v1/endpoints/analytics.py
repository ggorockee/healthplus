import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query

from app.application.schemas.analytics import (
    MedicationStatsResponse, ComplianceRateResponse, MedicationHistoryResponse,
    AnalyticsSummaryResponse
)
from app.application.services.analytics_service import AnalyticsService
from app.api.v1.deps import get_medication_service, get_current_user_id
from app.core.exceptions import NotFoundError, ValidationError
from app.core.error_codes import ErrorCode


router = APIRouter(tags=["통계 및 분석"])


@router.get("/medication-stats", response_model=MedicationStatsResponse)
async def get_medication_stats(
    start_date: Optional[str] = Query(None, description="시작 날짜 (YYYY-MM-DD)"),
    end_date: Optional[str] = Query(None, description="종료 날짜 (YYYY-MM-DD)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service = Depends(get_medication_service)
):
    """약물 복용 통계 조회 (API 명세서 기준)"""
    try:
        # AnalyticsService 인스턴스 생성
        analytics_service = AnalyticsService(med_service.med_repo)
        stats = await analytics_service.get_medication_stats(
            user_id=user_id,
            start_date=start_date,
            end_date=end_date
        )
        return stats
    except ValidationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/compliance-rate", response_model=ComplianceRateResponse)
async def get_compliance_rate(
    medication_id: Optional[str] = Query(None, description="약물 ID"),
    period: str = Query("month", description="기간 (week, month, year)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service = Depends(get_medication_service)
):
    """복용 준수율 조회 (API 명세서 기준)"""
    try:
        # AnalyticsService 인스턴스 생성
        analytics_service = AnalyticsService(med_service.med_repo)
        compliance = await analytics_service.get_compliance_rate(
            user_id=user_id,
            medication_id=medication_id,
            period=period
        )
        return compliance
    except (ValidationError, NotFoundError) as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/history", response_model=MedicationHistoryResponse)
async def get_medication_history(
    medication_id: Optional[str] = Query(None, description="약물 ID"),
    period: str = Query("week", description="기간 (week, month, year)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service = Depends(get_medication_service)
):
    """복용 히스토리 조회 (API 명세서 기준)"""
    try:
        # AnalyticsService 인스턴스 생성
        analytics_service = AnalyticsService(med_service.med_repo)
        history = await analytics_service.get_medication_history(
            user_id=user_id,
            medication_id=medication_id,
            period=period
        )
        return history
    except (ValidationError, NotFoundError) as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/summary", response_model=AnalyticsSummaryResponse)
async def get_analytics_summary(
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service = Depends(get_medication_service)
):
    """분석 요약 조회"""
    try:
        # AnalyticsService 인스턴스 생성
        analytics_service = AnalyticsService(med_service.med_repo)
        summary = await analytics_service.get_analytics_summary(user_id=user_id)
        return summary
    except ValidationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)
