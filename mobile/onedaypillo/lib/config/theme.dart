import 'package:flutter/material.dart';

/// 앱 전역 테마 토큰 정의
/// - 색상: Figma 디자인 시스템 기반 (design-tokens.json)
/// - 타이포그래피: HelveticaNeue 계열 가중치/사이즈 맵핑
class AppColors {
  AppColors._();

  // Primary brand colors (Figma 기반)
  static const Color primary = Color(0xFF8E97FD); // 메인 보라색
  static const Color primaryDark = Color(0xFF7583CA); // 다크 보라
  static const Color primaryLight = Color(0xFFF2F3F7); // 라이트 그레이

  // Secondary colors (Figma 기반)
  static const Color secondary = Color(0xFF7583CA); // 페이스북 버튼 색상
  static const Color secondaryLight = Color(0xFFF3F0FF); // 라이트 보라

  // Accent colors (Figma 기반)
  static const Color accent = Color(0xFF3F414E); // 다크 텍스트
  static const Color accentLight = Color(0xFFECFDF5); // 라이트 그린
  
  // Tertiary colors (Figma 기반)
  static const Color tertiary = Color(0xFF6B7280); // 그레이
  static const Color tertiaryLight = Color(0xFFF9FAFB); // 라이트 그레이

  // Text colors (Figma 기반)
  static const Color textPrimary = Color(0xFF3F414E); // 주요 텍스트
  static const Color textSecondary = Color(0xFFA1A4B2); // 보조 텍스트
  static const Color textOnPrimary = Color(0xFFF6F1FB); // 버튼 내 텍스트
  static const Color textOnDark = Color(0xFFF9FAFB);

  // Surface colors (Figma 기반)
  static const Color surface = Color(0xFFFFFFFF); // 배경색
  static const Color surfaceAlt = Color(0xFFF2F3F7); // 입력 필드 배경
  static const Color surfaceDark = Color(0xFF111827);

  // Utility colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Status colors (세련된 색상)
  static const Color success = Color(0xFF10B981); // 에메랄드
  static const Color error = Color(0xFFEF4444); // 모던 레드
  static const Color warning = Color(0xFFF59E0B); // 앰버
  static const Color info = Color(0xFF3B82F6); // 블루

  // Border colors (Figma 기반)
  static const Color border = Color(0xFFEBEAEC); // 테두리 색상
  static const Color borderLight = Color(0xFFE6E6E6); // 라이트 테두리

  // Component specific colors (Figma 기반)
  static const Color meditation = Color(0xFF8E97FD); // 명상 카드
  static const Color relaxation = Color(0xFFFFC97E); // 릴랙세이션 카드
  static const Color focus = Color(0xFFAFDBC5); // 포커스 카드
  static const Color welcome = Color(0xFFFFECCC); // 웰컴 텍스트
}

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'HelveticaNeue';

  // Figma 디자인 토큰 기반 타이포그래피
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 30,
      height: 41.13 / 30, // lineHeight: 41.13
      letterSpacing: 0.3,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      height: 37.8 / 28, // lineHeight: 37.8
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 18,
      height: 19.46 / 18, // lineHeight: 19.46
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 17.3 / 16, // lineHeight: 17.3
      letterSpacing: 0.8,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.4,
      color: AppColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.3,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 15.13 / 14, // lineHeight: 15.13
      letterSpacing: 0.7,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 15.13 / 14,
      letterSpacing: 0.7,
      color: AppColors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 12.97 / 12, // lineHeight: 12.97
      letterSpacing: 0.6,
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
      secondary: AppColors.accent,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
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
        color: Color(0xFFA1A4B2),
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


