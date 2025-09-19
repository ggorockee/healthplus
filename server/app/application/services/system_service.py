from datetime import datetime, timedelta, timezone
from typing import Dict, Any, Optional
import uuid
import psutil
import os
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.config import settings
from app.application.schemas.system import (
    HealthCheckResponse, VersionResponse, SystemConfigResponse, SystemStatsResponse,
    ServiceStatus, SystemConfig, SystemStats
)
from app.infrastructure.database.models.user import User
from app.infrastructure.database.models.medications import Medication, MedicationRecord


class SystemService:
    """시스템 서비스 (API 명세서 기준)"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_health_check(self) -> HealthCheckResponse:
        """헬스체크 조회 (API 명세서 기준)"""
        # 데이터베이스 연결 상태 확인
        try:
            await self.db.execute(select(func.now()))
            database_status = "connected"
        except Exception:
            database_status = "disconnected"

        # 서비스 상태 확인
        services = {
            "auth": "healthy",
            "medication": "healthy",
            "notification": "healthy"
        }

        # 전체 상태 결정
        if database_status == "connected" and all(status == "healthy" for status in services.values()):
            overall_status = ServiceStatus.HEALTHY
        elif database_status == "disconnected":
            overall_status = ServiceStatus.UNHEALTHY
        else:
            overall_status = ServiceStatus.DEGRADED

        return HealthCheckResponse(
            status=overall_status,
            timestamp=datetime.now(timezone.utc),
            version=settings.APP_VERSION,
            database=database_status,
            services=services
        )

    async def get_version_info(self) -> VersionResponse:
        """앱 버전 정보 조회 (API 명세서 기준)"""
        return VersionResponse(
            version=settings.APP_VERSION,
            build_number=settings.APP_VERSION.replace(".", ""),
            release_date=datetime.now(timezone.utc),  # 실제로는 빌드 날짜를 사용
            min_supported_version=settings.APP_VERSION,
            force_update=False
        )

    async def get_system_config(self) -> SystemConfigResponse:
        """시스템 설정 조회"""
        config = SystemConfig(
            maintenance_mode=getattr(settings, 'MAINTENANCE_MODE', False),
            api_rate_limit=getattr(settings, 'API_RATE_LIMIT', 1000),
            max_file_size=getattr(settings, 'MAX_FILE_SIZE', 10485760),
            supported_image_formats=getattr(settings, 'SUPPORTED_IMAGE_FORMATS', ["jpg", "jpeg", "png", "gif"]),
            notification_enabled=getattr(settings, 'NOTIFICATION_ENABLED', True),
            analytics_enabled=getattr(settings, 'ANALYTICS_ENABLED', True)
        )

        return SystemConfigResponse(
            config=config,
            last_updated=datetime.now(timezone.utc)
        )

    async def get_system_stats(self) -> SystemStatsResponse:
        """시스템 통계 조회"""
        # 사용자 통계
        try:
            user_count_result = await self.db.execute(select(func.count(User.id)))
            total_users = user_count_result.scalar() or 0
        except Exception:
            total_users = 0

        # 활성 사용자 (최근 30일 내 활동)
        try:
            thirty_days_ago = datetime.now(timezone.utc) - timedelta(days=30)
            active_user_count_result = await self.db.execute(
                select(func.count(func.distinct(User.id)))
                .where(User.created_at >= thirty_days_ago)
            )
            active_users = active_user_count_result.scalar() or 0
        except Exception:
            active_users = 0

        # 약물 통계
        try:
            medication_count_result = await self.db.execute(select(func.count(Medication.id)))
            total_medications = medication_count_result.scalar() or 0
        except Exception:
            total_medications = 0

        # 복용 로그 통계
        try:
            log_count_result = await self.db.execute(select(func.count(MedicationRecord.id)))
            total_logs = log_count_result.scalar() or 0
        except Exception:
            total_logs = 0

        # 시스템 리소스 정보
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')

        # API 요청 수 (시뮬레이션)
        api_requests_today = 1000  # 실제로는 로그에서 계산

        # 업타임 계산 (시뮬레이션)
        uptime_seconds = int((datetime.now(timezone.utc) - datetime.now(timezone.utc).replace(hour=0, minute=0, second=0)).total_seconds())

        stats = SystemStats(
            total_users=total_users,
            active_users=active_users,
            total_medications=total_medications,
            total_logs=total_logs,
            api_requests_today=api_requests_today,
            uptime_seconds=uptime_seconds
        )

        return SystemStatsResponse(
            stats=stats,
            timestamp=datetime.now(timezone.utc)
        )

    async def get_server_info(self) -> Dict[str, Any]:
        """서버 정보 조회"""
        return {
            "server": {
                "name": getattr(settings, 'APP_NAME', 'OneDayPillo'),
                "version": getattr(settings, 'APP_VERSION', '1.0.0'),
                "environment": getattr(settings, 'APP_ENVIRONMENT', 'development'),
                "python_version": f"{os.sys.version_info.major}.{os.sys.version_info.minor}.{os.sys.version_info.micro}",
                "platform": os.name,
                "uptime": self._get_uptime(),
                "resources": {
                    "cpu_percent": psutil.cpu_percent(interval=1),
                    "memory_percent": psutil.virtual_memory().percent,
                    "disk_percent": psutil.disk_usage('/').percent
                }
            },
            "database": {
                "url": settings.DATABASE_URL.split('@')[1] if '@' in settings.DATABASE_URL else "hidden",
                "pool_size": getattr(settings, 'DATABASE_POOL_SIZE', 10),
                "max_overflow": getattr(settings, 'DATABASE_MAX_OVERFLOW', 20)
            },
            "features": {
                "social_login": bool(getattr(settings, 'GOOGLE_CLIENT_ID', None)),
                "firebase": bool(getattr(settings, 'FIREBASE_PROJECT_ID', None)),
                "admob": bool(getattr(settings, 'ADMOB_APP_ID', None)),
                "notifications": getattr(settings, 'NOTIFICATION_ENABLED', True),
                "analytics": getattr(settings, 'ANALYTICS_ENABLED', True)
            }
        }

    def _get_uptime(self) -> str:
        """서버 업타임 계산"""
        try:
            # 시스템 부팅 시간 대신 현재 시간 기준으로 시뮬레이션
            uptime_seconds = int((datetime.now(timezone.utc) - datetime.now(timezone.utc).replace(hour=0, minute=0, second=0)).total_seconds())
            days = uptime_seconds // 86400
            hours = (uptime_seconds % 86400) // 3600
            minutes = (uptime_seconds % 3600) // 60
            seconds = uptime_seconds % 60
            return f"{days}d {hours}h {minutes}m {seconds}s"
        except:
            return "unknown"
