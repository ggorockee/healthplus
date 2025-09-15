import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 구독 상태 열거형
enum SubscriptionStatus {
  free('무료', '무료 사용자'),
  premium('프리미엄', '유료 구독자'),
  trial('체험', '체험 사용자');

  const SubscriptionStatus(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 구독 정보 모델
class SubscriptionInfo {
  final SubscriptionStatus status;
  final DateTime? expiryDate;
  final String? planName;
  final bool isActive;

  const SubscriptionInfo({
    required this.status,
    this.expiryDate,
    this.planName,
    this.isActive = true,
  });

  SubscriptionInfo copyWith({
    SubscriptionStatus? status,
    DateTime? expiryDate,
    String? planName,
    bool? isActive,
  }) {
    return SubscriptionInfo(
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      planName: planName ?? this.planName,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// 구독 상태 관리 클래스
class SubscriptionNotifier extends StateNotifier<SubscriptionInfo> {
  SubscriptionNotifier() : super(const SubscriptionInfo(status: SubscriptionStatus.free)) {
    _loadSubscriptionStatus();
  }

  /// 구독 상태 로드
  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('subscription_status') ?? 'free';
    final expiryString = prefs.getString('subscription_expiry');
    final planName = prefs.getString('subscription_plan');
    
    SubscriptionStatus status;
    switch (statusString) {
      case 'premium':
        status = SubscriptionStatus.premium;
        break;
      case 'trial':
        status = SubscriptionStatus.trial;
        break;
      default:
        status = SubscriptionStatus.free;
    }
    
    DateTime? expiryDate;
    if (expiryString != null) {
      expiryDate = DateTime.parse(expiryString);
    }
    
    state = SubscriptionInfo(
      status: status,
      expiryDate: expiryDate,
      planName: planName,
      isActive: expiryDate == null || expiryDate.isAfter(DateTime.now()),
    );
  }

  /// 구독 상태 업데이트
  Future<void> updateSubscriptionStatus({
    required SubscriptionStatus status,
    DateTime? expiryDate,
    String? planName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('subscription_status', status.name);
    if (expiryDate != null) {
      await prefs.setString('subscription_expiry', expiryDate.toIso8601String());
    }
    if (planName != null) {
      await prefs.setString('subscription_plan', planName);
    }
    
    state = state.copyWith(
      status: status,
      expiryDate: expiryDate,
      planName: planName,
      isActive: expiryDate == null || expiryDate.isAfter(DateTime.now()),
    );
  }

  /// 구독 취소
  Future<void> cancelSubscription() async {
    await updateSubscriptionStatus(status: SubscriptionStatus.free);
  }

  /// 체험 구독 시작
  Future<void> startTrial({required int trialDays}) async {
    final expiryDate = DateTime.now().add(Duration(days: trialDays));
    await updateSubscriptionStatus(
      status: SubscriptionStatus.trial,
      expiryDate: expiryDate,
      planName: '체험',
    );
  }

  /// 프리미엄 구독 시작
  Future<void> startPremium({required int subscriptionDays, required String planName}) async {
    final expiryDate = DateTime.now().add(Duration(days: subscriptionDays));
    await updateSubscriptionStatus(
      status: SubscriptionStatus.premium,
      expiryDate: expiryDate,
      planName: planName,
    );
  }

  /// 구독 만료 확인
  bool get isSubscriptionExpired {
    if (state.expiryDate == null) return false;
    return DateTime.now().isAfter(state.expiryDate!);
  }

  /// 광고 표시 가능 여부 (무료 사용자만 광고 표시)
  bool get shouldShowAds {
    return state.status == SubscriptionStatus.free && state.isActive;
  }
}

/// 구독 상태 관리 Provider
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionInfo>((ref) {
  return SubscriptionNotifier();
});

/// 광고 표시 가능 여부 Provider
final shouldShowAdsProvider = Provider<bool>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.status == SubscriptionStatus.free && subscription.isActive;
});
