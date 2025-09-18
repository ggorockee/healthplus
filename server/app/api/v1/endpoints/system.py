from typing import Dict, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.application.schemas.system import (
    HealthCheckResponse, VersionResponse, SystemConfigResponse, SystemStatsResponse
)
from app.application.services.system_service import SystemService
from app.api.v1.deps import get_db
from app.core.exceptions import ValidationError


router = APIRouter(prefix="/system", tags=["시스템"])


def get_system_service(db: AsyncSession = Depends(get_db)) -> SystemService:
    """시스템 서비스 의존성"""
    return SystemService(db)


@router.get("/health", response_model=HealthCheckResponse)
async def health_check(
    system_service: SystemService = Depends(get_system_service)
):
    """헬스체크 (API 명세서 기준)"""
    try:
        return await system_service.get_health_check()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Health check failed: {str(e)}")


@router.get("/version", response_model=VersionResponse)
async def get_version_info(
    system_service: SystemService = Depends(get_system_service)
):
    """앱 버전 정보 (API 명세서 기준)"""
    try:
        return await system_service.get_version_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get version info: {str(e)}")


@router.get("/config", response_model=SystemConfigResponse)
async def get_system_config(
    system_service: SystemService = Depends(get_system_service)
):
    """시스템 설정 조회"""
    try:
        return await system_service.get_system_config()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get system config: {str(e)}")


@router.get("/stats", response_model=SystemStatsResponse)
async def get_system_stats(
    system_service: SystemService = Depends(get_system_service)
):
    """시스템 통계 조회"""
    try:
        return await system_service.get_system_stats()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get system stats: {str(e)}")


@router.get("/info")
async def get_server_info(
    system_service: SystemService = Depends(get_system_service)
):
    """서버 정보 조회 (상세 정보)"""
    try:
        return await system_service.get_server_info()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get server info: {str(e)}")


@router.get("/ping")
async def ping():
    """간단한 핑 테스트"""
    return {"message": "pong", "timestamp": "2024-01-01T00:00:00Z"}
