import '../models/analytics_api.dart';
import '../config/api_config.dart';
import '../services/api_client.dart';

/// 통계 및 분석 Repository 인터페이스
abstract class AnalyticsRepository {
  /// 약물 복용 통계 조회
  Future<MedicationStatsResponse> getMedicationStats({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// 복용 준수율 조회
  Future<ComplianceRateResponse> getComplianceRate({
    required String medicationId,
    required String period,
  });
  
  /// 복용 히스토리 조회
  Future<HistoryResponse> getHistory({
    required String medicationId,
    required String period,
  });
  
  /// 분석 요약 조회
  Future<AnalyticsSummaryResponse> getSummary({
    required String period,
  });
}

/// API 기반 통계 Repository 구현체
class ApiAnalyticsRepository implements AnalyticsRepository {
  final ApiClient _apiClient;
  
  ApiAnalyticsRepository(this._apiClient);

  @override
  Future<MedicationStatsResponse> getMedicationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get<MedicationStatsResponse>(
        ApiEndpoints.medicationStats,
        queryParameters: queryParams,
        fromJson: MedicationStatsResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '통계 조회에 실패했습니다.');
    } catch (e) {
      throw Exception('통계 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<ComplianceRateResponse> getComplianceRate({
    required String medicationId,
    required String period,
  }) async {
    try {
      final response = await _apiClient.get<ComplianceRateResponse>(
        ApiEndpoints.complianceRate,
        queryParameters: {
          'medicationId': medicationId,
          'period': period,
        },
        fromJson: ComplianceRateResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '복용 준수율 조회에 실패했습니다.');
    } catch (e) {
      throw Exception('복용 준수율 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<HistoryResponse> getHistory({
    required String medicationId,
    required String period,
  }) async {
    try {
      final response = await _apiClient.get<HistoryResponse>(
        ApiEndpoints.history,
        queryParameters: {
          'medicationId': medicationId,
          'period': period,
        },
        fromJson: HistoryResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '복용 히스토리 조회에 실패했습니다.');
    } catch (e) {
      throw Exception('복용 히스토리 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<AnalyticsSummaryResponse> getSummary({
    required String period,
  }) async {
    try {
      final response = await _apiClient.get<AnalyticsSummaryResponse>(
        '${ApiEndpoints.analytics}/summary',
        queryParameters: {
          'period': period,
        },
        fromJson: AnalyticsSummaryResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '분석 요약 조회에 실패했습니다.');
    } catch (e) {
      throw Exception('분석 요약 조회에 실패했습니다: $e');
    }
  }
}

/// 로컬 캐시 통계 Repository 구현체
class LocalAnalyticsRepository implements AnalyticsRepository {
  
  @override
  Future<MedicationStatsResponse> getMedicationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 로컬에서 통계 계산 (간단한 구현)
    return const MedicationStatsResponse(
      totalMedications: 0,
      totalLogs: 0,
      complianceRate: 0.0,
      dailyStats: [],
    );
  }

  @override
  Future<ComplianceRateResponse> getComplianceRate({
    required String medicationId,
    required String period,
  }) async {
    // 로컬에서 복용 준수율 계산
    return ComplianceRateResponse(
      medicationId: medicationId,
      medicationName: 'Unknown',
      period: period,
      complianceRate: 0.0,
      totalDoses: 0,
      takenDoses: 0,
      missedDoses: 0,
    );
  }

  @override
  Future<HistoryResponse> getHistory({
    required String medicationId,
    required String period,
  }) async {
    // 로컬에서 히스토리 조회
    return HistoryResponse(
      medicationId: medicationId,
      medicationName: 'Unknown',
      period: period,
      history: [],
    );
  }

  @override
  Future<AnalyticsSummaryResponse> getSummary({
    required String period,
  }) async {
    // 로컬에서 요약 계산
    return AnalyticsSummaryResponse(
      period: period,
      overallComplianceRate: 0.0,
      totalMedications: 0,
      activeMedications: 0,
      totalDoses: 0,
      takenDoses: 0,
      missedDoses: 0,
      medicationSummaries: [],
      weeklyTrends: [],
    );
  }
}

/// 통계 Repository 팩토리
class AnalyticsRepositoryFactory {
  static AnalyticsRepository create({
    required bool useApi,
    ApiClient? apiClient,
  }) {
    if (useApi && apiClient != null) {
      return ApiAnalyticsRepository(apiClient);
    } else {
      return LocalAnalyticsRepository();
    }
  }
}
