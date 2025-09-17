/// 약물 복용 기록 모델
class MedicationLog {
  final String id;
  final String medicationId; // 약물 ID 참조
  final DateTime takenAt; // 복용한 시간
  final bool isTaken; // 복용 여부
  final String? note; // 메모 (선택사항)

  const MedicationLog({
    required this.id,
    required this.medicationId,
    required this.takenAt,
    required this.isTaken,
    this.note,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'takenAt': takenAt.toIso8601String(),
      'isTaken': isTaken,
      'note': note,
    };
  }

  /// JSON 역직렬화
  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      takenAt: DateTime.parse(json['takenAt'] as String),
      isTaken: json['isTaken'] as bool,
      note: json['note'] as String?,
    );
  }

  /// 복사본 생성
  MedicationLog copyWith({
    String? id,
    String? medicationId,
    DateTime? takenAt,
    bool? isTaken,
    String? note,
  }) {
    return MedicationLog(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      takenAt: takenAt ?? this.takenAt,
      isTaken: isTaken ?? this.isTaken,
      note: note ?? this.note,
    );
  }

  /// 오늘 복용했는지 확인
  bool isTakenToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(takenAt.year, takenAt.month, takenAt.day);
    return logDate.isAtSameMomentAs(today) && isTaken;
  }

  /// 특정 날짜에 복용했는지 확인
  bool isTakenOnDate(DateTime date) {
    final logDate = DateTime(takenAt.year, takenAt.month, takenAt.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return logDate.isAtSameMomentAs(targetDate) && isTaken;
  }
}
