import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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