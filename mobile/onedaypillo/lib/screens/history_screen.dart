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
  String _filterType = 'all'; // 'all', 'not_taken', 'taken'

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationProvider);
    final logs = ref.watch(medicationLogProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.white, AppColors.primaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 4),
                _buildWeeklyCalendar(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 필터 칩
          _buildFilterChips(),
          // 복용 기록 목록
          Expanded(
            child: medications.isEmpty
                ? _buildEmptyState()
                : Builder(
                    builder: (context) {
                      final sortedMedications = _getSortedMedications(medications, logs);
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 하단 여백 추가
                        itemCount: sortedMedications.length,
                        itemBuilder: (context, index) {
                          final medication = sortedMedications[index];
                          return _buildMedicationHistoryCard(medication, logs);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 필터 칩 빌드
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: _buildFilterChip('전체', 'all')),
          Expanded(child: _buildFilterChip('미복용', 'not_taken')),
          Expanded(child: _buildFilterChip('복용완료', 'taken')),
        ],
      ),
    );
  }

  /// 개별 필터 칩 빌드
  Widget _buildFilterChip(String label, String filterType) {
    final isSelected = _filterType == filterType;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterType = filterType;
          });
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 약물을 복용 상태에 따라 정렬 및 필터링
  List<Medication> _getSortedMedications(List<Medication> medications, List<dynamic> logs) {
    // 먼저 필터링
    List<Medication> filteredMedications = medications.where((medication) {
      final dayLogs = logs.where((log) => 
          log.medicationId == medication.id && 
          _isSameDay(log.takenAt, _selectedDate)).toList();
      
      final isTaken = dayLogs.isNotEmpty && dayLogs.first.isTaken;
      
      switch (_filterType) {
        case 'not_taken':
          return !isTaken;
        case 'taken':
          return isTaken;
        case 'all':
        default:
          return true;
      }
    }).toList();
    
    // 그 다음 정렬 (미복용 먼저, 복용완료 나중에)
    return filteredMedications..sort((a, b) {
      final aLogs = logs.where((log) => 
          log.medicationId == a.id && 
          _isSameDay(log.takenAt, _selectedDate)).toList();
      final bLogs = logs.where((log) => 
          log.medicationId == b.id && 
          _isSameDay(log.takenAt, _selectedDate)).toList();
      
      final aIsTaken = aLogs.isNotEmpty && aLogs.first.isTaken;
      final bIsTaken = bLogs.isNotEmpty && bLogs.first.isTaken;
      
      // 미복용(false)을 먼저, 복용완료(true)를 나중에
      if (aIsTaken && !bIsTaken) return 1;
      if (!aIsTaken && bIsTaken) return -1;
      return 0;
    });
  }

  /// 주간 달력 빌드
  Widget _buildWeeklyCalendar() {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    // 선택된 날짜의 주 시작일 (일요일) 계산
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final isSelected = day.day == _selectedDate.day && 
                            day.month == _selectedDate.month && 
                            day.year == _selectedDate.year;
          final isToday = day.day == DateTime.now().day && 
                         day.month == DateTime.now().month && 
                         day.year == DateTime.now().year;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = day;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 요일 약어
                  Text(
                    weekdays[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 날짜
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : 
                             isToday ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.white : 
                                 isToday ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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
                    color: isTaken ? AppColors.tertiary : AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    isTaken ? Icons.check_circle : Icons.medication,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 약물 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isTaken ? AppColors.textSecondary : AppColors.textPrimary,
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '복용량: ${medication.dosage}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isTaken ? AppColors.textSecondary : AppColors.textSecondary,
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        '시간: ${medication.notificationTime.format(context)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isTaken ? AppColors.textSecondary : AppColors.textSecondary,
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 복용 상태
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isTaken ? AppColors.tertiary : AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isTaken ? '복용완료' : '미복용',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isTaken ? AppColors.white : AppColors.white,
                    ),
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

  /// 같은 날인지 확인
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
