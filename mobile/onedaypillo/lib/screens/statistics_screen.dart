import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../widgets/app_text.dart';
import '../widgets/app_card.dart';
import '../providers/medication_provider.dart';
import '../providers/medication_log_provider.dart';
import '../models/medication.dart';

/// 통계 화면 - 복용률 및 리포트
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationProvider);
    final logs = ref.watch(medicationLogProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: AppText.titleLarge('복용 통계'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: medications.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 하단 여백 추가
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 전체 복용률 카드
                  _buildOverallAdherenceCard(medications, logs, ref),
                  const SizedBox(height: 16),
                  
                  // 약물별 복용률
                  AppText.titleMedium('약물별 복용률'),
                  const SizedBox(height: 12),
                  ...medications.map((medication) => 
                    _buildMedicationStatsCard(medication, logs, ref)),
                  
                  const SizedBox(height: 16),
                  
                  // 주간 통계
                  _buildWeeklyStatsCard(logs),
                  
                  const SizedBox(height: 20), // 추가 여백
                ],
              ),
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
            Icons.bar_chart,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          AppText.titleMedium(
            '통계 데이터가 없습니다',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText.bodySmall(
            '약을 추가하고 복용 기록을 쌓아보세요',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 전체 복용률 카드
  Widget _buildOverallAdherenceCard(List<Medication> medications, List<dynamic> logs, WidgetRef ref) {
    if (medications.isEmpty) return const SizedBox.shrink();
    
    double totalAdherence = 0;
    for (final medication in medications) {
      totalAdherence += ref.read(medicationLogProvider.notifier).getAdherenceRate(medication.id);
    }
    final averageAdherence = totalAdherence / medications.length;
    final adherencePercentage = (averageAdherence * 100).round();

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium('전체 복용률'),
                    AppText.bodySmall('최근 7일 평균'),
                  ],
                ),
              ),
              AppText.titleLarge(
                '$adherencePercentage%',
                style: TextStyle(
                  color: adherencePercentage >= 80 ? AppColors.success : 
                         adherencePercentage >= 60 ? AppColors.warning : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: averageAdherence,
            backgroundColor: AppColors.primaryLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              adherencePercentage >= 80 ? AppColors.success : 
              adherencePercentage >= 60 ? AppColors.warning : AppColors.error,
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  /// 약물별 통계 카드
  Widget _buildMedicationStatsCard(Medication medication, List<dynamic> logs, WidgetRef ref) {
    final adherenceRate = ref.read(medicationLogProvider.notifier).getAdherenceRate(medication.id);
    final adherencePercentage = (adherenceRate * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.medication,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.titleMedium(medication.name),
                  AppText.bodySmall('복용량: ${medication.dosage}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.titleMedium(
                  '$adherencePercentage%',
                  style: TextStyle(
                    color: adherencePercentage >= 80 ? AppColors.success : 
                           adherencePercentage >= 60 ? AppColors.warning : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppText.bodySmall('최근 7일'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 주간 통계 카드
  Widget _buildWeeklyStatsCard(List<dynamic> logs) {
    final now = DateTime.now();
    final weekDays = ['일', '월', '화', '수', '목', '금', '토'];
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleMedium('주간 복용 현황'),
          const SizedBox(height: 12), // 16 -> 12로 줄임
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = DateTime(now.year, now.month, now.day - (6 - index));
              final dayLogs = logs.where((log) => 
                log.takenAt.year == date.year &&
                log.takenAt.month == date.month &&
                log.takenAt.day == date.day &&
                log.isTaken).length;
              
              return Column(
                children: [
                  AppText.bodySmall(weekDays[date.weekday % 7]),
                  const SizedBox(height: 4),
                  Container(
                    width: 28, // 30 -> 28로 줄임
                    height: 28, // 30 -> 28로 줄임
                    decoration: BoxDecoration(
                      color: dayLogs > 0 ? AppColors.success : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: AppText.bodySmall(
                        '$dayLogs',
                        style: TextStyle(
                          color: dayLogs > 0 ? AppColors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
