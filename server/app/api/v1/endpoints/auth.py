from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse

from app.application.schemas.auth import (
    LoginRequest, SignUpRequest, AuthResponse,
    UserResponse, UserProfileUpdate
)
from app.application.services.auth_service import AuthService
from app.api.v1.deps import get_auth_service, get_current_user
from app.core.exceptions import AuthenticationError, ValidationError
from app.infrastructure.database.models.user import User


router = APIRouter(prefix="/auth", tags=["인증"])


@router.post("/signup", response_model=AuthResponse)
async def sign_up(
    signup_data: SignUpRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """이메일 회원가입"""
    try:
        return await auth_service.sign_up_with_email(signup_data)
    except (AuthenticationError, ValidationError) as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.post("/signin", response_model=AuthResponse)
async def sign_in(
    login_data: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """이메일 로그인"""
    try:
        return await auth_service.sign_in_with_email(login_data)
    except AuthenticationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """현재 사용자 정보 조회"""
    # ORM 모델을 Pydantic 스키마로 변환하여 반환
    return UserResponse.model_validate(current_user)


@router.post("/logout")
async def logout():
    """로그아웃"""
    # 클라이언트에서 토큰을 삭제하도록 안내 (서버 측 상태 변경 없음)
    return JSONResponse(
        content={"message": "로그아웃되었습니다. 클라이언트에서 토큰을 삭제해주세요."},
        status_code=200
    )


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    profile_data: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service)
):
    """사용자 프로필 업데이트"""
    # TODO: 프로필 업데이트 로직 구현 필요
    # updated_user = await auth_service.update_profile(current_user.id, profile_data)
    # return UserResponse.from_orm(updated_user)
    return UserResponse.model_validate(current_user) # 임시로 현재 정보 반환
