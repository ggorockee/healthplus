import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 온보딩 상태 관리 클래스
class OnboardingNotifier extends StateNotifier<int> {
  OnboardingNotifier() : super(0);

  /// 다음 온보딩 화면으로 이동
  void nextPage() {
    if (state < 2) { // 0, 1, 2 (총 3개 화면)
      state = state + 1;
    }
  }

  /// 이전 온보딩 화면으로 이동
  void previousPage() {
    if (state > 0) {
      state = state - 1;
    }
  }

  /// 온보딩 완료 처리
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  /// 온보딩 완료 여부 확인
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  /// 현재 페이지가 마지막 페이지인지 확인
  bool get isLastPage => state == 2;

  /// 현재 페이지가 첫 번째 페이지인지 확인
  bool get isFirstPage => state == 0;
}

/// 온보딩 상태 관리 Provider
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, int>((ref) {
  return OnboardingNotifier();
});

/// 온보딩 완료 여부 Provider
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  return await OnboardingNotifier.isOnboardingCompleted();
});
