import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medication_log.dart';

/// 약물 복용 기록 상태 관리
class MedicationLogNotifier extends StateNotifier<List<MedicationLog>> {
  MedicationLogNotifier() : super([]) {
    _loadLogs();
  }

  /// 복용 기록 추가
  Future<void> addLog(MedicationLog log) async {
    // 같은 날짜의 기존 기록이 있으면 업데이트
    final existingIndex = state.indexWhere((l) => 
        l.medicationId == log.medicationId && 
        _isSameDay(l.takenAt, log.takenAt));
    
    if (existingIndex >= 0) {
      state = [
        ...state.sublist(0, existingIndex),
        log,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, log];
    }
    await _saveLogs();
  }

  /// 복용 기록 업데이트
  Future<void> updateLog(MedicationLog log) async {
    state = state.map((l) => l.id == log.id ? log : l).toList();
    await _saveLogs();
  }

  /// 복용 기록 삭제
  Future<void> deleteLog(String logId) async {
    state = state.where((l) => l.id != logId).toList();
    await _saveLogs();
  }

  /// 특정 약물의 오늘 복용 기록 가져오기
  MedicationLog? getTodayLog(String medicationId) {
    final today = DateTime.now();
    try {
      return state.firstWhere((log) => 
          log.medicationId == medicationId && 
          _isSameDay(log.takenAt, today));
    } catch (e) {
      return null;
    }
  }

  /// 특정 약물의 특정 날짜 복용 기록 가져오기
  MedicationLog? getLogForDate(String medicationId, DateTime date) {
    try {
      return state.firstWhere((log) => 
          log.medicationId == medicationId && 
          _isSameDay(log.takenAt, date));
    } catch (e) {
      return null;
    }
  }

  /// 특정 약물의 복용 기록 목록 가져오기
  List<MedicationLog> getLogsForMedication(String medicationId) {
    return state.where((log) => log.medicationId == medicationId).toList();
  }

  /// 특정 날짜의 모든 복용 기록 가져오기
  List<MedicationLog> getLogsForDate(DateTime date) {
    return state.where((log) => _isSameDay(log.takenAt, date)).toList();
  }

  /// 복용률 계산 (최근 7일)
  double getAdherenceRate(String medicationId) {
    final logs = getLogsForMedication(medicationId);
    final now = DateTime.now();
    int takenCount = 0;
    int totalCount = 0;

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final log = getLogForDate(medicationId, date);
      totalCount++;
      if (log != null && log.isTaken) {
        takenCount++;
      }
    }

    return totalCount > 0 ? takenCount / totalCount : 0.0;
  }

  /// 같은 날인지 확인
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 로컬 저장소에서 복용 기록 로드
  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList('medication_logs') ?? [];
      final logs = logsJson
          .map((json) => MedicationLog.fromJson(jsonDecode(json)))
          .toList();
      state = logs;
    } catch (e) {
      debugPrint('복용 기록 로드 실패: $e');
    }
  }

  /// 로컬 저장소에 복용 기록 저장
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = state
          .map((log) => jsonEncode(log.toJson()))
          .toList();
      await prefs.setStringList('medication_logs', logsJson);
    } catch (e) {
      debugPrint('복용 기록 저장 실패: $e');
    }
  }
}

/// 복용 기록 프로바이더
final medicationLogProvider = StateNotifierProvider<MedicationLogNotifier, List<MedicationLog>>(
  (ref) => MedicationLogNotifier(),
);

/// 특정 약물의 오늘 복용 기록 프로바이더
final todayLogProvider = Provider.family<MedicationLog?, String>((ref, medicationId) {
  final logs = ref.watch(medicationLogProvider);
  final today = DateTime.now();
  try {
    return logs.firstWhere((log) => 
        log.medicationId == medicationId && 
        log.takenAt.year == today.year &&
        log.takenAt.month == today.month &&
        log.takenAt.day == today.day);
  } catch (e) {
    return null;
  }
});
