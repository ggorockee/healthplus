import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 서비스 상태 관리
class AdMobNotifier extends StateNotifier<AdMobState> {
  AdMobNotifier() : super(const AdMobState());

  /// AdMob 초기화
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      state = state.copyWith(isInitialized: true);
      debugPrint('AdMob 초기화 완료');
    } catch (e) {
      debugPrint('AdMob 초기화 실패: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 배너 광고 로드
  Future<void> loadBannerAd(String adUnitId) async {
    try {
      final bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            state = state.copyWith(bannerAd: ad as BannerAd);
            debugPrint('배너 광고 로드 완료');
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('배너 광고 로드 실패: $error');
            ad.dispose();
            state = state.copyWith(bannerError: error.message);
          },
        ),
      );
      await bannerAd.load();
    } catch (e) {
      debugPrint('배너 광고 로드 중 오류: $e');
      state = state.copyWith(bannerError: e.toString());
    }
  }

  /// 배너 광고 해제
  void disposeBannerAd() {
    state.bannerAd?.dispose();
    state = state.copyWith(bannerAd: null);
  }
}

/// AdMob 상태 모델
class AdMobState {
  final bool isInitialized;
  final BannerAd? bannerAd;
  final String? error;
  final String? bannerError;

  const AdMobState({
    this.isInitialized = false,
    this.bannerAd,
    this.error,
    this.bannerError,
  });

  AdMobState copyWith({
    bool? isInitialized,
    BannerAd? bannerAd,
    String? error,
    String? bannerError,
  }) {
    return AdMobState(
      isInitialized: isInitialized ?? this.isInitialized,
      bannerAd: bannerAd ?? this.bannerAd,
      error: error ?? this.error,
      bannerError: bannerError ?? this.bannerError,
    );
  }
}

/// AdMob 프로바이더
final adMobProvider = StateNotifierProvider<AdMobNotifier, AdMobState>(
  (ref) => AdMobNotifier(),
);

/// 테스트용 광고 단위 ID
class AdUnitIds {
  // Android 실제 ID
  static const String androidAppId = 'ca-app-pub-3219791135582658~9464059809';
  static const String androidTopBanner = 'ca-app-pub-3219791135582658/3094092576';
  static const String androidInterstitial = 'ca-app-pub-3219791135582658/1291762600';
  static const String androidNative = 'ca-app-pub-3219791135582658/5039435928';
  static const String androidBottomBanner = 'ca-app-pub-3219791135582658/2413272583';

  // iOS 실제 ID
  static const String iosAppId = 'ca-app-pub-3219791135582658~8150978139';
  static const String iosBottomBanner = 'ca-app-pub-3219791135582658/8886347444';
  static const String iosInterstitial = 'ca-app-pub-3219791135582658/6160945902';
  static const String iosNative = 'ca-app-pub-3219791135582658/5935878331';
  static const String iosBottomBannerAlt = 'ca-app-pub-3219791135582658/4847864236';

  /// 하단 배너 광고 단위 ID (플랫폼별 반환)
  static String get bottomBanner {
    // 간단히 Android 우선; 실제로는 Platform.isIOS 체크 사용
    return androidBottomBanner;
  }

  /// 상단 배너 광고 단위 ID (플랫폼별 반환)
  static String get topBanner {
    return androidTopBanner;
  }

  /// 전면 광고 단위 ID (플랫폼별 반환)
  static String get interstitial {
    return androidInterstitial;
  }

  /// 네이티브 광고 단위 ID (플랫폼별 반환)
  static String get nativeAd {
    return androidNative;
  }
}
