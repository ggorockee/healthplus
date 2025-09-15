import 'dart:io';

/// AdMob 설정 클래스
class AdMobConfig {
  // 앱 ID
  static String get appId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3219791135582658~9464059809';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3219791135582658~8150978139';
    }
    return '';
  }
  
  // 배너 광고 ID
  static String get bannerAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3219791135582658/2413272583'; // 하단배너
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3219791135582658/8886347444'; // 하단배너
    }
    return '';
  }
  
  // 전면 광고 ID
  static String get interstitialAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3219791135582658/1291762600';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3219791135582658/6160945902';
    }
    return '';
  }
  
  // 네이티브 광고 ID
  static String get nativeAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3219791135582658/5039435928';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3219791135582658/5935878331';
    }
    return '';
  }
  
  // 상단 배너 광고 ID (Android만)
  static String get topBannerAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3219791135582658/3094092576';
    }
    return '';
  }
  
  // 테스트 광고 ID (개발용)
  static String get testBannerAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }
  
  static String get testInterstitialAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }
  
  static String get testNativeAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
    }
    return '';
  }
  
  // 개발 모드 여부
  static bool get isTestMode => true; // 배포 시 false로 변경
  
  // 실제 광고 ID 반환 (테스트 모드에 따라)
  static String getBannerAdId() => isTestMode ? testBannerAdId : bannerAdId;
  static String getInterstitialAdId() => isTestMode ? testInterstitialAdId : interstitialAdId;
  static String getNativeAdId() => isTestMode ? testNativeAdId : nativeAdId;
}
