import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_auth_service.dart';

/// API 인증 상태
class ApiAuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  const ApiAuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  ApiAuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return ApiAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() {
    return 'ApiAuthState(status: $status, user: $user, errorMessage: $errorMessage, isLoading: $isLoading)';
  }
}

/// API 인증 상태 관리 프로바이더
class ApiAuthNotifier extends StateNotifier<ApiAuthState> {
  ApiAuthNotifier() : super(const ApiAuthState()) {
    _initializeAuth();
  }

  final ApiAuthService _authService = ApiAuthService();

  /// 인증 상태 초기화
  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      // 토큰 존재 여부 확인
      final isSignedIn = await _authService.isSignedIn();
      
      if (isSignedIn) {
        // 사용자 정보 조회
        final user = await _authService.getCurrentUser();
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
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
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (response.success && response.data != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data!.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.error?.message ?? '회원가입에 실패했습니다.',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// 이메일로 로그인
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.success && response.data != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data!.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.error?.message ?? '로그인에 실패했습니다.',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// 토큰 갱신
  Future<void> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      
      if (response.success) {
        // 토큰 갱신 성공 시 사용자 정보 다시 조회
        final user = await _authService.getCurrentUser();
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        }
      } else {
        // 토큰 갱신 실패 시 로그아웃
        await signOut();
      }
    } catch (e) {
      // 토큰 갱신 실패 시 로그아웃
      await signOut();
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      );
    } catch (e) {
      // 에러가 발생해도 로컬 상태는 초기화
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      );
    }
  }

  /// 프로필 수정
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final response = await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      if (response.success && response.data != null) {
        state = state.copyWith(
          user: response.data!,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.error?.message ?? '프로필 수정에 실패했습니다.',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    state = state.copyWith(
      status: state.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

/// API 인증 프로바이더
final apiAuthProvider = StateNotifierProvider<ApiAuthNotifier, ApiAuthState>(
  (ref) => ApiAuthNotifier(),
);

/// 현재 사용자 프로바이더
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(apiAuthProvider);
  return authState.user;
});

/// 로그인 상태 프로바이더
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(apiAuthProvider);
  return authState.status == AuthStatus.authenticated && authState.user != null;
});

/// 로딩 상태 프로바이더
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(apiAuthProvider);
  return authState.isLoading;
});
