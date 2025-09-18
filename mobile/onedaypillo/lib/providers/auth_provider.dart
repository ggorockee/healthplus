import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/supabase_auth_service.dart';

/// 인증 상태 관리 프로바이더
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  /// 인증 상태 초기화
  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      // 현재 사용자 확인
      final user = SupabaseAuthService.currentUser;
      
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 이메일로 회원가입
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      final user = await SupabaseAuthService.signUpWithEmail(email, password);
      
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: '회원가입에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 이메일로 로그인
  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      final user = await SupabaseAuthService.signInWithEmail(email, password);
      
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: '로그인에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      final user = await SupabaseAuthService.signInWithGoogle();
      
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Google 로그인에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Kakao 로그인
  Future<void> signInWithKakao() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      final user = await SupabaseAuthService.signInWithKakao();
      
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Kakao 로그인에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Apple 로그인
  Future<void> signInWithApple() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      final user = await SupabaseAuthService.signInWithApple();
      
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Apple 로그인에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await SupabaseAuthService.signOut();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// 인증 프로바이더
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// 현재 사용자 프로바이더
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// 인증 상태 프로바이더
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});
