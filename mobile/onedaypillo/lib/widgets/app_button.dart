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
            foregroundColor: AppColors.white, // 더 명확한 흰색 사용
            shape: const StadiumBorder(),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 2, // 그림자 추가로 더 명확하게
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
          foregroundColor: AppColors.primary, // 아웃라인 버튼도 primary 색상 사용
          side: const BorderSide(color: AppColors.primary, width: 2), // 더 굵은 테두리
          shape: const StadiumBorder(),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: child,
      ),
    );
  }
}


