import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? '';
  }

  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
}
