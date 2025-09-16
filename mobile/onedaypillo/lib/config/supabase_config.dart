import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 설정 및 초기화
class SupabaseConfig {
  static const String supabaseUrl = 'https://yjkfjytsfnpkahuiajjv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlqa2ZqeXRzZm5wa2FodWlhamp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NDQwNjIsImV4cCI6MjA3MzUyMDA2Mn0.3HpbNmM3jD5jy-B38KghXwKJwJe2ZMACxAsdHGluRxM';
  
  /// Supabase 초기화
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  /// Supabase 클라이언트 인스턴스
  static SupabaseClient get client => Supabase.instance.client;
}
