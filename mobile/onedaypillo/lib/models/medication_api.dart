import 'package:flutter/material.dart';
import 'medication.dart';

/// 약물 목록 응답 모델
class MedicationListResponse {
  final List<Medication> medications;
  final int total;

  const MedicationListResponse({
    required this.medications,
    required this.total,
  });

  factory MedicationListResponse.fromJson(Map<String, dynamic> json) {
    return MedicationListResponse(
      medications: (json['medications'] as List<dynamic>)
          .map((item) => Medication.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medications': medications.map((m) => m.toJson()).toList(),
      'total': total,
    };
  }
}

/// 약물 생성 요청 모델
class CreateMedicationRequest {
  final String name;
  final String dosage;
  final TimeOfDay notificationTime;
  final List<int> repeatDays;

  const CreateMedicationRequest({
    required this.name,
    required this.dosage,
    required this.notificationTime,
    required this.repeatDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'notificationTime': {
        'hour': notificationTime.hour,
        'minute': notificationTime.minute,
      },
      'repeatDays': repeatDays,
    };
  }
}

/// 약물 수정 요청 모델
class UpdateMedicationRequest {
  final String? name;
  final String? dosage;
  final TimeOfDay? notificationTime;
  final List<int>? repeatDays;
  final bool? isActive;

  const UpdateMedicationRequest({
    this.name,
    this.dosage,
    this.notificationTime,
    this.repeatDays,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (dosage != null) json['dosage'] = dosage;
    if (notificationTime != null) {
      json['notificationTime'] = {
        'hour': notificationTime!.hour,
        'minute': notificationTime!.minute,
      };
    }
    if (repeatDays != null) json['repeatDays'] = repeatDays;
    if (isActive != null) json['isActive'] = isActive;
    return json;
  }
}

/// 오늘의 약물 응답 모델
class TodayMedicationsResponse {
  final List<Medication> medications;
  final String date;
  final int total;

  const TodayMedicationsResponse({
    required this.medications,
    required this.date,
    required this.total,
  });

  factory TodayMedicationsResponse.fromJson(Map<String, dynamic> json) {
    return TodayMedicationsResponse(
      medications: (json['medications'] as List<dynamic>)
          .map((item) => Medication.fromJson(item as Map<String, dynamic>))
          .toList(),
      date: json['date'] as String,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medications': medications.map((m) => m.toJson()).toList(),
      'date': date,
      'total': total,
    };
  }
}
