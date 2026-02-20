import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world_frontend/main.dart';

Finder _filledButtonWithText(String text) => find.widgetWithText(FilledButton, text);
Finder _outlinedButtonWithText(String text) => find.widgetWithText(OutlinedButton, text);

void main() {
  group('CalculatorApp - Login screen', () {
    testWidgets('initial route shows Login screen with unambiguous finders', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      // "Login" appears twice (title + button). Use unambiguous finders.
      expect(find.text(AppStrings.loginTitle), findsNWidgets(2));
      expect(_filledButtonWithText(AppStrings.loginButton), findsOneWidget);
      expect(_outlinedButtonWithText(AppStrings.goToSignUpButton), findsOneWidget);

      // Ensure fields exist by label.
      expect(find.widgetWithText(TextField, AppStrings.emailLabel), findsOneWidget);
      expect(find.widgetWithText(TextField, AppStrings.passwordLabel), findsOneWidget);
    });

    testWidgets('login validation shows field errors + general banner', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tester.tap(_filledButtonWithText(AppStrings.loginButton));
      await tester.pumpAndSettle();

      // General banner
      expect(find.text(AppStrings.fixHighlightedFields), findsOneWidget);

      // Field errors
      expect(find.text(AppStrings.emailRequired), findsOneWidget);
      expect(find.text(AppStrings.passwordRequired), findsOneWidget);
    });

    testWidgets('successful login clears stack and shows Dashboard (cannot pop back)', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tester.enterText(find.widgetWithText(TextField, AppStrings.emailLabel), 'user@example.com');
      await tester.enterText(find.widgetWithText(TextField, AppStrings.passwordLabel), '123456');

      await tester.tap(_filledButtonWithText(AppStrings.loginButton));

      // Navigation happens in a post-frame callback -> settle.
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.dashboardTitle), findsOneWidget);

      // pushNamedAndRemoveUntil should clear auth screens from back stack.
      final dynamic popped = await tester.binding.handlePopRoute();
      expect(popped, isFalse);

      await tester.pumpAndSettle();
      expect(find.text(AppStrings.dashboardTitle), findsOneWidget);
      expect(find.text(AppStrings.loginTitle), findsNothing);
    });
  });

  group('CalculatorApp - Sign up screen', () {
    testWidgets('sign up validation shows confirm password error + general banner', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tester.tap(_outlinedButtonWithText(AppStrings.goToSignUpButton));
      await tester.pumpAndSettle();

      // "Sign Up" appears in both the AppBar title and the submit button text.
      // Assert specifically on the AppBar title to avoid ambiguity.
      expect(find.widgetWithText(AppBar, AppStrings.signUpTitle), findsOneWidget);

      // Tap Sign Up with empty fields.
      await tester.tap(_filledButtonWithText(AppStrings.signUpButton));
      await tester.pumpAndSettle();

      // General banner
      expect(find.text(AppStrings.fixHighlightedFields), findsOneWidget);

      // Field errors
      expect(find.text(AppStrings.emailRequired), findsOneWidget);
      expect(find.text(AppStrings.passwordRequired), findsOneWidget);
      expect(find.text(AppStrings.confirmPasswordRequired), findsOneWidget);
    });

    testWidgets('successful sign up clears stack and shows Dashboard (cannot pop back)', (WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tester.tap(_outlinedButtonWithText(AppStrings.goToSignUpButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, AppStrings.emailLabel), 'user@example.com');
      await tester.enterText(find.widgetWithText(TextField, AppStrings.passwordLabel), '123456');
      await tester.enterText(find.widgetWithText(TextField, AppStrings.confirmPasswordLabel), '123456');

      await tester.tap(_filledButtonWithText(AppStrings.signUpButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.dashboardTitle), findsOneWidget);

      // pushNamedAndRemoveUntil should clear auth screens from back stack.
      final dynamic popped = await tester.binding.handlePopRoute();
      expect(popped, isFalse);

      await tester.pumpAndSettle();
      expect(find.text(AppStrings.dashboardTitle), findsOneWidget);
      expect(find.text(AppStrings.signUpTitle), findsNothing);
    });
  });

  group('CalculatorApp - Dashboard calculator', () {
    Future<void> goToDashboard(WidgetTester tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tester.enterText(find.widgetWithText(TextField, AppStrings.emailLabel), 'user@example.com');
      await tester.enterText(find.widgetWithText(TextField, AppStrings.passwordLabel), '123456');
      await tester.tap(_filledButtonWithText(AppStrings.loginButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.dashboardTitle), findsOneWidget);
    }

    testWidgets('formats result without trailing zeros (#.########## parity)', (WidgetTester tester) async {
      await goToDashboard(tester);

      await tester.enterText(find.widgetWithText(TextField, AppStrings.operandALabel), '1');
      await tester.enterText(find.widgetWithText(TextField, AppStrings.operandBLabel), '3');

      await tester.tap(_filledButtonWithText('÷'));
      await tester.pumpAndSettle();

      // 1 / 3 formatted with pattern "#.##########" => "0.3333333333"
      expect(find.text('0.3333333333'), findsOneWidget);
      expect(find.text(AppStrings.cannotDivideByZero), findsNothing);
    });

    testWidgets('divide by zero shows error banner and keeps result as dash', (WidgetTester tester) async {
      await goToDashboard(tester);

      await tester.enterText(find.widgetWithText(TextField, AppStrings.operandALabel), '10');
      await tester.enterText(find.widgetWithText(TextField, AppStrings.operandBLabel), '0');

      await tester.tap(_filledButtonWithText('÷'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.cannotDivideByZero), findsOneWidget);
      expect(find.text(AppStrings.dash), findsOneWidget);
    });

    testWidgets('invalid operand shows validation + general banner', (WidgetTester tester) async {
      await goToDashboard(tester);

      await tester.enterText(find.widgetWithText(TextField, AppStrings.operandALabel), 'abc');
      await tester.enterText(find.widgetWithText(TextField, AppStrings.operandBLabel), '2');

      await tester.tap(_filledButtonWithText('+'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.fixHighlightedFields), findsOneWidget);
      expect(find.text(AppStrings.validNumberError), findsOneWidget);
    });
  });

  testWidgets('uses light theme background color parity', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, isNotNull);

    final ThemeData theme = app.theme!;
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF9FAFB));
  });
}
