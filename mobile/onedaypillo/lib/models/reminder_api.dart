/// 알림 설정 모델
class Reminder {
  final String id;
  final String medicationId;
  final String medicationName;
  final ReminderTime reminderTime;
  final bool isEnabled;
  final String notificationType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Reminder({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.reminderTime,
    required this.isEnabled,
    required this.notificationType,
    required this.createdAt,
    this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      reminderTime: ReminderTime.fromJson(json['reminderTime'] as Map<String, dynamic>),
      isEnabled: json['isEnabled'] as bool,
      notificationType: json['notificationType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'reminderTime': reminderTime.toJson(),
      'isEnabled': isEnabled,
      'notificationType': notificationType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Reminder copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    ReminderTime? reminderTime,
    bool? isEnabled,
    String? notificationType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      reminderTime: reminderTime ?? this.reminderTime,
      isEnabled: isEnabled ?? this.isEnabled,
      notificationType: notificationType ?? this.notificationType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 알림 시간 모델
class ReminderTime {
  final int hour;
  final int minute;

  const ReminderTime({
    required this.hour,
    required this.minute,
  });

  factory ReminderTime.fromJson(Map<String, dynamic> json) {
    return ReminderTime(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  /// 시간 문자열로 변환 (예: "09:00")
  String get timeString {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// DateTime으로 변환
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

/// 알림 설정 목록 응답 모델
class ReminderListResponse {
  final List<Reminder> reminders;
  final int total;

  const ReminderListResponse({
    required this.reminders,
    required this.total,
  });

  factory ReminderListResponse.fromJson(Map<String, dynamic> json) {
    return ReminderListResponse(
      reminders: (json['reminders'] as List<dynamic>)
          .map((item) => Reminder.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
      'total': total,
    };
  }
}

/// 알림 설정 생성 요청 모델
class CreateReminderRequest {
  final String medicationId;
  final ReminderTime reminderTime;
  final bool isEnabled;
  final String notificationType;

  const CreateReminderRequest({
    required this.medicationId,
    required this.reminderTime,
    required this.isEnabled,
    required this.notificationType,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'reminderTime': reminderTime.toJson(),
      'isEnabled': isEnabled,
      'notificationType': notificationType,
    };
  }
}

/// 알림 설정 수정 요청 모델
class UpdateReminderRequest {
  final ReminderTime? reminderTime;
  final bool? isEnabled;
  final String? notificationType;

  const UpdateReminderRequest({
    this.reminderTime,
    this.isEnabled,
    this.notificationType,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (reminderTime != null) json['reminderTime'] = reminderTime!.toJson();
    if (isEnabled != null) json['isEnabled'] = isEnabled;
    if (notificationType != null) json['notificationType'] = notificationType;
    return json;
  }
}

/// 알림 로그 모델
class ReminderLog {
  final String id;
  final String reminderId;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledTime;
  final DateTime? sentTime;
  final String status; // sent, clicked, dismissed, failed
  final String? errorMessage;

  const ReminderLog({
    required this.id,
    required this.reminderId,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledTime,
    this.sentTime,
    required this.status,
    this.errorMessage,
  });

  factory ReminderLog.fromJson(Map<String, dynamic> json) {
    return ReminderLog(
      id: json['id'] as String,
      reminderId: json['reminderId'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      sentTime: json['sentTime'] != null ? DateTime.parse(json['sentTime'] as String) : null,
      status: json['status'] as String,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderId': reminderId,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'sentTime': sentTime?.toIso8601String(),
      'status': status,
      'errorMessage': errorMessage,
    };
  }
}

/// 알림 로그 목록 응답 모델
class ReminderLogListResponse {
  final List<ReminderLog> logs;
  final int total;
  final String? startDate;
  final String? endDate;

  const ReminderLogListResponse({
    required this.logs,
    required this.total,
    this.startDate,
    this.endDate,
  });

  factory ReminderLogListResponse.fromJson(Map<String, dynamic> json) {
    return ReminderLogListResponse(
      logs: (json['logs'] as List<dynamic>)
          .map((item) => ReminderLog.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logs': logs.map((log) => log.toJson()).toList(),
      'total': total,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

/// 알림 통계 모델
class ReminderStats {
  final String period;
  final int totalReminders;
  final int sentReminders;
  final int clickedReminders;
  final int dismissedReminders;
  final int failedReminders;
  final double clickRate;
  final double deliveryRate;

  const ReminderStats({
    required this.period,
    required this.totalReminders,
    required this.sentReminders,
    required this.clickedReminders,
    required this.dismissedReminders,
    required this.failedReminders,
    required this.clickRate,
    required this.deliveryRate,
  });

  factory ReminderStats.fromJson(Map<String, dynamic> json) {
    return ReminderStats(
      period: json['period'] as String,
      totalReminders: json['totalReminders'] as int,
      sentReminders: json['sentReminders'] as int,
      clickedReminders: json['clickedReminders'] as int,
      dismissedReminders: json['dismissedReminders'] as int,
      failedReminders: json['failedReminders'] as int,
      clickRate: (json['clickRate'] as num).toDouble(),
      deliveryRate: (json['deliveryRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'totalReminders': totalReminders,
      'sentReminders': sentReminders,
      'clickedReminders': clickedReminders,
      'dismissedReminders': dismissedReminders,
      'failedReminders': failedReminders,
      'clickRate': clickRate,
      'deliveryRate': deliveryRate,
    };
  }
}

/// 알림 스케줄링 요청 모델
class ScheduleReminderRequest {
  final String medicationId;
  final DateTime scheduleTime;

  const ScheduleReminderRequest({
    required this.medicationId,
    required this.scheduleTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'scheduleTime': scheduleTime.toIso8601String(),
    };
  }
}

/// 알림 처리 요청 모델
class ProcessReminderRequest {
  final String reminderId;
  final String action; // sent, clicked, dismissed

  const ProcessReminderRequest({
    required this.reminderId,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'reminderId': reminderId,
      'action': action,
    };
  }
}
