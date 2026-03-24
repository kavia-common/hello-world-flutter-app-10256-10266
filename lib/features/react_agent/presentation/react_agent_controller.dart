import 'package:flutter/material.dart';
import 'package:react_agent/features/react_agent/domain/agent_step.dart';
import 'package:react_agent/features/react_agent/services/agent_service.dart';
import 'package:react_agent/features/react_agent/services/api_key_secure_store.dart';

// PUBLIC_INTERFACE
/// Controller for the ReAct Agent screen. Mirrors Swift ContentViewModel.
///
/// Extended with an in-app OpenAI API key entry flow stored securely so users
/// can enable Live mode without env vars / --dart-define.
class ReactAgentController extends ChangeNotifier {
  ReactAgentController({AgentService? agentService, ApiKeySecureStore? keyStore})
      : _agentService = agentService ?? AgentService(),
        _keyStore = keyStore ?? ApiKeySecureStore() {
    _agentService.addListener(_onAgentChanged);
  }

  final AgentService _agentService;
  final ApiKeySecureStore _keyStore;

  String userInput = '';
  List<AgentStep> steps = [];
  bool isRunning = false;
  bool isMockMode = false;
  String? errorMessage;

  /// Latest loaded key presence for UI.
  bool hasStoredApiKey = false;

  void _onAgentChanged() {
    steps = _agentService.steps;
    isRunning = _agentService.isRunning;
    isMockMode = _agentService.isMockMode;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Loads stored key (if any) and updates the agent service mode.
  ///
  /// Call this once from UI initState (fire-and-forget).
  Future<void> loadStoredApiKeyAndConfigure() async {
    try {
      final key = await _keyStore.loadOpenAIApiKey();
      hasStoredApiKey = (key != null && key.trim().isNotEmpty);
      _agentService.setApiKey(key);
    } catch (e) {
      // Don't block app usage if secure storage fails; stay in existing mode.
      errorMessage = 'Could not load API key: $e';
    }
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Saves the API key and switches to Live mode (if non-empty).
  ///
  /// Returns a user-displayable status message.
  Future<String> saveApiKey(String value) async {
    final trimmed = value.trim();
    try {
      await _keyStore.saveOpenAIApiKey(trimmed);
      hasStoredApiKey = trimmed.isNotEmpty;
      _agentService.setApiKey(trimmed);
      notifyListeners();
      return trimmed.isNotEmpty ? 'Saved. Live mode enabled.' : 'Key cleared. Using Mock mode.';
    } catch (e) {
      notifyListeners();
      return 'Failed to save key: $e';
    }
  }

  // PUBLIC_INTERFACE
  /// Clears stored API key and switches to mock mode fallback.
  Future<String> clearApiKey() async {
    try {
      await _keyStore.clearOpenAIApiKey();
      hasStoredApiKey = false;
      _agentService.setApiKey(null);
      notifyListeners();
      return 'API key removed. Using Mock mode.';
    } catch (e) {
      notifyListeners();
      return 'Failed to clear key: $e';
    }
  }

  // PUBLIC_INTERFACE
  Future<void> startAgent() async {
    if (userInput.trim().isEmpty) {
      errorMessage = 'Please enter a question or task.';
      notifyListeners();
      return;
    }

    errorMessage = null;
    notifyListeners();

    // Await to prevent overlapping runs in preview/rapid taps and to keep
    // running state transitions consistent.
    await _agentService.runAgent(userInput);
  }

  // PUBLIC_INTERFACE
  void clearSteps() {
    _agentService.reset();
    steps = [];
    errorMessage = null;
    userInput = '';
    notifyListeners();
  }

  void setUserInput(String value) {
    userInput = value;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  IconData getStepIcon(StepType type) {
    switch (type) {
      case StepType.thought:
        return Icons.psychology;
      case StepType.action:
        return Icons.settings;
      case StepType.observation:
        return Icons.visibility;
      case StepType.finalAnswer:
        return Icons.check_circle;
      case StepType.error:
        return Icons.warning;
    }
  }

  // PUBLIC_INTERFACE
  Color getStepColor(StepType type) {
    switch (type) {
      case StepType.thought:
        return Colors.blue;
      case StepType.action:
        return Colors.orange;
      case StepType.observation:
        return Colors.green;
      case StepType.finalAnswer:
        return Colors.purple;
      case StepType.error:
        return Colors.red;
    }
  }

  // PUBLIC_INTERFACE
  String getStepTitle(StepType type) {
    switch (type) {
      // Keep titles plain ASCII so widget tests can reliably match substrings
      // like "Action" across all test renderers/platforms.
      case StepType.thought:
        return 'Thought';
      case StepType.action:
        return 'Action';
      case StepType.observation:
        return 'Observation';
      case StepType.finalAnswer:
        return 'Final Answer';
      case StepType.error:
        return 'Error';
    }
  }

  @override
  void dispose() {
    _agentService.removeListener(_onAgentChanged);
    super.dispose();
  }
}
