"""
OneDayPillo API 에러 코드 체계
API 명세서에 맞는 에러 코드 정의
"""

from enum import Enum


class ErrorCode(str, Enum):
    """API 에러 코드 열거형"""
    
    # 인증 관련 (AUTH_*)
    AUTH_INVALID_CREDENTIALS = "AUTH_INVALID_CREDENTIALS"
    AUTH_TOKEN_EXPIRED = "AUTH_TOKEN_EXPIRED"
    AUTH_TOKEN_INVALID = "AUTH_TOKEN_INVALID"
    AUTH_USER_NOT_FOUND = "AUTH_USER_NOT_FOUND"
    AUTH_EMAIL_ALREADY_EXISTS = "AUTH_EMAIL_ALREADY_EXISTS"
    AUTH_WEAK_PASSWORD = "AUTH_WEAK_PASSWORD"
    AUTH_SOCIAL_LOGIN_FAILED = "AUTH_SOCIAL_LOGIN_FAILED"
    AUTH_REFRESH_TOKEN_INVALID = "AUTH_REFRESH_TOKEN_INVALID"
    AUTH_EMAIL_NOT_VERIFIED = "AUTH_EMAIL_NOT_VERIFIED"
    
    # 약물 관리 관련 (MED_*)
    MED_MEDICATION_NOT_FOUND = "MED_MEDICATION_NOT_FOUND"
    MED_INVALID_DOSAGE = "MED_INVALID_DOSAGE"
    MED_INVALID_TIME = "MED_INVALID_TIME"
    MED_DUPLICATE_MEDICATION = "MED_DUPLICATE_MEDICATION"
    MED_INVALID_REPEAT_DAYS = "MED_INVALID_REPEAT_DAYS"
    MED_INVALID_NOTIFICATION_TIME = "MED_INVALID_NOTIFICATION_TIME"
    
    # 복용 로그 관련 (LOG_*)
    LOG_LOG_NOT_FOUND = "LOG_LOG_NOT_FOUND"
    LOG_ALREADY_TAKEN = "LOG_ALREADY_TAKEN"
    LOG_INVALID_DATE = "LOG_INVALID_DATE"
    LOG_INVALID_MEDICATION_ID = "LOG_INVALID_MEDICATION_ID"
    LOG_DUPLICATE_LOG = "LOG_DUPLICATE_LOG"
    
    # 통계 관련 (STATS_*)
    STATS_INVALID_PERIOD = "STATS_INVALID_PERIOD"
    STATS_NO_DATA_FOUND = "STATS_NO_DATA_FOUND"
    STATS_INVALID_DATE_RANGE = "STATS_INVALID_DATE_RANGE"
    
    # 알림 관련 (REMINDER_*)
    REMINDER_NOT_FOUND = "REMINDER_NOT_FOUND"
    REMINDER_INVALID_TIME = "REMINDER_INVALID_TIME"
    REMINDER_DUPLICATE = "REMINDER_DUPLICATE"
    REMINDER_NOTIFICATION_FAILED = "REMINDER_NOTIFICATION_FAILED"
    
    # 시스템 관련 (SYS_*)
    SYS_DATABASE_ERROR = "SYS_DATABASE_ERROR"
    SYS_EXTERNAL_SERVICE_ERROR = "SYS_EXTERNAL_SERVICE_ERROR"
    SYS_RATE_LIMIT_EXCEEDED = "SYS_RATE_LIMIT_EXCEEDED"
    SYS_INTERNAL_SERVER_ERROR = "SYS_INTERNAL_SERVER_ERROR"
    SYS_SERVICE_UNAVAILABLE = "SYS_SERVICE_UNAVAILABLE"
    
    # 유효성 검사 관련 (VALIDATION_*)
    VALIDATION_REQUIRED_FIELD = "VALIDATION_REQUIRED_FIELD"
    VALIDATION_INVALID_FORMAT = "VALIDATION_INVALID_FORMAT"
    VALIDATION_INVALID_VALUE = "VALIDATION_INVALID_VALUE"
    VALIDATION_FIELD_TOO_LONG = "VALIDATION_FIELD_TOO_LONG"
    VALIDATION_FIELD_TOO_SHORT = "VALIDATION_FIELD_TOO_SHORT"
    
    # 권한 관련 (PERMISSION_*)
    PERMISSION_DENIED = "PERMISSION_DENIED"
    PERMISSION_INSUFFICIENT = "PERMISSION_INSUFFICIENT"
    PERMISSION_RESOURCE_NOT_OWNED = "PERMISSION_RESOURCE_NOT_OWNED"


class ErrorMessage:
    """에러 메시지 매핑"""
    
    MESSAGES = {
        # 인증 관련
        ErrorCode.AUTH_INVALID_CREDENTIALS: "잘못된 인증 정보입니다.",
        ErrorCode.AUTH_TOKEN_EXPIRED: "토큰이 만료되었습니다.",
        ErrorCode.AUTH_TOKEN_INVALID: "유효하지 않은 토큰입니다.",
        ErrorCode.AUTH_USER_NOT_FOUND: "사용자를 찾을 수 없습니다.",
        ErrorCode.AUTH_EMAIL_ALREADY_EXISTS: "이미 존재하는 이메일입니다.",
        ErrorCode.AUTH_WEAK_PASSWORD: "비밀번호가 너무 약합니다.",
        ErrorCode.AUTH_SOCIAL_LOGIN_FAILED: "소셜 로그인에 실패했습니다.",
        ErrorCode.AUTH_REFRESH_TOKEN_INVALID: "유효하지 않은 리프레시 토큰입니다.",
        ErrorCode.AUTH_EMAIL_NOT_VERIFIED: "이메일 인증이 필요합니다.",
        
        # 약물 관리 관련
        ErrorCode.MED_MEDICATION_NOT_FOUND: "약물을 찾을 수 없습니다.",
        ErrorCode.MED_INVALID_DOSAGE: "잘못된 복용량입니다.",
        ErrorCode.MED_INVALID_TIME: "잘못된 시간 형식입니다.",
        ErrorCode.MED_DUPLICATE_MEDICATION: "중복된 약물입니다.",
        ErrorCode.MED_INVALID_REPEAT_DAYS: "잘못된 반복 요일입니다.",
        ErrorCode.MED_INVALID_NOTIFICATION_TIME: "잘못된 알림 시간입니다.",
        
        # 복용 로그 관련
        ErrorCode.LOG_LOG_NOT_FOUND: "복용 로그를 찾을 수 없습니다.",
        ErrorCode.LOG_ALREADY_TAKEN: "이미 복용 기록이 있습니다.",
        ErrorCode.LOG_INVALID_DATE: "잘못된 날짜입니다.",
        ErrorCode.LOG_INVALID_MEDICATION_ID: "잘못된 약물 ID입니다.",
        ErrorCode.LOG_DUPLICATE_LOG: "중복된 복용 로그입니다.",
        
        # 통계 관련
        ErrorCode.STATS_INVALID_PERIOD: "잘못된 기간입니다.",
        ErrorCode.STATS_NO_DATA_FOUND: "데이터를 찾을 수 없습니다.",
        ErrorCode.STATS_INVALID_DATE_RANGE: "잘못된 날짜 범위입니다.",
        
        # 알림 관련
        ErrorCode.REMINDER_NOT_FOUND: "알림 설정을 찾을 수 없습니다.",
        ErrorCode.REMINDER_INVALID_TIME: "잘못된 알림 시간입니다.",
        ErrorCode.REMINDER_DUPLICATE: "중복된 알림 설정입니다.",
        ErrorCode.REMINDER_NOTIFICATION_FAILED: "알림 전송에 실패했습니다.",
        
        # 시스템 관련
        ErrorCode.SYS_DATABASE_ERROR: "데이터베이스 오류가 발생했습니다.",
        ErrorCode.SYS_EXTERNAL_SERVICE_ERROR: "외부 서비스 오류가 발생했습니다.",
        ErrorCode.SYS_RATE_LIMIT_EXCEEDED: "요청 한도를 초과했습니다.",
        ErrorCode.SYS_INTERNAL_SERVER_ERROR: "서버 내부 오류가 발생했습니다.",
        ErrorCode.SYS_SERVICE_UNAVAILABLE: "서비스를 사용할 수 없습니다.",
        
        # 유효성 검사 관련
        ErrorCode.VALIDATION_REQUIRED_FIELD: "필수 필드가 누락되었습니다.",
        ErrorCode.VALIDATION_INVALID_FORMAT: "잘못된 형식입니다.",
        ErrorCode.VALIDATION_INVALID_VALUE: "잘못된 값입니다.",
        ErrorCode.VALIDATION_FIELD_TOO_LONG: "필드가 너무 깁니다.",
        ErrorCode.VALIDATION_FIELD_TOO_SHORT: "필드가 너무 짧습니다.",
        
        # 권한 관련
        ErrorCode.PERMISSION_DENIED: "권한이 없습니다.",
        ErrorCode.PERMISSION_INSUFFICIENT: "권한이 부족합니다.",
        ErrorCode.PERMISSION_RESOURCE_NOT_OWNED: "소유하지 않은 리소스입니다.",
    }
    
    @classmethod
    def get_message(cls, error_code: ErrorCode) -> str:
        """에러 코드에 해당하는 메시지를 반환"""
        return cls.MESSAGES.get(error_code, "알 수 없는 오류가 발생했습니다.")
