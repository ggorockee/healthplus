import 'env_config.dart';

/// Supabase 설정 클래스
class SupabaseConfig {
  // Project URL
  static String get url => EnvConfig.supabaseUrl;
  
  // anon public key (클라이언트에서 사용해도 안전)
  static String get anonKey => EnvConfig.supabaseAnonKey;
  
  // service_role key (서버에서만 사용, 클라이언트에 노출 금지)
  static String get serviceRoleKey => EnvConfig.supabaseServiceRoleKey;
  
  /// 설정 유효성 검사
  static bool get isValid => EnvConfig.isValid;
}
