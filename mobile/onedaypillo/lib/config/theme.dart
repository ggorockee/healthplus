import 'package:flutter/material.dart';

/// 앱 전역 테마 토큰 정의
/// - 색상: Figma에서 반복 등장하는 팔레트 기반
/// - 타이포그래피: HelveticaNeue 계열 가중치/사이즈 맵핑
class AppColors {
  AppColors._();

  // Primary brand colors (모던 블루 계열)
  static const Color primary = Color(0xFF2563EB); // 모던 블루
  static const Color primaryDark = Color(0xFF1D4ED8); // 다크 블루
  static const Color primaryLight = Color(0xFFEFF6FF); // 라이트 블루

  // Secondary colors (세련된 보조 색상)
  static const Color secondary = Color(0xFF7C3AED); // 보라색
  static const Color secondaryLight = Color(0xFFF3F0FF); // 라이트 보라

  // Accent colors (세련된 포인트 색상)
  static const Color accent = Color(0xFF10B981); // 에메랄드 그린
  static const Color accentLight = Color(0xFFECFDF5); // 라이트 그린

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937); // 다크 그레이
  static const Color textSecondary = Color(0xFF6B7280); // 미디엄 그레이
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF9FAFB);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF9FAFB); // 매우 연한 그레이
  static const Color surfaceDark = Color(0xFF111827);

  // Utility colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Status colors (세련된 색상)
  static const Color success = Color(0xFF10B981); // 에메랄드
  static const Color error = Color(0xFFEF4444); // 모던 레드
  static const Color warning = Color(0xFFF59E0B); // 앰버
  static const Color info = Color(0xFF3B82F6); // 블루

  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
}

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'HelveticaNeue';

  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 40, // 34 -> 40 (40-50대 유저를 위한 증가)
      height: 1.2,
      color: AppColors.textPrimary,
    ), // 예: 큰 타이틀 (Focus Attention, Happy Morning)
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 28, // 20 -> 28
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 26, // 18 -> 26
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 20, // 16 -> 20
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 20, // 새로 추가
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 18, // 16 -> 18
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16, // 새로 추가
      height: 1.3,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 18, // 14 -> 18
      letterSpacing: 0.7,
      color: AppColors.textPrimary,
    ),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.accentYellow,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      background: AppColors.surface,
      onBackground: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: AppTypography.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        shape: const StadiumBorder(),
        textStyle: AppTypography.textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.primaryLight,
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: 0.55,
        color: AppColors.textSecondary,
      ),
      shape: const StadiumBorder(),
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.primary,
      disabledColor: AppColors.primaryLight,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF2F3F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontWeight: FontWeight.w300,
        fontSize: 16,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
  );
}


