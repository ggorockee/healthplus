import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Supabase 서비스 클래스
class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // ========== 인증 관련 ==========
  
  /// 현재 사용자 정보 가져오기
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }
  
  /// 이메일로 회원가입
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  /// 이메일로 로그인
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// 로그아웃
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  /// 인증 상태 스트림
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  /// 사용자 프로필 업데이트
  static Future<void> updateUserProfile({required String name}) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    await _client
        .from('users')
        .update({'name': name})
        .eq('id', user.id);
  }

  /// 사용자 프로필 가져오기
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    final response = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();
    
    return response;
  }
  
  // ========== 약 정보 관련 ==========
  
  /// 사용자의 약 목록 가져오기
  static Future<List<Map<String, dynamic>>> getMedications() async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    final response = await _client
        .from('medications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// 약 정보 추가
  static Future<Map<String, dynamic>> addMedication({
    required Map<String, dynamic> medicationData,
  }) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    final response = await _client
        .from('medications')
        .insert({
          'user_id': user.id,
          ...medicationData,
        })
        .select()
        .single();
    
    return response;
  }
  
  /// 약 정보 업데이트
  static Future<Map<String, dynamic>> updateMedication({
    required String medicationId,
    required Map<String, dynamic> medicationData,
  }) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    final response = await _client
        .from('medications')
        .update(medicationData)
        .eq('id', medicationId)
        .eq('user_id', user.id)
        .select()
        .single();
    
    return response;
  }
  
  /// 약 정보 삭제
  static Future<void> deleteMedication(String medicationId) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    await _client
        .from('medications')
        .delete()
        .eq('id', medicationId)
        .eq('user_id', user.id);
  }
  
  // ========== 복용 기록 관련 ==========
  
  /// 특정 날짜의 복용 기록 가져오기
  static Future<List<Map<String, dynamic>>> getMedicationRecords({
    required DateTime date,
  }) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    final dateString = date.toIso8601String().split('T')[0];
    
    final response = await _client
        .from('medication_records')
        .select('''
          *,
          medications(name, dosage_unit, single_dosage_amount)
        ''')
        .eq('user_id', user.id)
        .eq('date', dateString)
        .order('time');
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// 복용 기록 추가
  static Future<Map<String, dynamic>> addMedicationRecord({
    required String medicationId,
    required DateTime date,
    required String time,
    required String status,
    String? delayReason,
  }) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    final response = await _client
        .from('medication_records')
        .insert({
          'user_id': user.id,
          'medication_id': medicationId,
          'date': date.toIso8601String().split('T')[0],
          'time': time,
          'status': status,
          'delay_reason': delayReason,
          'taken_at': status == 'taken' ? DateTime.now().toIso8601String() : null,
        })
        .select()
        .single();
    
    return response;
  }
  
  /// 복용 기록 업데이트
  static Future<Map<String, dynamic>> updateMedicationRecord({
    required String recordId,
    required String status,
    String? delayReason,
  }) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    final response = await _client
        .from('medication_records')
        .update({
          'status': status,
          'delay_reason': delayReason,
          'taken_at': status == 'taken' ? DateTime.now().toIso8601String() : null,
        })
        .eq('id', recordId)
        .eq('user_id', user.id)
        .select()
        .single();
    
    return response;
  }
  
  // ========== 월간 통계 관련 ==========
  
  /// 월간 복용 통계 가져오기
  static Future<Map<String, dynamic>> getMonthlyStatistics({
    required DateTime month,
  }) async {
    final user = getCurrentUser();
    if (user == null) throw Exception('사용자가 로그인되지 않았습니다');
    
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    
    final response = await _client
        .from('medication_records')
        .select('status, date, time')
        .eq('user_id', user.id)
        .gte('date', startDate.toIso8601String().split('T')[0])
        .lte('date', endDate.toIso8601String().split('T')[0]);
    
    return _calculateMonthlyStats(response);
  }
  
  /// 월간 통계 계산
  static Map<String, dynamic> _calculateMonthlyStats(List<dynamic> records) {
    if (records.isEmpty) {
      return {
        'averageCompletionRate': 0.0,
        'consecutiveDays': 0,
        'bestTime': '아침',
        'totalDays': 0,
        'completedDays': 0,
      };
    }
    
    final totalRecords = records.length;
    final completedRecords = records.where((r) => r['status'] == 'taken').length;
    final averageCompletionRate = completedRecords / totalRecords;
    
    // 연속 복용일 계산 (간단한 버전)
    int consecutiveDays = 0;
    final sortedRecords = records..sort((a, b) => a['date'].compareTo(b['date']));
    for (final record in sortedRecords.reversed) {
      if (record['status'] == 'taken') {
        consecutiveDays++;
      } else {
        break;
      }
    }
    
    // 베스트 시간 계산
    final timeCounts = <String, int>{};
    for (final record in records) {
      if (record['status'] == 'taken') {
        final time = record['time'];
        timeCounts[time] = (timeCounts[time] ?? 0) + 1;
      }
    }
    
    String bestTime = '아침';
    int maxCount = 0;
    timeCounts.forEach((time, count) {
      if (count > maxCount) {
        maxCount = count;
        if (time == '08:00') {
          bestTime = '아침';
        } else if (time == '12:00') {
          bestTime = '점심';
        } else if (time == '18:00') {
          bestTime = '저녁';
        }
      }
    });
    
    return {
      'averageCompletionRate': averageCompletionRate,
      'consecutiveDays': consecutiveDays,
      'bestTime': bestTime,
      'totalDays': totalRecords,
      'completedDays': completedRecords,
    };
  }
}
