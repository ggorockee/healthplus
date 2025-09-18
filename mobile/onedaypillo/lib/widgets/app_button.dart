import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 공용 버튼: Figma 디자인 토큰 기반
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled; // true: primary filled, false: outlined
  final EdgeInsetsGeometry? padding;
  final double? width;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
    this.padding,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: 63, // Figma 디자인 토큰: height: 63
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(38), // Figma 디자인 토큰: borderRadius: 38
        border: filled ? null : Border.all(
          color: AppColors.border, // #EBEAEC
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(38),
          onTap: isLoading ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24), // Figma 디자인 토큰: padding: "0 24px"
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                    ),
                  )
                else
                  Text(
                    label,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: filled ? AppColors.textOnPrimary : AppColors.textPrimary,
                      letterSpacing: 0.7, // Figma 디자인 토큰: letterSpacing: 0.7
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


