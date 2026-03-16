import 'package:react_agent/features/react_agent/domain/chat_message.dart';

/// Abstraction for sending chat messages (real OpenAI or mock).
abstract class ChatService {
  /// Sends [messages] and returns the assistant response content.
  ///
  /// Implementations may call a remote API (OpenAI) or return a deterministic
  /// mocked response for offline/demo/testing scenarios.
  // PUBLIC_INTERFACE
  Future<String> sendMessage({required List<ChatMessage> messages});
}
