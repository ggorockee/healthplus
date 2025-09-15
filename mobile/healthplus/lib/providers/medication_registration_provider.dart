import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_registration_model.dart';
import '../models/home_model.dart';
import '../providers/home_provider.dart';
import '../services/supabase_service.dart';

/// 약 등록 상태 관리 클래스
class MedicationRegistrationNotifier extends StateNotifier<MedicationRegistration> {
  MedicationRegistrationNotifier() : super(MedicationRegistrationDefaults.initial);

  /// 약품명 업데이트
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  /// 약 사진 경로 업데이트
  void updateImagePath(String? imagePath) {
    state = state.copyWith(imagePath: imagePath);
  }

  /// 하루 복용 횟수 업데이트
  void updateDailyDosageCount(int count) {
    state = state.copyWith(dailyDosageCount: count);
  }

  /// 복용 시간 추가
  void addDosageTime(String time) {
    final newTimes = [...state.dosageTimes, time];
    state = state.copyWith(dosageTimes: newTimes);
  }

  /// 복용 시간 제거
  void removeDosageTime(int index) {
    final newTimes = List<String>.from(state.dosageTimes);
    newTimes.removeAt(index);
    state = state.copyWith(dosageTimes: newTimes);
  }

  /// 복용 시간 업데이트
  void updateDosageTime(int index, String time) {
    final newTimes = List<String>.from(state.dosageTimes);
    newTimes[index] = time;
    state = state.copyWith(dosageTimes: newTimes);
  }

  /// 약 형태 업데이트
  void updateForm(MedicationForm form) {
    state = state.copyWith(form: form);
  }

  /// 1회 복용량 업데이트
  void updateSingleDosageAmount(int amount) {
    state = state.copyWith(singleDosageAmount: amount);
  }

  /// 복용량 단위 업데이트
  void updateDosageUnit(DosageUnit unit) {
    state = state.copyWith(dosageUnit: unit);
  }

  /// 식사 관계 토글
  void toggleMealRelation() {
    state = state.copyWith(hasMealRelation: !state.hasMealRelation);
  }

  /// 식사 관계 업데이트
  void updateMealRelation(MealRelation? relation) {
    state = state.copyWith(mealRelation: relation);
  }

  /// 지속 복용 토글
  void toggleContinuous() {
    state = state.copyWith(isContinuous: !state.isContinuous);
  }

  /// 메모 업데이트
  void updateMemo(String? memo) {
    state = state.copyWith(memo: memo);
  }

  /// 약 등록 완료
  Future<bool> saveMedication(WidgetRef ref) async {
    try {
      // Supabase에 약 정보 저장
      final medicationData = _convertToMedicationData();
      await SupabaseService.addMedication(medicationData: medicationData);
      
      // Medication 모델로 변환하여 홈 화면에 추가
      final newMedication = Medication.fromMap(medicationData);
      await ref.read(homeProvider.notifier).addMedication(newMedication);
      
      // 상태 초기화
      state = MedicationRegistrationDefaults.initial;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 약 정보를 Supabase 형식으로 변환
  Map<String, dynamic> _convertToMedicationData() {
    return {
      'name': state.name,
      'image_path': state.imagePath,
      'daily_dosage_count': state.dailyDosageCount,
      'dosage_times': state.dosageTimes,
      'form': state.form.name,
      'single_dosage_amount': state.singleDosageAmount,
      'dosage_unit': state.dosageUnit.name,
      'meal_relation': state.mealRelation?.name,
      'is_continuous': state.isContinuous,
      'memo': state.memo,
    };
  }

  /// 폼 유효성 검사
  bool get isValid {
    return state.name.isNotEmpty && 
           state.dosageTimes.isNotEmpty &&
           state.singleDosageAmount > 0;
  }
}

/// 약 등록 상태 관리 Provider
final medicationRegistrationProvider = StateNotifierProvider<MedicationRegistrationNotifier, MedicationRegistration>((ref) {
  return MedicationRegistrationNotifier();
});

/// 약 등록 폼 유효성 Provider
final medicationRegistrationValidProvider = Provider<bool>((ref) {
  final registration = ref.watch(medicationRegistrationProvider);
  return registration.name.isNotEmpty && 
         registration.dosageTimes.isNotEmpty &&
         registration.singleDosageAmount > 0;
});
