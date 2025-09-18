import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/social_login_button.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';
import '../main.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // 인증 성공 시 메인 화면으로 이동
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? '회원가입에 실패했습니다.')),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface, // #FFFFFF
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Figma 기반 패딩
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 100), // 상단 여백
                  
                  // Create account 텍스트
                  Text(
                    'Create account',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary, // #3F414E
                      fontSize: 28, // Figma: fontSize: 28
                      fontWeight: FontWeight.w700, // Bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 80), // 텍스트와 입력 필드 사이 여백
                  
                  // 이메일 입력 필드
                  AppInput(
                    hintText: 'Email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return '올바른 이메일 형식을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 비밀번호 입력 필드
                  AppInput(
                    hintText: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary, // #A1A4B2
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 비밀번호 확인 입력 필드
                  AppInput(
                    hintText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary, // #A1A4B2
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호 확인을 입력해주세요';
                      }
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // CREATE ACCOUNT 버튼
                  AppButton(
                    label: 'CREATE ACCOUNT',
                    onPressed: authState.isLoading ? null : _signUpWithEmail,
                    filled: true,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // OR LOG IN WITH EMAIL 텍스트
                  Text(
                    'OR LOG IN WITH SOCIAL',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary, // #A1A4B2
                      fontWeight: FontWeight.w700, // Bold
                      letterSpacing: 0.7, // Figma: letterSpacing: 0.7
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Google 회원가입 버튼
                  SocialLoginButton(
                    type: SocialLoginType.google,
                    onPressed: _signUpWithGoogle,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Facebook 회원가입 버튼
                  SocialLoginButton(
                    type: SocialLoginType.facebook,
                    onPressed: _signUpWithFacebook,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Kakao 회원가입 버튼
                  SocialLoginButton(
                    type: SocialLoginType.kakao,
                    onPressed: _signUpWithKakao,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 로그인 링크
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'ALREADY HAVE AN ACCOUNT? ',
                              style: AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.textPrimary, // #3F414E
                                fontWeight: FontWeight.w500, // Medium
                                letterSpacing: 0.7, // Figma: letterSpacing: 0.7
                              ),
                            ),
                            TextSpan(
                              text: 'LOG IN',
                              style: AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.black, // #000000
                                fontWeight: FontWeight.w500, // Medium
                                letterSpacing: 0.7, // Figma: letterSpacing: 0.7
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 이메일 회원가입
  Future<void> _signUpWithEmail() async {
    if (isIncubatorMode) {
      // Incubator 모드에서는 바로 홈 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  /// Google 회원가입
  Future<void> _signUpWithGoogle() async {
    if (isIncubatorMode) {
      // Incubator 모드에서는 바로 홈 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
      return;
    }
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  /// Facebook 회원가입 (실제로는 Kakao로 대체)
  Future<void> _signUpWithFacebook() async {
    if (isIncubatorMode) {
      // Incubator 모드에서는 바로 홈 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
      return;
    }
    await ref.read(authProvider.notifier).signInWithKakao();
  }

  /// Kakao 회원가입
  Future<void> _signUpWithKakao() async {
    if (isIncubatorMode) {
      // Incubator 모드에서는 바로 홈 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
      return;
    }
    await ref.read(authProvider.notifier).signInWithKakao();
  }
}