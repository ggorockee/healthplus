import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/onboarding_provider.dart';
import 'providers/auth_provider.dart';
import 'models/auth_model.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'config/supabase_config.dart';
import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 환경 변수 초기화 (가장 먼저)
    await EnvConfig.init();
    
    // Firebase 초기화
    await Firebase.initializeApp();
    
    // Supabase 설정 유효성 검사
    if (!SupabaseConfig.isValid) {
      throw Exception('Supabase 설정이 올바르지 않습니다. .env 파일을 확인해주세요.');
    }
    
    // Supabase 초기화
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    
    // AdMob 초기화 비활성화 (임시)
    // await AdMobService.initialize();
    
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e) {
    print('앱 초기화 중 오류 발생: $e');
    // 에러 발생 시에도 앱 실행
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '약 관리',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 앱 초기화 위젯
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompletedAsync = ref.watch(onboardingCompletedProvider);
    final authStatus = ref.watch(authProvider);

    // 온보딩 완료 여부를 비동기적으로 처리
    return onboardingCompletedAsync.when(
      data: (onboardingCompleted) {
        // 온보딩이 완료되지 않았으면 온보딩 화면 표시
        if (!onboardingCompleted) {
          return const OnboardingScreen();
        }

        // 인증 상태에 따른 화면 분기
        if (authStatus == AuthStatus.authenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const Scaffold(
        body: Center(
          child: Text('오류가 발생했습니다'),
        ),
      ),
    );
  }
}