import 'package:react_agent/features/react_agent/domain/chat_message.dart';
import 'package:react_agent/features/react_agent/services/chat_service.dart';

/// Deterministic offline chat service used when no OpenAI API key is provided.
///
/// This enables the app (and widget tests) to run without network calls while
/// still exercising the ReAct loop and timeline UI.
///
/// IMPORTANT:
/// Mock mode should still return a *real* final answer to the user’s prompt,
/// not a placeholder string. This keeps UI behavior consistent between Mock
/// and Live modes, while remaining deterministic and offline.
// PUBLIC_INTERFACE
class MockChatService implements ChatService {
  int _turn = 0;

  static String? _extractTag(String text, String tag) {
    final match = RegExp('<$tag>(.*?)</$tag>', dotAll: true).firstMatch(text);
    return match?.group(1)?.trim();
  }

  static String _buildOfflineFinalAnswer({
    required String question,
    required String observation,
  }) {
    // A simple deterministic “answer” that demonstrates the end-to-end flow
    // and clearly indicates it is offline/mock generated.
    return [
      'Offline (mock) answer:',
      '',
      'You asked: $question',
      'Tool observation: $observation',
      '',
      'Note: Set OPENAI_API_KEY to switch to Live mode.',
    ].join('\n');
  }

  @override
  Future<String> sendMessage({required List<ChatMessage> messages}) async {
    // We return a minimal two-iteration ReAct flow:
    //  - First response: thought + action (tool invocation)
    //  - Second response: thought + final answer (derived from the user question)
    //
    // AgentService will execute the tool and then call again with an
    // <observation> message, which triggers the final answer response.
    if (_turn == 0) {
      _turn++;
      return '''
<thought>I will call a tool to demonstrate the agent loop.</thought>
<action>get_current_time</action>
'''.trim();
    }

    _turn++;

    // Derive final answer from the last user question + last observation so
    // the “Final Answer” card always shows something relevant.
    final question = messages
            .where((m) => m.role == 'user')
            .map((m) => _extractTag(m.content, 'question'))
            .whereType<String>()
            .lastOrNull ??
        'unknown';
    final observation = messages
            .where((m) => m.role == 'user')
            .map((m) => _extractTag(m.content, 'observation'))
            .whereType<String>()
            .lastOrNull ??
        'none';

    final finalAnswer = _buildOfflineFinalAnswer(
      question: question,
      observation: observation,
    );

    return '''
<thought>I can now answer using the tool observation.</thought>
<final_answer>$finalAnswer</final_answer>
'''.trim();
  }
}

extension _LastOrNullExt<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
