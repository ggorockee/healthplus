import 'medication_log.dart';

/// 복용 로그 목록 응답 모델
class MedicationLogListResponse {
  final List<MedicationLog> logs;
  final int total;
  final String? startDate;
  final String? endDate;

  const MedicationLogListResponse({
    required this.logs,
    required this.total,
    this.startDate,
    this.endDate,
  });

  factory MedicationLogListResponse.fromJson(Map<String, dynamic> json) {
    return MedicationLogListResponse(
      logs: (json['logs'] as List<dynamic>)
          .map((item) => MedicationLog.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logs': logs.map((l) => l.toJson()).toList(),
      'total': total,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

/// 복용 로그 생성 요청 모델
class CreateMedicationLogRequest {
  final String medicationId;
  final DateTime takenAt;
  final bool isTaken;
  final String? note;

  const CreateMedicationLogRequest({
    required this.medicationId,
    required this.takenAt,
    required this.isTaken,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'takenAt': takenAt.toIso8601String(),
      'isTaken': isTaken,
      'note': note,
    };
  }
}

/// 복용 로그 수정 요청 모델
class UpdateMedicationLogRequest {
  final bool? isTaken;
  final String? note;

  const UpdateMedicationLogRequest({
    this.isTaken,
    this.note,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (isTaken != null) json['isTaken'] = isTaken;
    if (note != null) json['note'] = note;
    return json;
  }
}

/// 복용 로그 조회 쿼리 모델
class MedicationLogQuery {
  final String? medicationId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? page;
  final int? limit;

  const MedicationLogQuery({
    this.medicationId,
    this.startDate,
    this.endDate,
    this.page,
    this.limit,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    if (medicationId != null) params['medicationId'] = medicationId;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String().split('T')[0];
    if (endDate != null) params['endDate'] = endDate!.toIso8601String().split('T')[0];
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    return params;
  }
}
