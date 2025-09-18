import time
import uuid
from typing import Dict, Optional
from fastapi import Request, Response, HTTPException
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp

from app.core.config import settings
from app.core.error_codes import ErrorCode


class SecurityMiddleware(BaseHTTPMiddleware):
    """보안 미들웨어"""

    def __init__(self, app: ASGIApp):
        super().__init__(app)
        self.rate_limit_store: Dict[str, Dict] = {}
        self.blocked_ips: set = set()

    async def dispatch(self, request: Request, call_next):
        # 요청 시작 시간 기록
        start_time = time.time()
        
        # 클라이언트 IP 추출
        client_ip = self._get_client_ip(request)
        
        # 차단된 IP 확인
        if client_ip in self.blocked_ips:
            return JSONResponse(
                status_code=403,
                content={
                    "success": False,
                    "error": {
                        "code": ErrorCode.PERMISSION_DENIED,
                        "message": "접근이 차단된 IP입니다."
                    }
                }
            )
        
        # Rate Limiting 확인
        if not self._check_rate_limit(client_ip, request):
            return JSONResponse(
                status_code=429,
                content={
                    "success": False,
                    "error": {
                        "code": ErrorCode.SYS_RATE_LIMIT_EXCEEDED,
                        "message": "요청 한도를 초과했습니다. 잠시 후 다시 시도해주세요."
                    }
                }
            )
        
        # 보안 헤더 추가
        response = await call_next(request)
        
        # 응답 시간 계산
        process_time = time.time() - start_time
        
        # 보안 헤더 추가
        response.headers["X-Process-Time"] = str(process_time)
        response.headers["X-Request-ID"] = str(uuid.uuid4())
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        
        # CORS 헤더 (필요한 경우)
        if request.method == "OPTIONS":
            response.headers["Access-Control-Allow-Origin"] = "*"
            response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
            response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
        
        return response

    def _get_client_ip(self, request: Request) -> str:
        """클라이언트 IP 추출"""
        # X-Forwarded-For 헤더 확인 (프록시 환경)
        forwarded_for = request.headers.get("X-Forwarded-For")
        if forwarded_for:
            return forwarded_for.split(",")[0].strip()
        
        # X-Real-IP 헤더 확인
        real_ip = request.headers.get("X-Real-IP")
        if real_ip:
            return real_ip
        
        # 직접 연결
        return request.client.host if request.client else "unknown"

    def _check_rate_limit(self, client_ip: str, request: Request) -> bool:
        """Rate Limiting 확인"""
        current_time = time.time()
        window_size = 60  # 1분 윈도우
        max_requests = 100  # 최대 요청 수
        
        # IP별 요청 기록 초기화 또는 정리
        if client_ip not in self.rate_limit_store:
            self.rate_limit_store[client_ip] = {
                "requests": [],
                "last_cleanup": current_time
            }
        
        ip_data = self.rate_limit_store[client_ip]
        
        # 오래된 요청 기록 정리
        if current_time - ip_data["last_cleanup"] > window_size:
            ip_data["requests"] = [
                req_time for req_time in ip_data["requests"]
                if current_time - req_time < window_size
            ]
            ip_data["last_cleanup"] = current_time
        
        # 현재 요청 수 확인
        if len(ip_data["requests"]) >= max_requests:
            return False
        
        # 요청 기록 추가
        ip_data["requests"].append(current_time)
        
        return True

    def block_ip(self, ip: str):
        """IP 차단"""
        self.blocked_ips.add(ip)

    def unblock_ip(self, ip: str):
        """IP 차단 해제"""
        self.blocked_ips.discard(ip)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """요청 로깅 미들웨어"""

    async def dispatch(self, request: Request, call_next):
        # 요청 정보 로깅
        start_time = time.time()
        
        # 요청 로그
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {request.method} {request.url.path} - {request.client.host if request.client else 'unknown'}")
        
        # 응답 처리
        response = await call_next(request)
        
        # 응답 시간 계산
        process_time = time.time() - start_time
        
        # 응답 로그
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {response.status_code} - {process_time:.3f}s")
        
        return response


class ErrorHandlingMiddleware(BaseHTTPMiddleware):
    """에러 처리 미들웨어"""

    async def dispatch(self, request: Request, call_next):
        try:
            response = await call_next(request)
            return response
        except HTTPException as e:
            # FastAPI HTTPException은 그대로 전달
            raise e
        except Exception as e:
            # 예상치 못한 에러 처리
            print(f"Unexpected error: {str(e)}")
            return JSONResponse(
                status_code=500,
                content={
                    "success": False,
                    "error": {
                        "code": ErrorCode.SYS_INTERNAL_SERVER_ERROR,
                        "message": "서버 내부 오류가 발생했습니다.",
                        "details": str(e) if settings.APP_ENVIRONMENT == "development" else None
                    }
                }
            )
