import 'package:react_agent/features/react_agent/domain/chat_message.dart';
import 'package:react_agent/features/react_agent/services/chat_service.dart';

/// Deterministic offline chat service used when no OpenAI API key is provided.
///
/// This enables the app (and widget tests) to run without network calls while
/// still exercising the ReAct loop and timeline UI.
// PUBLIC_INTERFACE
class MockChatService implements ChatService {
  int _turn = 0;

  @override
  Future<String> sendMessage({required List<ChatMessage> messages}) async {
    // We return a minimal two-iteration ReAct flow:
    //  - First response: thought + action (tool invocation)
    //  - Second response: thought + final answer
    //
    // AgentService will execute the tool and then call again with an
    // <observation> message, which triggers the final answer response.
    if (_turn == 0) {
      _turn++;
      return '''
<thought>I can demonstrate the agent loop by calling a tool.</thought>
<action>get_current_time</action>
'''.trim();
    }

    _turn++;
    return '''
<thought>Now that I observed the tool output, I can answer.</thought>
<final_answer>Mock mode is working (no OPENAI_API_KEY required).</final_answer>
'''.trim();
  }
}
