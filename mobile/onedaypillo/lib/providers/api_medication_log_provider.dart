import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_log.dart';
import '../repositories/medication_log_repository.dart';
import 'repository_provider.dart';

/// 복용 로그 상태 관리
class MedicationLogState {
  final List<MedicationLog> logs;
  final bool isLoading;
  final String? errorMessage;
  final bool isRefreshing;

  const MedicationLogState({
    this.logs = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isRefreshing = false,
  });

  MedicationLogState copyWith({
    List<MedicationLog>? logs,
    bool? isLoading,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return MedicationLogState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  String toString() {
    return 'MedicationLogState(logs: ${logs.length}, isLoading: $isLoading, errorMessage: $errorMessage, isRefreshing: $isRefreshing)';
  }
}

/// API 기반 복용 로그 상태 관리 프로바이더
class ApiMedicationLogNotifier extends StateNotifier<MedicationLogState> {
  ApiMedicationLogNotifier(this._repository) : super(const MedicationLogState()) {
    _loadTodayLogs();
  }

  final MedicationLogRepository _repository;

  /// 오늘의 복용 로그 로드
  Future<void> _loadTodayLogs() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final logs = await _repository.getTodayLogs();
      
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

  /// 복용 로그 목록 새로고침
  Future<void> refreshLogs() async {
    try {
      state = state.copyWith(isRefreshing: true, errorMessage: null);
      
      final logs = await _repository.getTodayLogs();
      
      state = state.copyWith(
        logs: logs,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 복용 로그 추가
  Future<void> addLog(MedicationLog log) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final newLog = await _repository.addLog(log);
      
      state = state.copyWith(
        logs: [...state.logs, newLog],
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

  /// 복용 로그 수정
  Future<void> updateLog(MedicationLog log) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedLog = await _repository.updateLog(log);
      
      final updatedLogs = state.logs.map((l) {
        return l.id == log.id ? updatedLog : l;
      }).toList();
      
      state = state.copyWith(
        logs: updatedLogs,
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

  /// 복용 로그 삭제
  Future<void> deleteLog(String logId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _repository.deleteLog(logId);
      
      state = state.copyWith(
        logs: state.logs.where((l) => l.id != logId).toList(),
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

  /// 복용 로그 목록 조회
  Future<List<MedicationLog>> getLogs({
    String? medicationId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _repository.getLogs(
        medicationId: medicationId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      // API 실패 시 로컬에서 필터링
      var filteredLogs = List<MedicationLog>.from(state.logs);
      
      if (medicationId != null) {
        filteredLogs = filteredLogs.where((log) => log.medicationId == medicationId).toList();
      }
      
      if (startDate != null) {
        filteredLogs = filteredLogs.where((log) => log.takenAt.isAfter(startDate) || log.takenAt.isAtSameMomentAs(startDate)).toList();
      }
      
      if (endDate != null) {
        filteredLogs = filteredLogs.where((log) => log.takenAt.isBefore(endDate) || log.takenAt.isAtSameMomentAs(endDate)).toList();
      }
      
      return filteredLogs;
    }
  }

  /// 특정 날짜의 복용 로그 조회
  Future<List<MedicationLog>> getLogsByDate(DateTime date) async {
    try {
      return await _repository.getLogsByDate(date);
    } catch (e) {
      // API 실패 시 로컬에서 검색
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return state.logs.where((log) {
        return log.takenAt.isAfter(startOfDay) && log.takenAt.isBefore(endOfDay);
      }).toList();
    }
  }

  /// 특정 약물의 복용 로그 조회
  Future<List<MedicationLog>> getLogsByMedication(String medicationId) async {
    try {
      return await _repository.getLogs(medicationId: medicationId);
    } catch (e) {
      // API 실패 시 로컬에서 검색
      return state.logs.where((log) => log.medicationId == medicationId).toList();
    }
  }

  /// 특정 복용 로그 조회
  Future<MedicationLog?> getLog(String id) async {
    try {
      return await _repository.getLog(id);
    } catch (e) {
      // API 실패 시 로컬에서 검색
      try {
        return state.logs.firstWhere((log) => log.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// 복용 체크 (복용/미복용 토글)
  Future<void> toggleTakenStatus(String logId) async {
    try {
      final log = await getLog(logId);
      if (log != null) {
        final updatedLog = log.copyWith(isTaken: !log.isTaken);
        await updateLog(updatedLog);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 오늘 복용 체크
  Future<void> checkTodayTaken(String medicationId, bool isTaken, {String? note}) async {
    try {
      final today = DateTime.now();
      
      // 이미 오늘 복용 로그가 있는지 확인
      final existingLogs = await getLogsByDate(today);
      final existingLog = existingLogs.firstWhere(
        (log) => log.medicationId == medicationId,
        orElse: () => null,
      );

      if (existingLog != null) {
        // 기존 로그 업데이트
        final updatedLog = existingLog.copyWith(
          isTaken: isTaken,
          note: note ?? existingLog.note,
        );
        await updateLog(updatedLog);
      } else {
        // 새 로그 생성
        final newLog = MedicationLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          medicationId: medicationId,
          takenAt: today,
          isTaken: isTaken,
          note: note,
        );
        await addLog(newLog);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// API 기반 복용 로그 프로바이더
final apiMedicationLogProvider = StateNotifierProvider<ApiMedicationLogNotifier, MedicationLogState>((ref) {
  final repository = ref.watch(dynamicMedicationLogRepositoryProvider);
  return ApiMedicationLogNotifier(repository);
});

/// 복용 로그 목록 프로바이더 (간편 접근용)
final medicationLogsProvider = Provider<List<MedicationLog>>((ref) {
  final logState = ref.watch(apiMedicationLogProvider);
  return logState.logs;
});

/// 복용 로그 로딩 상태 프로바이더
final medicationLogLoadingProvider = Provider<bool>((ref) {
  final logState = ref.watch(apiMedicationLogProvider);
  return logState.isLoading || logState.isRefreshing;
});

/// 복용 로그 에러 상태 프로바이더
final medicationLogErrorProvider = Provider<String?>((ref) {
  final logState = ref.watch(apiMedicationLogProvider);
  return logState.errorMessage;
});

/// 특정 약물의 복용 로그 프로바이더
final logsByMedicationProvider = FutureProvider.family<List<MedicationLog>, String>((ref, medicationId) async {
  final notifier = ref.read(apiMedicationLogProvider.notifier);
  return await notifier.getLogsByMedication(medicationId);
});

/// 특정 날짜의 복용 로그 프로바이더
final logsByDateProvider = FutureProvider.family<List<MedicationLog>, DateTime>((ref, date) async {
  final notifier = ref.read(apiMedicationLogProvider.notifier);
  return await notifier.getLogsByDate(date);
});

/// 오늘의 복용 로그 프로바이더
final todayLogsProvider = FutureProvider<List<MedicationLog>>((ref) async {
  final notifier = ref.read(apiMedicationLogProvider.notifier);
  return await notifier.getLogsByDate(DateTime.now());
});
