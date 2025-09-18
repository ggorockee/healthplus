/// 약물 복용 통계 응답 모델
class MedicationStatsResponse {
  final int totalMedications;
  final int totalLogs;
  final double complianceRate;
  final MostTakenMedication? mostTakenMedication;
  final List<DailyStat> dailyStats;

  const MedicationStatsResponse({
    required this.totalMedications,
    required this.totalLogs,
    required this.complianceRate,
    this.mostTakenMedication,
    required this.dailyStats,
  });

  factory MedicationStatsResponse.fromJson(Map<String, dynamic> json) {
    return MedicationStatsResponse(
      totalMedications: json['totalMedications'] as int,
      totalLogs: json['totalLogs'] as int,
      complianceRate: (json['complianceRate'] as num).toDouble(),
      mostTakenMedication: json['mostTakenMedication'] != null
          ? MostTakenMedication.fromJson(json['mostTakenMedication'] as Map<String, dynamic>)
          : null,
      dailyStats: (json['dailyStats'] as List<dynamic>)
          .map((item) => DailyStat.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMedications': totalMedications,
      'totalLogs': totalLogs,
      'complianceRate': complianceRate,
      'mostTakenMedication': mostTakenMedication?.toJson(),
      'dailyStats': dailyStats.map((stat) => stat.toJson()).toList(),
    };
  }
}

/// 가장 많이 복용된 약물 모델
class MostTakenMedication {
  final String id;
  final String name;
  final int count;

  const MostTakenMedication({
    required this.id,
    required this.name,
    required this.count,
  });

  factory MostTakenMedication.fromJson(Map<String, dynamic> json) {
    return MostTakenMedication(
      id: json['id'] as String,
      name: json['name'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'count': count,
    };
  }
}

/// 일별 통계 모델
class DailyStat {
  final String date;
  final int total;
  final int taken;
  final int missed;

  const DailyStat({
    required this.date,
    required this.total,
    required this.taken,
    required this.missed,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: json['date'] as String,
      total: json['total'] as int,
      taken: json['taken'] as int,
      missed: json['missed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total': total,
      'taken': taken,
      'missed': missed,
    };
  }

  /// 복용률 계산
  double get complianceRate {
    if (total == 0) return 0.0;
    return (taken / total) * 100;
  }
}

/// 복용 준수율 응답 모델
class ComplianceRateResponse {
  final String medicationId;
  final String medicationName;
  final String period;
  final double complianceRate;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;

  const ComplianceRateResponse({
    required this.medicationId,
    required this.medicationName,
    required this.period,
    required this.complianceRate,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
  });

  factory ComplianceRateResponse.fromJson(Map<String, dynamic> json) {
    return ComplianceRateResponse(
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      period: json['period'] as String,
      complianceRate: (json['complianceRate'] as num).toDouble(),
      totalDoses: json['totalDoses'] as int,
      takenDoses: json['takenDoses'] as int,
      missedDoses: json['missedDoses'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'period': period,
      'complianceRate': complianceRate,
      'totalDoses': totalDoses,
      'takenDoses': takenDoses,
      'missedDoses': missedDoses,
    };
  }
}

/// 복용 히스토리 응답 모델
class HistoryResponse {
  final String medicationId;
  final String medicationName;
  final String period;
  final List<HistoryEntry> history;

  const HistoryResponse({
    required this.medicationId,
    required this.medicationName,
    required this.period,
    required this.history,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    return HistoryResponse(
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      period: json['period'] as String,
      history: (json['history'] as List<dynamic>)
          .map((item) => HistoryEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'period': period,
      'history': history.map((entry) => entry.toJson()).toList(),
    };
  }
}

/// 히스토리 엔트리 모델
class HistoryEntry {
  final String date;
  final bool isTaken;
  final String? note;
  final DateTime takenAt;

  const HistoryEntry({
    required this.date,
    required this.isTaken,
    this.note,
    required this.takenAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      date: json['date'] as String,
      isTaken: json['isTaken'] as bool,
      note: json['note'] as String?,
      takenAt: DateTime.parse(json['takenAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'isTaken': isTaken,
      'note': note,
      'takenAt': takenAt.toIso8601String(),
    };
  }
}

/// 분석 요약 응답 모델
class AnalyticsSummaryResponse {
  final String period;
  final double overallComplianceRate;
  final int totalMedications;
  final int activeMedications;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final List<MedicationSummary> medicationSummaries;
  final List<WeeklyTrend> weeklyTrends;

  const AnalyticsSummaryResponse({
    required this.period,
    required this.overallComplianceRate,
    required this.totalMedications,
    required this.activeMedications,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.medicationSummaries,
    required this.weeklyTrends,
  });

  factory AnalyticsSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryResponse(
      period: json['period'] as String,
      overallComplianceRate: (json['overallComplianceRate'] as num).toDouble(),
      totalMedications: json['totalMedications'] as int,
      activeMedications: json['activeMedications'] as int,
      totalDoses: json['totalDoses'] as int,
      takenDoses: json['takenDoses'] as int,
      missedDoses: json['missedDoses'] as int,
      medicationSummaries: (json['medicationSummaries'] as List<dynamic>)
          .map((item) => MedicationSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      weeklyTrends: (json['weeklyTrends'] as List<dynamic>)
          .map((item) => WeeklyTrend.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'overallComplianceRate': overallComplianceRate,
      'totalMedications': totalMedications,
      'activeMedications': activeMedications,
      'totalDoses': totalDoses,
      'takenDoses': takenDoses,
      'missedDoses': missedDoses,
      'medicationSummaries': medicationSummaries.map((summary) => summary.toJson()).toList(),
      'weeklyTrends': weeklyTrends.map((trend) => trend.toJson()).toList(),
    };
  }
}

/// 약물 요약 모델
class MedicationSummary {
  final String id;
  final String name;
  final double complianceRate;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;

  const MedicationSummary({
    required this.id,
    required this.name,
    required this.complianceRate,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
  });

  factory MedicationSummary.fromJson(Map<String, dynamic> json) {
    return MedicationSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      complianceRate: (json['complianceRate'] as num).toDouble(),
      totalDoses: json['totalDoses'] as int,
      takenDoses: json['takenDoses'] as int,
      missedDoses: json['missedDoses'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'complianceRate': complianceRate,
      'totalDoses': totalDoses,
      'takenDoses': takenDoses,
      'missedDoses': missedDoses,
    };
  }
}

/// 주간 트렌드 모델
class WeeklyTrend {
  final String week;
  final double complianceRate;
  final int totalDoses;
  final int takenDoses;

  const WeeklyTrend({
    required this.week,
    required this.complianceRate,
    required this.totalDoses,
    required this.takenDoses,
  });

  factory WeeklyTrend.fromJson(Map<String, dynamic> json) {
    return WeeklyTrend(
      week: json['week'] as String,
      complianceRate: (json['complianceRate'] as num).toDouble(),
      totalDoses: json['totalDoses'] as int,
      takenDoses: json['takenDoses'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'complianceRate': complianceRate,
      'totalDoses': totalDoses,
      'takenDoses': takenDoses,
    };
  }
}
