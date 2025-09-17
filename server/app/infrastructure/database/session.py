from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import declarative_base

from app.core.config import settings

# 비동기 SQLAlchemy 엔진 생성
# connect_args={"check_same_thread": False}는 SQLite 사용 시에만 필요합니다.
# PostgreSQL을 사용하므로 해당 인자는 제외합니다.
async_engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,  # DEBUG 모드일 때 SQL 쿼리 로그 출력
    pool_pre_ping=True,
)

# 비동기 세션 생성기
AsyncSessionLocal = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False,
)

# 모든 ORM 모델이 상속받을 기본 클래스
Base = declarative_base()


async def get_db() -> AsyncSession:
    """
    FastAPI 의존성 주입을 위한 데이터베이스 세션 생성기입니다.

    - API 요청이 시작될 때 세션을 생성합니다.
    - 요청 처리 중에는 이 세션을 사용합니다.
    - 요청이 끝나면 세션을 자동으로 닫아 리소스를 반환합니다.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
