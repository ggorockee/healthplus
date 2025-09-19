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
from app.core.middleware import SecurityMiddleware, RequestLoggingMiddleware, ErrorHandlingMiddleware

# DB 초기화 관련 임포트 수정
from app.infrastructure.database.session import Base, create_db_engine_and_session
from app.infrastructure.database.models import user, medications, reminders


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """앱 시작/종료 시 실행되는 코드"""
    print("🚀 HealthPlus API 서버가 시작되었습니다")
    # 앱 시작 시 DB 엔진 및 세션 생성
    create_db_engine_and_session(settings.DATABASE_URL)
    yield
    print("⛔ HealthPlus API 서버가 종료됩니다")

# ... (이하 코드는 이전과 동일) ...

# --------------------------------------------------------------------------
# 1. v1 API를 위한 Sub-Application 생성
# --------------------------------------------------------------------------
v1_app = FastAPI(
    title="OneDayPillo API v1",
    description="""
    ## OneDayPillo API v1
    
    약물 복용 관리 애플리케이션을 위한 RESTful API입니다.
    
    ### 주요 기능
    - **인증 시스템**: JWT 기반 사용자 인증 및 소셜 로그인
    - **약물 관리**: 약물 등록, 수정, 삭제, 조회
    - **복용 로그**: 복용 기록 생성 및 관리
    - **통계 분석**: 복용 준수율 및 통계 제공
    - **알림 시스템**: 약물 복용 알림 설정 및 전송
    - **시스템 모니터링**: 헬스체크 및 시스템 상태 확인
    
    ### 인증
    대부분의 API는 JWT 토큰을 통한 인증이 필요합니다.
    Authorization 헤더에 `Bearer {access_token}` 형식으로 토큰을 포함해주세요.
    
    ### 응답 형식
    모든 API는 표준화된 응답 형식을 사용합니다:
    
    **성공 응답:**
    ```json
    {
        "success": true,
        "data": { ... },
        "message": "성공 메시지",
        "timestamp": "2024-01-01T00:00:00Z"
    }
    ```
    
    **에러 응답:**
    ```json
    {
        "success": false,
        "error": {
            "code": "ERROR_CODE",
            "message": "에러 메시지",
            "details": "상세 정보 (선택사항)",
            "field": "문제가 된 필드 (선택사항)"
        },
        "timestamp": "2024-01-01T00:00:00Z"
    }
    ```
    """,
    version="1.0.0",
    docs_url="/docs" if settings.DEBUG else None,      # 최종 경로: <ROOT_PATH>/v1/docs
    redoc_url="/redoc" if settings.DEBUG else None,    # 최종 경로: <ROOT_PATH>/v1/redoc
    contact={
        "name": "OneDayPillo API Support",
        "email": "support@onedaypillo.com",
    },
    license_info={
        "name": "MIT License",
        "url": "https://opensource.org/licenses/MIT",
    },
)

v1_app.include_router(api_router)

@v1_app.exception_handler(APIException)
async def api_exception_handler(request: Request, exc: APIException):
    from app.application.schemas.common import APIErrorResponse, ErrorDetail
    
    error_response = APIErrorResponse(
        error=ErrorDetail(
            code=exc.error_code.value if hasattr(exc.error_code, 'value') else str(exc.error_code),
            message=exc.detail,
            field=exc.field
        )
    )
    
    return JSONResponse(
        status_code=exc.status_code,
        content=error_response.model_dump()
    )

# --------------------------------------------------------------------------
# 2. 실제 비즈니스 앱(inner)을 만들고, 필요 시 ROOT_PATH로 마운트
# --------------------------------------------------------------------------
inner_app = FastAPI(
    title="HealthPlus API",
    lifespan=lifespan,
)

inner_app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if settings.APP_ENVIRONMENT == "production":
    inner_app.add_middleware(SecurityMiddleware)

if settings.DEBUG:
    inner_app.add_middleware(RequestLoggingMiddleware)

inner_app.add_middleware(ErrorHandlingMiddleware)

@inner_app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "HealthPlus API is running"}

inner_app.mount("/v1", v1_app)

# --------------------------------------------------------------------------
# 3. 외부 노출용 최상위 앱(root). ROOT_PATH가 있으면 그 경로에 inner_app을 마운트
# --------------------------------------------------------------------------
if settings.ROOT_PATH:
    app = FastAPI()
    app.mount(settings.ROOT_PATH, inner_app)
else:
    app = inner_app

# --------------------------------------------------------------------------

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info" if settings.DEBUG else "warning",
    )
