import uuid
from datetime import datetime, timedelta
from typing import Optional

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings
from app.core.exceptions import AuthenticationError, ValidationError
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
        """액세스 토큰 생성"""
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode.update({"exp": expire})

        encoded_jwt = jwt.encode(
            to_encode,
            settings.JWT_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM
        )
        return encoded_jwt

    def verify_token(self, token: str) -> Optional[dict]:
        """토큰 검증"""
        try:
            payload = jwt.decode(
                token,
                settings.JWT_SECRET_KEY,
                algorithms=[settings.JWT_ALGORITHM]
            )
            return payload
        except JWTError:
            return None

    async def sign_up_with_email(self, signup_data: SignUpRequest) -> AuthResponse:
        """이메일 회원가입 로직"""
        existing_user = await self.user_repo.get_user_by_email(signup_data.email)
        if existing_user:
            raise ValidationError("이미 등록된 이메일입니다")

        hashed_password = self.get_password_hash(signup_data.password)
        
        db_user = await self.user_repo.create_user(
            email=signup_data.email,
            hashed_password=hashed_password,
            name=signup_data.name
        )

        access_token = self.create_access_token(data={"sub": str(db_user.id)})
        
        return AuthResponse(
            user=UserResponse.model_validate(db_user),
            token=TokenResponse(
                access_token=access_token,
                expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
            )
        )

    async def sign_in_with_email(self, login_data: LoginRequest) -> AuthResponse:
        """이메일 로그인 로직"""
        db_user = await self.user_repo.get_user_by_email(login_data.email)
        if not db_user or not self.verify_password(login_data.password, db_user.hashed_password):
            raise AuthenticationError("이메일 또는 비밀번호가 올바르지 않습니다")

        access_token = self.create_access_token(data={"sub": str(db_user.id)})

        return AuthResponse(
            user=UserResponse.model_validate(db_user),
            token=TokenResponse(
                access_token=access_token,
                expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
            )
        )

    async def get_current_user(self, token: str) -> User:
        """토큰으로 현재 사용자 정보 가져오기"""
        payload = self.verify_token(token)
        if not payload:
            raise AuthenticationError("유효하지 않은 토큰입니다")

        user_id_str = payload.get("sub")
        if not user_id_str:
            raise AuthenticationError("토큰에서 사용자 ID를 찾을 수 없습니다")
        
        try:
            user_id = uuid.UUID(user_id_str)
        except ValueError:
            raise AuthenticationError("유효하지 않은 사용자 ID 형식입니다")

        db_user = await self.user_repo.get_user_by_id(user_id)
        if not db_user:
            raise AuthenticationError("사용자를 찾을 수 없습니다")
        
        return db_user
