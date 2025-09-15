/// 약 정보 모델
class Medication {
  final String id;
  final String name;
  final String time;
  final bool isCompleted;
  final String? dosage;
  final String? notes;

  const Medication({
    required this.id,
    required this.name,
    required this.time,
    required this.isCompleted,
    this.dosage,
    this.notes,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? time,
    bool? isCompleted,
    String? dosage,
    String? notes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
    );
  }

  /// Supabase Map에서 Medication 객체 생성
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
      isCompleted: map['is_completed'] ?? false,
      dosage: map['dosage']?.toString(),
      notes: map['notes']?.toString(),
    );
  }

  /// Medication 객체를 Supabase Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'is_completed': isCompleted,
      'dosage': dosage,
      'notes': notes,
    };
  }
}

/// 복용 진행률 정보
class MedicationProgress {
  final int completed;
  final int total;
  final double percentage;

  const MedicationProgress({
    required this.completed,
    required this.total,
  }) : percentage = total > 0 ? completed / total : 0.0;
}

/// 다음 복용 예정 정보
class NextDose {
  final String medicationName;
  final String timeRemaining;
  final String message;

  const NextDose({
    required this.medicationName,
    required this.timeRemaining,
    required this.message,
  });
}

/// 홈 화면 데이터
class HomeScreenData {
  /// 오늘 복용할 약 목록
  static const List<Medication> todayMedications = [
    Medication(
      id: '1',
      name: '타이레놀',
      time: '08:00',
      isCompleted: true,
      dosage: '500mg',
    ),
    Medication(
      id: '2',
      name: '혈압약',
      time: '12:00',
      isCompleted: false,
      dosage: '10mg',
    ),
    Medication(
      id: '3',
      name: '소화제',
      time: '18:00',
      isCompleted: false,
      dosage: '1정',
    ),
  ];

  /// 복용 진행률
  static const MedicationProgress progress = MedicationProgress(
    completed: 3,
    total: 5,
  );

  /// 다음 복용 예정
  static const NextDose nextDose = NextDose(
    medicationName: '혈압약',
    timeRemaining: '2시간 30분 후',
    message: '혈압약 복용 시간입니다',
  );
}
