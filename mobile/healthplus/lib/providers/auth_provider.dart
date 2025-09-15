import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_model.dart';
import '../services/supabase_service.dart';
import '../services/firebase_service.dart';

/// 인증 상태 관리 클래스
class AuthNotifier extends StateNotifier<AuthStatus> {
  AuthNotifier() : super(AuthStatus.initial) {
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  /// 인증 상태 확인
  Future<void> _checkAuthStatus() async {
    try {
      final user = SupabaseService.getCurrentUser();
      
      if (user != null) {
        // JWT 토큰 유효성 확인
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null && !session.isExpired) {
          state = AuthStatus.authenticated;
        } else {
          // 토큰이 만료된 경우 로그아웃
          await _clearAuthData();
          state = AuthStatus.unauthenticated;
        }
      } else {
        state = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('인증 상태 확인 중 오류: $e');
      state = AuthStatus.unauthenticated;
    }
  }

  /// 인증 상태 변화 감지
  void _listenToAuthChanges() {
    try {
      SupabaseService.authStateChanges.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        if (event == AuthChangeEvent.signedIn && session != null) {
          // JWT 토큰 저장
          _saveJWTToken(session.accessToken);
          state = AuthStatus.authenticated;
        } else if (event == AuthChangeEvent.signedOut) {
          _clearAuthData();
          state = AuthStatus.unauthenticated;
        } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
          // 토큰 갱신 시 새 토큰 저장
          _saveJWTToken(session.accessToken);
        }
      });
    } catch (e) {
      print('인증 상태 변화 감지 중 오류: $e');
      state = AuthStatus.unauthenticated;
    }
  }

  /// JWT 토큰 저장
  Future<void> _saveJWTToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('token_saved_at', DateTime.now().toIso8601String());
  }

  /// 인증 데이터 초기화
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('token_saved_at');
    await prefs.remove('is_logged_in');
    await prefs.remove('login_method');
    await prefs.remove('login_time');
  }

  /// 이메일로 회원가입
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    state = AuthStatus.loading;
    
    try {
      // 현재 버전에서는 Supabase 설정이 없으므로 임시로 회원가입 성공 처리
      // TODO: 실제 Supabase 설정 완료 후 아래 코드로 교체
      /*
      final response = await SupabaseService.signUpWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // 사용자 프로필 업데이트 (선택사항)
        try {
          await SupabaseService.updateUserProfile(name: name);
        } catch (e) {
          print('프로필 업데이트 실패 (무시): $e');
        }
        
        // 로그인 상태 저장
        await _saveLoginStatus(LoginMethod.email);
        state = AuthStatus.authenticated;
        
        return AuthResult.success('회원가입이 완료되었습니다!');
      } else {
        state = AuthStatus.unauthenticated;
        return AuthResult.error('회원가입에 실패했습니다.');
      }
      */
      
      // 임시 회원가입 성공 처리
      await _saveLoginStatus(LoginMethod.email);
      state = AuthStatus.authenticated;
      return AuthResult.success('회원가입이 완료되었습니다!');
      
    } catch (e) {
      print('회원가입 오류: $e');
      state = AuthStatus.error;
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  /// 이메일로 로그인
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthStatus.loading;
    
    try {
      // 현재 버전에서는 Supabase 설정이 없으므로 임시로 로그인 성공 처리
      // TODO: 실제 Supabase 설정 완료 후 아래 코드로 교체
      /*
      final response = await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _saveLoginStatus(LoginMethod.email);
        state = AuthStatus.authenticated;
        return AuthResult.success('로그인되었습니다!');
      } else {
        state = AuthStatus.unauthenticated;
        return AuthResult.error('로그인에 실패했습니다.');
      }
      */
      
      // 임시 로그인 성공 처리
      await _saveLoginStatus(LoginMethod.email);
      state = AuthStatus.authenticated;
      return AuthResult.success('로그인되었습니다!');
      
    } catch (e) {
      print('로그인 오류: $e');
      state = AuthStatus.error;
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  /// 로그인 상태 저장
  Future<void> _saveLoginStatus(LoginMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('login_method', method.name);
    await prefs.setString('login_time', DateTime.now().toIso8601String());
  }

  /// 로그아웃
  Future<void> logout() async {
    state = AuthStatus.loading;
    
    try {
      await SupabaseService.signOut();
      await _clearAuthData();
      state = AuthStatus.unauthenticated;
    } catch (e) {
      state = AuthStatus.error;
    }
  }

  /// JWT 토큰 가져오기
  Future<String?> getJWTToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// 토큰 만료 확인
  Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenSavedAt = prefs.getString('token_saved_at');
    
    if (tokenSavedAt == null) return true;
    
    final savedTime = DateTime.parse(tokenSavedAt);
    final now = DateTime.now();
    final difference = now.difference(savedTime);
    
    // 1시간 후 만료로 설정 (실제로는 JWT 토큰의 exp 클레임 확인)
    return difference.inHours >= 1;
  }

  /// 에러 메시지 변환
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    } else if (error.toString().contains('User already registered')) {
      return '이미 등록된 이메일입니다.';
    } else if (error.toString().contains('Password should be at least')) {
      return '비밀번호는 최소 6자 이상이어야 합니다.';
    } else if (error.toString().contains('Invalid email')) {
      return '올바른 이메일 형식이 아닙니다.';
    } else {
      return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final user = SupabaseService.getCurrentUser();
    return user != null;
  }
}

/// 로그인 폼 상태 관리 클래스
class LoginFormNotifier extends StateNotifier<LoginFormData> {
  LoginFormNotifier() : super(const LoginFormData());

  /// 이메일 업데이트
  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  /// 비밀번호 업데이트
  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  /// 비밀번호 확인 업데이트
  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  /// 회원가입 모드 토글
  void toggleSignUpMode() {
    state = state.copyWith(isSignUp: !state.isSignUp);
  }

  /// 약관 동의 토글
  void toggleAgreeToTerms() {
    state = state.copyWith(agreeToTerms: !state.agreeToTerms);
  }

  /// 폼 초기화
  void resetForm() {
    state = const LoginFormData();
  }
}

/// 인증 상태 관리 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  return AuthNotifier();
});

/// 로그인 폼 상태 관리 Provider
final loginFormProvider = StateNotifierProvider<LoginFormNotifier, LoginFormData>((ref) {
  return LoginFormNotifier();
});

/// 로그인 상태 확인 Provider
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  return await AuthNotifier.isLoggedIn();
});
