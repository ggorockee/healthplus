import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 공용 텍스트 위젯: 타이포 토큰에 맞춘 프리셋 제공
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const AppText(this.data, {super.key, this.style, this.textAlign, this.maxLines});

  factory AppText.titleLarge(String data, {TextAlign? textAlign, TextStyle? style}) => AppText(
        data,
        textAlign: textAlign,
        style: style ?? AppTypography.textTheme.titleLarge,
      );

  factory AppText.titleMedium(String data, {TextAlign? textAlign, TextStyle? style}) => AppText(
        data,
        textAlign: textAlign,
        style: style ?? AppTypography.textTheme.titleMedium,
      );

  factory AppText.bodyLarge(String data, {TextAlign? textAlign, TextStyle? style}) => AppText(
        data,
        textAlign: textAlign,
        style: style ?? AppTypography.textTheme.bodyLarge,
      );

  factory AppText.bodyMedium(String data, {TextAlign? textAlign, TextStyle? style}) => AppText(
        data,
        textAlign: textAlign,
        style: style ?? AppTypography.textTheme.bodyMedium,
      );

  factory AppText.bodySmall(String data, {TextAlign? textAlign, TextStyle? style}) => AppText(
        data,
        textAlign: textAlign,
        style: style ?? AppTypography.textTheme.bodySmall,
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}


