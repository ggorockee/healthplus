import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user.dart' as app_user;

/// Supabase 인증 서비스
class SupabaseAuthService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// 현재 사용자 스트림
  static Stream<app_user.User?> get user {
    return _client.auth.onAuthStateChange.map((data) {
      final session = data.session;
      if (session?.user == null) return null;
      
      return app_user.User(
        id: session!.user.id,
        email: session.user.email ?? '',
        displayName: session.user.userMetadata?['name'] as String?,
        provider: app_user.AuthProvider.email, // 기본값
        createdAt: DateTime.parse(session.user.createdAt),
        isEmailVerified: session.user.emailConfirmedAt != null,
      );
    });
  }

  /// 현재 사용자 가져오기
  static app_user.User? get currentUser {
    final session = _client.auth.currentSession;
    if (session?.user == null) return null;
    
    return app_user.User(
      id: session!.user.id,
      email: session.user.email ?? '',
      displayName: session.user.userMetadata?['name'] as String?,
      provider: app_user.AuthProvider.email,
      createdAt: DateTime.parse(session.user.createdAt),
      isEmailVerified: session.user.emailConfirmedAt != null,
    );
  }

  /// 이메일로 회원가입
  static Future<app_user.User?> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // 사용자 프로필을 users 테이블에 저장
        await _createUserProfile(response.user!);
        
        return app_user.User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          provider: app_user.AuthProvider.email,
          createdAt: DateTime.parse(response.user!.createdAt),
          isEmailVerified: response.user!.emailConfirmedAt != null,
        );
      }
      return null;
    } catch (e) {
      debugPrint('회원가입 실패: $e');
      rethrow;
    }
  }

  /// 이메일로 로그인
  static Future<app_user.User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return app_user.User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          displayName: response.user!.userMetadata?['name'] as String?,
          provider: app_user.AuthProvider.email,
          createdAt: DateTime.parse(response.user!.createdAt),
          isEmailVerified: response.user!.emailConfirmedAt != null,
        );
      }
      return null;
    } catch (e) {
      debugPrint('로그인 실패: $e');
      rethrow;
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 사용자 프로필 생성
  static Future<void> _createUserProfile(User user) async {
    try {
      await _client.from('users').insert({
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('사용자 프로필 생성 실패: $e');
    }
  }

  /// 데모 계정 생성 (개발용)
  static Future<void> createDemoAccount() async {
    try {
      // 이미 데모 계정이 있는지 확인
      final existingUser = await _client
          .from('users')
          .select()
          .eq('email', 'sample@example.com')
          .maybeSingle();

      if (existingUser != null) {
        debugPrint('데모 계정이 이미 존재합니다.');
        return;
      }

      // 데모 계정 회원가입
      final response = await _client.auth.signUp(
        email: 'sample@example.com',
        password: 'sample123\$',
      );

      if (response.user != null) {
        await _createUserProfile(response.user!);
        
        debugPrint('데모 계정 생성 완료: sample@example.com');
      }
    } catch (e) {
      debugPrint('데모 계정 생성 실패: $e');
    }
  }
}
