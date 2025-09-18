from datetime import datetime, date
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field


class MedicationStats(BaseModel):
    """약물 통계 정보"""
    id: str
    name: str
    count: int


class DailyStats(BaseModel):
    """일별 통계"""
    date: str  # YYYY-MM-DD 형식
    total: int
    taken: int
    missed: int


class MedicationStatsResponse(BaseModel):
    """약물 복용 통계 응답 (API 명세서 기준)"""
    total_medications: int
    total_logs: int
    compliance_rate: float = Field(..., ge=0.0, le=100.0)
    most_taken_medication: Optional[MedicationStats] = None
    daily_stats: List[DailyStats]


class ComplianceRateResponse(BaseModel):
    """복용 준수율 응답 (API 명세서 기준)"""
    medication_id: str
    medication_name: str
    period: str  # week, month, year
    compliance_rate: float = Field(..., ge=0.0, le=100.0)
    total_expected: int
    total_taken: int
    missed_count: int


class HistoryEntry(BaseModel):
    """히스토리 엔트리"""
    date: str  # YYYY-MM-DD 형식
    taken_at: Optional[datetime] = None
    is_taken: bool
    note: Optional[str] = None


class MedicationHistoryResponse(BaseModel):
    """복용 히스토리 응답 (API 명세서 기준)"""
    medication_id: str
    medication_name: str
    period: str  # week, month, year
    history: List[HistoryEntry]
    total_entries: int


class WeeklyStats(BaseModel):
    """주간 통계"""
    week_start: str  # YYYY-MM-DD 형식
    week_end: str    # YYYY-MM-DD 형식
    total_medications: int
    total_taken: int
    compliance_rate: float = Field(..., ge=0.0, le=100.0)


class MonthlyStats(BaseModel):
    """월간 통계"""
    month: str  # YYYY-MM 형식
    total_medications: int
    total_taken: int
    compliance_rate: float = Field(..., ge=0.0, le=100.0)
    consecutive_days: int
    best_day: Optional[str] = None


class YearlyStats(BaseModel):
    """연간 통계"""
    year: int
    total_medications: int
    total_taken: int
    compliance_rate: float = Field(..., ge=0.0, le=100.0)
    monthly_breakdown: List[MonthlyStats]


class AnalyticsSummaryResponse(BaseModel):
    """분석 요약 응답"""
    overall_compliance_rate: float = Field(..., ge=0.0, le=100.0)
    total_medications: int
    active_medications: int
    total_logs: int
    streak_days: int
    last_taken_date: Optional[str] = None
    most_active_time: Optional[str] = None  # morning, afternoon, evening
