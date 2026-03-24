import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for user-provided OpenAI API key.
///
/// Uses platform keychain/keystore via `flutter_secure_storage`.
class ApiKeySecureStore {
  ApiKeySecureStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _openAiApiKeyKey = 'openai_api_key';

  // PUBLIC_INTERFACE
  /// Loads the stored OpenAI API key.
  ///
  /// Returns null if not set.
  Future<String?> loadOpenAIApiKey() async {
    final v = await _storage.read(key: _openAiApiKeyKey);
    final trimmed = v?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  // PUBLIC_INTERFACE
  /// Saves the OpenAI API key securely.
  ///
  /// Passing an empty/whitespace-only value clears the stored key.
  Future<void> saveOpenAIApiKey(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await clearOpenAIApiKey();
      return;
    }
    await _storage.write(key: _openAiApiKeyKey, value: trimmed);
  }

  // PUBLIC_INTERFACE
  /// Clears the stored OpenAI API key.
  Future<void> clearOpenAIApiKey() async {
    await _storage.delete(key: _openAiApiKeyKey);
  }
}
