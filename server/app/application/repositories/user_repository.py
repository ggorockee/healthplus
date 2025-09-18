from abc import ABC, abstractmethod
from typing import Optional
import uuid

from app.infrastructure.database.models.user import User


class IUserRepository(ABC):
    """
    사용자 리포지토리 인터페이스 (추상 클래스)
    AuthService는 이 인터페이스에 의존하며, 실제 구현에는 관심이 없습니다.
    """

    @abstractmethod
    async def get_user_by_id(self, user_id: uuid.UUID) -> Optional[User]:
        """ID로 사용자를 조회합니다."""
        raise NotImplementedError

    @abstractmethod
    async def get_user_by_email(self, email: str) -> Optional[User]:
        """이메일로 사용자를 조회합니다."""
        raise NotImplementedError

    @abstractmethod
    async def create_user(
        self,
        email: str,
        hashed_password: str = None,
        display_name: str = None,
        photo_url: str = None,
        provider: str = "email",
        is_email_verified: bool = False
    ) -> User:
        """새로운 사용자를 생성합니다."""
        raise NotImplementedError

    @abstractmethod
    async def update_user(self, user_id: uuid.UUID, **update_data) -> Optional[User]:
        """사용자 정보를 업데이트합니다."""
        raise NotImplementedError
