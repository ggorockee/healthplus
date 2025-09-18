import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onedaypillo/main.dart';
import 'package:onedaypillo/widgets/app_button.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DailyPillApp(),
      ),
    );

    // The auth state resolves synchronously, so we should see the LoginScreen.
    await tester.pump();

    // Verify that the login screen is shown.
    expect(find.text('하루 알약'), findsOneWidget);
    expect(find.text('이메일'), findsOneWidget);
    
    // Find the login button specifically to avoid ambiguity with the title.
    expect(find.widgetWithText(AppButton, '로그인'), findsOneWidget);
    
    // Find the sign up link text.
    expect(find.text('계정이 없으신가요? '), findsOneWidget);
  });
}