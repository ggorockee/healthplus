import 'user.dart';

/// JWT 토큰 모델
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  String toString() {
    return 'AuthTokens(accessToken: ${accessToken.substring(0, 20)}..., refreshToken: ${refreshToken.substring(0, 20)}...)';
  }
}

/// 로그인 응답 모델
class LoginResponse {
  final User user;
  final AuthTokens tokens;

  const LoginResponse({
    required this.user,
    required this.tokens,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}

/// 회원가입 응답 모델
class RegisterResponse {
  final User user;
  final AuthTokens tokens;

  const RegisterResponse({
    required this.user,
    required this.tokens,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}

/// 토큰 갱신 응답 모델
class RefreshTokenResponse {
  final AuthTokens tokens;

  const RefreshTokenResponse({
    required this.tokens,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokens': tokens.toJson(),
    };
  }
}

/// 로그인 요청 모델
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// 회원가입 요청 모델
class RegisterRequest {
  final String email;
  final String password;
  final String displayName;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'displayName': displayName,
    };
  }
}

/// 토큰 갱신 요청 모델
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

/// 프로필 수정 요청 모델
class UpdateProfileRequest {
  final String? displayName;
  final String? photoURL;

  const UpdateProfileRequest({
    this.displayName,
    this.photoURL,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (displayName != null) json['displayName'] = displayName;
    if (photoURL != null) json['photoURL'] = photoURL;
    return json;
  }
}
