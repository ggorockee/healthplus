import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 공용 하단 네비게이션 (Home / Sleep / Meditate / Music / Profile)
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: const Color(0xFF98A1BD),
      backgroundColor: AppColors.white,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontSize: 16, // 기본 12 -> 16 (40-50대 유저를 위한 증가)
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14, // 기본 12 -> 14
        fontWeight: FontWeight.w400,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded, size: 28),
          label: '오늘의 약',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded, size: 28),
          label: '복용 기록',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded, size: 28),
          label: '통계',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom_rounded, size: 28),
          label: '가족 관리',
        ),
      ],
    );
  }
}


