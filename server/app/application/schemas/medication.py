from datetime import datetime, time
from typing import List, Optional
from pydantic import BaseModel, Field
from enum import Enum


class MedicationForm(str, Enum):
    """약 형태"""
    TABLET = "tablet"
    CAPSULE = "capsule"
    SYRUP = "syrup"
    OTHER = "other"


class MealRelation(str, Enum):
    """식사 관계"""
    BEFORE_MEAL = "before_meal"
    AFTER_MEAL = "after_meal"
    IRRELEVANT = "irrelevant"


class DosageUnit(str, Enum):
    """복용량 단위"""
    TABLET = "tablet"
    CAPSULE = "capsule"
    ML = "ml"
    MG = "mg"
    OTHER = "other"


class MedicationStatus(str, Enum):
    """복용 상태"""
    TAKEN = "taken"
    MISSED = "missed"
    DELAYED = "delayed"


# API 명세서 기준 스키마들

class NotificationTime(BaseModel):
    """알림 시간 (API 명세서 기준)"""
    hour: int = Field(..., ge=0, le=23, description="시간 (0-23)")
    minute: int = Field(..., ge=0, le=59, description="분 (0-59)")


class MedicationCreate(BaseModel):
    """약물 등록 요청 (API 명세서 기준)"""
    name: str = Field(..., min_length=1, max_length=100, description="약물명")
    dosage: str = Field(..., min_length=1, max_length=50, description="복용량 (예: 1정, 2캡슐)")
    notification_time: NotificationTime = Field(..., description="알림 시간")
    repeat_days: List[int] = Field(..., min_length=1, max_length=7, description="반복 요일 (1=월요일, 7=일요일)")
    
    # 기존 필드들 (호환성을 위해 유지)
    image_path: Optional[str] = None
    daily_dosage_count: Optional[int] = Field(None, ge=1, le=10)
    dosage_times: Optional[List[str]] = None
    form: Optional[MedicationForm] = None
    single_dosage_amount: Optional[int] = Field(None, ge=1)
    dosage_unit: Optional[DosageUnit] = None
    has_meal_relation: Optional[bool] = True
    meal_relation: Optional[MealRelation] = None
    is_continuous: Optional[bool] = True
    memo: Optional[str] = Field(None, max_length=500)


class MedicationUpdate(BaseModel):
    """약물 정보 업데이트 (API 명세서 기준)"""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    dosage: Optional[str] = Field(None, min_length=1, max_length=50)
    notification_time: Optional[NotificationTime] = None
    repeat_days: Optional[List[int]] = Field(None, min_length=1, max_length=7)
    is_active: Optional[bool] = None
    
    # 기존 필드들 (호환성을 위해 유지)
    image_path: Optional[str] = None
    daily_dosage_count: Optional[int] = Field(None, ge=1, le=10)
    dosage_times: Optional[List[str]] = None
    form: Optional[MedicationForm] = None
    single_dosage_amount: Optional[int] = Field(None, ge=1)
    dosage_unit: Optional[DosageUnit] = None
    has_meal_relation: Optional[bool] = None
    meal_relation: Optional[MealRelation] = None
    is_continuous: Optional[bool] = None
    memo: Optional[str] = Field(None, max_length=500)


class MedicationResponse(BaseModel):
    """약물 응답 (API 명세서 기준)"""
    id: str
    name: str
    dosage: str
    notification_time: NotificationTime
    repeat_days: List[int]
    is_active: bool
    created_at: datetime
    
    # 기존 필드들 (호환성을 위해 유지)
    image_path: Optional[str] = None
    daily_dosage_count: Optional[int] = None
    dosage_times: Optional[List[str]] = None
    form: Optional[MedicationForm] = None
    single_dosage_amount: Optional[int] = None
    dosage_unit: Optional[DosageUnit] = None
    has_meal_relation: Optional[bool] = None
    meal_relation: Optional[MealRelation] = None
    is_continuous: Optional[bool] = None
    memo: Optional[str] = None
    updated_at: Optional[datetime] = None


class MedicationListResponse(BaseModel):
    """약물 목록 응답 (API 명세서 기준)"""
    medications: List[MedicationResponse]
    total: int


class TodayMedicationResponse(BaseModel):
    """오늘의 약물 목록 응답 (API 명세서 기준)"""
    medications: List[MedicationResponse]
    date: str  # YYYY-MM-DD 형식
    total: int


# 복용 로그 관련 스키마들 (API 명세서 기준)

class MedicationLogCreate(BaseModel):
    """복용 로그 기록 요청 (API 명세서 기준)"""
    medication_id: str = Field(..., description="약물 ID")
    taken_at: datetime = Field(..., description="복용 시간")
    is_taken: bool = Field(..., description="복용 여부")
    note: Optional[str] = Field(None, max_length=500, description="복용 메모")


class MedicationLogUpdate(BaseModel):
    """복용 로그 수정 요청 (API 명세서 기준)"""
    is_taken: Optional[bool] = None
    note: Optional[str] = Field(None, max_length=500)


class MedicationLogResponse(BaseModel):
    """복용 로그 응답 (API 명세서 기준)"""
    id: str
    medication_id: str
    taken_at: datetime
    is_taken: bool
    note: Optional[str] = None


class MedicationLogListResponse(BaseModel):
    """복용 로그 목록 응답 (API 명세서 기준)"""
    logs: List[MedicationLogResponse]
    total: int
    start_date: Optional[str] = None
    end_date: Optional[str] = None


# 기존 스키마들 (호환성을 위해 유지)

class MedicationRecordCreate(BaseModel):
    """복용 기록 생성 (기존 호환성)"""
    medication_id: str
    date: datetime
    time: str
    status: MedicationStatus
    delay_reason: Optional[str] = None


class MedicationRecordUpdate(BaseModel):
    """복용 기록 업데이트 (기존 호환성)"""
    status: MedicationStatus
    delay_reason: Optional[str] = None


class MedicationDoseResponse(BaseModel):
    """복용 기록 응답 (기존 호환성)"""
    id: str
    medication_name: str
    time: str
    status: MedicationStatus
    delay_reason: Optional[str] = None
    taken_at: Optional[datetime] = None


class DailyMedicationRecord(BaseModel):
    """일별 복용 기록 (기존 호환성)"""
    date: datetime
    doses: List[MedicationDoseResponse]
    completion_rate: float = Field(..., ge=0.0, le=1.0)
    overall_status: MedicationStatus


class MonthlyStatistics(BaseModel):
    """월간 통계 (기존 호환성)"""
    average_completion_rate: float = Field(..., ge=0.0, le=1.0)
    consecutive_days: int = Field(..., ge=0)
    best_time: str
    total_days: int = Field(..., ge=0)
    completed_days: int = Field(..., ge=0)


class CalendarStatus(BaseModel):
    """달력 상태 (기존 호환성)"""
    date: int
    status: MedicationStatus