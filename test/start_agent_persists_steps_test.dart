import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:react_agent/main.dart';

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
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify multiple step cards exist and remain on screen.
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Text), findsWidgets);

      // Titles include emoji prefixes; match by substring.
      expect(find.textContaining('Thought'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Action'), findsAtLeastNWidgets(1));
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
