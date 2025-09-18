from fastapi import APIRouter

from app.api.v1.endpoints import auth, medications, analytics, reminders, system


api_router = APIRouter()

# 인증 관련 라우터
api_router.include_router(auth.router, prefix="/auth", tags=["인증"])

# 약물 관리 관련 라우터
api_router.include_router(medications.router, prefix="/medications", tags=["약물 관리"])

# 통계 및 분석 관련 라우터
api_router.include_router(analytics.router, prefix="/analytics", tags=["통계 및 분석"])

# 알림 및 리마인더 관련 라우터
api_router.include_router(reminders.router, prefix="/reminders", tags=["알림 및 리마인더"])

# 시스템 관련 라우터
api_router.include_router(system.router, prefix="/system", tags=["시스템"])
