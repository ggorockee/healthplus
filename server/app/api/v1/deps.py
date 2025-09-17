import uuid
from typing import AsyncGenerator

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

# Repositories
from app.application.repositories.user_repository import IUserRepository
from app.application.repositories.medication_repository import IMedicationRepository
from app.infrastructure.repositories.user_repository import SQLAlchemyUserRepository
from app.infrastructure.repositories.medication_repository import SQLAlchemyMedicationRepository

# Services
from app.application.services.auth_service import AuthService
from app.application.services.medication_service import MedicationService

# Models and DB Session
from app.infrastructure.database.models.user import User
from app.infrastructure.database.session import get_db


security = HTTPBearer()

# --- User and Auth Dependencies ---

def get_user_repository(db: AsyncSession = Depends(get_db)) -> IUserRepository:
    """사용자 리포지토리 의존성 주입"""
    return SQLAlchemyUserRepository(db)


def get_auth_service(user_repo: IUserRepository = Depends(get_user_repository)) -> AuthService:
    """인증 서비스 의존성 주입"""
    return AuthService(user_repo)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    auth_service: AuthService = Depends(get_auth_service)
) -> User:
    """현재 로그인된 사용자의 ORM 모델을 반환하는 의존성"""
    token = credentials.credentials
    try:
        user = await auth_service.get_current_user(token)
        if not user.is_active:
            raise HTTPException(status_code=400, detail="비활성화된 계정입니다.")
        return user
    except HTTPException as http_exc:
        raise http_exc
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="유효하지 않은 토큰입니다.",
            headers={"WWW-Authenticate": "Bearer"},
        )


def get_current_user_id(current_user: User = Depends(get_current_user)) -> uuid.UUID:
    """현재 로그인된 사용자의 ID(UUID)를 반환하는 의존성"""
    return current_user.id


# --- Medication Dependencies ---

def get_medication_repository(db: AsyncSession = Depends(get_db)) -> IMedicationRepository:
    """약물 리포지토리 의존성 주입"""
    return SQLAlchemyMedicationRepository(db)


def get_medication_service(med_repo: IMedicationRepository = Depends(get_medication_repository)) -> MedicationService:
    """약물 서비스 의존성 주입"""
    return MedicationService(med_repo)
