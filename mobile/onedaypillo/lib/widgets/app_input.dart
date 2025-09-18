import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 공용 입력 필드 위젯: Figma 디자인 토큰 기반
class AppInput extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const AppInput({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: AppTypography.textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary, // #3F414E
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary, // #A1A4B2
          fontWeight: FontWeight.w300, // Light
          letterSpacing: 0.8, // Figma 디자인 토큰: letterSpacing: 0.8
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceAlt, // #F2F3F7
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Figma 디자인 토큰: borderRadius: 15
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18, // Figma 디자인 토큰: padding: "18px 16px"
        ),
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}


