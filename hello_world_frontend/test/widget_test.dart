import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world_frontend/main.dart';

void main() {
  testWidgets('Initial route is Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.widgetWithText(FilledButton, AppStrings.loginButton), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, AppStrings.goToSignUpButton), findsOneWidget);
  });

  testWidgets('Uses light theme background color parity', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, isNotNull);

    final ThemeData theme = app.theme!;
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF9FAFB));
  });
}
