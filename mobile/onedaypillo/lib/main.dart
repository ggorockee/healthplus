import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'config/theme.dart';
import 'config/supabase_config.dart';
import 'config/firebase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/api_auth_provider.dart';
import 'services/api_client.dart';
import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

// Firebase Analytics 전역 인스턴스
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// 개발 단계 설정
const bool isIncubatorMode = true; // 개발 초기 단계: true, 프로덕션: false

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  await dotenv.load(fileName: ".env.common");
  if (kReleaseMode) {
    await dotenv.load(fileName: ".env.prod");
  } else {
    await dotenv.load(fileName: ".env.dev");
  }
  
  // Firebase 초기화
  await Firebase.initializeApp();
  
  // Incubator 모드에서는 일부 서비스 비활성화
  if (!isIncubatorMode) {
    // Firebase Crashlytics 설정
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Firebase Performance 모니터링 활성화
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    
    // Firebase Remote Config 초기화
    await FirebaseConfig.initializeRemoteConfig();
    
    // AdMob 초기화
    await MobileAds.instance.initialize();
  }
  
  // Supabase 초기화 (개발 단계에서도 필요)
  await SupabaseConfig.initialize();
  
  // API 클라이언트 초기화
  ApiClient().initialize();
  
  runApp(const ProviderScope(child: DailyPillApp()));
}

class DailyPillApp extends StatelessWidget {
  const DailyPillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: isIncubatorMode ? '하루 알약 (Incubator)' : '하루 알약',
      theme: buildLightTheme(),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: isIncubatorMode, // Incubator 모드에서는 디버그 배너 표시
    );
  }
}

/// 인증 상태에 따른 화면 분기
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Incubator 모드에서는 바로 홈 화면으로 이동
    if (isIncubatorMode) {
      return const MainNavigationScreen();
    }

    final authState = ref.watch(authProvider);
    final apiAuthState = ref.watch(apiAuthProvider);

    // 로딩 중
    if (authState.status == AuthStatus.loading || apiAuthState.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 인증된 사용자 (API 또는 Supabase)
    if (authState.isAuthenticated || apiAuthState.status == AuthStatus.authenticated) {
      return const MainNavigationScreen();
    }

    // 미인증 사용자
    return const LoginScreen();
  }
}