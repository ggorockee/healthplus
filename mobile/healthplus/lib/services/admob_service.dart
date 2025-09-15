import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

/// AdMob 서비스 클래스
class AdMobService {
  static bool _isInitialized = false;
  static InterstitialAd? _interstitialAd;
  static int _interstitialAdLoadAttempts = 0;
  static int _interstitialAdShowCount = 0;
  static DateTime? _lastInterstitialAdTime;
  
  // ========== 초기화 ==========
  
  /// AdMob 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // AdMob 초기화 전에 설정 확인
      final appId = AdMobConfig.appId;
      if (appId.isEmpty) {
        print('AdMob 앱 ID가 설정되지 않았습니다.');
        return;
      }
      
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('AdMob 초기화 완료');
      
      // 전면 광고 미리 로드 (비동기로 처리)
      Future.delayed(const Duration(seconds: 1), () {
        _loadInterstitialAd();
      });
    } catch (e) {
      print('AdMob 초기화 실패: $e');
      _isInitialized = false;
      // 초기화 실패해도 앱은 계속 실행
    }
  }
  
  // ========== 배너 광고 ==========
  
  /// 배너 광고 생성
  static BannerAd? createBannerAd({
    required AdSize adSize,
    required Function(Ad, LoadAdError) onAdFailedToLoad,
    required Function(Ad) onAdLoaded,
  }) {
    if (!_isInitialized) {
      print('AdMob이 초기화되지 않았습니다.');
      return null;
    }
    
    final adUnitId = AdMobConfig.getBannerAdId();
    if (adUnitId.isEmpty) {
      print('배너 광고 ID가 설정되지 않았습니다.');
      return null;
    }
    
    return BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (ad) => _logAdEvent('banner_opened'),
        onAdClosed: (ad) => _logAdEvent('banner_closed'),
        onAdClicked: (ad) => _logAdEvent('banner_clicked'),
      ),
    );
  }
  
  // ========== 전면 광고 ==========
  
  /// 전면 광고 로드
  static void _loadInterstitialAd() {
    if (!_isInitialized || _interstitialAdLoadAttempts >= 3) return;
    
    final adUnitId = AdMobConfig.getInterstitialAdId();
    if (adUnitId.isEmpty) {
      print('전면 광고 ID가 설정되지 않았습니다.');
      return;
    }
    
    try {
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialAdLoadAttempts = 0;
            _logAdEvent('interstitial_loaded');
          },
          onAdFailedToLoad: (error) {
            _interstitialAdLoadAttempts++;
            _logAdEvent('interstitial_load_failed', error: error.message);
            // 3초 후 재시도
            Future.delayed(const Duration(seconds: 3), () {
              _loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      print('전면 광고 로드 중 오류 발생: $e');
    }
  }
  
  /// 전면 광고 표시
  static Future<bool> showInterstitialAd() async {
    if (!_isInitialized) {
      print('AdMob이 초기화되지 않았습니다.');
      return false;
    }
    
    // 일일 최대 5회 제한
    if (_interstitialAdShowCount >= 5) return false;
    
    // 최소 30초 간격
    if (_lastInterstitialAdTime != null) {
      final timeDiff = DateTime.now().difference(_lastInterstitialAdTime!);
      if (timeDiff.inSeconds < 30) return false;
    }
    
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _logAdEvent('interstitial_showed');
        },
        onAdDismissedFullScreenContent: (ad) {
          _interstitialAdShowCount++;
          _lastInterstitialAdTime = DateTime.now();
          _logAdEvent('interstitial_dismissed');
          ad.dispose();
          _interstitialAd = null;
          // 다음 광고 미리 로드
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _logAdEvent('interstitial_show_failed', error: error.message);
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
        },
      );
      
      await _interstitialAd!.show();
      return true;
    }
    
    return false;
  }
  
  // ========== 네이티브 광고 ==========
  
  /// 네이티브 광고 로드
  static Future<NativeAd?> loadNativeAd({
    required Function(NativeAd) onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) async {
    if (!_isInitialized) {
      print('AdMob이 초기화되지 않았습니다.');
      return null;
    }
    
    final adUnitId = AdMobConfig.getNativeAdId();
    if (adUnitId.isEmpty) {
      print('네이티브 광고 ID가 설정되지 않았습니다.');
      return null;
    }
    
    try {
      final nativeAd = NativeAd(
        adUnitId: adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            _logAdEvent('native_loaded');
            onAdLoaded(ad as NativeAd);
          },
          onAdFailedToLoad: (ad, error) {
            _logAdEvent('native_load_failed', error: error.message);
            onAdFailedToLoad(error);
          },
          onAdClicked: (ad) => _logAdEvent('native_clicked'),
          onAdClosed: (ad) => _logAdEvent('native_closed'),
          onAdOpened: (ad) => _logAdEvent('native_opened'),
        ),
        request: const AdRequest(),
      );
      
      await nativeAd.load();
      return nativeAd;
    } catch (e) {
      print('네이티브 광고 로드 중 오류 발생: $e');
      return null;
    }
  }
  
  // ========== 광고 이벤트 로깅 ==========
  
  /// 광고 이벤트 로깅
  static void _logAdEvent(String event, {String? error}) {
    print('AdMob Event: $event ${error != null ? 'Error: $error' : ''}');
    // 추후 Firebase Analytics 연동 시 여기에 추가
  }
  
  // ========== 유틸리티 ==========
  
  /// 전면 광고 표시 가능 여부 확인
  static bool canShowInterstitialAd() {
    return _interstitialAd != null && 
           _interstitialAdShowCount < 5 &&
           (_lastInterstitialAdTime == null || 
            DateTime.now().difference(_lastInterstitialAdTime!).inSeconds >= 30);
  }
  
  /// 일일 전면 광고 카운트 리셋 (매일 자정에 호출)
  static void resetDailyInterstitialCount() {
    _interstitialAdShowCount = 0;
  }
  
  /// 리소스 정리
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
