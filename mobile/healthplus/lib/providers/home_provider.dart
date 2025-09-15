import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_model.dart';
import '../services/supabase_service.dart';

/// 홈 화면 상태 관리 클래스
class HomeNotifier extends StateNotifier<List<Medication>> {
  HomeNotifier() : super([]) {
    _loadMedications();
  }

  /// 약 목록 로드
  Future<void> _loadMedications() async {
    try {
      final medicationsData = await SupabaseService.getMedications();
      final medications = medicationsData.map((data) => Medication.fromMap(data)).toList();
      state = medications;
    } catch (e) {
      // 에러 발생 시 샘플 데이터 사용
      state = HomeScreenData.todayMedications;
    }
  }

  /// 약 복용 완료 처리
  Future<void> toggleMedicationCompletion(String medicationId) async {
    try {
      // Supabase에서 복용 기록 업데이트
      final medication = state.firstWhere((med) => med.id == medicationId);
      await SupabaseService.addMedicationRecord(
        medicationId: medicationId,
        date: DateTime.now(),
        time: medication.time,
        status: medication.isCompleted ? 'missed' : 'taken',
      );
      
      // 로컬 상태 업데이트
      state = state.map((medication) {
        if (medication.id == medicationId) {
          return medication.copyWith(isCompleted: !medication.isCompleted);
        }
        return medication;
      }).toList();
    } catch (e) {
      // 에러 발생 시 로컬 상태만 업데이트
      state = state.map((medication) {
        if (medication.id == medicationId) {
          return medication.copyWith(isCompleted: !medication.isCompleted);
        }
        return medication;
      }).toList();
    }
  }

  /// 새로운 약 추가
  Future<void> addMedication(Medication medication) async {
    try {
      // Supabase에 약 정보 저장
      final medicationData = medication.toMap();
      await SupabaseService.addMedication(medicationData: medicationData);
      
      // 로컬 상태 업데이트
      state = [...state, medication];
    } catch (e) {
      // 에러 발생 시 로컬 상태만 업데이트
      state = [...state, medication];
    }
  }

  /// 약 삭제
  Future<void> removeMedication(String medicationId) async {
    try {
      // Supabase에서 약 정보 삭제
      await SupabaseService.deleteMedication(medicationId);
      
      // 로컬 상태 업데이트
      state = state.where((medication) => medication.id != medicationId).toList();
    } catch (e) {
      // 에러 발생 시 로컬 상태만 업데이트
      state = state.where((medication) => medication.id != medicationId).toList();
    }
  }

  /// 약 목록 새로고침
  Future<void> refreshMedications() async {
    await _loadMedications();
  }

  /// 복용 진행률 계산
  MedicationProgress get progress {
    final completed = state.where((med) => med.isCompleted).length;
    final total = state.length;
    return MedicationProgress(completed: completed, total: total);
  }

  /// 다음 복용 예정 약 찾기
  NextDose? get nextDose {
    final incompleteMedications = state.where((med) => !med.isCompleted).toList();
    if (incompleteMedications.isEmpty) return null;

    // 시간 순으로 정렬하여 가장 가까운 약 찾기
    incompleteMedications.sort((a, b) => a.time.compareTo(b.time));
    final nextMed = incompleteMedications.first;

    return NextDose(
      medicationName: nextMed.name,
      timeRemaining: '2시간 30분 후', // 실제로는 현재 시간과 비교해서 계산
      message: '${nextMed.name} 복용 시간입니다',
    );
  }
}

/// 홈 화면 상태 관리 Provider
final homeProvider = StateNotifierProvider<HomeNotifier, List<Medication>>((ref) {
  return HomeNotifier();
});

/// 복용 진행률 Provider
final progressProvider = Provider<MedicationProgress>((ref) {
  final medications = ref.watch(homeProvider);
  final completed = medications.where((med) => med.isCompleted).length;
  final total = medications.length;
  return MedicationProgress(completed: completed, total: total);
});

/// 다음 복용 예정 Provider
final nextDoseProvider = Provider<NextDose?>((ref) {
  final homeNotifier = ref.watch(homeProvider.notifier);
  return homeNotifier.nextDose;
});
