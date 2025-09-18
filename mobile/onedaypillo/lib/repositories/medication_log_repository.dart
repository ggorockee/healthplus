import '../models/medication_log.dart';
import '../models/medication_log_api.dart';
import '../models/api_response.dart';
import '../config/api_config.dart';
import '../services/api_client.dart';

/// 복용 로그 Repository 인터페이스
abstract class MedicationLogRepository {
  /// 복용 로그 목록 조회
  Future<List<MedicationLog>> getLogs({
    String? medicationId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// 특정 복용 로그 조회
  Future<MedicationLog?> getLog(String id);
  
  /// 복용 로그 추가
  Future<MedicationLog> addLog(MedicationLog log);
  
  /// 복용 로그 수정
  Future<MedicationLog> updateLog(MedicationLog log);
  
  /// 복용 로그 삭제
  Future<void> deleteLog(String id);
  
  /// 오늘의 복용 로그
  Future<List<MedicationLog>> getTodayLogs();
  
  /// 특정 날짜의 복용 로그
  Future<List<MedicationLog>> getLogsByDate(DateTime date);
}

/// API 기반 복용 로그 Repository 구현체
class ApiMedicationLogRepository implements MedicationLogRepository {
  final ApiClient _apiClient;
  
  ApiMedicationLogRepository(this._apiClient);

  @override
  Future<List<MedicationLog>> getLogs({
    String? medicationId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = MedicationLogQuery(
        medicationId: medicationId,
        startDate: startDate,
        endDate: endDate,
      );

      final response = await _apiClient.get<MedicationLogListResponse>(
        ApiEndpoints.medicationLog,
        queryParameters: query.toQueryParameters(),
        fromJson: MedicationLogListResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!.logs;
      }
      return [];
    } catch (e) {
      throw Exception('복용 로그를 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<MedicationLog?> getLog(String id) async {
    try {
      final response = await _apiClient.get<MedicationLog>(
        '${ApiEndpoints.medicationLog}/$id',
        fromJson: MedicationLog.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return null;
    } catch (e) {
      throw Exception('복용 로그를 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<MedicationLog> addLog(MedicationLog log) async {
    try {
      final request = CreateMedicationLogRequest(
        medicationId: log.medicationId,
        takenAt: log.takenAt,
        isTaken: log.isTaken,
        note: log.note,
      );

      final response = await _apiClient.post<MedicationLog>(
        ApiEndpoints.medicationLog,
        data: request.toJson(),
        fromJson: MedicationLog.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '복용 로그 추가에 실패했습니다.');
    } catch (e) {
      throw Exception('복용 로그 추가에 실패했습니다: $e');
    }
  }

  @override
  Future<MedicationLog> updateLog(MedicationLog log) async {
    try {
      final request = UpdateMedicationLogRequest(
        isTaken: log.isTaken,
        note: log.note,
      );

      final response = await _apiClient.put<MedicationLog>(
        '${ApiEndpoints.medicationLog}/${log.id}',
        data: request.toJson(),
        fromJson: MedicationLog.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '복용 로그 수정에 실패했습니다.');
    } catch (e) {
      throw Exception('복용 로그 수정에 실패했습니다: $e');
    }
  }

  @override
  Future<void> deleteLog(String id) async {
    try {
      final response = await _apiClient.delete<void>(
        '${ApiEndpoints.medicationLog}/$id',
      );
      
      if (!response.success) {
        throw Exception(response.error?.message ?? '복용 로그 삭제에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('복용 로그 삭제에 실패했습니다: $e');
    }
  }

  @override
  Future<List<MedicationLog>> getTodayLogs() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await getLogs(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  @override
  Future<List<MedicationLog>> getLogsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await getLogs(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }
}

/// 로컬 캐시 복용 로그 Repository 구현체
class LocalMedicationLogRepository implements MedicationLogRepository {
  final List<MedicationLog> _logs = [];
  
  @override
  Future<List<MedicationLog>> getLogs({
    String? medicationId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var filteredLogs = List<MedicationLog>.from(_logs);
    
    if (medicationId != null) {
      filteredLogs = filteredLogs.where((log) => log.medicationId == medicationId).toList();
    }
    
    if (startDate != null) {
      filteredLogs = filteredLogs.where((log) => log.takenAt.isAfter(startDate) || log.takenAt.isAtSameMomentAs(startDate)).toList();
    }
    
    if (endDate != null) {
      filteredLogs = filteredLogs.where((log) => log.takenAt.isBefore(endDate) || log.takenAt.isAtSameMomentAs(endDate)).toList();
    }
    
    return filteredLogs;
  }

  @override
  Future<MedicationLog?> getLog(String id) async {
    try {
      return _logs.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<MedicationLog> addLog(MedicationLog log) async {
    _logs.add(log);
    return log;
  }

  @override
  Future<MedicationLog> updateLog(MedicationLog log) async {
    final index = _logs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      _logs[index] = log;
      return log;
    }
    throw Exception('복용 로그를 찾을 수 없습니다.');
  }

  @override
  Future<void> deleteLog(String id) async {
    _logs.removeWhere((log) => log.id == id);
  }

  @override
  Future<List<MedicationLog>> getTodayLogs() async {
    return await getLogsByDate(DateTime.now());
  }

  @override
  Future<List<MedicationLog>> getLogsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _logs.where((log) {
      return log.takenAt.isAfter(startOfDay) && log.takenAt.isBefore(endOfDay);
    }).toList();
  }
}

/// 복용 로그 Repository 팩토리
class MedicationLogRepositoryFactory {
  static MedicationLogRepository create({
    required bool useApi,
    ApiClient? apiClient,
  }) {
    if (useApi && apiClient != null) {
      return ApiMedicationLogRepository(apiClient);
    } else {
      return LocalMedicationLogRepository();
    }
  }
}
