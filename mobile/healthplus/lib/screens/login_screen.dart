import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/auth_model.dart';

/// 로그인 화면
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUpMode = false;
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
    final authStatus = ref.watch(authProvider);
    final formData = ref.watch(loginFormProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // 로고 및 타이틀
                  _buildHeader(),
                  
                  const SizedBox(height: 40),
                  
                  // 소셜 로그인 버튼들
                  _buildSocialLoginButtons(),
                  
                  const SizedBox(height: 16),
                  
                  // 구분선
                  _buildDivider(),
                  
                  const SizedBox(height: 16),
                  
                  // 이메일 로그인/회원가입 폼
                  _buildEmailForm(),
                  
                  const SizedBox(height: 16),
                  
                  // 로그인/회원가입 전환
                  _buildModeToggle(),
                  
                  const SizedBox(height: 24),
                  
                  // 약관 동의 (회원가입 모드일 때만)
                  if (_isSignUpMode) _buildTermsAgreement(),
                  
                  const Spacer(),
                  
                  // 하단 안내
                  _buildBottomText(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 (로고 및 타이틀)
  Widget _buildHeader() {
    return Column(
      children: [
        // 약병 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF4CAF50),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.medication,
            size: 40,
            color: Color(0xFF4CAF50),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 타이틀
        const Text(
          '내 약 관리',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 설명 텍스트
        const Column(
          children: [
            Text(
              '건강한 약 복용 습관을 만들어보세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '정확한 시간에 알림을 받고 체계적으로 관리하세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 소셜 로그인 버튼들
  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // 카카오 로그인
        _buildSocialButtonWithImage(
          '카카오로 계속하기',
          Colors.yellow.shade400,
          Colors.black,
          'kakao_logo.png',
          () => _showComingSoonDialog('카카오 로그인'),
        ),
        
        const SizedBox(height: 12),
        
        // 구글 로그인
        _buildSocialButtonWithImage(
          'Google로 계속하기',
          Colors.white,
          Colors.black,
          'google_logo.png',
          () => _showComingSoonDialog('구글 로그인'),
          hasBorder: true,
        ),
        
        const SizedBox(height: 12),
        
        // 애플 로그인
        _buildSocialButtonWithImage(
          'Apple로 계속하기',
          Colors.black,
          Colors.white,
          'apple-logo.png',
          () => _showComingSoonDialog('Apple 로그인'),
        ),
      ],
    );
  }

  /// 준비 중 다이얼로그 표시
  void _showComingSoonDialog(String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$serviceName 준비 중'),
        content: Text('$serviceName 기능은 현재 개발 중입니다.\n곧 만나보실 수 있습니다!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 소셜 로그인 버튼 (이미지 사용)
  Widget _buildSocialButtonWithImage(
    String text,
    Color backgroundColor,
    Color textColor,
    String imagePath,
    VoidCallback onPressed, {
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasBorder ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 소셜 로그인 버튼
  Widget _buildSocialButton(
    String text,
    Color backgroundColor,
    Color textColor,
    IconData icon,
    VoidCallback onPressed, {
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasBorder ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '또는',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  /// 이메일 폼
  Widget _buildEmailForm() {
    return Column(
      children: [
        // 이메일 입력
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: '이메일',
            hintText: '이메일을 입력하세요',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 비밀번호 입력
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: '비밀번호',
            hintText: '비밀번호를 입력하세요',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        
        // 비밀번호 확인 (회원가입 모드일 때만)
        if (_isSignUpMode) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              hintText: '비밀번호를 다시 입력하세요',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // 이메일 로그인/회원가입 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSignUpMode ? _handleSignUp : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email_outlined, size: 20),
                const SizedBox(width: 12),
                Text(
                  _isSignUpMode ? '이메일로 회원가입' : '이메일로 로그인',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 모드 전환
  Widget _buildModeToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSignUpMode = !_isSignUpMode;
        });
      },
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          children: [
            TextSpan(text: _isSignUpMode ? '이미 계정이 있으신가요? ' : '계정이 없으신가요? '),
            TextSpan(
              text: _isSignUpMode ? '로그인' : '회원가입',
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 약관 동의
  Widget _buildTermsAgreement() {
    return Row(
      children: [
        Checkbox(
          value: ref.watch(loginFormProvider).agreeToTerms,
          onChanged: (value) {
            ref.read(loginFormProvider.notifier).toggleAgreeToTerms();
          },
          activeColor: const Color(0xFF4CAF50),
        ),
        Expanded(
          child: Text(
            '회원가입 시 서비스 이용약관 및 개인정보 처리방침에 동의한 것으로 간주됩니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  /// 하단 안내 텍스트
  Widget _buildBottomText() {
    return Text(
      '회원가입 시 서비스 이용약관 및 개인정보 처리방침에 동의한 것으로 간주됩니다.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade500,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 로그인 처리
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      final result = await authNotifier.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (result.isSuccess) {
        _showSuccessDialog(result.message);
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      _showErrorDialog('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 회원가입 처리
  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('모든 필드를 입력해주세요.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('비밀번호가 일치하지 않습니다.');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog('비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    if (!ref.read(loginFormProvider).agreeToTerms) {
      _showErrorDialog('약관에 동의해주세요.');
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    
    try {
      final result = await authNotifier.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _emailController.text.split('@')[0], // 이메일에서 이름 추출
      );
      
      if (result.isSuccess) {
        _showSuccessDialog(result.message);
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      _showErrorDialog('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 성공 다이얼로그 표시
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성공'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
