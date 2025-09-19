from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import declarative_base

from app.core.config import settings

# 엔진과 세션메이커를 None으로 초기화
async_engine = None
AsyncSessionLocal = None

Base = declarative_base()

def create_db_engine_and_session(db_url: str):
    """데이터베이스 엔진과 세션을 생성하고 초기화합니다."""
    global async_engine, AsyncSessionLocal

    async_engine = create_async_engine(
        db_url,
        echo=settings.DEBUG,
        pool_pre_ping=True,
        connect_args={"statement_cache_size": 0} if "postgresql" in db_url else {}
    )

    AsyncSessionLocal = async_sessionmaker(
        bind=async_engine,
        class_=AsyncSession,
        autocommit=False,
        autoflush=False,
        expire_on_commit=False,
    )

async def get_db() -> AsyncSession:
    """FastAPI 의존성 주입을 위한 데이터베이스 세션 생성기입니다."""
    if AsyncSessionLocal is None:
        raise RuntimeError("Database session not initialized. Call create_db_engine_and_session() first.")
    
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()