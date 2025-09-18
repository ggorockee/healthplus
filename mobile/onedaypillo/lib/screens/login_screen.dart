import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/social_login_button.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'main_navigation_screen.dart';

/// 로그인 화면
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          SnackBar(content: Text(next.errorMessage ?? '로그인에 실패했습니다.')),
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
                  
                  // Welcome Back! 텍스트
                  Text(
                    'Welcome Back!',
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
                  
                  // LOG IN 버튼
                  AppButton(
                    label: 'LOG IN',
                    onPressed: authState.isLoading ? null : _signInWithEmail,
                    filled: true,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Forgot Password? 링크
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // 비밀번호 찾기 기능 (추후 구현)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('비밀번호 찾기 기능은 추후 구현 예정입니다.')),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary, // #3F414E
                          fontWeight: FontWeight.w500, // Medium
                          letterSpacing: 0.7, // Figma: letterSpacing: 0.7
                        ),
                      ),
                    ),
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
                  
                  // Google 로그인 버튼
                  SocialLoginButton(
                    type: SocialLoginType.google,
                    onPressed: _signInWithGoogle,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Facebook 로그인 버튼
                  SocialLoginButton(
                    type: SocialLoginType.facebook,
                    onPressed: _signInWithFacebook,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Kakao 로그인 버튼
                  SocialLoginButton(
                    type: SocialLoginType.kakao,
                    onPressed: _signInWithKakao,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 회원가입 링크
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
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
                              text: 'SIGN UP',
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

  /// 이메일 로그인
  Future<void> _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  /// Google 로그인
  Future<void> _signInWithGoogle() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  /// Facebook 로그인 (실제로는 Kakao로 대체)
  Future<void> _signInWithFacebook() async {
    await ref.read(authProvider.notifier).signInWithKakao();
  }

  /// Kakao 로그인
  Future<void> _signInWithKakao() async {
    await ref.read(authProvider.notifier).signInWithKakao();
  }
}
