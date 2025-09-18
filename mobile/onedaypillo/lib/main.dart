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
import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

// Firebase Analytics 전역 인스턴스
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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
  
  // Firebase Crashlytics 설정
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // Firebase Performance 모니터링 활성화
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  
  // Firebase Remote Config 초기화
  await FirebaseConfig.initializeRemoteConfig();
  
  // Supabase 초기화
  await SupabaseConfig.initialize();
  
  // AdMob 초기화
  await MobileAds.instance.initialize();
  
  runApp(const ProviderScope(child: DailyPillApp()));
}

class DailyPillApp extends StatelessWidget {
  const DailyPillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루 알약',
      theme: buildLightTheme(),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 인증 상태에 따른 화면 분기
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 로딩 중
    if (authState.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 인증된 사용자
    if (authState.isAuthenticated) {
      return const MainNavigationScreen();
    }

    // 미인증 사용자
    return const LoginScreen();
  }
}