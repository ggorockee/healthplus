import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('HealthPlus App E2E', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver!.close();
      }
    });

    test('전체 인증 흐름 테스트 (Mockup)', () async {
      // 1. 앱 시작 - 로그인 화면 확인
      await driver!.waitFor(find.text('로그인'));
      await driver!.waitFor(find.byValueKey('login_email_input'));

      // 2. 회원가입 화면으로 이동
      await driver!.tap(find.byValueKey('go_to_signup_button'));

      // 3. 회원가입 화면 확인
      await driver!.waitFor(find.text('HealthPlus 시작하기'));
      final emailInput = find.byValueKey('signup_email_input');
      final passwordInput = find.byValueKey('signup_password_input');
      final signupButton = find.byValueKey('signup_button');
      
      await driver!.waitFor(emailInput);
      await driver!.waitFor(passwordInput);
      await driver!.waitFor(find.byValueKey('google_login_button'));
      await driver!.waitFor(find.byValueKey('apple_login_button'));
      await driver!.waitFor(find.byValueKey('kakao_login_button'));

      // 4. 정보 입력 및 회원가입 버튼 탭 (Mockup)
      await driver!.tap(emailInput);
      await driver!.enterText('test@example.com');
      await driver!.tap(passwordInput);
      await driver!.enterText('password123');
      await driver!.tap(signupButton);
      
      // (Mockup이므로 네비게이션은 일어나지 않음)
      // 잠시 대기하여 UI 상호작용이 완료되었는지 확인
      await driver!.waitFor(find.text('HealthPlus 시작하기'));

      // 5. 다시 로그인 화면으로 이동
      await driver!.tap(find.byValueKey('go_to_login_button'));
      await driver!.waitFor(find.text('로그인'));
      await driver!.waitFor(find.byValueKey('login_email_input'));

      // 테스트 완료
    });
  });
}
