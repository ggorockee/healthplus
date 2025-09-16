import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 공용 버튼: Figma의 START/GET STARTED 스타일 반영
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled; // true: primary filled, false: outlined/tonal
  final EdgeInsetsGeometry? padding;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.textTheme.labelLarge;
    final child = Text(label, style: textStyle);

    if (filled) {
      return SizedBox(
        width: width,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: const StadiumBorder(),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.primaryLight),
          shape: const StadiumBorder(),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: child,
      ),
    );
  }
}


