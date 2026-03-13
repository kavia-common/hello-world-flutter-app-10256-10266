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
    final color = controller.getStepColor(step.type);
    final icon = controller.getStepIcon(step.type);
    final title = controller.getStepTitle(step.type);
    final maxLines = step.type == StepType.action ? 5 : 10;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(26)),
          child: Center(child: Icon(icon, size: 18, color: color)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color))),
            Text(DateFormat.jms().format(step.timestamp), style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withAlpha(153))),
          ]),
          const SizedBox(height: 8),
          Text(step.content, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
          if (step.type == StepType.finalAnswer) ...[const SizedBox(height: 8), Divider(color: color)],
        ])),
      ]),
    );
  }
}
