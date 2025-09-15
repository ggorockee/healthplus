import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 관리 클래스
class EnvConfig {
  // Supabase 설정
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseServiceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  
  // JWT 설정
  static String get jwtSecret => dotenv.env['JWT_SECRET'] ?? '';
  static int get jwtExpiryHours => int.tryParse(dotenv.env['JWT_EXPIRY_HOURS'] ?? '24') ?? 24;
  
  // 앱 설정
  static String get appName => dotenv.env['APP_NAME'] ?? '내 약 관리';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get appEnvironment => dotenv.env['APP_ENVIRONMENT'] ?? 'development';
  
  // 알림 설정
  static bool get notificationEnabled => dotenv.env['NOTIFICATION_ENABLED']?.toLowerCase() == 'true';
  static bool get pushNotificationEnabled => dotenv.env['PUSH_NOTIFICATION_ENABLED']?.toLowerCase() == 'true';
  
  // 로깅 설정
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'debug';
  
  /// 환경 변수 초기화
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
  
  /// 환경 변수 유효성 검사
  static bool get isValid {
    return supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty && 
           jwtSecret.isNotEmpty;
  }
  
  /// 개발 환경 여부
  static bool get isDevelopment => appEnvironment == 'development';
  
  /// 프로덕션 환경 여부
  static bool get isProduction => appEnvironment == 'production';
}
