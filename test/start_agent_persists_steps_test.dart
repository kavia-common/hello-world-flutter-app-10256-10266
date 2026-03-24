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

    // ignore: avoid_print
    print('Text[$i]: "${content.replaceAll('\n', '\\n')}"');
    i++;
  }
  // ignore: avoid_print
  print('================ END DIAGNOSTICS: $label ================\n');
}

void main() {
  testWidgets(
    'Start Agent appends multiple step cards that remain visible (mock mode)',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ReactAgentApp());

      // Enter a question so the Start Agent button enables.
      await tester.enterText(
        find.byType(TextField),
        'Show me multiple steps',
      );
      await tester.pump();

      // Tap Start Agent.
      await tester.tap(find.text('Start Agent'));

      // Let async agent loop run and UI rebuild. In mock mode we expect:
      // Thought -> Action -> Observation -> Thought -> Final Answer (at least).
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify multiple step cards exist and remain on screen.
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Text), findsWidgets);

      // Titles include emoji prefixes; match by substring.
      expect(find.textContaining('Thought'), findsAtLeastNWidgets(1));
      try {
        expect(find.textContaining('Action'), findsAtLeastNWidgets(1));
      } catch (e) {
        _dumpWidgetDiagnostics(
          tester,
          label: 'start_agent_persists_steps_test.Action',
        );
        rethrow;
      }
      expect(find.textContaining('Observation'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Final Answer'), findsAtLeastNWidgets(1));

      // Ensure they persist after additional pumps (no clearing/flicker).
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Thought'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Final Answer'), findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'Tapping Start Agent without input shows validation error and no steps',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ReactAgentApp());

      // Button exists but is disabled because input is empty.
      expect(find.text('Start Agent'), findsOneWidget);

      // Tap does nothing when disabled; ensure still on empty state.
      await tester.tap(find.text('Start Agent'));
      await tester.pump();

      expect(find.text('Ready when you are'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    },
  );
}
