import 'package:flutter/material.dart';
import 'package:react_agent/features/react_agent/presentation/react_agent_controller.dart';
import 'package:react_agent/features/react_agent/presentation/widgets/step_card.dart';

// PUBLIC_INTERFACE
/// The main (and only) screen of the ReAct Agent app.
class ReactAgentScreen extends StatefulWidget {
  const ReactAgentScreen({super.key});
  @override
  State<ReactAgentScreen> createState() => _ReactAgentScreenState();
}

class _ReactAgentScreenState extends State<ReactAgentScreen> {
  late final ReactAgentController _ctrl;
  late final TextEditingController _textCtrl;
  late final ScrollController _scrollCtrl;
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = ReactAgentController();
    _textCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    _ctrl.addListener(_onChanged);
  }

  void _onChanged() {
    if (_ctrl.userInput.isEmpty && _textCtrl.text.isNotEmpty) _textCtrl.clear();
    final nc = _ctrl.steps.length;
    if (nc > _prevCount && nc > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      });
    }
    _prevCount = nc;
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose(); _textCtrl.dispose(); _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(child: Column(children: [
        _buildHeader(context),
        Expanded(child: _ctrl.steps.isNotEmpty ? _buildSteps() : _buildEmpty(context)),
      ])),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('ReAct Agent', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        Text('Ask me anything and watch how I think and act!', textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
        const SizedBox(height: 16),
        TextField(controller: _textCtrl, minLines: 3, maxLines: 6,
          onChanged: (v) => _ctrl.setUserInput(v),
          decoration: InputDecoration(hintText: 'Enter your question or task...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton(onPressed: _ctrl.isRunning ? null : () => _ctrl.clearSteps(), child: const Text('Clear')),
          const Spacer(),
          ElevatedButton(
            onPressed: (_ctrl.isRunning || _ctrl.userInput.trim().isEmpty) ? null : () => _ctrl.startAgent(),
            child: _ctrl.isRunning
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8), const Text('Agent is thinking...')])
              : const Text('Start Agent')),
        ]),
        if (_ctrl.errorMessage != null) ...[
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft,
            child: Text(_ctrl.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)))],
      ]),
    ));
  }

  Widget _buildSteps() {
    return ListView.builder(
      controller: _scrollCtrl, padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _ctrl.steps.length,
      itemBuilder: (context, i) {
        final step = _ctrl.steps[i];
        return Padding(padding: const EdgeInsets.only(bottom: 12),
          child: StepCard(key: ValueKey(step.id), step: step, controller: _ctrl));
      });
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.psychology, size: 60, color: Theme.of(context).colorScheme.onSurface.withAlpha(77)),
      const SizedBox(height: 16),
      Text('Ready to help!', style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
      const SizedBox(height: 8),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text('Enter a question above to see the ReAct agent in action.', textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153)))),
    ]));
  }
}
