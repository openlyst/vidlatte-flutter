import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/generation_job.dart';
import '../../../i18n/app_strings.dart';

class ProgressCard extends StatelessWidget {
  final GenerationJob job;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const ProgressCard({
    super.key,
    required this.job,
    this.onCancel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final progress = job.progressFraction;
    final isActive = job.status != JobStatus.failed && job.status != JobStatus.completed && job.status != JobStatus.cancelled;

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
              else if (job.status == JobStatus.cancelled)
                Icon(Icons.cancel_outlined, color: theme.colorScheme.onSurfaceVariant, size: 18)
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
              if (isActive && onCancel != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onCancel,
                  tooltip: AppStrings.of(context).cancelTooltip,
                  visualDensity: VisualDensity.compact,
                ),
              if (job.status == JobStatus.failed && onRetry != null)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: onRetry,
                  tooltip: AppStrings.of(context).retryTooltip,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (isActive && job.previewBase64 != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
              child: Image.memory(
                base64Decode(job.previewBase64!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
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
              job.errorMessage ?? AppStrings.of(context).generationFailed,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ] else if (job.status == JobStatus.cancelled) ...[
            Text(
              AppStrings.of(context).cancelled,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ] else ...[
            Text(
              AppStrings.of(context).statusLabel(job.status.name),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
