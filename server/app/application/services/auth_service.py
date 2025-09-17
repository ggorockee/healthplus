import asyncio
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from supabase import Client

from app.core.config import settings
from app.core.database import get_supabase, get_service_supabase
from app.core.exceptions import AuthenticationError, ValidationError
from app.schemas.auth import LoginRequest, SignUpRequest, UserResponse, TokenResponse


class AuthService:
    """인증 서비스"""

    def __init__(self):
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
        expire = datetime.utcnow() + timedelta(hours=settings.JWT_EXPIRY_HOURS)
        to_encode.update({"exp": expire})

        encoded_jwt = jwt.encode(
            to_encode,
            settings.JWT_SECRET,
            algorithm=settings.JWT_ALGORITHM
        )
        return encoded_jwt

    def verify_token(self, token: str) -> Optional[dict]:
        """토큰 검증"""
        try:
            payload = jwt.decode(
                token,
                settings.JWT_SECRET,
                algorithms=[settings.JWT_ALGORITHM]
            )
            return payload
        except JWTError:
            return None

    async def sign_up_with_email(self, signup_data: SignUpRequest) -> dict:
        """이메일 회원가입"""
        try:
            client = get_supabase()

            # Supabase 회원가입
            response = await asyncio.get_event_loop().run_in_executor(
                None,
                lambda: client.auth.sign_up({
                    "email": signup_data.email,
                    "password": signup_data.password,
                    "options": {
                        "data": {
                            "name": signup_data.name,
                            "login_method": "email"
                        }
                    }
                })
            )

            if response.user:
                # 사용자 프로필 테이블에 추가 정보 저장
                await self._create_user_profile(
                    user_id=response.user.id,
                    email=response.user.email,
                    name=signup_data.name,
                    login_method="email"
                )

                return {
                    "user": UserResponse(
                        id=response.user.id,
                        email=response.user.email,
                        name=signup_data.name,
                        login_method="email",
                        created_at=datetime.utcnow(),
                        is_email_verified=response.user.email_confirmed_at is not None
                    ),
                    "token": TokenResponse(
                        access_token=self.create_access_token({"sub": response.user.id}),
                        expires_in=settings.JWT_EXPIRY_HOURS * 3600
                    )
                }
            else:
                raise AuthenticationError("회원가입에 실패했습니다")

        except Exception as e:
            if "already been registered" in str(e):
                raise ValidationError("이미 등록된 이메일입니다")
            raise AuthenticationError(f"회원가입 실패: {str(e)}")

    async def sign_in_with_email(self, login_data: LoginRequest) -> dict:
        """이메일 로그인"""
        try:
            client = get_supabase()

            response = await asyncio.get_event_loop().run_in_executor(
                None,
                lambda: client.auth.sign_in_with_password({
                    "email": login_data.email,
                    "password": login_data.password
                })
            )

            if response.user:
                # 사용자 프로필 정보 가져오기
                profile = await self._get_user_profile(response.user.id)

                return {
                    "user": UserResponse(
                        id=response.user.id,
                        email=response.user.email,
                        name=profile.get("name"),
                        profile_image_url=profile.get("profile_image_url"),
                        login_method=profile.get("login_method", "email"),
                        created_at=datetime.fromisoformat(
                            response.user.created_at.replace("Z", "+00:00")
                        ),
                        is_email_verified=response.user.email_confirmed_at is not None
                    ),
                    "token": TokenResponse(
                        access_token=self.create_access_token({"sub": response.user.id}),
                        expires_in=settings.JWT_EXPIRY_HOURS * 3600
                    )
                }
            else:
                raise AuthenticationError("로그인에 실패했습니다")

        except Exception as e:
            if "Invalid login credentials" in str(e):
                raise AuthenticationError("이메일 또는 비밀번호가 올바르지 않습니다")
            raise AuthenticationError(f"로그인 실패: {str(e)}")

    async def get_current_user(self, token: str) -> UserResponse:
        """현재 사용자 정보 가져오기"""
        payload = self.verify_token(token)
        if not payload:
            raise AuthenticationError("유효하지 않은 토큰입니다")

        user_id = payload.get("sub")
        if not user_id:
            raise AuthenticationError("토큰에서 사용자 ID를 찾을 수 없습니다")

        client = get_supabase()

        # Supabase에서 사용자 정보 가져오기
        try:
            response = await asyncio.get_event_loop().run_in_executor(
                None,
                lambda: client.auth.get_user()
            )

            if response.user:
                profile = await self._get_user_profile(user_id)

                return UserResponse(
                    id=response.user.id,
                    email=response.user.email,
                    name=profile.get("name"),
                    profile_image_url=profile.get("profile_image_url"),
                    login_method=profile.get("login_method", "email"),
                    created_at=datetime.fromisoformat(
                        response.user.created_at.replace("Z", "+00:00")
                    ),
                    is_email_verified=response.user.email_confirmed_at is not None
                )
            else:
                raise AuthenticationError("사용자를 찾을 수 없습니다")

        except Exception as e:
            raise AuthenticationError(f"사용자 정보 조회 실패: {str(e)}")

    async def _create_user_profile(
        self,
        user_id: str,
        email: str,
        name: Optional[str],
        login_method: str
    ):
        """사용자 프로필 생성"""
        client = get_service_supabase()

        await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("user_profiles").insert({
                "user_id": user_id,
                "email": email,
                "name": name,
                "login_method": login_method,
                "created_at": datetime.utcnow().isoformat()
            }).execute()
        )

    async def _get_user_profile(self, user_id: str) -> dict:
        """사용자 프로필 가져오기"""
        client = get_service_supabase()

        response = await asyncio.get_event_loop().run_in_executor(
            None,
            lambda: client.table("user_profiles").select("*").eq("user_id", user_id).single().execute()
        )

        return response.data if response.data else {}


auth_service = AuthService()