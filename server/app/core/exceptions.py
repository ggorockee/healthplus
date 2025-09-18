from typing import Optional
from .error_codes import ErrorCode, ErrorMessage


class APIException(Exception):
    """기본 API 예외 클래스 (API 명세서 기준)"""

    def __init__(
        self,
        detail: str = "Internal Server Error",
        status_code: int = 500,
        error_code: Optional[ErrorCode] = None,
        field: Optional[str] = None,
    ):
        self.detail = detail
        self.status_code = status_code
        self.error_code = error_code or ErrorCode.SYS_INTERNAL_SERVER_ERROR
        self.field = field
        super().__init__(detail)


class AuthenticationError(APIException):
    """인증 오류 (API 명세서 기준)"""

    def __init__(
        self, 
        detail: str = None, 
        error_code: ErrorCode = ErrorCode.AUTH_INVALID_CREDENTIALS,
        field: Optional[str] = None
    ):
        if detail is None:
            detail = ErrorMessage.get_message(error_code)
        super().__init__(detail=detail, status_code=401, error_code=error_code, field=field)


class AuthorizationError(APIException):
    """권한 오류 (API 명세서 기준)"""

    def __init__(
        self, 
        detail: str = None, 
        error_code: ErrorCode = ErrorCode.PERMISSION_DENIED,
        field: Optional[str] = None
    ):
        if detail is None:
            detail = ErrorMessage.get_message(error_code)
        super().__init__(detail=detail, status_code=403, error_code=error_code, field=field)


class ValidationError(APIException):
    """유효성 검사 오류 (API 명세서 기준)"""

    def __init__(
        self, 
        detail: str = None, 
        error_code: ErrorCode = ErrorCode.VALIDATION_REQUIRED_FIELD,
        field: Optional[str] = None
    ):
        if detail is None:
            detail = ErrorMessage.get_message(error_code)
        super().__init__(detail=detail, status_code=422, error_code=error_code, field=field)


class NotFoundError(APIException):
    """리소스 찾기 실패 (API 명세서 기준)"""

    def __init__(
        self, 
        detail: str = None, 
        error_code: ErrorCode = ErrorCode.MED_MEDICATION_NOT_FOUND,
        field: Optional[str] = None
    ):
        if detail is None:
            detail = ErrorMessage.get_message(error_code)
        super().__init__(detail=detail, status_code=404, error_code=error_code, field=field)


class ConflictError(APIException):
    """충돌 오류 (API 명세서 기준)"""

    def __init__(
        self, 
        detail: str = None, 
        error_code: ErrorCode = ErrorCode.MED_DUPLICATE_MEDICATION,
        field: Optional[str] = None
    ):
        if detail is None:
            detail = ErrorMessage.get_message(error_code)
        super().__init__(detail=detail, status_code=409, error_code=error_code, field=field)


class ExternalServiceError(APIException):
    """외부 서비스 오류 (API 명세서 기준)"""

    def __init__(
        self, 
        detail: str = None, 
        error_code: ErrorCode = ErrorCode.SYS_EXTERNAL_SERVICE_ERROR,
        field: Optional[str] = None
    ):
        if detail is None:
            detail = ErrorMessage.get_message(error_code)
        super().__init__(detail=detail, status_code=502, error_code=error_code, field=field)


# 편의를 위한 특화된 예외 클래스들

class TokenExpiredError(AuthenticationError):
    """토큰 만료 오류"""
    def __init__(self, detail: str = None):
        super().__init__(detail, ErrorCode.AUTH_TOKEN_EXPIRED)


class InvalidTokenError(AuthenticationError):
    """유효하지 않은 토큰 오류"""
    def __init__(self, detail: str = None):
        super().__init__(detail, ErrorCode.AUTH_TOKEN_INVALID)


class UserNotFoundError(NotFoundError):
    """사용자 찾기 실패"""
    def __init__(self, detail: str = None):
        super().__init__(detail, ErrorCode.AUTH_USER_NOT_FOUND)


class MedicationNotFoundError(NotFoundError):
    """약물 찾기 실패"""
    def __init__(self, detail: str = None):
        super().__init__(detail, ErrorCode.MED_MEDICATION_NOT_FOUND)


class LogNotFoundError(NotFoundError):
    """복용 로그 찾기 실패"""
    def __init__(self, detail: str = None):
        super().__init__(detail, ErrorCode.LOG_LOG_NOT_FOUND)


class EmailAlreadyExistsError(ConflictError):
    """이메일 중복 오류"""
    def __init__(self, detail: str = None):
        super().__init__(detail, ErrorCode.AUTH_EMAIL_ALREADY_EXISTS)


class DuplicateMedicationError(ConflictError):
    """중복 약물 오류"""
    def __init__(self, detail: str = None):
        super().__init__(detail, ErrorCode.MED_DUPLICATE_MEDICATION)