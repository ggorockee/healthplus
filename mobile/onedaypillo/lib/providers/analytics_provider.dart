import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_api.dart';
import '../repositories/analytics_repository.dart';
import 'repository_provider.dart';

/// 통계 상태 관리
class AnalyticsState {
  final MedicationStatsResponse? stats;
  final AnalyticsSummaryResponse? summary;
  final bool isLoading;
  final String? errorMessage;
  final bool isRefreshing;

  const AnalyticsState({
    this.stats,
    this.summary,
    this.isLoading = false,
    this.errorMessage,
    this.isRefreshing = false,
  });

  AnalyticsState copyWith({
    MedicationStatsResponse? stats,
    AnalyticsSummaryResponse? summary,
    bool? isLoading,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return AnalyticsState(
      stats: stats ?? this.stats,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  String toString() {
    return 'AnalyticsState(stats: ${stats != null}, summary: ${summary != null}, isLoading: $isLoading, errorMessage: $errorMessage, isRefreshing: $isRefreshing)';
  }
}

/// API 기반 통계 상태 관리 프로바이더
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier(this._repository) : super(const AnalyticsState());

  final AnalyticsRepository _repository;

  /// 약물 통계 로드
  Future<void> loadMedicationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final stats = await _repository.getMedicationStats(
        startDate: startDate,
        endDate: endDate,
      );
      
      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 분석 요약 로드
  Future<void> loadSummary({
    required String period,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final summary = await _repository.getSummary(period: period);
      
      state = state.copyWith(
        summary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 통계 새로고침
  Future<void> refreshStats({
    DateTime? startDate,
    DateTime? endDate,
    String? period,
  }) async {
    try {
      state = state.copyWith(isRefreshing: true, errorMessage: null);
      
      if (startDate != null && endDate != null) {
        final stats = await _repository.getMedicationStats(
          startDate: startDate,
          endDate: endDate,
        );
        state = state.copyWith(stats: stats);
      }
      
      if (period != null) {
        final summary = await _repository.getSummary(period: period);
        state = state.copyWith(summary: summary);
      }
      
      state = state.copyWith(isRefreshing: false);
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 복용 준수율 조회
  Future<ComplianceRateResponse?> getComplianceRate({
    required String medicationId,
    required String period,
  }) async {
    try {
      return await _repository.getComplianceRate(
        medicationId: medicationId,
        period: period,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// 복용 히스토리 조회
  Future<HistoryResponse?> getHistory({
    required String medicationId,
    required String period,
  }) async {
    try {
      return await _repository.getHistory(
        medicationId: medicationId,
        period: period,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// 통계 Repository 프로바이더
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final config = ref.watch(repositoryConfigProvider);
  
  return AnalyticsRepositoryFactory.create(
    useApi: config.useApi && config.isOnline,
    apiClient: (config.useApi && config.isOnline) ? apiClient : null,
  );
});

/// API 기반 통계 프로바이더
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return AnalyticsNotifier(repository);
});

/// 약물 통계 프로바이더 (간편 접근용)
final medicationStatsProvider = Provider<MedicationStatsResponse?>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  return analyticsState.stats;
});

/// 분석 요약 프로바이더 (간편 접근용)
final analyticsSummaryProvider = Provider<AnalyticsSummaryResponse?>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  return analyticsState.summary;
});

/// 통계 로딩 상태 프로바이더
final analyticsLoadingProvider = Provider<bool>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  return analyticsState.isLoading || analyticsState.isRefreshing;
});

/// 통계 에러 상태 프로바이더
final analyticsErrorProvider = Provider<String?>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  return analyticsState.errorMessage;
});

/// 복용 준수율 프로바이더
final complianceRateProvider = FutureProvider.family<ComplianceRateResponse?, Map<String, String>>((ref, params) async {
  final notifier = ref.read(analyticsProvider.notifier);
  return await notifier.getComplianceRate(
    medicationId: params['medicationId']!,
    period: params['period']!,
  );
});

/// 복용 히스토리 프로바이더
final historyProvider = FutureProvider.family<HistoryResponse?, Map<String, String>>((ref, params) async {
  final notifier = ref.read(analyticsProvider.notifier);
  return await notifier.getHistory(
    medicationId: params['medicationId']!,
    period: params['period']!,
  );
});

/// 월간 통계 프로바이더
final monthlyStatsProvider = FutureProvider.family<MedicationStatsResponse?, Map<String, DateTime>>((ref, params) async {
  final notifier = ref.read(analyticsProvider.notifier);
  await notifier.loadMedicationStats(
    startDate: params['startDate']!,
    endDate: params['endDate']!,
  );
  return ref.read(medicationStatsProvider);
});

/// 주간 요약 프로바이더
final weeklySummaryProvider = FutureProvider<AnalyticsSummaryResponse?>((ref) async {
  final notifier = ref.read(analyticsProvider.notifier);
  await notifier.loadSummary(period: 'week');
  return ref.read(analyticsSummaryProvider);
});

/// 월간 요약 프로바이더
final monthlySummaryProvider = FutureProvider<AnalyticsSummaryResponse?>((ref) async {
  final notifier = ref.read(analyticsProvider.notifier);
  await notifier.loadSummary(period: 'month');
  return ref.read(analyticsSummaryProvider);
});
