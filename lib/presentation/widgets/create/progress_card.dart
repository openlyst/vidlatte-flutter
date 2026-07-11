import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/generation_job.dart';

class ProgressCard extends StatelessWidget {
  final GenerationJob job;

  const ProgressCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final progress = job.progressFraction;
    final isActive = job.status != JobStatus.failed && job.status != JobStatus.completed;

    return Container(
      decoration: BoxDecoration(
        color: ext.surfaceElevated,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        border: Border.all(color: ext.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isActive)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(ext.accent),
                  ),
                )
              else if (job.status == JobStatus.failed)
                Icon(Icons.error_outline, color: theme.colorScheme.error, size: 18)
              else
                Icon(Icons.check_circle, color: ext.accent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job.prompt,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (progress != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).round()}% · ${job.currentNode ?? ''}',
              style: theme.textTheme.bodySmall,
            ),
          ] else if (job.status == JobStatus.failed) ...[
            Text(
              job.errorMessage ?? 'Generation failed',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ] else ...[
            Text(
              'Status: ${job.status.name}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
