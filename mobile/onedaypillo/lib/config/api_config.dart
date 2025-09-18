/// API 설정 관리 클래스
class ApiConfig {
  static const String _defaultBaseUrl = 'https://api.onedaypillo.com';
  static const String _defaultApiVersion = 'v1';
  static const int _defaultTimeout = 30000; // 30초
  
  // 환경별 설정
  static const Map<String, String> _environments = {
    'dev': 'http://localhost:8000',
    'prod': 'https://api.onedaypillo.com',
  };
  
  /// 현재 환경 (기본값: dev)
  static String get environment => 
      const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
  
  /// API Base URL
  static String get baseUrl => _environments[environment] ?? _defaultBaseUrl;
  
  /// API 버전
  static String get apiVersion => _defaultApiVersion;
  
  /// 전체 API URL
  static String get apiUrl => '$baseUrl/$apiVersion';
  
  /// 요청 타임아웃 (밀리초)
  static int get timeout => _defaultTimeout;
  
  /// JWT 토큰 만료 시간 (일)
  static int get jwtExpiresIn => 7;
  
  /// Refresh 토큰 만료 시간 (일)
  static int get refreshExpiresIn => 30;
  
  /// 디버그 모드 여부
  static bool get isDebug => environment == 'dev';
  
  /// 로깅 활성화 여부
  static bool get enableLogging => isDebug;
}

/// API 엔드포인트 상수
class ApiEndpoints {
  // 인증 관련
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refresh = '$auth/refresh';
  static const String logout = '$auth/logout';
  static const String profile = '$auth/profile';
  
  // 약물 관리
  static const String medicine = '/medicine';
  static const String medicineToday = '$medicine/today';
  
  // 복용 로그
  static const String medicationLog = '/medication-log';
  
  // 통계 및 분석
  static const String analytics = '/analytics';
  static const String medicationStats = '$analytics/medication-stats';
  static const String complianceRate = '$analytics/compliance-rate';
  static const String history = '$analytics/history';
  
  // 알림 및 리마인더
  static const String reminders = '/reminders';
  
  // 시스템
  static const String system = '/system';
  static const String health = '$system/health';
  static const String version = '$system/version';
}

/// API 에러 코드
class ApiErrorCodes {
  // 인증 관련
  static const String authInvalidCredentials = 'AUTH_INVALID_CREDENTIALS';
  static const String authTokenExpired = 'AUTH_TOKEN_EXPIRED';
  static const String authTokenInvalid = 'AUTH_TOKEN_INVALID';
  static const String authUserNotFound = 'AUTH_USER_NOT_FOUND';
  static const String authEmailAlreadyExists = 'AUTH_EMAIL_ALREADY_EXISTS';
  static const String authWeakPassword = 'AUTH_WEAK_PASSWORD';
  
  // 약물 관리 관련
  static const String medMedicationNotFound = 'MED_MEDICATION_NOT_FOUND';
  static const String medInvalidDosage = 'MED_INVALID_DOSAGE';
  static const String medInvalidTime = 'MED_INVALID_TIME';
  static const String medDuplicateMedication = 'MED_DUPLICATE_MEDICATION';
  
  // 복용 로그 관련
  static const String logLogNotFound = 'LOG_LOG_NOT_FOUND';
  static const String logAlreadyTaken = 'LOG_ALREADY_TAKEN';
  static const String logInvalidDate = 'LOG_INVALID_DATE';
  
  // 시스템 관련
  static const String sysDatabaseError = 'SYS_DATABASE_ERROR';
  static const String sysExternalServiceError = 'SYS_EXTERNAL_SERVICE_ERROR';
  static const String sysRateLimitExceeded = 'SYS_RATE_LIMIT_EXCEEDED';
}

/// HTTP 상태 코드
class HttpStatusCodes {
  static const int ok = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int internalServerError = 500;
}
