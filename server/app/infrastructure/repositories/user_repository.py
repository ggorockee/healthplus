from typing import Optional
import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.application.repositories.user_repository import IUserRepository
from app.infrastructure.database.models.user import User
from app.application.schemas.auth import UserProfileUpdate


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

    async def create_user(self, email: str, hashed_password: str, name: Optional[str]) -> User:
        """새로운 사용자를 생성합니다."""
        db_user = User(
            email=email,
            hashed_password=hashed_password,
            name=name
        )
        self.session.add(db_user)
        await self.session.commit()
        await self.session.refresh(db_user)
        return db_user

    async def update_user(self, user_id: uuid.UUID, update_data: UserProfileUpdate) -> Optional[User]:
        """사용자 정보를 업데이트합니다."""
        user = await self.get_user_by_id(user_id)
        if not user:
            return None

        update_values = update_data.model_dump(exclude_unset=True)
        for key, value in update_values.items():
            setattr(user, key, value)

        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user
