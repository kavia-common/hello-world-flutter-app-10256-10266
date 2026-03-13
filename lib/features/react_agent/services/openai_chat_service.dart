import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:react_agent/config/config.dart';
import 'package:react_agent/features/react_agent/domain/chat_message.dart';

/// Errors from the OpenAI API.
enum ChatGPTError {
  /// The endpoint URL could not be parsed.
  invalidURL,
  /// The server returned a non-2xx status code.
  invalidResponse,
  /// No content in choices[0].message.content.
  noContent,
}

/// Exception wrapper for [ChatGPTError].
class ChatGPTException implements Exception {
  /// Creates a [ChatGPTException].
  const ChatGPTException(this.error);

  /// The specific error type.
  final ChatGPTError error;

  /// Human-readable description matching Swift errorDescription.
  String get message {
    switch (error) {
      case ChatGPTError.invalidURL:
        return 'Invalid URL';
      case ChatGPTError.invalidResponse:
        return 'Invalid response from server';
      case ChatGPTError.noContent:
        return 'No content in response';
    }
  }

  @override
  String toString() => message;
}

/// Service that communicates with the OpenAI Chat Completions API.
// PUBLIC_INTERFACE
class OpenAIChatService {
  /// Creates an [OpenAIChatService].
  OpenAIChatService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final String _apiKey = Config.apiKey;
  static const String _baseURL = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o';
  final http.Client _httpClient;

  /// Sends [messages] to OpenAI and returns assistant content.
  // PUBLIC_INTERFACE
  Future<String> sendMessage({required List<ChatMessage> messages}) async {
    final uri = Uri.tryParse(_baseURL);
    if (uri == null) {
      throw const ChatGPTException(ChatGPTError.invalidURL);
    }

    final requestBody = jsonEncode({
      'model': _model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': 0.7,
    });

    final response = await _httpClient.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw const ChatGPTException(ChatGPTError.invalidResponse);
    }

    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;

    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const ChatGPTException(ChatGPTError.noContent);
    }

    final firstChoice = choices[0] as Map<String, dynamic>;
    final msg = firstChoice['message'] as Map<String, dynamic>?;
    final content = msg?['content'] as String?;

    if (content == null) {
      throw const ChatGPTException(ChatGPTError.noContent);
    }

    return content;
  }
}
