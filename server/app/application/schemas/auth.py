from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr
from enum import Enum


class LoginMethod(str, Enum):
    """로그인 방식 (API 명세서 기준)"""
    EMAIL = "email"
    GOOGLE = "google"
    FACEBOOK = "facebook"
    KAKAO = "kakao"


class AuthStatus(str, Enum):
    """인증 상태"""
    INITIAL = "initial"
    LOADING = "loading"
    AUTHENTICATED = "authenticated"
    UNAUTHENTICATED = "unauthenticated"
    ERROR = "error"


class LoginRequest(BaseModel):
    """로그인 요청 (API 명세서 기준)"""
    email: EmailStr
    password: str


class SignUpRequest(BaseModel):
    """회원가입 요청 (API 명세서 기준)"""
    email: EmailStr
    password: str
    display_name: str


class SocialLoginRequest(BaseModel):
    """소셜 로그인 요청 (API 명세서 기준)"""
    # Google 로그인
    id_token: Optional[str] = None
    access_token: Optional[str] = None
    
    # Facebook 로그인
    user_id: Optional[str] = None
    
    # Kakao 로그인
    refresh_token: Optional[str] = None


class TokenResponse(BaseModel):
    """토큰 응답 (API 명세서 기준)"""
    access_token: str
    refresh_token: str
    expires_in: int  # 초 단위


class UserResponse(BaseModel):
    """사용자 응답 (API 명세서 기준)"""
    id: str
    email: str
    display_name: Optional[str] = None
    photo_url: Optional[str] = None
    provider: LoginMethod
    is_email_verified: bool = False
    created_at: datetime


class UserProfileUpdate(BaseModel):
    """사용자 프로필 업데이트 (API 명세서 기준)"""
    display_name: Optional[str] = None
    photo_url: Optional[str] = None


class AuthResponse(BaseModel):
    """인증 응답 (API 명세서 기준)"""
    user: UserResponse
    tokens: TokenResponse


class RefreshTokenRequest(BaseModel):
    """토큰 갱신 요청 (API 명세서 기준)"""
    refresh_token: str