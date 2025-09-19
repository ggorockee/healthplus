from datetime import datetime
from enum import Enum
from typing import Dict, Any, Optional
from pydantic import BaseModel, Field


class ServiceStatus(str, Enum):
    """서비스 상태"""
    HEALTHY = "healthy"
    UNHEALTHY = "unhealthy"
    DEGRADED = "degraded"


class HealthCheckResponse(BaseModel):
    """헬스체크 응답 (API 명세서 기준)"""
    status: ServiceStatus
    timestamp: datetime
    version: str
    database: str
    services: Dict[str, str]


class VersionInfo(BaseModel):
    """버전 정보"""
    version: str
    build_number: str
    release_date: datetime
    min_supported_version: str
    force_update: bool


class VersionResponse(BaseModel):
    """앱 버전 정보 응답 (API 명세서 기준)"""
    version: str
    build_number: str
    release_date: datetime
    min_supported_version: str
    force_update: bool


class SystemConfig(BaseModel):
    """시스템 설정"""
    maintenance_mode: bool = False
    api_rate_limit: int = 1000
    max_file_size: int = 10485760  # 10MB
    supported_image_formats: list = ["jpg", "jpeg", "png", "gif"]
    notification_enabled: bool = True
    analytics_enabled: bool = True


class SystemConfigResponse(BaseModel):
    """시스템 설정 응답"""
    config: SystemConfig
    last_updated: datetime


class SystemStats(BaseModel):
    """시스템 통계"""
    total_users: int
    active_users: int
    total_medications: int
    total_logs: int
    api_requests_today: int
    uptime_seconds: int


class SystemStatsResponse(BaseModel):
    """시스템 통계 응답"""
    stats: SystemStats
    timestamp: datetime
