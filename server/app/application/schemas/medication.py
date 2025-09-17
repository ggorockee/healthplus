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


class MedicationCreate(BaseModel):
    """약물 등록 요청"""
    name: str = Field(..., min_length=1, max_length=100)
    image_path: Optional[str] = None
    daily_dosage_count: int = Field(..., ge=1, le=10)
    dosage_times: List[str] = Field(..., min_items=1, max_items=10)
    form: MedicationForm
    single_dosage_amount: int = Field(..., ge=1)
    dosage_unit: DosageUnit
    has_meal_relation: bool = True
    meal_relation: Optional[MealRelation] = None
    is_continuous: bool = True
    memo: Optional[str] = Field(None, max_length=500)


class MedicationUpdate(BaseModel):
    """약물 정보 업데이트"""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    image_path: Optional[str] = None
    daily_dosage_count: Optional[int] = Field(None, ge=1, le=10)
    dosage_times: Optional[List[str]] = Field(None, min_items=1, max_items=10)
    form: Optional[MedicationForm] = None
    single_dosage_amount: Optional[int] = Field(None, ge=1)
    dosage_unit: Optional[DosageUnit] = None
    has_meal_relation: Optional[bool] = None
    meal_relation: Optional[MealRelation] = None
    is_continuous: Optional[bool] = None
    memo: Optional[str] = Field(None, max_length=500)


class MedicationResponse(BaseModel):
    """약물 응답"""
    id: str
    name: str
    image_path: Optional[str] = None
    daily_dosage_count: int
    dosage_times: List[str]
    form: MedicationForm
    single_dosage_amount: int
    dosage_unit: DosageUnit
    has_meal_relation: bool
    meal_relation: Optional[MealRelation] = None
    is_continuous: bool
    memo: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class MedicationRecordCreate(BaseModel):
    """복용 기록 생성"""
    medication_id: str
    date: datetime
    time: str
    status: MedicationStatus
    delay_reason: Optional[str] = None


class MedicationRecordUpdate(BaseModel):
    """복용 기록 업데이트"""
    status: MedicationStatus
    delay_reason: Optional[str] = None


class MedicationDoseResponse(BaseModel):
    """복용 기록 응답"""
    id: str
    medication_name: str
    time: str
    status: MedicationStatus
    delay_reason: Optional[str] = None
    taken_at: Optional[datetime] = None


class DailyMedicationRecord(BaseModel):
    """일별 복용 기록"""
    date: datetime
    doses: List[MedicationDoseResponse]
    completion_rate: float = Field(..., ge=0.0, le=1.0)
    overall_status: MedicationStatus


class MonthlyStatistics(BaseModel):
    """월간 통계"""
    average_completion_rate: float = Field(..., ge=0.0, le=1.0)
    consecutive_days: int = Field(..., ge=0)
    best_time: str
    total_days: int = Field(..., ge=0)
    completed_days: int = Field(..., ge=0)


class CalendarStatus(BaseModel):
    """달력 상태"""
    date: int
    status: MedicationStatus