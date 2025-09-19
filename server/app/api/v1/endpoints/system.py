from typing import Dict, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.application.schemas.system import (
    HealthCheckResponse, VersionResponse, SystemConfigResponse, SystemStatsResponse
)
from app.application.services.system_service import SystemService
from app.api.v1.deps import get_db
from app.core.exceptions import ValidationError
from app.application.schemas.common import APIResponse


router = APIRouter(tags=["시스템"])


def get_system_service(db: AsyncSession = Depends(get_db)) -> SystemService:
    """시스템 서비스 의존성"""
    return SystemService(db)


@router.get("/health")
async def health_check(
    system_service: SystemService = Depends(get_system_service)
):
    """헬스체크 (API 명세서 기준)"""
    try:
        health_data = await system_service.get_health_check()
        return APIResponse(
            success=True,
            data=health_data.model_dump(),
            message="헬스체크 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Health check failed: {str(e)}")


@router.get("/version")
async def get_version_info(
    system_service: SystemService = Depends(get_system_service)
):
    """앱 버전 정보 (API 명세서 기준)"""
    try:
        version_data = await system_service.get_version_info()
        return APIResponse(
            success=True,
            data=version_data.model_dump(),
            message="버전 정보 조회 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get version info: {str(e)}")


@router.get("/config")
async def get_system_config(
    system_service: SystemService = Depends(get_system_service)
):
    """시스템 설정 조회"""
    try:
        config_data = await system_service.get_system_config()
        return APIResponse(
            success=True,
            data=config_data.model_dump(),
            message="시스템 설정 조회 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get system config: {str(e)}")


@router.get("/stats")
async def get_system_stats(
    system_service: SystemService = Depends(get_system_service)
):
    """시스템 통계 조회"""
    try:
        stats_data = await system_service.get_system_stats()
        return APIResponse(
            success=True,
            data=stats_data.model_dump(),
            message="시스템 통계 조회 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get system stats: {str(e)}")


@router.get("/info")
async def get_server_info(
    system_service: SystemService = Depends(get_system_service)
):
    """서버 정보 조회 (상세 정보)"""
    try:
        info_data = await system_service.get_server_info()
        return APIResponse(
            success=True,
            data=info_data,
            message="서버 정보 조회 성공"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get server info: {str(e)}")


@router.get("/ping")
async def ping():
    """간단한 핑 테스트"""
    return APIResponse(
        success=True,
        data={"message": "pong"},
        message="핑 테스트 성공"
    )
