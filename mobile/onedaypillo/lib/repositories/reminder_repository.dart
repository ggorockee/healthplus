import '../models/reminder_api.dart';
import '../models/api_response.dart';
import '../config/api_config.dart';
import '../services/api_client.dart';

/// 알림 Repository 인터페이스
abstract class ReminderRepository {
  /// 알림 설정 목록 조회
  Future<List<Reminder>> getReminders();
  
  /// 특정 알림 설정 조회
  Future<Reminder?> getReminder(String id);
  
  /// 알림 설정 추가
  Future<Reminder> addReminder(CreateReminderRequest request);
  
  /// 알림 설정 수정
  Future<Reminder> updateReminder(String id, UpdateReminderRequest request);
  
  /// 알림 설정 삭제
  Future<void> deleteReminder(String id);
  
  /// 알림 로그 조회
  Future<List<ReminderLog>> getReminderLogs({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// 알림 통계 조회
  Future<ReminderStats> getReminderStats({
    required String period,
  });
  
  /// 알림 스케줄링
  Future<void> scheduleReminder(ScheduleReminderRequest request);
  
  /// 알림 처리
  Future<void> processReminder(ProcessReminderRequest request);
}

/// API 기반 알림 Repository 구현체
class ApiReminderRepository implements ReminderRepository {
  final ApiClient _apiClient;
  
  ApiReminderRepository(this._apiClient);

  @override
  Future<List<Reminder>> getReminders() async {
    try {
      final response = await _apiClient.get<ReminderListResponse>(
        ApiEndpoints.reminders,
        fromJson: ReminderListResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!.reminders;
      }
      return [];
    } catch (e) {
      throw Exception('알림 설정 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<Reminder?> getReminder(String id) async {
    try {
      final response = await _apiClient.get<Reminder>(
        '${ApiEndpoints.reminders}/$id',
        fromJson: Reminder.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return null;
    } catch (e) {
      throw Exception('알림 설정 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<Reminder> addReminder(CreateReminderRequest request) async {
    try {
      final response = await _apiClient.post<Reminder>(
        ApiEndpoints.reminders,
        data: request.toJson(),
        fromJson: Reminder.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '알림 설정 추가에 실패했습니다.');
    } catch (e) {
      throw Exception('알림 설정 추가에 실패했습니다: $e');
    }
  }

  @override
  Future<Reminder> updateReminder(String id, UpdateReminderRequest request) async {
    try {
      final response = await _apiClient.put<Reminder>(
        '${ApiEndpoints.reminders}/$id',
        data: request.toJson(),
        fromJson: Reminder.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '알림 설정 수정에 실패했습니다.');
    } catch (e) {
      throw Exception('알림 설정 수정에 실패했습니다: $e');
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      final response = await _apiClient.delete<void>(
        '${ApiEndpoints.reminders}/$id',
      );
      
      if (!response.success) {
        throw Exception(response.error?.message ?? '알림 설정 삭제에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('알림 설정 삭제에 실패했습니다: $e');
    }
  }

  @override
  Future<List<ReminderLog>> getReminderLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get<ReminderLogListResponse>(
        '${ApiEndpoints.reminders}/logs',
        queryParameters: queryParams,
        fromJson: ReminderLogListResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!.logs;
      }
      return [];
    } catch (e) {
      throw Exception('알림 로그 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<ReminderStats> getReminderStats({
    required String period,
  }) async {
    try {
      final response = await _apiClient.get<ReminderStats>(
        '${ApiEndpoints.reminders}/stats',
        queryParameters: {'period': period},
        fromJson: ReminderStats.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '알림 통계 조회에 실패했습니다.');
    } catch (e) {
      throw Exception('알림 통계 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<void> scheduleReminder(ScheduleReminderRequest request) async {
    try {
      final response = await _apiClient.post<void>(
        '${ApiEndpoints.reminders}/schedule',
        data: request.toJson(),
      );
      
      if (!response.success) {
        throw Exception(response.error?.message ?? '알림 스케줄링에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('알림 스케줄링에 실패했습니다: $e');
    }
  }

  @override
  Future<void> processReminder(ProcessReminderRequest request) async {
    try {
      final response = await _apiClient.post<void>(
        '${ApiEndpoints.reminders}/process',
        data: request.toJson(),
      );
      
      if (!response.success) {
        throw Exception(response.error?.message ?? '알림 처리에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('알림 처리에 실패했습니다: $e');
    }
  }
}

/// 로컬 캐시 알림 Repository 구현체
class LocalReminderRepository implements ReminderRepository {
  final List<Reminder> _reminders = [];
  final List<ReminderLog> _logs = [];
  
  @override
  Future<List<Reminder>> getReminders() async {
    return List.from(_reminders);
  }

  @override
  Future<Reminder?> getReminder(String id) async {
    try {
      return _reminders.firstWhere((reminder) => reminder.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Reminder> addReminder(CreateReminderRequest request) async {
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: request.medicationId,
      medicationName: 'Unknown', // 실제로는 약물 이름 조회 필요
      reminderTime: request.reminderTime,
      isEnabled: request.isEnabled,
      notificationType: request.notificationType,
      createdAt: DateTime.now(),
    );
    
    _reminders.add(reminder);
    return reminder;
  }

  @override
  Future<Reminder> updateReminder(String id, UpdateReminderRequest request) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      throw Exception('알림 설정을 찾을 수 없습니다.');
    }

    final existingReminder = _reminders[index];
    final updatedReminder = existingReminder.copyWith(
      reminderTime: request.reminderTime,
      isEnabled: request.isEnabled,
      notificationType: request.notificationType,
      updatedAt: DateTime.now(),
    );

    _reminders[index] = updatedReminder;
    return updatedReminder;
  }

  @override
  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((reminder) => reminder.id == id);
  }

  @override
  Future<List<ReminderLog>> getReminderLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var filteredLogs = List<ReminderLog>.from(_logs);
    
    if (startDate != null) {
      filteredLogs = filteredLogs.where((log) => 
          log.scheduledTime.isAfter(startDate) || log.scheduledTime.isAtSameMomentAs(startDate)).toList();
    }
    
    if (endDate != null) {
      filteredLogs = filteredLogs.where((log) => 
          log.scheduledTime.isBefore(endDate) || log.scheduledTime.isAtSameMomentAs(endDate)).toList();
    }
    
    return filteredLogs;
  }

  @override
  Future<ReminderStats> getReminderStats({
    required String period,
  }) async {
    // 로컬에서 간단한 통계 계산
    return ReminderStats(
      period: period,
      totalReminders: _logs.length,
      sentReminders: _logs.where((log) => log.status == 'sent').length,
      clickedReminders: _logs.where((log) => log.status == 'clicked').length,
      dismissedReminders: _logs.where((log) => log.status == 'dismissed').length,
      failedReminders: _logs.where((log) => log.status == 'failed').length,
      clickRate: 0.0,
      deliveryRate: 0.0,
    );
  }

  @override
  Future<void> scheduleReminder(ScheduleReminderRequest request) async {
    // 로컬에서는 스케줄링 로직 구현 (실제로는 로컬 알림 스케줄러 사용)
  }

  @override
  Future<void> processReminder(ProcessReminderRequest request) async {
    // 로컬에서는 처리 로직 구현
  }
}

/// 알림 Repository 팩토리
class ReminderRepositoryFactory {
  static ReminderRepository create({
    required bool useApi,
    ApiClient? apiClient,
  }) {
    if (useApi && apiClient != null) {
      return ApiReminderRepository(apiClient);
    } else {
      return LocalReminderRepository();
    }
  }
}
