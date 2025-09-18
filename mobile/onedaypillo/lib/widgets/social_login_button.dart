import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 소셜 로그인 버튼 타입
enum SocialLoginType {
  google,
  facebook,
  kakao,
  apple,
}

/// 소셜 로그인 버튼 위젯
class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.type,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 63, // Figma 디자인 토큰: height: 63
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(38), // Figma 디자인 토큰: borderRadius: 38
        border: _getBorder(),
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
                else ...[
                  _buildIcon(),
                  const SizedBox(width: 12),
                ],
                Text(
                  _getButtonText(),
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: _getTextColor(),
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

  /// 아이콘 빌드
  Widget _buildIcon() {
    switch (type) {
      case SocialLoginType.google:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.g_mobiledata,
            size: 16,
            color: Color(0xFF4285F4),
          ),
        );
      case SocialLoginType.facebook:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFF1877F2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.facebook,
            size: 16,
            color: Colors.white,
          ),
        );
      case SocialLoginType.kakao:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE500), // Kakao Yellow
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            size: 16,
            color: Colors.black,
          ),
        );
      case SocialLoginType.apple:
        return const Icon(
          Icons.apple,
          size: 20,
          color: Colors.black,
        );
    }
  }

  /// 버튼 텍스트 가져오기
  String _getButtonText() {
    switch (type) {
      case SocialLoginType.google:
        return 'CONTINUE WITH GOOGLE';
      case SocialLoginType.facebook:
        return 'CONTINUE WITH FACEBOOK';
      case SocialLoginType.kakao:
        return 'CONTINUE WITH KAKAO';
      case SocialLoginType.apple:
        return 'CONTINUE WITH APPLE';
    }
  }

  /// 배경색 가져오기
  Color _getBackgroundColor() {
    switch (type) {
      case SocialLoginType.google:
        return Colors.transparent; // outline 스타일
      case SocialLoginType.facebook:
        return AppColors.secondary; // #7583CA
      case SocialLoginType.kakao:
        return const Color(0xFFFEE500); // Kakao Yellow
      case SocialLoginType.apple:
        return Colors.black;
    }
  }

  /// 테두리 가져오기
  Border? _getBorder() {
    switch (type) {
      case SocialLoginType.google:
        return Border.all(
          color: AppColors.border, // #EBEAEC
          width: 1,
        );
      case SocialLoginType.facebook:
      case SocialLoginType.kakao:
      case SocialLoginType.apple:
        return null;
    }
  }

  /// 텍스트 색상 가져오기
  Color _getTextColor() {
    switch (type) {
      case SocialLoginType.google:
        return AppColors.textPrimary; // #3F414E
      case SocialLoginType.facebook:
        return AppColors.textOnPrimary; // #F6F1FB
      case SocialLoginType.kakao:
        return Colors.black; // Kakao는 검은 텍스트
      case SocialLoginType.apple:
        return Colors.white;
    }
  }
}