/// API 응답 기본 모델
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? timestamp;
  final ApiError? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.timestamp,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : json['data'],
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'timestamp': timestamp,
      'error': error?.toJson(),
    };
  }
}

/// API 에러 모델
class ApiError {
  final String code;
  final String message;
  final String? details;
  final String? field;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
    this.field,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] as String?,
      field: json['field'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details,
      'field': field,
    };
  }

  @override
  String toString() {
    return 'ApiError(code: $code, message: $message, details: $details, field: $field)';
  }
}

/// 페이지네이션 응답 모델
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<T>(
      items: items,
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'total': total,
      'page': page,
      'limit': limit,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}
