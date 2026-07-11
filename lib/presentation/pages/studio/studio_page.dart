import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/studio/studio_bloc.dart';
import '../../../config/constants.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= ThemeConstants.tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createSession(context),
            tooltip: 'New Session',
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
              action: FilledButton.icon(
                onPressed: () => _createSession(context),
                icon: const Icon(Icons.add),
                label: const Text('New Session'),
              ),
            );
          }

          if (isWide) {
            return Row(
              children: [
                _SessionList(state: state),
                const VerticalDivider(width: 1),
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

class _SessionList extends StatelessWidget {
  final StudioState state;

  const _SessionList({required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ListView.builder(
        padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
        itemCount: state.sessions.length,
        itemBuilder: (context, index) {
          final session = state.sessions[index];
          final selected = session.id == state.selectedSessionId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Material(
              color: selected
                  ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
              child: InkWell(
                onTap: () => context.read<StudioBloc>().add(StudioSessionSelected(session.id)),
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
                        color: selected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: ThemeConstants.spacingSmall),
                      Expanded(
                        child: Text(
                          session.title,
                          style: TextStyle(
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${session.images.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
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
        Row(
          children: [
            Expanded(
              child: Text(s.title, style: Theme.of(context).textTheme.headlineSmall),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, s.id),
              tooltip: 'Delete Session',
            ),
          ],
        ),
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
          ),
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
