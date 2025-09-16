import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_card.dart';
import '../providers/medication_provider.dart';
import '../providers/medication_log_provider.dart';
import '../providers/admob_provider.dart';
import '../models/medication.dart';
import '../models/medication_log.dart';
import 'add_medication_screen.dart';

/// 홈 화면 - 오늘의 약물 목록과 복용 체크
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // AdMob 초기화 및 배너 광고 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(adMobProvider.notifier).initialize();
        ref.read(adMobProvider.notifier).loadBannerAd(AdUnitIds.bottomBanner);
      }
    });
  }

  @override
  void dispose() {
    // 배너 광고 해제 (mounted 체크 없이 직접 호출)
    try {
      ref.read(adMobProvider.notifier).disposeBannerAd();
    } catch (e) {
      // dispose 중 오류 무시
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayMedications = ref.watch(todayMedicationsProvider);
    final adMobState = ref.watch(adMobProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: AppText.titleLarge('하루 알약'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 오늘 날짜 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryLight,
            child: AppText.bodyMedium(
              _getTodayDateString(),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 약물 목록
          Expanded(
            child: todayMedications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 하단 여백 추가
                    itemCount: todayMedications.length,
                    itemBuilder: (context, index) {
                      final medication = todayMedications[index];
                      return _buildMedicationCard(medication);
                    },
                  ),
          ),
          
          // 배너 광고
          if (adMobState.bannerAd != null)
            Container(
              width: double.infinity,
              height: 50,
              color: AppColors.white,
              child: AdWidget(ad: adMobState.bannerAd!),
            ),
        ],
      ),
      floatingActionButton: Container(
        width: 120,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMedicationScreen(),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: AppColors.textOnPrimary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                AppText.bodyLarge(
                  '약 추가',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
            Icons.medication,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          AppText.titleMedium(
            '오늘 복용할 약이 없습니다',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText.bodySmall(
            '하단의 + 버튼을 눌러 약을 추가해보세요',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 약물 카드 위젯
  Widget _buildMedicationCard(Medication medication) {
    final todayLog = ref.watch(todayLogProvider(medication.id));
    final isTaken = todayLog?.isTaken ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        background: isTaken ? AppColors.primaryLight : AppColors.white,
        child: Row(
          children: [
            // 약물 아이콘
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isTaken ? AppColors.primary : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                isTaken ? Icons.check : Icons.medication,
                color: isTaken ? AppColors.textOnPrimary : AppColors.primary,
                size: 30,
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
            
            // 복용 체크 버튼
            AppButton(
              label: isTaken ? '완료' : '먹었어요',
              filled: !isTaken,
              onPressed: () => _toggleMedicationTaken(medication),
              width: 100,
            ),
          ],
        ),
      ),
    );
  }

  /// 약물 복용 상태 토글
  void _toggleMedicationTaken(Medication medication) {
    final todayLog = ref.read(todayLogProvider(medication.id));
    final isTaken = todayLog?.isTaken ?? false;
    
    final newLog = MedicationLog(
      id: todayLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: medication.id,
      takenAt: DateTime.now(),
      isTaken: !isTaken,
    );

    ref.read(medicationLogProvider.notifier).addLog(newLog);
  }

  /// 오늘 날짜 문자열 반환
  String _getTodayDateString() {
    final now = DateTime.now();
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[now.weekday % 7];
    return '${now.year}년 ${now.month}월 ${now.day}일 ($weekday)';
  }
}
