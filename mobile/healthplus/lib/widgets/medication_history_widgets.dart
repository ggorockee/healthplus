import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_history_model.dart';
import '../providers/medication_history_provider.dart';

/// 달력 위젯
class MedicationCalendarWidget extends ConsumerStatefulWidget {
  const MedicationCalendarWidget({super.key});

  @override
  ConsumerState<MedicationCalendarWidget> createState() => _MedicationCalendarWidgetState();
}

class _MedicationCalendarWidgetState extends ConsumerState<MedicationCalendarWidget> {
  DateTime _currentMonth = DateTime(2025, 9);
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2025, 9, 15); // 기본 선택 날짜
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 월 네비게이션
          _buildMonthNavigation(),
          const SizedBox(height: 16),
          // 달력 그리드
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  /// 월 네비게이션
  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${_currentMonth.month}월 ${_currentMonth.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  /// 달력 그리드
  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 일요일을 0으로 맞춤

    return Column(
      children: [
        // 요일 헤더
        Row(
          children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: day == '일' ? Colors.red : 
                           day == '토' ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // 날짜 그리드
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
              final isCurrentMonth = dayNumber > 0 && dayNumber <= lastDayOfMonth.day;
              final date = isCurrentMonth ? DateTime(_currentMonth.year, _currentMonth.month, dayNumber) : null;
              final isSelected = date != null && _selectedDate != null && 
                                date.day == _selectedDate!.day && 
                                date.month == _selectedDate!.month && 
                                date.year == _selectedDate!.year;
              final isSunday = dayIndex == 0;
              final isSaturday = dayIndex == 6;

              if (!isCurrentMonth) {
                return Expanded(child: Container(height: 40));
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white :
                                   isSunday ? Colors.red :
                                   isSaturday ? Colors.grey : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // 상태 점
                        if (date != null) _buildStatusDot(date),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  /// 상태 점 표시
  Widget _buildStatusDot(DateTime date) {
    final record = ref.read(medicationHistoryProvider.notifier).getRecordForDate(date);
    if (record == null) return const SizedBox.shrink();

    Color dotColor;
    switch (record.overallStatus) {
      case MedicationStatus.taken:
        dotColor = const Color(0xFF4CAF50);
        break;
      case MedicationStatus.delayed:
        dotColor = Colors.orange;
        break;
      case MedicationStatus.missed:
        dotColor = Colors.red;
        break;
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 일별 복용 상세 위젯
class DailyMedicationDetailWidget extends ConsumerWidget {
  final DateTime selectedDate;

  const DailyMedicationDetailWidget({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(dailyRecordProvider(selectedDate));

    if (record == null) {
      return const Center(
        child: Text('해당 날짜의 복용 기록이 없습니다.'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedDate.month}월 ${selectedDate.day}일 (${_getWeekdayName(selectedDate.weekday)})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // 진행률 표시기
              _buildProgressIndicator(record.completionRate),
            ],
          ),
          const SizedBox(height: 16),
          // 시간대별 복용 기록
          ..._buildTimeBasedRecords(record.doses),
        ],
      ),
    );
  }

  /// 진행률 표시기
  Widget _buildProgressIndicator(double rate) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: rate,
              strokeWidth: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
          Center(
            child: Text(
              '${(rate * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 시간대별 복용 기록
  List<Widget> _buildTimeBasedRecords(List<MedicationDose> doses) {
    final timeGroups = <String, List<MedicationDose>>{};
    
    for (final dose in doses) {
      final timeGroup = _getTimeGroup(dose.time);
      timeGroups[timeGroup] = (timeGroups[timeGroup] ?? [])..add(dose);
    }

    return timeGroups.entries.map((entry) {
      final timeGroup = entry.key;
      final dosesInGroup = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeGroup,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...dosesInGroup.map((dose) => _buildMedicationDoseItem(dose)),
          ],
        ),
      );
    }).toList();
  }

  /// 시간대 그룹명 반환
  String _getTimeGroup(String time) {
    switch (time) {
      case '08:00':
        return '아침 08:00';
      case '12:00':
        return '점심 12:00';
      case '18:00':
        return '저녁 18:00';
      default:
        return '기타 $time';
    }
  }

  /// 약 복용 아이템
  Widget _buildMedicationDoseItem(MedicationDose dose) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          // 상태 아이콘
          Icon(
            _getStatusIcon(dose.status),
            size: 16,
            color: _getStatusColor(dose.status),
          ),
          const SizedBox(width: 8),
          // 약 이름
          Expanded(
            child: Text(
              dose.medicationName,
              style: TextStyle(
                fontSize: 14,
                color: dose.status == MedicationStatus.missed ? Colors.grey : Colors.black87,
                decoration: dose.status == MedicationStatus.missed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          // 지연 사유
          if (dose.delayReason != null)
            Text(
              dose.delayReason!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  /// 상태 아이콘 반환
  IconData _getStatusIcon(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return Icons.check_circle;
      case MedicationStatus.missed:
        return Icons.cancel;
      case MedicationStatus.delayed:
        return Icons.schedule;
    }
  }

  /// 상태 색상 반환
  Color _getStatusColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return const Color(0xFF4CAF50);
      case MedicationStatus.missed:
        return Colors.red;
      case MedicationStatus.delayed:
        return Colors.orange;
    }
  }

  /// 요일명 반환
  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }
}

/// 월간 통계 위젯
class MonthlyStatisticsWidget extends ConsumerWidget {
  final DateTime month;

  const MonthlyStatisticsWidget({
    super.key,
    required this.month,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(monthlyStatisticsProvider(month));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번 달 통계',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 평균 복용률
              Expanded(
                child: _buildStatItem(
                  '이번 달 평균',
                  '${(stats.averageCompletionRate * 100).toInt()}%',
                  const Color(0xFF4CAF50),
                ),
              ),
              // 연속 복용일
              Expanded(
                child: _buildStatItem(
                  '연속 복용',
                  '${stats.consecutiveDays}일',
                  Colors.blue,
                ),
              ),
              // 베스트 시간
              Expanded(
                child: _buildStatItem(
                  '베스트 시간',
                  stats.bestTime,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 월간 리포트 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // 월간 리포트 화면으로 이동
              },
              icon: const Icon(Icons.assessment, size: 20),
              label: const Text('월간 리포트 보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
