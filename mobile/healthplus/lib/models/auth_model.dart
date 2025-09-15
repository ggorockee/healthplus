/// 인증 결과 모델
class AuthResult {
  final bool isSuccess;
  final String message;
  final String? errorCode;

  const AuthResult._({
    required this.isSuccess,
    required this.message,
    this.errorCode,
  });

  /// 성공 결과 생성
  factory AuthResult.success(String message) {
    return AuthResult._(
      isSuccess: true,
      message: message,
    );
  }

  /// 실패 결과 생성
  factory AuthResult.error(String message, {String? errorCode}) {
    return AuthResult._(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
    );
  }
}

/// 로그인 방식 열거형
enum LoginMethod {
  kakao('카카오', '카카오톡으로 로그인'),
  google('구글', '구글로 로그인'),
  apple('애플', '애플로 로그인'),
  email('이메일', '이메일로 회원가입');

  const LoginMethod(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 사용자 정보 모델
class User {
  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final LoginMethod loginMethod;
  final DateTime createdAt;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.profileImageUrl,
    required this.loginMethod,
    required this.createdAt,
    this.isEmailVerified = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    LoginMethod? loginMethod,
    DateTime? createdAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      loginMethod: loginMethod ?? this.loginMethod,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

/// 로그인 상태 열거형
enum AuthStatus {
  initial('초기', '초기 상태'),
  loading('로딩', '로그인 처리 중'),
  authenticated('인증됨', '로그인 완료'),
  unauthenticated('미인증', '로그인 필요'),
  error('오류', '로그인 오류');

  const AuthStatus(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 로그인 폼 데이터 모델
class LoginFormData {
  final String email;
  final String password;
  final String? confirmPassword;
  final bool isSignUp;
  final bool agreeToTerms;

  const LoginFormData({
    this.email = '',
    this.password = '',
    this.confirmPassword,
    this.isSignUp = false,
    this.agreeToTerms = false,
  });

  LoginFormData copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? isSignUp,
    bool? agreeToTerms,
  }) {
    return LoginFormData(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSignUp: isSignUp ?? this.isSignUp,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
    );
  }

  /// 폼 유효성 검사
  bool get isValid {
    if (isSignUp) {
      return email.isNotEmpty && 
             password.isNotEmpty && 
             confirmPassword == password &&
             agreeToTerms;
    } else {
      return email.isNotEmpty && password.isNotEmpty;
    }
  }
}
