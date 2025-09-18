import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'token_storage_service.dart';

/// API 클라이언트 클래스
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;
  final TokenStorageService _tokenStorage = TokenStorageService();

  /// Dio 인스턴스 초기화
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.timeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.timeout),
      sendTimeout: Duration(milliseconds: ApiConfig.timeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.addAll([
      _AuthInterceptor(_tokenStorage),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);

    if (kDebugMode && ApiConfig.enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }
  }

  /// GET 요청
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST 요청
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// PUT 요청
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE 요청
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// 응답 처리
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final data = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(data, fromJson);
  }

  /// 에러 처리
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 500;
      final message = error.message ?? 'Unknown error occurred';
      
      ApiError apiError;
      if (error.response?.data != null) {
        final errorData = error.response!.data as Map<String, dynamic>;
        apiError = ApiError.fromJson(errorData['error'] as Map<String, dynamic>);
      } else {
        apiError = ApiError(
          code: 'NETWORK_ERROR',
          message: _getErrorMessage(statusCode, message),
        );
      }

      return ApiResponse<T>(
        success: false,
        error: apiError,
      );
    }

    return ApiResponse<T>(
      success: false,
      error: ApiError(
        code: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred',
      ),
    );
  }

  /// HTTP 상태 코드에 따른 에러 메시지 생성
  String _getErrorMessage(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다.';
      case 401:
        return '인증이 필요합니다.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 리소스를 찾을 수 없습니다.';
      case 409:
        return '데이터 충돌이 발생했습니다.';
      case 422:
        return '입력 데이터가 올바르지 않습니다.';
      case 500:
        return '서버 오류가 발생했습니다.';
      default:
        return message.isNotEmpty ? message : '알 수 없는 오류가 발생했습니다.';
    }
  }
}

/// 인증 인터셉터
class _AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;

  _AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 인증이 필요한 요청에 토큰 추가
    if (_isAuthRequired(options.path)) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러 시 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // 토큰 갱신 성공 시 원래 요청 재시도
        final options = err.requestOptions;
        final token = await _tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        try {
          final response = await Dio().fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // 재시도 실패 시 로그아웃 처리
          await _tokenStorage.clearTokens();
        }
      }
    }
    handler.next(err);
  }

  /// 인증이 필요한 경로인지 확인
  bool _isAuthRequired(String path) {
    final publicPaths = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.refresh,
      ApiEndpoints.health,
      ApiEndpoints.version,
    ];
    return !publicPaths.contains(path);
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.apiUrl}${ApiEndpoints.refresh}',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>;
        
        await _tokenStorage.saveAccessToken(tokens['accessToken'] as String);
        await _tokenStorage.saveRefreshToken(tokens['refreshToken'] as String);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// 로깅 인터셉터
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      print('🚀 API Request: ${options.method} ${options.uri}');
      if (options.data != null) {
        print('📤 Request Data: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      print('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
      print('📥 Response Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConfig.enableLogging) {
      print('❌ API Error: ${err.response?.statusCode} ${err.requestOptions.uri}');
      print('🔍 Error Details: ${err.message}');
    }
    handler.next(err);
  }
}

/// 에러 처리 인터셉터
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 네트워크 에러 처리
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      err = err.copyWith(
        message: '네트워크 연결 시간이 초과되었습니다.',
      );
    } else if (err.type == DioExceptionType.connectionError) {
      err = err.copyWith(
        message: '네트워크 연결에 실패했습니다.',
      );
    }
    
    handler.next(err);
  }
}
