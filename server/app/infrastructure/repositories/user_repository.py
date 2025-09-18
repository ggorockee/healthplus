from typing import Optional
import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.application.repositories.user_repository import IUserRepository
from app.infrastructure.database.models.user import User


class SQLAlchemyUserRepository(IUserRepository):
    """
    SQLAlchemy를 사용한 사용자 리포지토리의 구체적인 구현체
    """

    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_user_by_id(self, user_id: uuid.UUID) -> Optional[User]:
        """ID로 사용자를 조회합니다."""
        result = await self.session.get(User, user_id)
        return result

    async def get_user_by_email(self, email: str) -> Optional[User]:
        """이메일로 사용자를 조회합니다."""
        stmt = select(User).where(User.email == email)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

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
        db_user = User(
            email=email,
            hashed_password=hashed_password,
            display_name=display_name,
            photo_url=photo_url,
            provider=provider,
            is_email_verified=is_email_verified
        )
        self.session.add(db_user)
        await self.session.commit()
        await self.session.refresh(db_user)
        return db_user

    async def update_user(self, user_id: uuid.UUID, **update_data) -> Optional[User]:
        """사용자 정보를 업데이트합니다."""
        user = await self.get_user_by_id(user_id)
        if not user:
            return None

        for key, value in update_data.items():
            if hasattr(user, key) and value is not None:
                setattr(user, key, value)

        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user
