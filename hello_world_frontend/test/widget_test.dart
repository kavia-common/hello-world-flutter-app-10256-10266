import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world_frontend/main.dart';

void main() {
  testWidgets('App shows persistent header and starts on Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    // Header is always visible and contains app name as title + subtitle.
    expect(find.text('Calculator App'), findsNWidgets(2));

    // Starts on Login screen content.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);

    // Shows login fields.
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
  });

  testWidgets('Theme uses light scaffold background', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, isNotNull);

    final ThemeData theme = app.theme!;
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF9FAFB));
  });
}

