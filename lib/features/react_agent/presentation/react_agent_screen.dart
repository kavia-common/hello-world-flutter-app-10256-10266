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
    // Keep existing behavior intact: clear input when controller resets,
    // autoscroll when new steps arrive, and rebuild.
    if (_ctrl.userInput.isEmpty && _textCtrl.text.isNotEmpty) {
      _textCtrl.clear();
    }

    final nc = _ctrl.steps.length;

    if (nc > _prevCount && nc > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollCtrl.hasClients) return;

        // In widget tests (and occasionally in preview), scroll metrics can be
        // temporarily unavailable even when hasClients is true. Avoid throwing
        // and breaking the rebuild loop.
        try {
          final pos = _scrollCtrl.position;
          if (!pos.hasContentDimensions) return;

          _scrollCtrl.animateTo(
            pos.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } catch (_) {
          // Intentionally ignore scroll errors; the timeline should still update.
        }
      });
    }

    _prevCount = nc;
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        // Modern dark canvas: subtle vertical gradient.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.surfaceContainerHighest.withAlpha(120),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _ctrl.steps.isNotEmpty ? _buildSteps() : _buildEmpty(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerHighest.withAlpha(210),
              scheme.surface.withAlpha(210),
            ],
          ),
          border: Border.all(color: scheme.outline.withAlpha(80)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(90),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withAlpha(230),
                        scheme.tertiary.withAlpha(210),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ReAct Agent',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: scheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Watch the agent reason, act with tools, and answer.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withAlpha(160),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _textCtrl,
              minLines: 3,
              maxLines: 6,
              onChanged: (v) => _ctrl.setUserInput(v),
              decoration: const InputDecoration(
                hintText: 'Enter your question or task...',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _ctrl.isRunning ? null : () => _ctrl.clearSteps(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear'),
                ),
                const Spacer(),
                _PrimaryActionButton(
                  isRunning: _ctrl.isRunning,
                  enabled: !_ctrl.isRunning && _ctrl.userInput.trim().isNotEmpty,
                  onPressed: () {
                    // Fire-and-forget; controller internally awaits service.
                    _ctrl.startAgent();
                  },
                ),
              ],
            ),
            if (_ctrl.errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.error.withAlpha(22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.error.withAlpha(90)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: scheme.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _ctrl.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _ctrl.steps.length,
      itemBuilder: (context, i) {
        final step = _ctrl.steps[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StepCard(key: ValueKey(step.id), step: step, controller: _ctrl),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withAlpha(70),
                    scheme.tertiary.withAlpha(40),
                  ],
                ),
                border: Border.all(color: scheme.outline.withAlpha(70)),
              ),
              child: const Icon(
                Icons.psychology,
                size: 42,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ready when you are',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Type a question above to see a step-by-step timeline of thoughts, tool calls, and observations.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface.withAlpha(160),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.isRunning,
    required this.enabled,
    required this.onPressed,
  });

  final bool isRunning;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Use a decorated container + transparent ElevatedButton for a "premium" gradient CTA.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: enabled
            ? LinearGradient(
                colors: [
                  scheme.primary.withAlpha(240),
                  scheme.tertiary.withAlpha(220),
                ],
              )
            : LinearGradient(
                colors: [
                  scheme.primary.withAlpha(90),
                  scheme.tertiary.withAlpha(70),
                ],
              ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: scheme.primary.withAlpha(55),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : const [],
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
        ),
        child: isRunning
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Agent is thinking...'),
                ],
              )
            : const Text('Start Agent'),
      ),
    );
  }
}
