import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../data/models/generation_job.dart';

class ProgressCard extends StatelessWidget {
  final GenerationJob job;

  const ProgressCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = job.progressFraction;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (job.status != JobStatus.failed && job.status != JobStatus.completed)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (job.status == JobStatus.failed)
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20)
                else
                  Icon(Icons.check_circle, color: theme.colorScheme.secondary, size: 20),
                const SizedBox(width: ThemeConstants.spacingSmall),
                Expanded(
                  child: Text(
                    job.prompt,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingSmall),
            if (progress != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
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
      ),
    );
  }
}
