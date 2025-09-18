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
        await conn.run_sync(Base.metadata.create_all)
    print("✅ 데이터베이스 테이블 초기화 완료")


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """앱 시작/종료 시 실행되는 코드"""
    print("🚀 HealthPlus API 서버가 시작되었습니다")
    await init_db()
    yield
    print("⛔ HealthPlus API 서버가 종료됩니다")

# --------------------------------------------------------------------------
# 1. v1 API를 위한 Sub-Application 생성
# --------------------------------------------------------------------------
v1_app = FastAPI(
    title="HealthPlus API v1",
    description="약물 복용 관리 애플리케이션 API - v1",
    version="1.0.0",
    docs_url="/docs" if settings.DEBUG else None,      # 경로는 /v1/docs가 됨
    redoc_url="/redoc" if settings.DEBUG else None,    # 경로는 /v1/redoc이 됨
)

# v1 라우터를 접두사 없이 포함
v1_app.include_router(api_router)

# v1 앱에 대한 예외 처리기
@v1_app.exception_handler(APIException)
async def api_exception_handler(request: Request, exc: APIException):
    """API 예외 처리"""
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "error_code": exc.error_code}
    )

# --------------------------------------------------------------------------
# 2. 전체를 감싸는 최상위(Root) Application 생성
# --------------------------------------------------------------------------
app = FastAPI(
    title="HealthPlus API",
    lifespan=lifespan,
    root_path=settings.ROOT_PATH,
)

# 최상위 앱에 CORS 미들웨어 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 특정 도메인만 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 최상위 앱에 공용 헬스 체크 엔드포인트 추가
@app.get("/health")
async def health_check():
    """헬스 체크 엔드포인트"""
    return {"status": "healthy", "message": "HealthPlus API is running"}


# 최상위 앱에 v1 Sub-Application을 /v1 경로로 마운트
app.mount("/v1", v1_app)

# --------------------------------------------------------------------------

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info" if settings.DEBUG else "warning",
    )