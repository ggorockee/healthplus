import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../providers/subscription_provider.dart';

/// 하단 고정 배너 광고 위젯
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  /// 배너 광고 로드
  void _loadBannerAd() {
    final shouldShowAds = ref.read(shouldShowAdsProvider);
    if (!shouldShowAds) return;

    try {
      _bannerAd = AdMobService.createBannerAd(
        adSize: AdSize.banner,
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
          });
        },
      );
      _bannerAd?.load();
    } catch (e) {
      print('배너 광고 로드 실패: $e');
      setState(() {
        _isAdLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowAds = ref.watch(shouldShowAdsProvider);
    
    // 구독자에게는 광고 표시 안함
    if (!shouldShowAds) {
      return const SizedBox.shrink();
    }

    // 광고가 로드되지 않았으면 빈 공간
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            '광고 로딩 중...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// 상단 배너 광고 위젯 (Android만)
class TopBannerAdWidget extends ConsumerStatefulWidget {
  const TopBannerAdWidget({super.key});

  @override
  ConsumerState<TopBannerAdWidget> createState() => _TopBannerAdWidgetState();
}

class _TopBannerAdWidgetState extends ConsumerState<TopBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  /// 배너 광고 로드
  void _loadBannerAd() {
    final shouldShowAds = ref.read(shouldShowAdsProvider);
    if (!shouldShowAds) return;

    try {
      _bannerAd = AdMobService.createBannerAd(
        adSize: AdSize.banner,
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
          });
        },
      );
      _bannerAd?.load();
    } catch (e) {
      print('배너 광고 로드 실패: $e');
      setState(() {
        _isAdLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowAds = ref.watch(shouldShowAdsProvider);
    
    // 구독자에게는 광고 표시 안함
    if (!shouldShowAds) {
      return const SizedBox.shrink();
    }

    // 광고가 로드되지 않았으면 빈 공간
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            '광고 로딩 중...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
