import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medication.dart';

/// 약물 목록 상태 관리
class MedicationNotifier extends StateNotifier<List<Medication>> {
  MedicationNotifier() : super([]) {
    _loadMedications();
  }

  /// 약물 추가
  Future<void> addMedication(Medication medication) async {
    state = [...state, medication];
    await _saveMedications();
  }

  /// 약물 수정
  Future<void> updateMedication(Medication medication) async {
    state = state.map((m) => m.id == medication.id ? medication : m).toList();
    await _saveMedications();
  }

  /// 약물 삭제
  Future<void> deleteMedication(String medicationId) async {
    state = state.where((m) => m.id != medicationId).toList();
    await _saveMedications();
  }

  /// 약물 활성화/비활성화 토글
  Future<void> toggleMedication(String medicationId) async {
    state = state.map((m) {
      if (m.id == medicationId) {
        return m.copyWith(isActive: !m.isActive);
      }
      return m;
    }).toList();
    await _saveMedications();
  }

  /// 오늘 복용해야 할 약물 목록
  List<Medication> getTodayMedications() {
    final today = DateTime.now().weekday % 7; // 0=일요일, 1=월요일, ...
    return state.where((medication) {
      return medication.isActive && 
             (medication.repeatDays.isEmpty || medication.repeatDays.contains(today));
    }).toList();
  }

  /// 로컬 저장소에서 약물 목록 로드
  Future<void> _loadMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = prefs.getStringList('medications') ?? [];
      final medications = medicationsJson
          .map((json) => Medication.fromJson(jsonDecode(json)))
          .toList();
      state = medications;
    } catch (e) {
      debugPrint('약물 목록 로드 실패: $e');
    }
  }

  /// 로컬 저장소에 약물 목록 저장
  Future<void> _saveMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = state
          .map((medication) => jsonEncode(medication.toJson()))
          .toList();
      await prefs.setStringList('medications', medicationsJson);
    } catch (e) {
      debugPrint('약물 목록 저장 실패: $e');
    }
  }
}

/// 약물 목록 프로바이더
final medicationProvider = StateNotifierProvider<MedicationNotifier, List<Medication>>(
  (ref) => MedicationNotifier(),
);

/// 오늘의 약물 목록 프로바이더
final todayMedicationsProvider = Provider<List<Medication>>((ref) {
  final medications = ref.watch(medicationProvider);
  final today = DateTime.now().weekday % 7;
  return medications.where((medication) {
    return medication.isActive && 
           (medication.repeatDays.isEmpty || medication.repeatDays.contains(today));
  }).toList();
});
