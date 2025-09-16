import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 공용 카드: 홈 목록/코스 카드 등에서 사용
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;

  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.background});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: background ?? AppColors.white,
      elevation: Theme.of(context).cardTheme.elevation ?? 0,
      shape: Theme.of(context).cardTheme.shape,
      child: Padding(padding: padding, child: child),
    );
  }
}


