import '../models/medication.dart';
import '../models/medication_api.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';

/// 약물 관리 Repository 인터페이스
abstract class MedicationRepository {
  /// 약물 목록 조회
  Future<List<Medication>> getMedications();
  
  /// 특정 약물 조회
  Future<Medication?> getMedication(String id);
  
  /// 약물 추가
  Future<Medication> addMedication(Medication medication);
  
  /// 약물 수정
  Future<Medication> updateMedication(Medication medication);
  
  /// 약물 삭제
  Future<void> deleteMedication(String id);
  
  /// 오늘의 약물 목록
  Future<List<Medication>> getTodayMedications();
  
  /// 약물 활성화/비활성화
  Future<Medication> toggleMedication(String id);
}

/// API 기반 약물 Repository 구현체
class ApiMedicationRepository implements MedicationRepository {
  final ApiClient _apiClient;
  
  ApiMedicationRepository(this._apiClient);

  @override
  Future<List<Medication>> getMedications() async {
    try {
      final response = await _apiClient.get<MedicationListResponse>(
        ApiEndpoints.medicine,
        fromJson: MedicationListResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!.medications;
      }
      return [];
    } catch (e) {
      throw Exception('약물 목록을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<Medication?> getMedication(String id) async {
    try {
      final response = await _apiClient.get<Medication>(
        '${ApiEndpoints.medicine}/$id',
        fromJson: Medication.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return null;
    } catch (e) {
      throw Exception('약물 정보를 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<Medication> addMedication(Medication medication) async {
    try {
      final request = CreateMedicationRequest(
        name: medication.name,
        dosage: medication.dosage,
        notificationTime: medication.notificationTime,
        repeatDays: medication.repeatDays,
      );

      final response = await _apiClient.post<Medication>(
        ApiEndpoints.medicine,
        data: request.toJson(),
        fromJson: Medication.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '약물 추가에 실패했습니다.');
    } catch (e) {
      throw Exception('약물 추가에 실패했습니다: $e');
    }
  }

  @override
  Future<Medication> updateMedication(Medication medication) async {
    try {
      final request = UpdateMedicationRequest(
        name: medication.name,
        dosage: medication.dosage,
        notificationTime: medication.notificationTime,
        repeatDays: medication.repeatDays,
        isActive: medication.isActive,
      );

      final response = await _apiClient.put<Medication>(
        '${ApiEndpoints.medicine}/${medication.id}',
        data: request.toJson(),
        fromJson: Medication.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.error?.message ?? '약물 수정에 실패했습니다.');
    } catch (e) {
      throw Exception('약물 수정에 실패했습니다: $e');
    }
  }

  @override
  Future<void> deleteMedication(String id) async {
    try {
      final response = await _apiClient.delete<void>(
        '${ApiEndpoints.medicine}/$id',
      );
      
      if (!response.success) {
        throw Exception(response.error?.message ?? '약물 삭제에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('약물 삭제에 실패했습니다: $e');
    }
  }

  @override
  Future<List<Medication>> getTodayMedications() async {
    try {
      final response = await _apiClient.get<TodayMedicationsResponse>(
        ApiEndpoints.medicineToday,
        fromJson: TodayMedicationsResponse.fromJson,
      );
      
      if (response.success && response.data != null) {
        return response.data!.medications;
      }
      return [];
    } catch (e) {
      throw Exception('오늘의 약물 목록을 가져오는데 실패했습니다: $e');
    }
  }

  @override
  Future<Medication> toggleMedication(String id) async {
    try {
      final medication = await getMedication(id);
      if (medication == null) {
        throw Exception('약물을 찾을 수 없습니다.');
      }

      final updatedMedication = medication.copyWith(isActive: !medication.isActive);
      return await updateMedication(updatedMedication);
    } catch (e) {
      throw Exception('약물 상태 변경에 실패했습니다: $e');
    }
  }
}

/// 로컬 캐시 약물 Repository 구현체
class LocalMedicationRepository implements MedicationRepository {
  final List<Medication> _medications = [];
  
  @override
  Future<List<Medication>> getMedications() async {
    return List.from(_medications);
  }

  @override
  Future<Medication?> getMedication(String id) async {
    try {
      return _medications.firstWhere((med) => med.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Medication> addMedication(Medication medication) async {
    _medications.add(medication);
    return medication;
  }

  @override
  Future<Medication> updateMedication(Medication medication) async {
    final index = _medications.indexWhere((med) => med.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
      return medication;
    }
    throw Exception('약물을 찾을 수 없습니다.');
  }

  @override
  Future<void> deleteMedication(String id) async {
    _medications.removeWhere((med) => med.id == id);
  }

  @override
  Future<List<Medication>> getTodayMedications() async {
    final today = DateTime.now().weekday % 7; // 0=일요일, 1=월요일, ...
    return _medications.where((medication) {
      return medication.isActive && 
             (medication.repeatDays.isEmpty || medication.repeatDays.contains(today));
    }).toList();
  }

  @override
  Future<Medication> toggleMedication(String id) async {
    final medication = await getMedication(id);
    if (medication == null) {
      throw Exception('약물을 찾을 수 없습니다.');
    }

    final updatedMedication = medication.copyWith(isActive: !medication.isActive);
    return await updateMedication(updatedMedication);
  }
}

/// Repository 팩토리
class MedicationRepositoryFactory {
  static MedicationRepository create({
    required bool useApi,
    ApiClient? apiClient,
  }) {
    if (useApi && apiClient != null) {
      return ApiMedicationRepository(apiClient);
    } else {
      return LocalMedicationRepository();
    }
  }
}
