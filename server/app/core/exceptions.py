from typing import Optional


class APIException(Exception):
    """기본 API 예외 클래스"""

    def __init__(
        self,
        detail: str = "Internal Server Error",
        status_code: int = 500,
        error_code: Optional[str] = None,
    ):
        self.detail = detail
        self.status_code = status_code
        self.error_code = error_code
        super().__init__(detail)


class AuthenticationError(APIException):
    """인증 오류"""

    def __init__(self, detail: str = "Authentication failed"):
        super().__init__(detail=detail, status_code=401, error_code="AUTH_FAILED")


class AuthorizationError(APIException):
    """권한 오류"""

    def __init__(self, detail: str = "Not authorized"):
        super().__init__(detail=detail, status_code=403, error_code="NOT_AUTHORIZED")


class ValidationError(APIException):
    """유효성 검사 오류"""

    def __init__(self, detail: str = "Validation failed"):
        super().__init__(detail=detail, status_code=422, error_code="VALIDATION_ERROR")


class NotFoundError(APIException):
    """리소스 찾기 실패"""

    def __init__(self, detail: str = "Resource not found"):
        super().__init__(detail=detail, status_code=404, error_code="NOT_FOUND")


class ConflictError(APIException):
    """충돌 오류"""

    def __init__(self, detail: str = "Resource conflict"):
        super().__init__(detail=detail, status_code=409, error_code="CONFLICT")


class ExternalServiceError(APIException):
    """외부 서비스 오류"""

    def __init__(self, detail: str = "External service error"):
        super().__init__(detail=detail, status_code=502, error_code="EXTERNAL_SERVICE_ERROR")