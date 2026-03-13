import 'package:flutter_test/flutter_test.dart';
import 'package:react_agent/main.dart';

void main() {
  testWidgets('ReactAgentApp renders the main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ReactAgentApp());
    expect(find.text('ReAct Agent'), findsOneWidget);
    expect(find.text('Ask me anything and watch how I think and act!'), findsOneWidget);
    expect(find.text('Ready to help!'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Start Agent'), findsOneWidget);
  });
}
