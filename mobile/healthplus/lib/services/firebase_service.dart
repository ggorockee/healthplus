import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase 서비스 클래스
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // ========== 인증 관련 ==========
  
  /// 현재 사용자 정보 가져오기
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  /// 이메일로 회원가입
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  /// 이메일로 로그인
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  /// 로그아웃
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  /// 비밀번호 재설정
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  /// 이메일 인증
  static Future<void> sendEmailVerification() async {
    final user = getCurrentUser();
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
  
  /// 인증 상태 스트림
  static Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }
  
  /// 사용자 프로필 업데이트
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = getCurrentUser();
    if (user != null) {
      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
    }
  }
  
  /// 사용자 삭제
  static Future<void> deleteUser() async {
    final user = getCurrentUser();
    if (user != null) {
      await user.delete();
    }
  }
  
  /// 비밀번호 변경
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = getCurrentUser();
    if (user != null) {
      // 현재 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      
      // 새 비밀번호로 변경
      await user.updatePassword(newPassword);
    }
  }
  
  // ========== 사용자 경험 개선 ==========
  
  /// 사용자 활동 로깅
  static void logUserActivity(String activity) {
    // Firebase Analytics에 사용자 활동 로깅
    // 추후 Firebase Analytics 패키지 추가 시 구현
    print('User Activity: $activity');
  }
  
  /// 에러 로깅
  static void logError(String error, {String? context}) {
    // Firebase Crashlytics에 에러 로깅
    // 추후 Firebase Crashlytics 패키지 추가 시 구현
    print('Error: $error ${context != null ? 'Context: $context' : ''}');
  }
  
  /// 성능 모니터링
  static void startPerformanceTrace(String traceName) {
    // Firebase Performance Monitoring
    // 추후 Firebase Performance 패키지 추가 시 구현
    print('Performance Trace Started: $traceName');
  }
  
  static void stopPerformanceTrace(String traceName) {
    // Firebase Performance Monitoring
    // 추후 Firebase Performance 패키지 추가 시 구현
    print('Performance Trace Stopped: $traceName');
  }
}
