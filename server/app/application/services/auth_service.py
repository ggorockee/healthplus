import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings
from app.core.exceptions import AuthenticationError, ValidationError, TokenExpiredError, InvalidTokenError
from app.core.error_codes import ErrorCode
from app.application.repositories.user_repository import IUserRepository
from app.application.schemas.auth import LoginRequest, SignUpRequest, UserResponse, TokenResponse, AuthResponse
from app.infrastructure.database.models.user import User


class AuthService:
    """인증 서비스 (비즈니스 로직)"""

    def __init__(self, user_repo: IUserRepository):
        self.user_repo = user_repo
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """비밀번호 검증"""
        return self.pwd_context.verify(plain_password, hashed_password)

    def get_password_hash(self, password: str) -> str:
        """비밀번호 해시화"""
        return self.pwd_context.hash(password)

    def create_access_token(self, data: dict) -> str:
        """액세스 토큰 생성 (API 명세서 기준)"""
        to_encode = data.copy()
        expire = datetime.now(timezone.utc) + timedelta(days=7)  # API 명세서: 7일
        to_encode.update({
            "exp": expire,
            "iat": datetime.now(timezone.utc),
            "iss": "onedaypillo-api",
            "type": "access"
        })

        encoded_jwt = jwt.encode(
            to_encode,
            settings.JWT_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM
        )
        return encoded_jwt

    def create_refresh_token(self, data: dict) -> str:
        """리프레시 토큰 생성 (API 명세서 기준)"""
        to_encode = data.copy()
        expire = datetime.now(timezone.utc) + timedelta(days=30)  # API 명세서: 30일
        to_encode.update({
            "exp": expire,
            "iat": datetime.now(timezone.utc),
            "iss": "onedaypillo-api",
            "type": "refresh"
        })

        encoded_jwt = jwt.encode(
            to_encode,
            settings.JWT_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM
        )
        return encoded_jwt

    def verify_token(self, token: str, token_type: str = "access") -> Optional[dict]:
        """토큰 검증 (API 명세서 기준)"""
        try:
            payload = jwt.decode(
                token,
                settings.JWT_SECRET_KEY,
                algorithms=[settings.JWT_ALGORITHM]
            )
            
            # 토큰 타입 검증
            if payload.get("type") != token_type:
                return None
                
            return payload
        except JWTError:
            return None

    def verify_access_token(self, token: str) -> Optional[dict]:
        """액세스 토큰 검증"""
        return self.verify_token(token, "access")

    def verify_refresh_token(self, token: str) -> Optional[dict]:
        """리프레시 토큰 검증"""
        return self.verify_token(token, "refresh")

    async def refresh_tokens(self, refresh_token: str) -> TokenResponse:
        """토큰 갱신 (API 명세서 기준)"""
        payload = self.verify_refresh_token(refresh_token)
        if not payload:
            raise InvalidTokenError("유효하지 않은 리프레시 토큰입니다")

        user_id_str = payload.get("sub")
        if not user_id_str:
            raise InvalidTokenError("토큰에서 사용자 ID를 찾을 수 없습니다")
        
        try:
            user_id = uuid.UUID(user_id_str)
        except ValueError:
            raise InvalidTokenError("유효하지 않은 사용자 ID 형식입니다")

        # 사용자 존재 확인
        db_user = await self.user_repo.get_user_by_id(user_id)
        if not db_user:
            raise AuthenticationError("사용자를 찾을 수 없습니다")

        # 새 토큰 생성
        token_data = {
            "sub": str(db_user.id),
            "email": db_user.email,
            "provider": db_user.provider
        }
        
        new_access_token = self.create_access_token(token_data)
        new_refresh_token = self.create_refresh_token(token_data)

        return TokenResponse(
            access_token=new_access_token,
            refresh_token=new_refresh_token,
            expires_in=7 * 24 * 60 * 60  # 7일 (초 단위)
        )

    async def sign_up_with_email(self, signup_data: SignUpRequest) -> AuthResponse:
        """이메일 회원가입 로직 (API 명세서 기준)"""
        existing_user = await self.user_repo.get_user_by_email(signup_data.email)
        if existing_user:
            raise ValidationError("이미 등록된 이메일입니다", ErrorCode.AUTH_EMAIL_ALREADY_EXISTS)

        hashed_password = self.get_password_hash(signup_data.password)
        
        db_user = await self.user_repo.create_user(
            email=signup_data.email,
            hashed_password=hashed_password,
            display_name=signup_data.display_name,
            provider="email",
            is_email_verified=False
        )

        # 토큰 데이터 생성
        token_data = {
            "sub": str(db_user.id),
            "email": db_user.email,
            "provider": db_user.provider
        }
        
        access_token = self.create_access_token(token_data)
        refresh_token = self.create_refresh_token(token_data)
        
        return AuthResponse(
            user=UserResponse(
                id=str(db_user.id),
                email=db_user.email,
                display_name=db_user.display_name,
                photo_url=db_user.photo_url,
                provider=db_user.provider,
                is_email_verified=db_user.is_email_verified,
                created_at=db_user.created_at
            ),
            tokens=TokenResponse(
                access_token=access_token,
                refresh_token=refresh_token,
                expires_in=7 * 24 * 60 * 60  # 7일 (초 단위)
            )
        )

    async def sign_in_with_email(self, login_data: LoginRequest) -> AuthResponse:
        """이메일 로그인 로직 (API 명세서 기준)"""
        db_user = await self.user_repo.get_user_by_email(login_data.email)
        if not db_user or not self.verify_password(login_data.password, db_user.hashed_password):
            raise AuthenticationError("이메일 또는 비밀번호가 올바르지 않습니다", ErrorCode.AUTH_INVALID_CREDENTIALS)

        # 토큰 데이터 생성
        token_data = {
            "sub": str(db_user.id),
            "email": db_user.email,
            "provider": db_user.provider
        }
        
        access_token = self.create_access_token(token_data)
        refresh_token = self.create_refresh_token(token_data)

        return AuthResponse(
            user=UserResponse(
                id=str(db_user.id),
                email=db_user.email,
                display_name=db_user.display_name,
                photo_url=db_user.photo_url,
                provider=db_user.provider,
                is_email_verified=db_user.is_email_verified,
                created_at=db_user.created_at
            ),
            tokens=TokenResponse(
                access_token=access_token,
                refresh_token=refresh_token,
                expires_in=7 * 24 * 60 * 60  # 7일 (초 단위)
            )
        )

    async def get_current_user(self, token: str) -> User:
        """토큰으로 현재 사용자 정보 가져오기 (API 명세서 기준)"""
        payload = self.verify_access_token(token)
        if not payload:
            raise InvalidTokenError("유효하지 않은 액세스 토큰입니다")

        user_id_str = payload.get("sub")
        if not user_id_str:
            raise InvalidTokenError("토큰에서 사용자 ID를 찾을 수 없습니다")
        
        try:
            user_id = uuid.UUID(user_id_str)
        except ValueError:
            raise InvalidTokenError("유효하지 않은 사용자 ID 형식입니다")

        db_user = await self.user_repo.get_user_by_id(user_id)
        if not db_user:
            raise AuthenticationError("사용자를 찾을 수 없습니다", ErrorCode.AUTH_USER_NOT_FOUND)
        
        return db_user

    async def update_user_profile(self, user_id: uuid.UUID, display_name: str = None, photo_url: str = None) -> UserResponse:
        """사용자 프로필 업데이트 (API 명세서 기준)"""
        db_user = await self.user_repo.get_user_by_id(user_id)
        if not db_user:
            raise AuthenticationError("사용자를 찾을 수 없습니다", ErrorCode.AUTH_USER_NOT_FOUND)

        # 업데이트할 필드들
        update_data = {}
        if display_name is not None:
            update_data["display_name"] = display_name
        if photo_url is not None:
            update_data["photo_url"] = photo_url

        if update_data:
            updated_user = await self.user_repo.update_user(user_id, **update_data)
            return UserResponse.model_validate(updated_user)
        
        return UserResponse.model_validate(db_user)
