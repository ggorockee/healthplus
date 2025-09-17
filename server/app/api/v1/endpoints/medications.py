import uuid
from datetime import date
from typing import List
from fastapi import APIRouter, Depends, HTTPException, Query

from app.application.schemas.medication import (
    MedicationCreate, MedicationUpdate, MedicationResponse,
    MedicationRecordCreate, MedicationRecordUpdate,
    DailyMedicationRecord, MedicationDoseResponse,
    MonthlyStatistics
)
from app.application.services.medication_service import MedicationService
from app.api.v1.deps import get_medication_service, get_current_user_id
from app.core.exceptions import NotFoundError, ValidationError


router = APIRouter(prefix="/medications", tags=["약물 관리"])


@router.post("", response_model=MedicationResponse)
async def create_medication(
    medication_data: MedicationCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """약물 등록"""
    try:
        return await med_service.create_medication(user_id, medication_data)
    except ValidationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("", response_model=List[MedicationResponse])
async def get_medications(
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """사용자의 약물 목록 조회"""
    return await med_service.get_medications(user_id)


@router.get("/{medication_id}", response_model=MedicationResponse)
async def get_medication(
    medication_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """특정 약물 조회"""
    try:
        return await med_service.get_medication(user_id, medication_id)
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.put("/{medication_id}", response_model=MedicationResponse)
async def update_medication(
    medication_id: uuid.UUID,
    medication_data: MedicationUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """약물 정보 업데이트"""
    try:
        return await med_service.update_medication(user_id, medication_id, medication_data)
    except NotFoundError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.delete("/{medication_id}", status_code=204)
async def delete_medication(
    medication_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """약물 삭제"""
    success = await med_service.delete_medication(user_id, medication_id)
    if not success:
        raise HTTPException(status_code=404, detail="약물을 찾을 수 없습니다")
    return


@router.post("/records", response_model=MedicationDoseResponse)
async def create_medication_record(
    record_data: MedicationRecordCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """복용 기록 생성"""
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
    """특정 날짜의 복용 기록 조회"""
    return await med_service.get_daily_records(user_id, target_date)


@router.put("/records/{record_id}", response_model=MedicationDoseResponse)
async def update_medication_record(
    record_id: uuid.UUID,
    update_data: MedicationRecordUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    med_service: MedicationService = Depends(get_medication_service)
):
    """복용 기록 업데이트"""
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
    """월간 통계 조회"""
    return await med_service.get_monthly_statistics(user_id, year, month)
