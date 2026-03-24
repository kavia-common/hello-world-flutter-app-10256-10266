import 'package:flutter/material.dart';
import 'package:react_agent/features/react_agent/domain/agent_step.dart';
import 'package:react_agent/features/react_agent/services/agent_service.dart';

// PUBLIC_INTERFACE
/// Controller for the ReAct Agent screen. Mirrors Swift ContentViewModel.
class ReactAgentController extends ChangeNotifier {
  ReactAgentController({AgentService? agentService})
      : _agentService = agentService ?? AgentService() {
    _agentService.addListener(_onAgentChanged);
  }

  final AgentService _agentService;

  String userInput = '';
  List<AgentStep> steps = [];
  bool isRunning = false;
  String? errorMessage;

  void _onAgentChanged() {
    steps = _agentService.steps;
    isRunning = _agentService.isRunning;
    notifyListeners();
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
