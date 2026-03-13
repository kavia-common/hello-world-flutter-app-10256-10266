import 'package:uuid/uuid.dart';

/// Represents the type of a step in the ReAct agent loop.
enum StepType {
  /// A reasoning step produced by the model inside `<thought>` tags.
  thought,
  /// An action the model wants to execute inside `<action>` tags.
  action,
  /// The result of executing a tool, fed back to the model.
  observation,
  /// The model's concluding response inside `<final_answer>` tags.
  finalAnswer,
  /// An error that occurred during the agent loop.
  error,
}

/// A single step in the ReAct agent timeline.
// PUBLIC_INTERFACE
class AgentStep {
  /// Creates an [AgentStep].
  AgentStep({
    required this.type,
    required this.content,
    required this.timestamp,
    String? id,
  }) : id = id ?? const Uuid().v4();

  /// Unique identifier for list keying.
  final String id;

  /// The semantic type of this step.
  final StepType type;

  /// The textual content extracted from the model output or tool result.
  final String content;

  /// When this step was created.
  final DateTime timestamp;
}
