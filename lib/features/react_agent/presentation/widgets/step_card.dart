import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:react_agent/features/react_agent/domain/agent_step.dart';
import 'package:react_agent/features/react_agent/presentation/react_agent_controller.dart';

// PUBLIC_INTERFACE
/// A card widget displaying a single AgentStep in the timeline.
class StepCard extends StatelessWidget {
  const StepCard({super.key, required this.step, required this.controller});
  final AgentStep step;
  final ReactAgentController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final color = controller.getStepColor(step.type);
    final icon = controller.getStepIcon(step.type);
    final title = controller.getStepTitle(step.type);

    // Preserve existing truncation behavior.
    final maxLines = step.type == StepType.action ? 5 : 10;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withAlpha(75)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerHighest.withAlpha(170),
            scheme.surface.withAlpha(210),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(70),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Accent stripe to give a "timeline" feel.
          Container(
            width: 6,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withAlpha(230),
                  color.withAlpha(120),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: color.withAlpha(26),
                      border: Border.all(color: color.withAlpha(80)),
                    ),
                    child: Center(child: Icon(icon, size: 18, color: color)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest.withAlpha(160),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: scheme.outline.withAlpha(70)),
                              ),
                              child: Text(
                                DateFormat.jms().format(step.timestamp),
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontSize: 11,
                                      color: scheme.onSurface.withAlpha(170),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          step.content,
                          maxLines: maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurface,
                              ),
                        ),
                        if (step.type == StepType.finalAnswer) ...[
                          const SizedBox(height: 12),
                          Divider(color: color.withAlpha(120)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
