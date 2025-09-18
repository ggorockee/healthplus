import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/medication_repository.dart';
import '../repositories/medication_log_repository.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';

/// API 클라이언트 프로바이더
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// 약물 Repository 프로바이더
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  
  // 환경에 따라 Repository 선택
  // 개발 중에는 API 사용, 오프라인 시에는 로컬 사용
  final useApi = ApiConfig.isDebug; // 개발 환경에서는 API 사용
  
  return MedicationRepositoryFactory.create(
    useApi: useApi,
    apiClient: useApi ? apiClient : null,
  );
});

/// 복용 로그 Repository 프로바이더
final medicationLogRepositoryProvider = Provider<MedicationLogRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  
  // 환경에 따라 Repository 선택
  final useApi = ApiConfig.isDebug; // 개발 환경에서는 API 사용
  
  return MedicationLogRepositoryFactory.create(
    useApi: useApi,
    apiClient: useApi ? apiClient : null,
  );
});

/// Repository 설정 프로바이더 (런타임에 Repository 타입 변경 가능)
final repositoryConfigProvider = StateNotifierProvider<RepositoryConfigNotifier, RepositoryConfig>((ref) {
  return RepositoryConfigNotifier();
});

/// Repository 설정 상태
class RepositoryConfig {
  final bool useApi;
  final bool isOnline;

  const RepositoryConfig({
    this.useApi = false,
    this.isOnline = true,
  });

  RepositoryConfig copyWith({
    bool? useApi,
    bool? isOnline,
  }) {
    return RepositoryConfig(
      useApi: useApi ?? this.useApi,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Repository 설정 관리자
class RepositoryConfigNotifier extends StateNotifier<RepositoryConfig> {
  RepositoryConfigNotifier() : super(const RepositoryConfig(useApi: false, isOnline: true));

  /// API 사용 여부 설정
  void setUseApi(bool useApi) {
    state = state.copyWith(useApi: useApi);
  }

  /// 온라인 상태 설정
  void setOnline(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }

  /// 개발 모드 설정
  void setDevelopmentMode() {
    state = state.copyWith(useApi: true, isOnline: true);
  }

  /// 프로덕션 모드 설정
  void setProductionMode() {
    state = state.copyWith(useApi: false, isOnline: true);
  }

  /// 오프라인 모드 설정
  void setOfflineMode() {
    state = state.copyWith(useApi: false, isOnline: false);
  }
}

/// 동적 약물 Repository 프로바이더
final dynamicMedicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final config = ref.watch(repositoryConfigProvider);
  
  return MedicationRepositoryFactory.create(
    useApi: config.useApi && config.isOnline,
    apiClient: (config.useApi && config.isOnline) ? apiClient : null,
  );
});

/// 동적 복용 로그 Repository 프로바이더
final dynamicMedicationLogRepositoryProvider = Provider<MedicationLogRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final config = ref.watch(repositoryConfigProvider);
  
  return MedicationLogRepositoryFactory.create(
    useApi: config.useApi && config.isOnline,
    apiClient: (config.useApi && config.isOnline) ? apiClient : null,
  );
});
