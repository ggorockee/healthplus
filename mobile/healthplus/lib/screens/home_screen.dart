import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/home_widgets.dart';
// 광고 위젯은 현재 사용하지 않음
import 'medication_registration_screen.dart';
import 'medication_history_screen.dart';
import 'subscription_screen.dart';

/// 홈 화면 (온보딩 완료 후 이동할 화면)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '안녕하세요, 김○○님!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF4CAF50), size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodayMedicationSection(context, ref, medications),
                  const SizedBox(height: 24),
                  const NextDoseCardWidget(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _BottomNavBar(
            onTapAdd: () => _showAddMedicationDialog(context),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF4CAF50),
          onPressed: () => _showAddMedicationDialog(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  /// 오늘 복용할 약 섹션
  Widget _buildTodayMedicationSection(BuildContext context, WidgetRef ref, List medications) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘 복용할 약',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 모든 약 보기 페이지로 이동
                },
                child: const Text(
                  '모두 보기',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 진행률과 약 목록
          Row(
            children: [
              // 진행률 표시기
              const MedicationProgressWidget(),
              
              const SizedBox(width: 20),
              
              // 약 목록
              Expanded(
                child: Column(
                  children: medications.map<Widget>((medication) {
                    return MedicationItemWidget(medication: medication);
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 바로가기 섹션
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '바로가기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 바로가기 버튼 그리드
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            // 새 약 추가 (큰 버튼)
            QuickActionButton(
              title: '새 약 추가',
              icon: Icons.add,
              isPrimary: true,
              onTap: () {
                _showAddMedicationDialog(context);
              },
            ),
            // 복용 기록
            QuickActionButton(
              title: '복용 기록',
              icon: Icons.history,
              onTap: () {
                _showMedicationHistory(context);
              },
            ),
            // 통계
            QuickActionButton(
              title: '복용 통계',
              icon: Icons.bar_chart,
              onTap: () {
                _showMedicationStats(context);
              },
            ),
            // 건강 리포트 (PRO)
            QuickActionButton(
              title: '건강 리포트',
              icon: Icons.trending_up,
              showProBadge: true,
              onTap: () {
                _showHealthReport(context);
              },
            ),
            // 구독 관리
            QuickActionButton(
              title: '구독 관리',
              icon: Icons.star,
              onTap: () {
                _showSubscriptionManagement(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 새 약 추가 화면으로 이동
  void _showAddMedicationDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MedicationRegistrationScreen(),
      ),
    );
  }

  /// 복용 기록 화면으로 이동
  void _showMedicationHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MedicationHistoryScreen(),
      ),
    );
  }

  /// 복용 통계 보기
  void _showMedicationStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('복용 통계'),
        content: const Text('복용 통계 기능을 구현할 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 건강 리포트 보기
  void _showHealthReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('건강 리포트'),
        content: const Text('건강 리포트 기능은 PRO 버전에서 이용 가능합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 구독 관리 화면으로 이동
  void _showSubscriptionManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SubscriptionScreen(),
      ),
    );
  }
}

/// 하단 네비게이션 바 (와이어프레임 스타일)
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.onTapAdd,
  });

  final VoidCallback onTapAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _BottomItem(
            icon: Icons.home,
            label: '홈',
            isActive: true,
            onTap: () {},
          ),
          _BottomItem(
            icon: Icons.medication,
            label: '내약',
            onTap: () {},
          ),
          _BottomItem(
            icon: Icons.family_restroom,
            label: '함께',
            onTap: () {},
          ),
          _BottomItem(
            icon: Icons.bar_chart,
            label: '통계',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? const Color(0xFF4CAF50) : const Color(0xFF9CA3AF);
    final FontWeight weight = isActive ? FontWeight.bold : FontWeight.w400;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: weight),
            ),
          ],
        ),
      ),
    );
  }
}