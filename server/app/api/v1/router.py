from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.medications import router as medications_router


api_router = APIRouter()

# 인증 관련 라우터
api_router.include_router(auth_router)

# 약물 관리 관련 라우터
api_router.include_router(medications_router)