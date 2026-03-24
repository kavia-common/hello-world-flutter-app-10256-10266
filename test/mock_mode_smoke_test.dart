import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:react_agent/main.dart';

/// Prints targeted diagnostics for widget-test failures.
///
/// Includes:
/// - Full widget tree dump (`debugDumpApp()`)
/// - All strings visible via `Text` widgets (from `data` or `textSpan`)
void _dumpWidgetDiagnostics(WidgetTester tester, {required String label}) {
  // ignore: avoid_print
  print('\n================ WIDGET TEST DIAGNOSTICS: $label ================');
  // ignore: avoid_print
  print('--- debugDumpApp() ---');
  debugDumpApp();

  // ignore: avoid_print
  print('--- Visible Text widgets (data/textSpan) ---');
  final Iterable<Element> textElements = find.byType(Text).evaluate();
  var i = 0;
  for (final Element el in textElements) {
    final widget = el.widget;
    if (widget is! Text) continue;

    final String? data = widget.data;
    final InlineSpan? span = widget.textSpan;
    final String content = (data ?? span?.toPlainText() ?? '').trim();

    // Print even if empty to help confirm what is/ isn't on screen.
    // ignore: avoid_print
    print('Text[$i]: "${content.replaceAll('\n', '\\n')}"');
    i++;
  }
  // ignore: avoid_print
  print('================ END DIAGNOSTICS: $label ================\n');
}

void main() {
  testWidgets(
    'Mock mode (no OPENAI_API_KEY) runs and produces timeline steps',
    (WidgetTester tester) async {
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

      // Let the async loop run. MockChatService returns action then final answer.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step titles include emoji prefixes; match by substring.
      expect(find.textContaining('Thought'), findsAtLeastNWidgets(1));
      try {
        expect(find.textContaining('Action'), findsAtLeastNWidgets(1));
      } catch (e) {
        _dumpWidgetDiagnostics(tester, label: 'mock_mode_smoke_test.Action');
        rethrow;
      }
      expect(find.textContaining('Final Answer'), findsAtLeastNWidgets(1));

      // Assert the final answer is derived from the actual user prompt
      // (not a generic placeholder).
      expect(find.textContaining('Offline (mock) answer:'), findsOneWidget);
      expect(
        find.textContaining('What time is it? (mock mode smoke test)'),
        findsOneWidget,
      );
    },
  );
}
