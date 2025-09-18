from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse

from app.application.schemas.auth import (
    LoginRequest, SignUpRequest, AuthResponse,
    UserResponse, UserProfileUpdate, RefreshTokenRequest, TokenResponse
)
from app.application.services.auth_service import AuthService
from app.api.v1.deps import get_auth_service, get_current_user
from app.core.exceptions import AuthenticationError, ValidationError
from app.infrastructure.database.models.user import User


router = APIRouter(prefix="/auth", tags=["인증"])


@router.post("/register", response_model=AuthResponse)
async def register(
    signup_data: SignUpRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """이메일 회원가입 (API 명세서 기준)"""
    try:
        return await auth_service.sign_up_with_email(signup_data)
    except (AuthenticationError, ValidationError) as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.post("/login", response_model=AuthResponse)
async def login(
    login_data: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """이메일 로그인 (API 명세서 기준)"""
    try:
        return await auth_service.sign_in_with_email(login_data)
    except AuthenticationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    refresh_data: RefreshTokenRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """토큰 갱신 (API 명세서 기준)"""
    try:
        return await auth_service.refresh_tokens(refresh_data.refresh_token)
    except AuthenticationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/profile", response_model=UserResponse)
async def get_profile(current_user: User = Depends(get_current_user)):
    """사용자 프로필 조회 (API 명세서 기준)"""
    return UserResponse.model_validate(current_user)


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    profile_data: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service)
):
    """사용자 프로필 수정 (API 명세서 기준)"""
    try:
        return await auth_service.update_user_profile(
            current_user.id,
            display_name=profile_data.display_name,
            photo_url=profile_data.photo_url
        )
    except AuthenticationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.post("/logout")
async def logout():
    """로그아웃 (API 명세서 기준)"""
    # 클라이언트에서 토큰을 삭제하도록 안내 (서버 측 상태 변경 없음)
    return JSONResponse(
        content={"message": "로그아웃되었습니다. 클라이언트에서 토큰을 삭제해주세요."},
        status_code=200
    )
