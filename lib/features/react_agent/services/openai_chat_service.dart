import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:react_agent/config/config.dart';
import 'package:react_agent/features/react_agent/domain/chat_message.dart';
import 'package:react_agent/features/react_agent/services/chat_service.dart';

/// Errors from the OpenAI API.
enum ChatGPTError {
  /// The endpoint URL could not be parsed.
  invalidURL,

  /// API key is missing/empty.
  missingApiKey,

  /// Network connectivity/timeout.
  networkError,

  /// The server returned a non-2xx status code.
  invalidResponse,

  /// No content could be extracted from the response.
  noContent,
}

/// Exception wrapper for [ChatGPTError].
class ChatGPTException implements Exception {
  /// Creates a [ChatGPTException].
  const ChatGPTException(this.error, {this.details});

  /// The specific error type.
  final ChatGPTError error;

  /// Optional extra context (e.g., HTTP status, OpenAI error message).
  final String? details;

  /// Human-readable description matching Swift errorDescription.
  String get message {
    switch (error) {
      case ChatGPTError.invalidURL:
        return 'Invalid OpenAI URL';
      case ChatGPTError.missingApiKey:
        return 'Missing OpenAI API key. Add an API key in Settings or provide --dart-define=OPENAI_API_KEY=...';
      case ChatGPTError.networkError:
        return details == null || details!.trim().isEmpty
            ? 'Network error while contacting OpenAI. Check connectivity and try again.'
            : 'Network error while contacting OpenAI: $details';
      case ChatGPTError.invalidResponse:
        return details == null || details!.trim().isEmpty
            ? 'OpenAI request failed (non-success HTTP response).'
            : 'OpenAI request failed: $details';
      case ChatGPTError.noContent:
        return 'OpenAI response contained no assistant text.';
    }
  }

  @override
  String toString() => message;
}

/// Service that communicates with the OpenAI API.
///
/// Notes:
/// - Uses the OpenAI Responses API (`/v1/responses`) which is the current
///   recommended API shape.
/// - If the API returns an error JSON payload, we extract and display the error
///   message so users can fix configuration issues (key/model/billing).
// PUBLIC_INTERFACE
class OpenAIChatService implements ChatService {
  /// Creates an [OpenAIChatService].
  ///
  /// If [apiKey] is not provided, falls back to [Config.apiKey] (injected via
  /// `--dart-define`).
  OpenAIChatService({String? apiKey, http.Client? httpClient})
      : _apiKey = (apiKey ?? Config.apiKey).trim(),
        _httpClient = httpClient ?? http.Client();

  final String _apiKey;

  // Current recommended endpoint.
  static const String _baseURL = 'https://api.openai.com/v1/responses';

  // Use a widely available model to reduce "model not found" issues.
  static const String _model = 'gpt-4o-mini';

  // Keep requests bounded to avoid hanging UI.
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _httpClient;

  /// Sends [messages] to OpenAI and returns assistant content.
  // PUBLIC_INTERFACE
  @override
  Future<String> sendMessage({required List<ChatMessage> messages}) async {
    if (_apiKey.isEmpty) {
      throw const ChatGPTException(ChatGPTError.missingApiKey);
    }

    final uri = Uri.tryParse(_baseURL);
    if (uri == null) {
      throw const ChatGPTException(ChatGPTError.invalidURL);
    }

    // Convert chat messages to a single prompt for Responses API.
    // We preserve roles in a readable way.
    final prompt = messages
        .map((m) => '${m.role.toUpperCase()}: ${m.content}')
        .join('\n\n');

    final requestBody = jsonEncode({
      'model': _model,
      'input': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
          ],
        },
      ],
    });

    http.Response response;
    try {
      response = await _httpClient
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: requestBody,
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const ChatGPTException(
        ChatGPTError.networkError,
        details: 'Request timed out. Verify network connectivity and try again.',
      );
    } catch (e) {
      throw ChatGPTException(ChatGPTError.networkError, details: e.toString());
    }

    if (response.statusCode < 200 || response.statusCode > 299) {
      final detail = _extractOpenAIErrorDetail(response);
      throw ChatGPTException(
        ChatGPTError.invalidResponse,
        details: 'HTTP ${response.statusCode}: $detail',
      );
    }

    // Attempt to parse the success payload. For Responses API, assistant text is
    // typically in `output_text`. If unavailable, fall back to extracting from
    // `output` structure. Also keep a fallback for Chat Completions-like shapes.
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ChatGPTException(ChatGPTError.noContent);
    }

    final outputText = decoded['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final extracted = _extractTextFromResponsesOutput(decoded);
    if (extracted != null && extracted.trim().isNotEmpty) {
      return extracted.trim();
    }

    final completionsFallback = _extractTextFromChatCompletions(decoded);
    if (completionsFallback != null && completionsFallback.trim().isNotEmpty) {
      return completionsFallback.trim();
    }

    throw const ChatGPTException(ChatGPTError.noContent);
  }

  String _extractOpenAIErrorDetail(http.Response response) {
    // Prefer JSON error payload:
    // { "error": { "message": "...", "type": "...", "code": "..." } }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          final code = error['code'];
          final type = error['type'];
          final parts = <String>[];
          if (message is String && message.trim().isNotEmpty) {
            parts.add(message.trim());
          }
          if (type is String && type.trim().isNotEmpty) {
            parts.add('type=$type');
          }
          if (code is String && code.trim().isNotEmpty) {
            parts.add('code=$code');
          }
          if (parts.isNotEmpty) return parts.join(' ');
        }
      }
    } catch (_) {
      // ignore parsing errors; fall back to raw body.
    }

    final raw = response.body.trim();
    if (raw.isEmpty) return 'Empty error response from server.';
    // Avoid dumping huge bodies.
    return raw.length > 600 ? raw.substring(0, 600) : raw;
  }

  String? _extractTextFromResponsesOutput(Map<String, dynamic> decoded) {
    final output = decoded['output'];
    if (output is! List) return null;

    final buffer = StringBuffer();
    for (final item in output) {
      if (item is! Map) continue;
      final content = item['content'];
      if (content is! List) continue;

      for (final c in content) {
        if (c is! Map) continue;
        if (c['type'] == 'output_text' && c['text'] is String) {
          final t = (c['text'] as String).trim();
          if (t.isNotEmpty) {
            if (buffer.isNotEmpty) buffer.writeln();
            buffer.write(t);
          }
        }
      }
    }

    return buffer.isEmpty ? null : buffer.toString();
  }

  String? _extractTextFromChatCompletions(Map<String, dynamic> decoded) {
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return null;

    final first = choices.first;
    if (first is! Map) return null;

    final msg = first['message'];
    if (msg is! Map) return null;

    final content = msg['content'];
    return content is String ? content : null;
  }
}
