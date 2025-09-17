import asyncio
from contextlib import asynccontextmanager
from typing import AsyncGenerator

import uvicorn
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.api.v1.router import api_router
from app.core.exceptions import APIException

# --- DB 초기화 관련 임포트 ---
from app.infrastructure.database.session import async_engine, Base
# 모든 모델을 Base에 등록하기 위해 임포트합니다.
from app.infrastructure.database.models import user, medications
# --------------------------


async def init_db():
    """애플리케이션 시작 시 데이터베이스 테이블을 생성합니다."""
    async with async_engine.begin() as conn:
        # 기존 테이블을 삭제하고 다시 생성하려면 아래 주석을 해제하세요.
        # await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    print("✅ 데이터베이스 테이블 초기화 완료")


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """앱 시작/종료 시 실행되는 코드"""
    # 애플리케이션 시작 시
    await init_db()
    print("🚀 HealthPlus API 서버가 시작되었습니다")

    yield

    # 애플리케이션 종료 시
    print("⛔ HealthPlus API 서버가 종료됩니다")


app = FastAPI(
    title="HealthPlus API",
    description="약물 복용 관리 애플리케이션 API",
    version="1.0.0",
    docs_url="/v1/docs" if settings.DEBUG else None,
    redoc_url="/v1/redoc" if settings.DEBUG else None,
    lifespan=lifespan,
)

# CORS 미들웨어 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 특정 도메인만 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(APIException)
async def api_exception_handler(request: Request, exc: APIException):
    """API 예외 처리"""
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "error_code": exc.error_code}
    )


@app.get("/health")
async def health_check():
    """헬스 체크 엔드포인트"""
    return {"status": "healthy", "message": "HealthPlus API is running"}


# API 라우터 등록
app.include_router(api_router, prefix="/v1")


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info" if settings.DEBUG else "warning",
    )
