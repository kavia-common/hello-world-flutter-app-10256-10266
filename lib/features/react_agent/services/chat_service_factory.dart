import 'package:react_agent/config/config.dart';
import 'package:react_agent/features/react_agent/services/chat_service.dart';
import 'package:react_agent/features/react_agent/services/mock_chat_service.dart';
import 'package:react_agent/features/react_agent/services/openai_chat_service.dart';

/// Creates the appropriate [ChatService] based on available API key.
///
/// Priority:
/// 1) in-app stored key (secure storage) if provided
/// 2) build-time key via `--dart-define` (Config.apiKey)
/// 3) mock mode fallback
class ChatServiceFactory {
  ChatServiceFactory._();

  // PUBLIC_INTERFACE
  /// Creates a chat service for the app.
  ///
  /// If [storedApiKey] is present (non-empty), Live mode will be used.
  /// Otherwise, falls back to [Config.apiKey]. If still missing, returns
  /// [MockChatService].
  static ChatService create({String? storedApiKey}) {
    final inAppKey = storedApiKey?.trim() ?? '';
    if (inAppKey.isNotEmpty) {
      return OpenAIChatService(apiKey: inAppKey);
    }

    final envKey = Config.apiKey.trim();
    if (envKey.isNotEmpty) {
      return OpenAIChatService(apiKey: envKey);
    }

    return MockChatService();
    }
}
