import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_history_model.dart';
import '../services/supabase_service.dart';

/// 복용 기록 상태 관리 클래스
class MedicationHistoryNotifier extends StateNotifier<Map<DateTime, DailyMedicationRecord>> {
  MedicationHistoryNotifier() : super({}) {
    _loadHistoryData();
  }

  /// 복용 기록 데이터 로드
  Future<void> _loadHistoryData() async {
    try {
      // Supabase에서 복용 기록 가져오기
      final records = await SupabaseService.getMedicationRecords(date: DateTime.now());
      
      // 데이터 변환
      final historyMap = <DateTime, DailyMedicationRecord>{};
      for (final record in records) {
        final date = DateTime.parse(record['date']);
        final dose = MedicationDose.fromMap(record);
        
        if (historyMap.containsKey(date)) {
          historyMap[date]!.doses.add(dose);
        } else {
          historyMap[date] = DailyMedicationRecord(
            date: date,
            doses: [dose],
            completionRate: 0.0,
            overallStatus: MedicationStatus.taken,
          );
        }
      }
      
      state = historyMap;
    } catch (e) {
      // 에러 발생 시 샘플 데이터 사용
      _initializeSampleData();
    }
  }

  /// 샘플 데이터 초기화
  void _initializeSampleData() {
    // 9월 데이터 초기화
    for (int day = 1; day <= 30; day++) {
      final date = DateTime(2025, 9, day);
      final status = MedicationHistoryData.septemberCalendarStatus[day] ?? MedicationStatus.taken;
      
      // 9월 15일은 특별한 데이터 사용
      if (day == 15) {
        state = {
          ...state,
          date: MedicationHistoryData.september15.copyWith(date: date),
        };
      } else {
        // 기본 데이터 생성
        state = {
          ...state,
          date: DailyMedicationRecord(
            date: date,
            doses: _generateSampleDoses(day, status),
            completionRate: _calculateCompletionRate(status),
            overallStatus: status,
          ),
        };
      }
    }
  }

  /// 샘플 복용 기록 생성
  List<MedicationDose> _generateSampleDoses(int day, MedicationStatus status) {
    return [
      MedicationDose(
        id: '${day}_1',
        medicationName: '타이레놀',
        time: '08:00',
        status: status == MedicationStatus.missed ? MedicationStatus.missed : MedicationStatus.taken,
      ),
      MedicationDose(
        id: '${day}_2',
        medicationName: '혈압약',
        time: '12:00',
        status: status == MedicationStatus.missed ? MedicationStatus.missed : MedicationStatus.taken,
      ),
      MedicationDose(
        id: '${day}_3',
        medicationName: '소화제',
        time: '18:00',
        status: status,
      ),
    ];
  }

  /// 완료율 계산
  double _calculateCompletionRate(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return 1.0;
      case MedicationStatus.delayed:
        return 0.8;
      case MedicationStatus.missed:
        return 0.0;
    }
  }

  /// 특정 날짜의 복용 기록 가져오기
  DailyMedicationRecord? getRecordForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return state[key];
  }

  /// 월간 통계 계산
  MonthlyStatistics getMonthlyStatistics(DateTime month) {
    final records = state.values.where((record) => 
      record.date.year == month.year && 
      record.date.month == month.month
    ).toList();

    if (records.isEmpty) {
      return MedicationHistoryData.monthlyStats;
    }

    final totalDays = records.length;
    final completedDays = records.where((r) => r.overallStatus == MedicationStatus.taken).length;
    final averageCompletionRate = records.fold<double>(0, (sum, record) => sum + record.completionRate) / totalDays;
    
    // 연속 복용일 계산
    int consecutiveDays = 0;
    final sortedRecords = records..sort((a, b) => a.date.compareTo(b.date));
    for (final record in sortedRecords.reversed) {
      if (record.overallStatus == MedicationStatus.taken) {
        consecutiveDays++;
      } else {
        break;
      }
    }

    // 베스트 시간 계산 (가장 많이 복용한 시간대)
    final timeCounts = <String, int>{};
    for (final record in records) {
      for (final dose in record.doses) {
        if (dose.status == MedicationStatus.taken) {
          timeCounts[dose.time] = (timeCounts[dose.time] ?? 0) + 1;
        }
      }
    }
    
    String bestTime = '아침';
    int maxCount = 0;
    timeCounts.forEach((time, count) {
      if (count > maxCount) {
        maxCount = count;
        if (time == '08:00') {
          bestTime = '아침';
        } else if (time == '12:00') {
          bestTime = '점심';
        } else if (time == '18:00') {
          bestTime = '저녁';
        }
      }
    });

    return MonthlyStatistics(
      averageCompletionRate: averageCompletionRate,
      consecutiveDays: consecutiveDays,
      bestTime: bestTime,
      totalDays: totalDays,
      completedDays: completedDays,
    );
  }

  /// 복용 상태 업데이트
  void updateMedicationStatus(DateTime date, String doseId, MedicationStatus status) {
    final key = DateTime(date.year, date.month, date.day);
    final record = state[key];
    
    if (record != null) {
      final updatedDoses = record.doses.map((dose) {
        if (dose.id == doseId) {
          return dose.copyWith(status: status);
        }
        return dose;
      }).toList();

      final completedCount = updatedDoses.where((d) => d.status == MedicationStatus.taken).length;
      final completionRate = completedCount / updatedDoses.length;
      
      final overallStatus = completionRate == 1.0 
          ? MedicationStatus.taken 
          : completionRate == 0.0 
              ? MedicationStatus.missed 
              : MedicationStatus.delayed;

      state = {
        ...state,
        key: record.copyWith(
          doses: updatedDoses,
          completionRate: completionRate,
          overallStatus: overallStatus,
        ),
      };
    }
  }
}

/// 복용 기록 상태 관리 Provider
final medicationHistoryProvider = StateNotifierProvider<MedicationHistoryNotifier, Map<DateTime, DailyMedicationRecord>>((ref) {
  return MedicationHistoryNotifier();
});

/// 특정 날짜의 복용 기록 Provider
final dailyRecordProvider = Provider.family<DailyMedicationRecord?, DateTime>((ref, date) {
  return ref.read(medicationHistoryProvider.notifier).getRecordForDate(date);
});

/// 월간 통계 Provider
final monthlyStatisticsProvider = Provider.family<MonthlyStatistics, DateTime>((ref, month) {
  final notifier = ref.read(medicationHistoryProvider.notifier);
  return notifier.getMonthlyStatistics(month);
});
