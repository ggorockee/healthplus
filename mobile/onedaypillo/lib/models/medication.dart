import 'package:flutter/material.dart';

/// 약물 정보 모델
class Medication {
  final String id;
  final String name; // 약 이름
  final String dosage; // 복용량 (예: "1정", "1포")
  final TimeOfDay notificationTime; // 알림 시간
  final List<int> repeatDays; // 반복 요일 (0=일요일, 1=월요일, ...)
  final DateTime createdAt;
  final bool isActive; // 활성화 상태

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.notificationTime,
    required this.repeatDays,
    required this.createdAt,
    this.isActive = true,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'notificationTime': {
        'hour': notificationTime.hour,
        'minute': notificationTime.minute,
      },
      'repeatDays': repeatDays,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// JSON 역직렬화
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      notificationTime: TimeOfDay(
        hour: json['notificationTime']['hour'] as int,
        minute: json['notificationTime']['minute'] as int,
      ),
      repeatDays: List<int>.from(json['repeatDays'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// 복사본 생성
  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    TimeOfDay? notificationTime,
    List<int>? repeatDays,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      notificationTime: notificationTime ?? this.notificationTime,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

