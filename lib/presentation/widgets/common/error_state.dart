import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/constants.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.error_outline, size: 36, color: theme.colorScheme.error),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 300.ms),
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 300.ms),
            if (onRetry != null) ...[
              const SizedBox(height: ThemeConstants.spacingLarge),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 300.ms)
                  .slideY(begin: 0.3, end: 0, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}
