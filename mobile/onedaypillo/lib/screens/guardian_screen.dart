import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_card.dart';

/// 가족 관리 화면 (플레이스홀더)
class GuardianScreen extends StatelessWidget {
  const GuardianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: AppText.titleLarge('가족 관리'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // 하단 여백 추가
        child: Column(
          children: [
            // 메인 카드
            AppCard(
              child: Column(
                children: [
                  Icon(
                    Icons.family_restroom,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  AppText.titleMedium(
                    '가족과 함께 관리하세요',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  AppText.bodyMedium(
                    '가족이나 친구를 초대해 약 복용 현황을 공유하고, 잊지 않도록 도움을 받을 수 있어요.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: '가족/친구 초대하기',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('곧 출시될 기능입니다!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 기능 소개 카드들
            _buildFeatureCard(
              icon: Icons.notifications_active,
              title: '부드러운 알림',
              description: '가족이 약 복용을 잊었을 때 부드럽게 알려드려요',
            ),
            
            const SizedBox(height: 16),
            
            _buildFeatureCard(
              icon: Icons.visibility,
              title: '복용 현황 확인',
              description: '가족의 약 복용 현황을 실시간으로 확인할 수 있어요',
            ),
            
            const SizedBox(height: 16),
            
            _buildFeatureCard(
              icon: Icons.chat_bubble_outline,
              title: '응원 메시지',
              description: '가족에게 따뜻한 응원 메시지를 보낼 수 있어요',
            ),
            
            const SizedBox(height: 20), // 추가 여백
          ],
        ),
      ),
    );
  }

  /// 기능 소개 카드 위젯
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyLarge(title),
                const SizedBox(height: 4),
                AppText.bodySmall(
                  description,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
