import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 공용 칩: 카테고리/필터 등에 사용 (All, My, Sleep 등)
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const AppChip({super.key, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary : AppColors.primaryLight;
    final fg = selected ? AppColors.textOnPrimary : AppColors.textSecondary;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            letterSpacing: 0.55,
          ).copyWith(color: fg),
        ),
      ),
    );
  }
}


