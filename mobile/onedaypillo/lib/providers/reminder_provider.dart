import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_api.dart';
import '../repositories/reminder_repository.dart';
import 'repository_provider.dart';

/// 알림 상태 관리
class ReminderState {
  final List<Reminder> reminders;
  final List<ReminderLog> logs;
  final ReminderStats? stats;
  final bool isLoading;
  final String? errorMessage;
  final bool isRefreshing;

  const ReminderState({
    this.reminders = const [],
    this.logs = const [],
    this.stats,
    this.isLoading = false,
    this.errorMessage,
    this.isRefreshing = false,
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    List<ReminderLog>? logs,
    ReminderStats? stats,
    bool? isLoading,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      logs: logs ?? this.logs,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  String toString() {
    return 'ReminderState(reminders: ${reminders.length}, logs: ${logs.length}, stats: ${stats != null}, isLoading: $isLoading, errorMessage: $errorMessage, isRefreshing: $isRefreshing)';
  }
}

/// API 기반 알림 상태 관리 프로바이더
class ReminderNotifier extends StateNotifier<ReminderState> {
  ReminderNotifier(this._repository) : super(const ReminderState()) {
    _loadReminders();
  }

  final ReminderRepository _repository;

  /// 알림 설정 목록 로드
  Future<void> _loadReminders() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final reminders = await _repository.getReminders();
      
      state = state.copyWith(
        reminders: reminders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 알림 설정 목록 새로고침
  Future<void> refreshReminders() async {
    try {
      state = state.copyWith(isRefreshing: true, errorMessage: null);
      
      final reminders = await _repository.getReminders();
      
      state = state.copyWith(
        reminders: reminders,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 알림 설정 추가
  Future<void> addReminder(CreateReminderRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final newReminder = await _repository.addReminder(request);
      
      state = state.copyWith(
        reminders: [...state.reminders, newReminder],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// 알림 설정 수정
  Future<void> updateReminder(String id, UpdateReminderRequest request) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedReminder = await _repository.updateReminder(id, request);
      
      final updatedReminders = state.reminders.map((r) {
        return r.id == id ? updatedReminder : r;
      }).toList();
      
      state = state.copyWith(
        reminders: updatedReminders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// 알림 설정 삭제
  Future<void> deleteReminder(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _repository.deleteReminder(id);
      
      state = state.copyWith(
        reminders: state.reminders.where((r) => r.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// 알림 설정 활성화/비활성화 토글
  Future<void> toggleReminder(String id) async {
    try {
      final reminder = state.reminders.firstWhere((r) => r.id == id);
      final request = UpdateReminderRequest(isEnabled: !reminder.isEnabled);
      await updateReminder(id, request);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 알림 로그 로드
  Future<void> loadReminderLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final logs = await _repository.getReminderLogs(
        startDate: startDate,
        endDate: endDate,
      );
      
      state = state.copyWith(
        logs: logs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 알림 통계 로드
  Future<void> loadReminderStats({
    required String period,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final stats = await _repository.getReminderStats(period: period);
      
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

  /// 알림 스케줄링
  Future<void> scheduleReminder(ScheduleReminderRequest request) async {
    try {
      await _repository.scheduleReminder(request);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 알림 처리
  Future<void> processReminder(ProcessReminderRequest request) async {
    try {
      await _repository.processReminder(request);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 특정 약물의 알림 설정 조회
  List<Reminder> getRemindersByMedication(String medicationId) {
    return state.reminders.where((r) => r.medicationId == medicationId).toList();
  }

  /// 활성화된 알림 설정 조회
  List<Reminder> getActiveReminders() {
    return state.reminders.where((r) => r.isEnabled).toList();
  }

  /// 특정 알림 설정 조회
  Reminder? getReminder(String id) {
    try {
      return state.reminders.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// 알림 Repository 프로바이더
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final config = ref.watch(repositoryConfigProvider);
  
  return ReminderRepositoryFactory.create(
    useApi: config.useApi && config.isOnline,
    apiClient: (config.useApi && config.isOnline) ? apiClient : null,
  );
});

/// API 기반 알림 프로바이더
final reminderProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return ReminderNotifier(repository);
});

/// 알림 설정 목록 프로바이더 (간편 접근용)
final remindersProvider = Provider<List<Reminder>>((ref) {
  final reminderState = ref.watch(reminderProvider);
  return reminderState.reminders;
});

/// 알림 로그 프로바이더 (간편 접근용)
final reminderLogsProvider = Provider<List<ReminderLog>>((ref) {
  final reminderState = ref.watch(reminderProvider);
  return reminderState.logs;
});

/// 알림 통계 프로바이더 (간편 접근용)
final reminderStatsProvider = Provider<ReminderStats?>((ref) {
  final reminderState = ref.watch(reminderProvider);
  return reminderState.stats;
});

/// 알림 로딩 상태 프로바이더
final reminderLoadingProvider = Provider<bool>((ref) {
  final reminderState = ref.watch(reminderProvider);
  return reminderState.isLoading || reminderState.isRefreshing;
});

/// 알림 에러 상태 프로바이더
final reminderErrorProvider = Provider<String?>((ref) {
  final reminderState = ref.watch(reminderProvider);
  return reminderState.errorMessage;
});

/// 특정 약물의 알림 설정 프로바이더
final remindersByMedicationProvider = Provider.family<List<Reminder>, String>((ref, medicationId) {
  final reminderState = ref.watch(reminderProvider);
  return reminderState.reminders.where((r) => r.medicationId == medicationId).toList();
});

/// 활성화된 알림 설정 프로바이더
final activeRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminderState = ref.watch(reminderProvider);
  return reminderState.reminders.where((r) => r.isEnabled).toList();
});

/// 특정 알림 설정 프로바이더
final reminderByIdProvider = Provider.family<Reminder?, String>((ref, id) {
  final reminderState = ref.watch(reminderProvider);
  try {
    return reminderState.reminders.firstWhere((r) => r.id == id);
  } catch (e) {
    return null;
  }
});

/// 알림 로그 통계 프로바이더
final reminderLogStatsProvider = FutureProvider.family<ReminderStats?, String>((ref, period) async {
  final notifier = ref.read(reminderProvider.notifier);
  await notifier.loadReminderStats(period: period);
  return ref.read(reminderStatsProvider);
});
