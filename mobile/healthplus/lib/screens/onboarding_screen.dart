import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_model.dart';
import '../providers/onboarding_provider.dart';

/// 온보딩 화면 위젯
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);
    final onboardingData = OnboardingData.onboardingScreens[currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // 건너뛰기 버튼
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () async {
                    await onboardingNotifier.completeOnboarding();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 아이콘 영역
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: onboardingData.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 메인 아이콘
                        Icon(
                          onboardingData.icon,
                          size: 80,
                          color: onboardingData.iconColor,
                        ),
                        // 보조 아이콘 (오른쪽 위에 위치)
                        if (onboardingData.secondaryIcon != null)
                          Positioned(
                            right: 30,
                            top: 30,
                            child: Icon(
                              onboardingData.secondaryIcon!,
                              size: 40,
                              color: onboardingData.iconColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 제목과 설명
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      onboardingData.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      onboardingData.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 페이지 인디케이터
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  OnboardingData.onboardingScreens.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == currentPage 
                          ? const Color(0xFF4CAF50) 
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 다음/시작하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (onboardingNotifier.isLastPage) {
                      // 마지막 페이지 - 온보딩 완료
                      await onboardingNotifier.completeOnboarding();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    } else {
                      // 다음 페이지로 이동
                      onboardingNotifier.nextPage();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    onboardingNotifier.isLastPage ? '시작하기' : '다음',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
