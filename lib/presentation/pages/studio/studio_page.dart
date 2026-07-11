import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/studio/studio_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/generated_image.dart';
import '../../../data/models/studio_session.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/image_detail_modal.dart';
import '../../widgets/common/image_grid.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= ThemeConstants.tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: ThemeConstants.spacingSmall),
            child: _GradientActionButton(
              icon: Icons.add,
              label: 'New Session',
              gradient: LinearGradient(
                colors: [ext.accentGradientStart, ext.accentGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onPressed: () => _createSession(context),
            ),
          ),
        ],
      ),
      body: BlocBuilder<StudioBloc, StudioState>(
        builder: (context, state) {
          if (state.sessions.isEmpty) {
            return EmptyState(
              icon: Icons.dashboard_outlined,
              title: 'No Studio Sessions',
              message: 'Create a session to organize your generations by project.',
              action: _GradientActionButton(
                icon: Icons.add,
                label: 'New Session',
                gradient: LinearGradient(
                  colors: [ext.accentGradientStart, ext.accentGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: () => _createSession(context),
              ),
            ).animate().fadeIn(duration: ThemeConstants.animationSlow);
          }

          if (isWide) {
            return Row(
              children: [
                _SessionList(state: state),
                VerticalDivider(width: 1, color: ext.border),
                Expanded(child: _SessionDetail(session: state.selectedSession)),
              ],
            );
          }

          return _SessionDetail(session: state.selectedSession);
        },
      ),
    );
  }

  void _createSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('New Session'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Session name'),
            onSubmitted: (_) {
              if (controller.text.trim().isNotEmpty) {
                context.read<StudioBloc>().add(StudioSessionCreated(controller.text.trim()));
              }
              Navigator.of(ctx).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<StudioBloc>().add(StudioSessionCreated(controller.text.trim()));
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _GradientActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingMedium,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: ThemeConstants.spacingSmall),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final StudioState state;

  const _SessionList({required this.state});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      width: 260,
      child: ListView.builder(
        padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
        itemCount: state.sessions.length,
        itemBuilder: (context, index) {
          final session = state.sessions[index];
          final selected = session.id == state.selectedSessionId;
          return Padding(
            padding: const EdgeInsets.only(bottom: ThemeConstants.spacingXSmall),
            child: Material(
              color: selected ? ext.accent.withValues(alpha: 0.12) : ext.surfaceElevated,
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
              clipBehavior: Clip.antiAlias,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected ? ext.accent.withValues(alpha: 0.4) : ext.border,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                ),
                child: InkWell(
                  onTap: () =>
                      context.read<StudioBloc>().add(StudioSessionSelected(session.id)),
                  borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.spacingMedium,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 20,
                          color: selected ? ext.accent : ext.muted,
                        ),
                        const SizedBox(width: ThemeConstants.spacingSmall),
                        Expanded(
                          child: Text(
                            session.title,
                            style: TextStyle(
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected
                                  ? Theme.of(context).colorScheme.onSurface
                                  : ext.muted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${session.images.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: selected ? ext.accent : ext.muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(
                duration: ThemeConstants.animationNormal,
                delay: Duration(milliseconds: index * 40),
              )
              .slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }
}

class _SessionDetail extends StatelessWidget {
  final StudioSession? session;

  const _SessionDetail({this.session});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;

    if (session == null) {
      return const EmptyState(
        icon: Icons.dashboard_outlined,
        title: 'Select a Session',
        message: 'Choose a session from the list to view its images.',
      );
    }

    final s = session!;
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: ext.surfaceElevated,
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
            border: Border.all(color: ext.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingLarge,
              vertical: ThemeConstants.spacingMedium,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ext.accentGradientStart, ext.accentGradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
                  ),
                  child: const Icon(Icons.folder, color: Colors.white, size: 20),
                ),
                const SizedBox(width: ThemeConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${s.images.length} images',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ext.muted,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: ext.muted,
                  onPressed: () => _confirmDelete(context, s.id),
                  tooltip: 'Delete Session',
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: ThemeConstants.animationSlow)
            .slideY(begin: 0.03, end: 0),
        const SizedBox(height: ThemeConstants.spacingMedium),
        if (s.images.isEmpty)
          const EmptyState(
            icon: Icons.image_outlined,
            title: 'No Images',
            message: 'Generate images from the Create page and add them to this session.',
          )
        else
          ImageGrid(
            images: s.images,
            onTap: (image) => _showImage(context, image),
            onFavorite: null,
            onDelete: null,
          ).animate().fadeIn(duration: ThemeConstants.animationSlow),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure? This will remove the session and its images.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<StudioBloc>().add(StudioSessionDeleted(id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showImage(BuildContext context, GeneratedImage image) {
    showDialog(
      context: context,
      builder: (_) => ImageDetailModal(image: image),
    );
  }
}
