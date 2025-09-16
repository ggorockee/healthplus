import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Firebase 설정 및 관리 클래스
class FirebaseConfig {
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static FirebasePerformance? _performance;
  static FirebaseRemoteConfig? _remoteConfig;

  /// Firebase Analytics 인스턴스
  static FirebaseAnalytics get analytics {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  /// Firebase Crashlytics 인스턴스
  static FirebaseCrashlytics get crashlytics {
    _crashlytics ??= FirebaseCrashlytics.instance;
    return _crashlytics!;
  }

  /// Firebase Performance 인스턴스
  static FirebasePerformance get performance {
    _performance ??= FirebasePerformance.instance;
    return _performance!;
  }

  /// Firebase Remote Config 인스턴스
  static FirebaseRemoteConfig get remoteConfig {
    _remoteConfig ??= FirebaseRemoteConfig.instance;
    return _remoteConfig!;
  }

  /// Remote Config 초기화
  static Future<void> initializeRemoteConfig() async {
    final remoteConfig = FirebaseConfig.remoteConfig;
    
    // 기본값 설정
    await remoteConfig.setDefaults({
      'app_version': '1.0.0',
      'feature_flags': {
        'enable_analytics': true,
        'enable_crashlytics': true,
        'enable_performance_monitoring': true,
      },
      'ui_settings': {
        'max_medications': 10,
        'notification_enabled': true,
      },
    });

    // Remote Config 설정
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // 값 가져오기
    await remoteConfig.fetchAndActivate();
  }

  /// 사용자 이벤트 로깅
  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      // 에러 로깅 실패 시 무시
    }
  }

  /// 사용자 속성 설정
  static Future<void> setUserProperty(String name, String? value) async {
    try {
      await analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      // 에러 로깅 실패 시 무시
    }
  }

  /// 사용자 ID 설정
  static Future<void> setUserId(String? userId) async {
    try {
      await analytics.setUserId(id: userId);
      await crashlytics.setUserIdentifier(userId ?? 'anonymous');
    } catch (e) {
      // 에러 로깅 실패 시 무시
    }
  }

  /// 커스텀 로그 기록
  static Future<void> logCustomEvent(String message) async {
    try {
      await crashlytics.log(message);
    } catch (e) {
      // 에러 로깅 실패 시 무시
    }
  }

  /// 성능 추적 시작
  static Trace startTrace(String name) {
    return performance.newTrace(name);
  }

  /// 앱 성능 이벤트 로깅
  static Future<void> logAppPerformanceEvent(String eventName, {Map<String, String>? attributes}) async {
    try {
      await logEvent('app_performance', parameters: {
        'event_name': eventName,
        ...?attributes,
      });
    } catch (e) {
      // 에러 로깅 실패 시 무시
    }
  }

  /// 약물 복용 이벤트 로깅
  static Future<void> logMedicationEvent(String action, String medicationName) async {
    try {
      await logEvent('medication_action', parameters: {
        'action': action,
        'medication_name': medicationName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // 에러 로깅 실패 시 무시
    }
  }

  /// 화면 조회 이벤트 로깅
  static Future<void> logScreenView(String screenName) async {
    try {
      await analytics.logScreenView(screenName: screenName);
    } catch (e) {
      // 에러 로깅 실패 시 무시
    }
  }
}
