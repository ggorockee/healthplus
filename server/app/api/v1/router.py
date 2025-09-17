from fastapi import APIRouter

from app.api.v1.endpoints import auth, medications


api_router = APIRouter()

# 인증 관련 라우터
api_router.include_router(auth.router, prefix="/auth", tags=["인증"])

# 약물 관리 관련 라우터
api_router.include_router(medications.router, prefix="/medications", tags=["약물 관리"])
