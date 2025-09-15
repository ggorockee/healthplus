/// 복용 상태 열거형
enum MedicationStatus {
  taken('복용완료', '복용 완료'),
  missed('복용안함', '복용 안함'),
  delayed('지연복용', '지연 복용');

  const MedicationStatus(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 일별 복용 기록 모델
class DailyMedicationRecord {
  final DateTime date;
  final List<MedicationDose> doses;
  final double completionRate;
  final MedicationStatus overallStatus;

  const DailyMedicationRecord({
    required this.date,
    required this.doses,
    required this.completionRate,
    required this.overallStatus,
  });

  DailyMedicationRecord copyWith({
    DateTime? date,
    List<MedicationDose>? doses,
    double? completionRate,
    MedicationStatus? overallStatus,
  }) {
    return DailyMedicationRecord(
      date: date ?? this.date,
      doses: doses ?? this.doses,
      completionRate: completionRate ?? this.completionRate,
      overallStatus: overallStatus ?? this.overallStatus,
    );
  }
}

/// 약 복용 기록 모델
class MedicationDose {
  final String id;
  final String medicationName;
  final String time;
  final MedicationStatus status;
  final String? delayReason;
  final DateTime? takenAt;

  const MedicationDose({
    required this.id,
    required this.medicationName,
    required this.time,
    required this.status,
    this.delayReason,
    this.takenAt,
  });

  MedicationDose copyWith({
    String? id,
    String? medicationName,
    String? time,
    MedicationStatus? status,
    String? delayReason,
    DateTime? takenAt,
  }) {
    return MedicationDose(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      time: time ?? this.time,
      status: status ?? this.status,
      delayReason: delayReason ?? this.delayReason,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  /// Supabase Map에서 MedicationDose 객체 생성
  factory MedicationDose.fromMap(Map<String, dynamic> map) {
    return MedicationDose(
      id: map['id']?.toString() ?? '',
      medicationName: map['medications']?['name']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
      status: _parseStatus(map['status']?.toString()),
      delayReason: map['delay_reason']?.toString(),
      takenAt: map['taken_at'] != null ? DateTime.parse(map['taken_at']) : null,
    );
  }

  /// MedicationDose 객체를 Supabase Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medication_name': medicationName,
      'time': time,
      'status': status.name,
      'delay_reason': delayReason,
      'taken_at': takenAt?.toIso8601String(),
    };
  }

  /// 상태 문자열을 MedicationStatus로 변환
  static MedicationStatus _parseStatus(String? status) {
    switch (status) {
      case 'taken':
        return MedicationStatus.taken;
      case 'missed':
        return MedicationStatus.missed;
      case 'delayed':
        return MedicationStatus.delayed;
      default:
        return MedicationStatus.taken;
    }
  }
}

/// 월간 통계 모델
class MonthlyStatistics {
  final double averageCompletionRate;
  final int consecutiveDays;
  final String bestTime;
  final int totalDays;
  final int completedDays;

  const MonthlyStatistics({
    required this.averageCompletionRate,
    required this.consecutiveDays,
    required this.bestTime,
    required this.totalDays,
    required this.completedDays,
  });
}

/// 복용 기록 샘플 데이터
class MedicationHistoryData {
  /// 9월 15일 샘플 데이터
  static DailyMedicationRecord get september15 => DailyMedicationRecord(
    date: DateTime(2025, 9, 15),
    doses: [
      MedicationDose(
        id: '1',
        medicationName: '타이레놀',
        time: '08:00',
        status: MedicationStatus.taken,
        takenAt: null, // DateTime(2025, 9, 15, 8, 0),
      ),
      MedicationDose(
        id: '2',
        medicationName: '혈압약',
        time: '08:00',
        status: MedicationStatus.taken,
        takenAt: null, // DateTime(2025, 9, 15, 8, 5),
      ),
      MedicationDose(
        id: '3',
        medicationName: '소화제',
        time: '12:00',
        status: MedicationStatus.missed,
      ),
      MedicationDose(
        id: '4',
        medicationName: '종합비타민',
        time: '18:00',
        status: MedicationStatus.delayed,
        delayReason: '30분 지연',
        takenAt: null, // DateTime(2025, 9, 15, 18, 30),
      ),
    ],
    completionRate: 0.85,
    overallStatus: MedicationStatus.taken,
  );

  /// 월간 통계 샘플 데이터
  static const MonthlyStatistics monthlyStats = MonthlyStatistics(
    averageCompletionRate: 0.87,
    consecutiveDays: 12,
    bestTime: '아침',
    totalDays: 30,
    completedDays: 26,
  );

  /// 달력 상태 점 샘플 데이터 (9월)
  static const Map<int, MedicationStatus> septemberCalendarStatus = {
    1: MedicationStatus.taken,
    2: MedicationStatus.taken,
    3: MedicationStatus.delayed,
    4: MedicationStatus.taken,
    5: MedicationStatus.taken,
    6: MedicationStatus.missed,
    7: MedicationStatus.taken,
    8: MedicationStatus.taken,
    9: MedicationStatus.taken,
    10: MedicationStatus.taken,
    11: MedicationStatus.taken,
    12: MedicationStatus.taken,
    13: MedicationStatus.taken,
    14: MedicationStatus.taken,
    15: MedicationStatus.taken,
    16: MedicationStatus.taken,
    17: MedicationStatus.taken,
    18: MedicationStatus.taken,
    19: MedicationStatus.taken,
    20: MedicationStatus.taken,
    21: MedicationStatus.taken,
    22: MedicationStatus.taken,
    23: MedicationStatus.taken,
    24: MedicationStatus.taken,
    25: MedicationStatus.taken,
    26: MedicationStatus.taken,
    27: MedicationStatus.taken,
    28: MedicationStatus.taken,
    29: MedicationStatus.taken,
    30: MedicationStatus.missed,
  };
}
