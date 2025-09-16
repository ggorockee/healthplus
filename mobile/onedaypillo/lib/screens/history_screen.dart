import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../widgets/app_text.dart';
import '../widgets/app_card.dart';
import '../providers/medication_provider.dart';
import '../providers/medication_log_provider.dart';
import '../models/medication.dart';

/// 복용 기록 화면
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationProvider);
    final logs = ref.watch(medicationLogProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: AppText.titleLarge('복용 기록'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 날짜 선택
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousDay,
                  icon: const Icon(Icons.chevron_left),
                ),
                GestureDetector(
                  onTap: _selectDate,
                  child: AppText.titleMedium(_getDateString(_selectedDate)),
                ),
                IconButton(
                  onPressed: _nextDay,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          
          // 복용 기록 목록
          Expanded(
            child: medications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 하단 여백 추가
                    itemCount: medications.length,
                    itemBuilder: (context, index) {
                      final medication = medications[index];
                      return _buildMedicationHistoryCard(medication, logs);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          AppText.titleMedium(
            '복용 기록이 없습니다',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText.bodySmall(
            '약을 추가하고 복용 기록을 확인해보세요',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 약물별 복용 기록 카드
  Widget _buildMedicationHistoryCard(Medication medication, List<dynamic> logs) {
    final dayLogs = logs.where((log) => 
        log.medicationId == medication.id && 
        _isSameDay(log.takenAt, _selectedDate)).toList();
    
    final isTaken = dayLogs.isNotEmpty && dayLogs.first.isTaken;
    final adherenceRate = ref.read(medicationLogProvider.notifier).getAdherenceRate(medication.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        background: isTaken ? AppColors.primaryLight : AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 약물 아이콘
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isTaken ? AppColors.primary : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    isTaken ? Icons.check : Icons.medication,
                    color: isTaken ? AppColors.textOnPrimary : AppColors.primary,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 약물 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.titleMedium(medication.name),
                      const SizedBox(height: 4),
                      AppText.bodySmall('복용량: ${medication.dosage}'),
                      AppText.bodySmall('시간: ${medication.notificationTime.format(context)}'),
                    ],
                  ),
                ),
                
                // 복용 상태
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isTaken ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText.bodySmall(
                    isTaken ? '복용완료' : '미복용',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 복용률 표시
            Row(
              children: [
                const Icon(Icons.trending_up, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                AppText.bodySmall('최근 7일 복용률: ${(adherenceRate * 100).toInt()}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 이전 날로 이동
  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  /// 다음 날로 이동
  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  /// 날짜 선택
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 같은 날인지 확인
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 날짜 문자열 반환
  String _getDateString(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
  }
}
