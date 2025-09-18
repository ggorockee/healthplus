import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication.dart';
import '../repositories/medication_repository.dart';
import 'repository_provider.dart';

/// 약물 상태 관리
class MedicationState {
  final List<Medication> medications;
  final bool isLoading;
  final String? errorMessage;
  final bool isRefreshing;

  const MedicationState({
    this.medications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isRefreshing = false,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    bool? isLoading,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  String toString() {
    return 'MedicationState(medications: ${medications.length}, isLoading: $isLoading, errorMessage: $errorMessage, isRefreshing: $isRefreshing)';
  }
}

/// API 기반 약물 상태 관리 프로바이더
class ApiMedicationNotifier extends StateNotifier<MedicationState> {
  ApiMedicationNotifier(this._repository) : super(const MedicationState()) {
    _loadMedications();
  }

  final MedicationRepository _repository;

  /// 약물 목록 로드
  Future<void> _loadMedications() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final medications = await _repository.getMedications();
      
      state = state.copyWith(
        medications: medications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 약물 목록 새로고침
  Future<void> refreshMedications() async {
    try {
      state = state.copyWith(isRefreshing: true, errorMessage: null);
      
      final medications = await _repository.getMedications();
      
      state = state.copyWith(
        medications: medications,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 약물 추가
  Future<void> addMedication(Medication medication) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final newMedication = await _repository.addMedication(medication);
      
      state = state.copyWith(
        medications: [...state.medications, newMedication],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow; // UI에서 에러 처리할 수 있도록 rethrow
    }
  }

  /// 약물 수정
  Future<void> updateMedication(Medication medication) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedMedication = await _repository.updateMedication(medication);
      
      final updatedMedications = state.medications.map((m) {
        return m.id == medication.id ? updatedMedication : m;
      }).toList();
      
      state = state.copyWith(
        medications: updatedMedications,
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

  /// 약물 삭제
  Future<void> deleteMedication(String medicationId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _repository.deleteMedication(medicationId);
      
      state = state.copyWith(
        medications: state.medications.where((m) => m.id != medicationId).toList(),
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

  /// 약물 활성화/비활성화 토글
  Future<void> toggleMedication(String medicationId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final updatedMedication = await _repository.toggleMedication(medicationId);
      
      final updatedMedications = state.medications.map((m) {
        return m.id == medicationId ? updatedMedication : m;
      }).toList();
      
      state = state.copyWith(
        medications: updatedMedications,
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

  /// 오늘의 약물 목록 가져오기
  Future<List<Medication>> getTodayMedications() async {
    try {
      return await _repository.getTodayMedications();
    } catch (e) {
      // API 실패 시 로컬에서 계산
      final today = DateTime.now().weekday % 7;
      return state.medications.where((medication) {
        return medication.isActive && 
               (medication.repeatDays.isEmpty || medication.repeatDays.contains(today));
      }).toList();
    }
  }

  /// 특정 약물 조회
  Future<Medication?> getMedication(String id) async {
    try {
      return await _repository.getMedication(id);
    } catch (e) {
      // API 실패 시 로컬에서 검색
      try {
        return state.medications.firstWhere((med) => med.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// API 기반 약물 프로바이더
final apiMedicationProvider = StateNotifierProvider<ApiMedicationNotifier, MedicationState>((ref) {
  final repository = ref.watch(dynamicMedicationRepositoryProvider);
  return ApiMedicationNotifier(repository);
});

/// 약물 목록 프로바이더 (간편 접근용)
final medicationsProvider = Provider<List<Medication>>((ref) {
  final medicationState = ref.watch(apiMedicationProvider);
  return medicationState.medications;
});

/// 오늘의 약물 목록 프로바이더
final apiTodayMedicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final notifier = ref.read(apiMedicationProvider.notifier);
  return await notifier.getTodayMedications();
});

/// 약물 로딩 상태 프로바이더
final medicationLoadingProvider = Provider<bool>((ref) {
  final medicationState = ref.watch(apiMedicationProvider);
  return medicationState.isLoading || medicationState.isRefreshing;
});

/// 약물 에러 상태 프로바이더
final medicationErrorProvider = Provider<String?>((ref) {
  final medicationState = ref.watch(apiMedicationProvider);
  return medicationState.errorMessage;
});

/// 특정 약물 프로바이더
final medicationByIdProvider = FutureProvider.family<Medication?, String>((ref, id) async {
  final notifier = ref.read(apiMedicationProvider.notifier);
  return await notifier.getMedication(id);
});
