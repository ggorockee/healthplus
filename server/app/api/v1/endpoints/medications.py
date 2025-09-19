import uuid
from datetime import date
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query

from app.application.schemas.medication import (
    MedicationCreate, MedicationUpdate, MedicationResponse, MedicationListResponse,
    MedicationLogCreate, MedicationLogUpdate, MedicationLogResponse, MedicationLogListResponse,
    TodayMedicationResponse,
    # 기존 호환성 스키마들
    MedicationRecordCreate, MedicationRecordUpdate,
    DailyMedicationRecord, MedicationDoseResponse,
    MonthlyStatistics
)
from app.application.schemas.common import APIResponse
from app.application.services.medication_service import MedicationService
from app.api.v1.deps import get_medication_service, get_current_user_id
from app.core.exceptions import NotFoundError, ValidationError
from app.core.error_codes import ErrorCode


router = APIRouter(tags=["약물 관리"])


# API 명세서 기준 엔드포인트들

@router.post("")
async def create_medication(
    medication_data: MedicationCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """약물 추가 (API 명세서 기준)"""
    try:
        medication = await med_service.create_medication(user_id, medication_data)
        return APIResponse(
            success=True,
            data=medication.model_dump(),
            message="약물이 성공적으로 등록되었습니다"
        )
    except ValidationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("")
async def get_medications(
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """약물 목록 조회 (API 명세서 기준)"""
    try:
        medications = await med_service.get_medications(user_id)
        return APIResponse(
            success=True,
            data=medications.model_dump(),
            message="약물 목록 조회 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get medications: {str(e)}")


@router.get("/today")
async def get_today_medications(
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """오늘의 약물 목록 (API 명세서 기준)"""
    try:
        today_medications = await med_service.get_today_medications(user_id)
        return APIResponse(
            success=True,
            data=today_medications.model_dump(),
            message="오늘의 약물 목록 조회 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get today's medications: {str(e)}")


@router.get("/{medication_id}")
async def get_medication(
    medication_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """특정 약물 조회 (API 명세서 기준)"""
    try:
        medication = await med_service.get_medication(user_id, medication_id)
        return APIResponse(
            success=True,
            data=medication.model_dump(),
            message="약물 조회 성공"
        )
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.put("/{medication_id}")
async def update_medication(
    medication_id: uuid.UUID,
    medication_data: MedicationUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """약물 수정 (API 명세서 기준)"""
    try:
        medication = await med_service.update_medication(user_id, medication_id, medication_data)
        return APIResponse(
            success=True,
            data=medication.model_dump(),
            message="약물 수정 성공"
        )
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.delete("/{medication_id}", status_code=200)
async def delete_medication(
    medication_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """약물 삭제 (API 명세서 기준)"""
    success = await med_service.delete_medication(user_id, medication_id)
    if not success:
        raise HTTPException(status_code=404, detail="약물을 찾을 수 없습니다")
    return {"message": "약물이 삭제되었습니다."}


# 복용 로그 관련 엔드포인트들 (API 명세서 기준)

@router.post("/medication-log")
async def create_medication_log(
    log_data: MedicationLogCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """복용 로그 기록 (API 명세서 기준)"""
    try:
        log = await med_service.create_medication_log(user_id, log_data)
        return APIResponse(
            success=True,
            data=log.model_dump(),
            message="복용 로그가 성공적으로 기록되었습니다"
        )
    except (ValidationError, NotFoundError) as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/medication-log")
async def get_medication_logs(
    medication_id: Optional[str] = Query(None, description="약물 ID"),
    start_date: Optional[str] = Query(None, description="시작 날짜 (YYYY-MM-DD)"),
    end_date: Optional[str] = Query(None, description="종료 날짜 (YYYY-MM-DD)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """복용 로그 조회 (API 명세서 기준)"""
    try:
        logs = await med_service.get_medication_logs(
            user_id=user_id,
            medication_id=medication_id,
            start_date=start_date,
            end_date=end_date
        )
        return APIResponse(
            success=True,
            data=logs.model_dump(),
            message="복용 로그 조회 성공"
        )
    except ValidationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.put("/medication-log/{log_id}")
async def update_medication_log(
    log_id: uuid.UUID,
    update_data: MedicationLogUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """복용 로그 수정 (API 명세서 기준)"""
    try:
        log = await med_service.update_medication_log(user_id, log_id, update_data)
        return APIResponse(
            success=True,
            data=log.model_dump(),
            message="복용 로그가 성공적으로 수정되었습니다"
        )
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.delete("/medication-log/{log_id}", status_code=200)
async def delete_medication_log(
    log_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """복용 로그 삭제 (API 명세서 기준)"""
    try:
        success = await med_service.delete_medication_log(user_id, log_id)
        if not success:
            raise HTTPException(status_code=404, detail="복용 로그를 찾을 수 없습니다")
        return APIResponse(
            success=True,
            data=None,
            message="복용 로그가 성공적으로 삭제되었습니다"
        )
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


# 기존 호환성 엔드포인트들 (하위 호환성을 위해 유지)

@router.post("/records", response_model=MedicationDoseResponse)
async def create_medication_record(
    record_data: MedicationRecordCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """복용 기록 생성 (기존 호환성)"""
    try:
        return await med_service.create_medication_record(user_id, record_data)
    except (ValidationError, NotFoundError) as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/records/daily", response_model=DailyMedicationRecord)
async def get_daily_records(
    target_date: date = Query(..., description="조회할 날짜 (YYYY-MM-DD)"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """특정 날짜의 복용 기록 조회 (기존 호환성)"""
    return await med_service.get_daily_records(user_id, target_date)


@router.put("/records/{record_id}", response_model=MedicationDoseResponse)
async def update_medication_record(
    record_id: uuid.UUID,
    update_data: MedicationRecordUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """복용 기록 업데이트 (기존 호환성)"""
    try:
        return await med_service.update_medication_record(user_id, record_id, update_data)
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/statistics/monthly", response_model=MonthlyStatistics)
async def get_monthly_statistics(
    year: int = Query(..., description="연도"),
    month: int = Query(..., ge=1, le=12, description="월"),
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """월간 통계 조회 (기존 호환성)"""
    return await med_service.get_monthly_statistics(user_id, year, month)
