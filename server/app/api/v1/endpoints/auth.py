from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import JSONResponse

from app.schemas.auth import (
    LoginRequest, SignUpRequest, AuthResponse,
    UserResponse, UserProfileUpdate
)
from app.services.auth_service import auth_service
from app.utils.auth import get_current_user, get_current_user_id
from app.core.exceptions import AuthenticationError, ValidationError


router = APIRouter(prefix="/auth", tags=["인증"])


@router.post("/signup", response_model=AuthResponse)
async def sign_up(signup_data: SignUpRequest):
    """이메일 회원가입"""
    try:
        result = await auth_service.sign_up_with_email(signup_data)
        return AuthResponse(**result)
    except (AuthenticationError, ValidationError) as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.post("/signin", response_model=AuthResponse)
async def sign_in(login_data: LoginRequest):
    """이메일 로그인"""
    try:
        result = await auth_service.sign_in_with_email(login_data)
        return AuthResponse(**result)
    except AuthenticationError as e:
        raise HTTPException(status_code=e.status_code, detail=e.detail)


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: UserResponse = Depends(get_current_user)):
    """현재 사용자 정보 조회"""
    return current_user


@router.post("/logout")
async def logout():
    """로그아웃"""
    # 클라이언트에서 토큰을 삭제하도록 안내
    return JSONResponse(
        content={"message": "로그아웃되었습니다. 클라이언트에서 토큰을 삭제해주세요."},
        status_code=200
    )


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    profile_data: UserProfileUpdate,
    current_user: UserResponse = Depends(get_current_user)
):
    """사용자 프로필 업데이트"""
    # TODO: 프로필 업데이트 로직 구현
    return current_user