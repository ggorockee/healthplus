from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr
from enum import Enum


class LoginMethod(str, Enum):
    """로그인 방식"""
    KAKAO = "kakao"
    GOOGLE = "google"
    APPLE = "apple"
    EMAIL = "email"


class AuthStatus(str, Enum):
    """인증 상태"""
    INITIAL = "initial"
    LOADING = "loading"
    AUTHENTICATED = "authenticated"
    UNAUTHENTICATED = "unauthenticated"
    ERROR = "error"


class LoginRequest(BaseModel):
    """로그인 요청"""
    email: EmailStr
    password: str


class SignUpRequest(BaseModel):
    """회원가입 요청"""
    email: EmailStr
    password: str
    name: Optional[str] = None
    agree_to_terms: bool = True


class SocialLoginRequest(BaseModel):
    """소셜 로그인 요청"""
    token: str
    provider: LoginMethod


class TokenResponse(BaseModel):
    """토큰 응답"""
    access_token: str
    token_type: str = "bearer"
    expires_in: int


class UserResponse(BaseModel):
    """사용자 응답"""
    id: str
    email: str
    name: Optional[str] = None
    profile_image_url: Optional[str] = None
    login_method: LoginMethod
    created_at: datetime
    is_email_verified: bool = False


class UserProfileUpdate(BaseModel):
    """사용자 프로필 업데이트"""
    name: Optional[str] = None
    profile_image_url: Optional[str] = None


class AuthResponse(BaseModel):
    """인증 응답"""
    user: UserResponse
    token: TokenResponse