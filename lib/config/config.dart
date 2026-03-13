/// Configuration for the ReAct Agent app.
///
/// The API key is read from the `--dart-define=OPENAI_API_KEY=<key>` flag
/// at build/run time. Never hard-code a real key in source.
class Config {
  Config._();

  /// OpenAI API key injected via `--dart-define`.
  ///
  /// Usage:
  /// ```
  /// flutter run --dart-define=OPENAI_API_KEY=sk-...
  /// ```
  // PUBLIC_INTERFACE
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');
}
