/// Represents a tool that the ReAct agent can invoke.
// PUBLIC_INTERFACE
class AgentTool {
  /// Creates an [AgentTool].
  const AgentTool({
    required this.name,
    required this.description,
    required this.action,
  });

  /// The tool name as referenced in `<action>` tags.
  final String name;

  /// A short description shown in the system prompt.
  final String description;

  /// The async callback that executes the tool logic.
  final Future<String> Function(List<String> args) action;
}
