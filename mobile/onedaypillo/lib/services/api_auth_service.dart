import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/auth_tokens.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'token_storage_service.dart';

/// API 기반 인증 서비스
class ApiAuthService {
  static final ApiAuthService _instance = ApiAuthService._internal();
  factory ApiAuthService() => _instance;
  ApiAuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final TokenStorageService _tokenStorage = TokenStorageService();

  /// 이메일로 회원가입
  Future<ApiResponse<RegisterResponse>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final request = RegisterRequest(
      email: email,
      password: password,
      displayName: displayName,
    );

    final response = await _apiClient.post<RegisterResponse>(
      ApiEndpoints.register,
      data: request.toJson(),
      fromJson: RegisterResponse.fromJson,
    );

    // 성공 시 토큰 저장
    if (response.success && response.data != null) {
      await _tokenStorage.saveTokens(
        accessToken: response.data!.tokens.accessToken,
        refreshToken: response.data!.tokens.refreshToken,
      );
    }

    return response;
  }

  /// 이메일로 로그인
  Future<ApiResponse<LoginResponse>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(
      email: email,
      password: password,
    );

    final response = await _apiClient.post<LoginResponse>(
      ApiEndpoints.login,
      data: request.toJson(),
      fromJson: LoginResponse.fromJson,
    );

    // 성공 시 토큰 저장
    if (response.success && response.data != null) {
      await _tokenStorage.saveTokens(
        accessToken: response.data!.tokens.accessToken,
        refreshToken: response.data!.tokens.refreshToken,
      );
    }

    return response;
  }

  /// 토큰 갱신
  Future<ApiResponse<RefreshTokenResponse>> refreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse<RefreshTokenResponse>(
        success: false,
        error: ApiError(
          code: ApiErrorCodes.authTokenInvalid,
          message: 'Refresh token not found',
        ),
      );
    }

    final request = RefreshTokenRequest(refreshToken: refreshToken);
    
    final response = await _apiClient.post<RefreshTokenResponse>(
      ApiEndpoints.refresh,
      data: request.toJson(),
      fromJson: RefreshTokenResponse.fromJson,
    );

    // 성공 시 새 토큰 저장
    if (response.success && response.data != null) {
      await _tokenStorage.saveTokens(
        accessToken: response.data!.tokens.accessToken,
        refreshToken: response.data!.tokens.refreshToken,
      );
    }

    return response;
  }

  /// 로그아웃
  Future<ApiResponse<void>> signOut() async {
    final response = await _apiClient.post<void>(
      ApiEndpoints.logout,
    );

    // 성공 또는 실패 상관없이 토큰 삭제
    await _tokenStorage.clearTokens();

    return response;
  }

  /// 사용자 프로필 조회
  Future<ApiResponse<User>> getProfile() async {
    return await _apiClient.get<User>(
      ApiEndpoints.profile,
      fromJson: User.fromJson,
    );
  }

  /// 사용자 프로필 수정
  Future<ApiResponse<User>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final request = UpdateProfileRequest(
      displayName: displayName,
      photoURL: photoURL,
    );

    return await _apiClient.put<User>(
      ApiEndpoints.profile,
      data: request.toJson(),
      fromJson: User.fromJson,
    );
  }

  /// 현재 사용자 조회 (토큰에서)
  Future<User?> getCurrentUser() async {
    try {
      final response = await getProfile();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 로그인 상태 확인
  Future<bool> isSignedIn() async {
    final hasAccessToken = await _tokenStorage.hasAccessToken();
    final hasRefreshToken = await _tokenStorage.hasRefreshToken();
    
    if (!hasAccessToken || !hasRefreshToken) {
      return false;
    }

    // 토큰 유효성 확인
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// 토큰 유효성 검증
  Future<bool> validateToken() async {
    try {
      final response = await getProfile();
      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Access Token 조회
  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  /// Refresh Token 조회
  Future<String?> getRefreshToken() async {
    return await _tokenStorage.getRefreshToken();
  }

  /// 토큰 삭제
  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
  }
}
