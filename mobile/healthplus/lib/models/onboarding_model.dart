import 'package:flutter/material.dart';

/// 온보딩 화면 데이터 모델
class OnboardingModel {
  /// 온보딩 화면 제목
  final String title;
  
  /// 온보딩 화면 설명
  final String description;
  
  /// 아이콘 색상 (배경색)
  final Color backgroundColor;
  
  /// 아이콘 색상 (아이콘 색상)
  final Color iconColor;
  
  /// 아이콘 데이터 (Flutter 아이콘 또는 커스텀 아이콘)
  final IconData icon;
  
  /// 추가 아이콘 (선택사항)
  final IconData? secondaryIcon;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    this.secondaryIcon,
  });
}

/// 온보딩 화면 데이터
class OnboardingData {
  /// 모든 온보딩 화면 데이터
  static const List<OnboardingModel> onboardingScreens = [
    OnboardingModel(
      title: "정확한 시간에 약 복용 알림",
      description: "실시간으로 정확한 시간에 약 복용을 알려드려\n건강한 습관을 만들어보세요",
      backgroundColor: Color(0xFFE8F5E8), // 연한 초록색
      iconColor: Color(0xFF4CAF50), // 초록색
      icon: Icons.access_time, // 알람 시계 아이콘
      secondaryIcon: Icons.medication, // 약병 아이콘
    ),
    OnboardingModel(
      title: "체계적인 복용 기록 관리",
      description: "언제, 어떤 약을 복용했는지 체계적으로\n관리하고 기록하세요",
      backgroundColor: Color(0xFFFFF3E0), // 연한 주황색
      iconColor: Color(0xFFFF9800), // 주황색
      icon: Icons.calendar_today, // 달력 아이콘
      secondaryIcon: Icons.check_circle, // 체크마크 아이콘
    ),
    OnboardingModel(
      title: "가족의 건강도 함께 관리",
      description: "부모님, 가족들의 약 복용을 안전하게\n관리할 수 있어요",
      backgroundColor: Color(0xFFF3E5F5), // 연한 보라색
      iconColor: Color(0xFF9C27B0), // 보라색
      icon: Icons.family_restroom, // 가족 아이콘
      secondaryIcon: Icons.favorite, // 하트 아이콘
    ),
  ];
}
