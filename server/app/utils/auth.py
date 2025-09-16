from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from app.services.auth_service import auth_service
from app.schemas.auth import UserResponse


security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> UserResponse:
    """현재 사용자 가져오기 의존성"""
    try:
        token = credentials.credentials
        user = await auth_service.get_current_user(token)
        return user
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="인증이 필요합니다",
            headers={"WWW-Authenticate": "Bearer"},
        )


def get_current_user_id(user: UserResponse = Depends(get_current_user)) -> str:
    """현재 사용자 ID 가져오기"""
    return user.id