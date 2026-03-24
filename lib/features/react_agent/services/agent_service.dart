import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:react_agent/config/config.dart';
import 'package:react_agent/features/react_agent/domain/agent_step.dart';
import 'package:react_agent/features/react_agent/domain/agent_tool.dart';
import 'package:react_agent/features/react_agent/domain/chat_message.dart';
import 'package:react_agent/features/react_agent/services/chat_service.dart';
import 'package:react_agent/features/react_agent/services/mock_chat_service.dart';
import 'package:react_agent/features/react_agent/services/openai_chat_service.dart';

enum AgentErrorType { noActionFound, toolNotFound, invalidActionFormat, executionError }

class AgentException implements Exception {
  const AgentException(this.type, [this.detail]);
  final AgentErrorType type;
  final String? detail;
  String get message {
    switch (type) {
      case AgentErrorType.noActionFound: return 'No action found in model response';
      case AgentErrorType.toolNotFound: return "Tool '${detail ?? 'unknown'}' not found";
      case AgentErrorType.invalidActionFormat: return 'Invalid action format';
      case AgentErrorType.executionError: return 'Execution error: ${detail ?? ''}';
    }
  }
  @override
  String toString() => message;
}

// PUBLIC_INTERFACE
/// The core ReAct agent loop service.
class AgentService extends ChangeNotifier {
  int _activeRunId = 0;
  /// Creates an [AgentService].
  ///
  /// If [chatService] is not provided, the service auto-selects:
  /// - [OpenAIChatService] when `OPENAI_API_KEY` is set
  /// - [MockChatService] when no API key is present (offline/mock mode)
  AgentService({ChatService? chatService})
      : _chatService = chatService ?? _defaultChatService() {
    _setupTools();
  }

  final ChatService _chatService;

  static ChatService _defaultChatService() {
    // `Config.apiKey` is injected via --dart-define. In preview/CI this is
    // typically absent, and we should still allow the demo UI to work.
    if (Config.apiKey.trim().isEmpty) {
      return MockChatService();
    }
    return OpenAIChatService();
  }

  List<AgentStep> steps = [];
  bool isRunning = false;
  final Map<String, AgentTool> _tools = {};
  List<ChatMessage> _messages = [];

  // PUBLIC_INTERFACE
  /// True when the agent is using the local deterministic [MockChatService]
  /// instead of the OpenAI-backed chat service.
  ///
  /// This is used for in-app diagnostics (debug overlay) and does not affect
  /// behavior.
  bool get isMockMode => _chatService is MockChatService;

  // PUBLIC_INTERFACE
  /// Resets the agent state (timeline, message history, and running flag).
  ///
  /// This is used by the UI "Clear" button to ensure both controller and service
  /// state stay in sync across multiple runs.
  void reset() {
    // Invalidate any in-flight runAgent loop so late async results cannot
    // repopulate steps after the user presses "Clear".
    _activeRunId++;

    steps = [];
    _messages = [];
    isRunning = false;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<void> runAgent(String userInput) async {
    // Each run gets a monotonically increasing id. Any async continuation must
    // verify it is still the active run before mutating state.
    final runId = ++_activeRunId;

    // Local helper: avoid updating UI/state if this run is stale (e.g. user hit
    // Clear/reset, or another run started).
    bool isStale() => runId != _activeRunId;

    // Mock-mode only: allow a deterministic small yield after intermediate step
    // additions so widgets/tests can observe Action/Observation before the loop
    // continues to the next await and potentially completes extremely quickly.
    //
    // IMPORTANT: Do not change Live mode behavior.
    final bool isMockMode = _chatService is MockChatService;
    Future<void> yieldForMockUI() async {
      if (!isMockMode) return;

      // Yield at least one event-loop tick. This is intentionally tiny so
      // mock mode still feels instant, but steps become reliably renderable.
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    // In mock mode, ensure each run starts from turn 0 so the timeline always
    // includes Thought -> Action -> Observation -> Final Answer.
    //
    // NOTE: We intentionally do not change the ChatService interface; we only
    // reset when we *know* this is the MockChatService.
    if (isMockMode) {
      // Type promotion applies because the check is on the same variable.
      _chatService.reset();
    }

    isRunning = true;
    steps = [];
    _messages = [];
    notifyListeners();

    final sp = _generateSystemPrompt();
    _messages.add(ChatMessage(role: 'system', content: sp));
    _messages.add(
      ChatMessage(role: 'user', content: '<question>$userInput</question>'),
    );

    try {
      while (true) {
        final content = await _chatService.sendMessage(messages: _messages);
        if (isStale()) return;

        _messages.add(ChatMessage(role: 'assistant', content: content));

        final thought = _extractContent(content, 'thought');
        if (thought != null) {
          _addStep(StepType.thought, thought);
          await yieldForMockUI();
          if (isStale()) return;
        }

        final fa = _extractContent(content, 'final_answer');
        if (fa != null) {
          _addStep(StepType.finalAnswer, fa);
          break;
        }

        final action = _extractContent(content, 'action');
        if (action != null) {
          _addStep(StepType.action, action);
          await yieldForMockUI();
          if (isStale()) return;

          try {
            final obs = await _executeAction(action);
            if (isStale()) return;

            _addStep(StepType.observation, obs);
            await yieldForMockUI();
            if (isStale()) return;

            _messages.add(
              ChatMessage(
                role: 'user',
                content: '<observation>$obs</observation>',
              ),
            );
          } catch (e) {
            if (isStale()) return;

            _addStep(StepType.error, e.toString());
            await yieldForMockUI();
            if (isStale()) return;

            _messages.add(
              ChatMessage(
                role: 'user',
                content: '<observation>Error: $e</observation>',
              ),
            );
          }
        } else {
          throw const AgentException(AgentErrorType.noActionFound);
        }
      }
    } catch (e) {
      if (isStale()) return;
      _addStep(StepType.error, e.toString());
    }

    // Only the currently active run may flip isRunning back to false.
    if (isStale()) return;
    isRunning = false;
    notifyListeners();
  }

  void _addStep(StepType type, String content) {
    steps = List.from(steps)..add(AgentStep(type: type, content: content, timestamp: DateTime.now()));
    notifyListeners();
  }

  void _setupTools() {
    _tools['read_file'] = AgentTool(name: 'read_file', description: 'Read contents of a file', action: (args) async {
      if (args.isEmpty) {
        throw const AgentException(AgentErrorType.executionError, 'File path required');
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${args.first}');
      try { return await file.readAsString(); }
      catch (e) { throw AgentException(AgentErrorType.executionError, 'Could not read file: $e'); }
    });
    _tools['write_to_file'] = AgentTool(name: 'write_to_file', description: 'Write content to a file', action: (args) async {
      if (args.length < 2) {
        throw const AgentException(AgentErrorType.executionError, 'File path and content required');
      }
      final content = args[1].replaceAll(r'\n', '\n');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${args[0]}');
      try {
        await file.parent.create(recursive: true);
        await file.writeAsString(content);
        return 'Write successful';
      } catch (e) {
        throw AgentException(AgentErrorType.executionError, 'Could not write file: $e');
      }
    });
    _tools['get_current_time'] = AgentTool(name: 'get_current_time', description: 'Get current date and time', action: (args) async {
      return DateFormat.yMMMd().add_jms().format(DateTime.now());
    });
    _tools['calculate'] = AgentTool(name: 'calculate', description: 'Perform simple mathematical calculations', action: (args) async {
      if (args.isEmpty) {
        throw const AgentException(AgentErrorType.executionError, 'Expression required');
      }
      try {
        final result = _evaluateExpression(args.first);
        if (result == result.truncateToDouble() && !result.isInfinite) {
          return result.toInt().toString();
        }
        return result.toString();
      } catch (_) {
        throw const AgentException(AgentErrorType.executionError, 'Invalid mathematical expression');
      }
    });
  }

  double _evaluateExpression(String expr) {
    final tokens = _tokenize(expr); final it = _TI(tokens);
    final result = _pE(it);
    if (it.h) {
      throw FormatException('Unexpected: ${it.p}');
    }
    return result;
  }
  List<String> _tokenize(String e) {
    final t = <String>[];
    final b = StringBuffer();
    for (var i = 0; i < e.length; i++) {
      final c = e[i];
      if (c == ' ') {
        if (b.isNotEmpty) {
          t.add(b.toString());
          b.clear();
        }
        continue;
      }
      if ('+-*/()'.contains(c)) {
        if (b.isNotEmpty) {
          t.add(b.toString());
          b.clear();
        }
        t.add(c);
      } else {
        b.write(c);
      }
    }
    if (b.isNotEmpty) {
      t.add(b.toString());
    }
    return t;
  }
  double _pE(_TI it) {
    var l = _pT(it);
    while (it.h && (it.p == '+' || it.p == '-')) { final o = it.n(); final r = _pT(it); l = o == '+' ? l + r : l - r; }
    return l;
  }
  double _pT(_TI it) {
    var l = _pF(it);
    while (it.h && (it.p == '*' || it.p == '/')) { final o = it.n(); final r = _pF(it); l = o == '*' ? l * r : l / r; }
    return l;
  }
  double _pF(_TI it) {
    if (it.h && it.p == '-') {
      it.n();
      return -_pF(it);
    }
    if (it.h && it.p == '(') {
      it.n();
      final r = _pE(it);
      if (it.h && it.p == ')') {
        it.n();
      }
      return r;
    }
    if (!it.h) {
      throw const FormatException('Unexpected end');
    }
    final t = it.n();
    final v = double.tryParse(t);
    if (v == null) {
      throw FormatException('Invalid: $t');
    }
    return v;
  }

  Future<String> _executeAction(String action) async {
    final parsed = _parseAction(action);
    final tool = _tools[parsed.$1];
    if (tool == null) {
      throw AgentException(AgentErrorType.toolNotFound, parsed.$1);
    }
    return tool.action(parsed.$2);
  }
  (String, List<String>) _parseAction(String action) {
    final trimmed = action.trim();
    final wa = RegExp(r'^(\w+)\((.*)\)$', dotAll: true).firstMatch(trimmed);
    if (wa != null) {
      return (wa.group(1)!, _parseArguments(wa.group(2)!));
    }
    final na = RegExp(r'^(\w+)$').firstMatch(trimmed);
    if (na != null) {
      return (na.group(1)!, <String>[]);
    }
    throw const AgentException(AgentErrorType.invalidActionFormat);
  }
  List<String> _parseArguments(String s) {
    final args = <String>[];
    final cur = StringBuffer();
    var inQ = false;
    var qc = '"';
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (!inQ) {
        if (c == '"' || c == "'") {
          inQ = true;
          qc = c;
        } else if (c == ',') {
          args.add(cur.toString().trim());
          cur.clear();
          continue;
        } else {
          cur.write(c);
        }
      } else {
        if (c == qc) {
          inQ = false;
        } else {
          cur.write(c);
        }
      }
    }
    final rem = cur.toString().trim();
    if (rem.isNotEmpty) {
      args.add(rem);
    }
    return args;
  }
  String? _extractContent(String text, String tag) {
    return RegExp('<$tag>(.*?)</$tag>', dotAll: true).firstMatch(text)?.group(1)?.trim();
  }
  String _generateSystemPrompt() {
    final tl = _tools.entries.map((e) => '- ${e.key}: ${e.value.description}').join('\n');
    return 'You need to solve a problem. To do this, you need to break the problem down into multiple steps. For each step, first use <thought> to think about what to do, then decide on an <action> using one of the available tools. Next, you will receive an <observation> from the environment/tools based on your action. Continue this thinking and acting process until you have enough information to provide a <final_answer>.\n\nPlease strictly use the following XML tag format for all steps:\n- <question> User question </question>\n- <thought> Thinking process </thought>\n- <action> Tool operation to take </action>\n- <observation> Results returned by tools or environment </observation>\n- <final_answer> Final answer </final_answer>\n\nPlease strictly follow these rules:\n- Your response must always include two tags: first <thought>, then either <action> or <final_answer>\n- After outputting <action>, stop generating immediately and wait for the actual <observation>. Generating <observation> yourself will cause errors\n\nIMPORTANT: Action format rules:\n- For tools with NO arguments: use just the tool name, e.g., <action>get_current_time</action>\n- For tools WITH arguments: use function call syntax with parentheses and comma-separated quoted arguments, e.g., <action>write_to_file("/path/to/file.txt", "content here")</action>\n- Do NOT use key-value format like tool_name param1="value1" param2="value2"\n- Always enclose string arguments in double quotes\n- Use commas to separate multiple arguments\n\nAvailable tools for this task:\n$tl\n\nEnvironment information:\nOperating System: iOS';
  }
}

class _TI { _TI(this._t); final List<String> _t; int _i = 0; bool get h => _i < _t.length; String get p => _t[_i]; String n() => _t[_i++]; }
