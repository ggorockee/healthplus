import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../providers/subscription_provider.dart';

/// 네이티브 광고 위젯
class NativeAdWidget extends ConsumerStatefulWidget {
  const NativeAdWidget({super.key});

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  /// 네이티브 광고 로드
  void _loadNativeAd() async {
    final shouldShowAds = ref.read(shouldShowAdsProvider);
    if (!shouldShowAds) return;

    try {
      final ad = await AdMobService.loadNativeAd(
        onAdLoaded: (ad) {
          setState(() {
            _nativeAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          setState(() {
            _isAdLoaded = false;
          });
        },
      );
      
      if (ad == null) {
        setState(() {
          _isAdLoaded = false;
        });
      }
    } catch (e) {
      print('네이티브 광고 로드 실패: $e');
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
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox(
        height: 100,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 광고 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '광고',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 네이티브 광고 콘텐츠
          SizedBox(
            height: 80,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }
}

/// 약 목록용 네이티브 광고 위젯
class MedicationListNativeAdWidget extends ConsumerStatefulWidget {
  const MedicationListNativeAdWidget({super.key});

  @override
  ConsumerState<MedicationListNativeAdWidget> createState() => _MedicationListNativeAdWidgetState();
}

class _MedicationListNativeAdWidgetState extends ConsumerState<MedicationListNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  /// 네이티브 광고 로드
  void _loadNativeAd() async {
    final shouldShowAds = ref.read(shouldShowAdsProvider);
    if (!shouldShowAds) return;

    try {
      final ad = await AdMobService.loadNativeAd(
        onAdLoaded: (ad) {
          setState(() {
            _nativeAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          setState(() {
            _isAdLoaded = false;
          });
        },
      );
      
      if (ad == null) {
        setState(() {
          _isAdLoaded = false;
        });
      }
    } catch (e) {
      print('네이티브 광고 로드 실패: $e');
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
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox(
        height: 80,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 광고 라벨
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '광고',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 네이티브 광고 콘텐츠
          SizedBox(
            height: 60,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }
}
