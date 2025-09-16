import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/theme.dart';
import '../widgets/app_text.dart';
import '../widgets/swipeable_medication_card.dart';
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
          // 약물 목록
          Expanded(
            child: todayMedications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 100), // 하단 여백 추가
                    itemCount: todayMedications.length,
                    itemBuilder: (context, index) {
                      final medication = todayMedications[index];
                      return SwipeableMedicationCard(
                        medication: medication,
                        isTaken: ref.watch(todayLogProvider(medication.id))?.isTaken ?? false,
                        onToggleTaken: () => _toggleMedicationTaken(medication),
                        onEdit: () => _editMedication(medication),
                        onDelete: () => _deleteMedication(medication),
                      );
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
        width: 140,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                  color: AppColors.white,
                  size: 28,
                ),
                const SizedBox(width: 8),
                AppText.bodyLarge(
                  '약 추가',
                  style: const TextStyle(
                    color: AppColors.white,
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.secondaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.medication,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          AppText.titleLarge(
            '오늘 복용할 약이 없습니다',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AppText.bodyMedium(
            '하단의 + 버튼을 눌러 약을 추가해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                AppText.bodyMedium(
                  '토글 버튼으로 복용 체크, 편집/삭제 버튼 사용',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  /// 약물 편집
  void _editMedication(Medication medication) {
    // TODO: 약물 편집 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${medication.name} 편집 기능은 준비 중입니다')),
    );
  }

  /// 약물 삭제
  void _deleteMedication(Medication medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('약물 삭제'),
        content: Text('${medication.name}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(medicationProvider.notifier).deleteMedication(medication.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${medication.name}이(가) 삭제되었습니다')),
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 주간 달력 빌드
  Widget _buildWeeklyCalendar() {
    final now = DateTime.now();
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    // 이번 주의 시작일 (일요일) 계산
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
          
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 요일 약어
                Text(
                  weekdays[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isToday ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                // 날짜
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isToday ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

}
