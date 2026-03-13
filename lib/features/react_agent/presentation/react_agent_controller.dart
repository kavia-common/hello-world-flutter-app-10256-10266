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
  void startAgent() {
    if (userInput.trim().isEmpty) { errorMessage = 'Please enter a question or task.'; notifyListeners(); return; }
    errorMessage = null; notifyListeners();
    _agentService.runAgent(userInput);
  }

  // PUBLIC_INTERFACE
  void clearSteps() { steps = []; errorMessage = null; userInput = ''; notifyListeners(); }

  void setUserInput(String value) { userInput = value; notifyListeners(); }

  // PUBLIC_INTERFACE
  IconData getStepIcon(StepType type) {
    switch (type) {
      case StepType.thought: return Icons.psychology;
      case StepType.action: return Icons.settings;
      case StepType.observation: return Icons.visibility;
      case StepType.finalAnswer: return Icons.check_circle;
      case StepType.error: return Icons.warning;
    }
  }

  // PUBLIC_INTERFACE
  Color getStepColor(StepType type) {
    switch (type) {
      case StepType.thought: return Colors.blue;
      case StepType.action: return Colors.orange;
      case StepType.observation: return Colors.green;
      case StepType.finalAnswer: return Colors.purple;
      case StepType.error: return Colors.red;
    }
  }

  // PUBLIC_INTERFACE
  String getStepTitle(StepType type) {
    switch (type) {
      case StepType.thought: return '\u{1F4AD} Thought';
      case StepType.action: return '\u{1F527} Action';
      case StepType.observation: return '\u{1F50D} Observation';
      case StepType.finalAnswer: return '\u2705 Final Answer';
      case StepType.error: return '\u274C Error';
    }
  }

  @override
  void dispose() { _agentService.removeListener(_onAgentChanged); super.dispose(); }
}
