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

  /// 이메일로 로그인 (무조건 성공)
  static Future<app_user.User?> signInWithEmail(String email, String password) async {
    try {
      // 실제 Supabase 인증 시도
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
      
      // Supabase 인증 실패 시에도 무조건 성공 처리 (데모용)
      debugPrint('Supabase 인증 실패, 데모 계정으로 처리: $email');
      return app_user.User(
        id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: '데모 사용자',
        provider: app_user.AuthProvider.email,
        createdAt: DateTime.now(),
        isEmailVerified: true,
      );
    } catch (e) {
      debugPrint('로그인 실패, 데모 계정으로 처리: $e');
      // 오류 발생 시에도 무조건 성공 처리 (데모용)
      return app_user.User(
        id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: '데모 사용자',
        provider: app_user.AuthProvider.email,
        createdAt: DateTime.now(),
        isEmailVerified: true,
      );
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
}
