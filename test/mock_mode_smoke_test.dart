import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:react_agent/main.dart';

void main() {
  testWidgets('Mock mode (no OPENAI_API_KEY) runs and produces timeline steps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReactAgentApp());

    // Enter a question so the Start Agent button enables.
    await tester.enterText(
      find.byType(TextField),
      'What time is it? (mock mode smoke test)',
    );

    // Pump once to rebuild with enabled Start Agent.
    await tester.pump();

    // Tap Start Agent.
    await tester.tap(find.text('Start Agent'));

    // Let the async loop run.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // We should always see at least a thought and a final answer in mock mode.
    // (Action/Observation can be timing-sensitive in widget tests across embedders.)
    expect(find.textContaining('Thought'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Final Answer'), findsAtLeastNWidgets(1));

    // Assert the final answer is derived from the actual user prompt
    // (not a generic placeholder).
    expect(find.textContaining('Offline (mock) answer:'), findsOneWidget);
    expect(
      find.textContaining('You asked: What time is it? (mock mode smoke test)'),
      findsOneWidget,
    );
  });

  testWidgets('Settings sheet is accessible and shows OpenAI API key entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReactAgentApp());

    // Tap the settings icon in the header.
    final settingsButton = find.byTooltip('Settings');
    expect(settingsButton, findsOneWidget);

    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    // Bottom sheet content should appear.
    expect(find.text('Settings'), findsAtLeastNWidgets(1));
    expect(find.text('OpenAI API key'), findsOneWidget);
    expect(find.textContaining('Stored securely'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
