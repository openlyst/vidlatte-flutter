import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
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
                gradient: LinearGradient(
                  colors: [
                    ext.accent.withValues(alpha: 0.12),
                    ext.accentGradientEnd.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 36, color: ext.accent),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 300.ms),
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 300.ms),
            if (action != null) ...[
              const SizedBox(height: ThemeConstants.spacingLarge),
              action!
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
