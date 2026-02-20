import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world_frontend/main.dart';

void main() {
  testWidgets('Shows Hello World centered', (WidgetTester tester) async {
    await tester.pumpWidget(const HelloWorldApp());

    // Text exists.
    expect(find.text('Hello World'), findsOneWidget);

    // Center widget exists and contains the text.
    expect(find.byType(Center), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Center),
        matching: find.text('Hello World'),
      ),
      findsOneWidget,
    );

    // Scaffold exists (single screen).
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Uses light theme (MaterialApp + ThemeData present)', (WidgetTester tester) async {
    await tester.pumpWidget(const HelloWorldApp());

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, isNotNull);

    // Sanity-check: scaffold background is the light background color specified.
    final ThemeData theme = app.theme!;
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF9FAFB));
  });
}

