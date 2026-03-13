/// A single message in the OpenAI chat conversation.
// PUBLIC_INTERFACE
class ChatMessage {
  /// Creates a [ChatMessage].
  const ChatMessage({
    required this.role,
    required this.content,
  });

  /// The role: "system", "user", or "assistant".
  final String role;

  /// The textual content of the message.
  final String content;

  /// Converts this message to a JSON-compatible map for the API request.
  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}
