import 'package:flutter_test/flutter_test.dart';
import 'package:react_agent/main.dart';

void main() {
  testWidgets('ReactAgentApp renders the main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ReactAgentApp());

    expect(find.text('ReAct Agent'), findsOneWidget);
    expect(
      find.text('Watch the agent reason, act with tools, and answer.'),
      findsOneWidget,
    );

    // Empty state copy.
    expect(find.text('Ready when you are'), findsOneWidget);

    // Actions.
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Start Agent'), findsOneWidget);
  });
}
