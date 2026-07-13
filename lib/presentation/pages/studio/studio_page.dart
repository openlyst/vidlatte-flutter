import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/generation/generation_bloc.dart';
import '../../../bloc/servers/servers_bloc.dart';
import '../../../bloc/studio/studio_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/comfy_server.dart';
import '../../../data/models/generated_image.dart';
import '../../../data/models/generation_job.dart';
import '../../../data/models/studio_session.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/image_detail_modal.dart';
import '../../widgets/common/image_grid.dart';
import '../../widgets/create/generation_controls.dart';
import '../../widgets/create/progress_card.dart';
import '../../widgets/create/prompt_input.dart';
import '../../../i18n/app_strings.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final ext = Theme.of(context).extension<AppColors>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= ThemeConstants.tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.studioTitle),
        actions: [
          BlocBuilder<StudioBloc, StudioState>(
            builder: (context, state) {
              if (state.sessions.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: ThemeConstants.spacingSmall),
                child: FilledButton.icon(
                  onPressed: () => _createSession(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(s.newSession),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<StudioBloc, StudioState>(
        builder: (context, state) {
          if (state.sessions.isEmpty) {
            return EmptyState(
              icon: Icons.dashboard_outlined,
              title: s.noStudioSessions,
              message: s.noStudioSessionsMsg,
              action: FilledButton.icon(
                onPressed: () => _createSession(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(s.newSession),
              ),
            );
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

          return _SessionDetail(
            session: state.selectedSession,
            sessions: state.sessions,
          );
        },
      ),
    );
  }

  void _createSession(BuildContext context) {
    _showCreateSessionDialog(context);
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
          );
        },
      ),
    );
  }
}

class _SessionDetail extends StatefulWidget {
  final StudioSession? session;
  final List<StudioSession> sessions;

  const _SessionDetail({this.session, this.sessions = const []});

  @override
  State<_SessionDetail> createState() => _SessionDetailState();
}

class _SessionDetailState extends State<_SessionDetail> {
  final _promptController = TextEditingController();
  final _negativePromptController = TextEditingController();
  String _selectedModel = '';
  List<String> _selectedLoras = [];
  Map<String, double> _loraWeights = {};
  Creativity _creativity = Creativity.normal;
  double? _customCfg;
  int? _customSteps;
  bool? _customHiresFix;
  int _width = ComfyConstants.defaultWidth;
  int _height = ComfyConstants.defaultHeight;
  String? _selectedServerId;
  final Set<String> _addedImageIds = {};

  @override
  void didUpdateWidget(_SessionDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session?.id != oldWidget.session?.id) {
      _loadFromSession();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFromSession();
  }

  void _loadFromSession() {
    final s = widget.session;
    if (s == null) return;
    _promptController.text = s.prompt;
    _selectedModel = s.model;
    _selectedLoras = List.from(s.loras);
    _addedImageIds.clear();
    for (final img in s.images) {
      _addedImageIds.add(img.id);
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _negativePromptController.dispose();
    super.dispose();
  }

  void _generate() {
    final s = widget.session;
    if (s == null) return;

    final serversState = context.read<ServersBloc>().state;
    ComfyServer? server;
    if (_selectedServerId != null) {
      server = serversState.servers.where((srv) => srv.id == _selectedServerId).firstOrNull;
    }
    server ??= serversState.defaultServer ?? (serversState.servers.isNotEmpty ? serversState.servers.first : null);

    if (server == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).comfyNoServerError)),
      );
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).enterPrompt)),
      );
      return;
    }

    if (_selectedModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).selectModel)),
      );
      return;
    }

    context.read<StudioBloc>().add(StudioSessionPromptChanged(s.id, _promptController.text.trim()));
    context.read<StudioBloc>().add(StudioSessionModelChanged(s.id, _selectedModel));
    context.read<StudioBloc>().add(StudioSessionLorasChanged(s.id, _selectedLoras));

    context.read<GenerationBloc>().add(GenerationSubmitted(
          server: server,
          prompt: _promptController.text.trim(),
          negativePrompt: _negativePromptController.text.trim(),
          model: _selectedModel,
          loras: _selectedLoras,
          loraWeights: _loraWeights,
          creativity: _creativity,
          cfg: _customCfg,
          steps: _customSteps,
          hiresFix: _customHiresFix,
          width: _width,
          height: _height,
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session == null) {
      return EmptyState(
        icon: Icons.dashboard_outlined,
        title: AppStrings.of(context).selectSession,
        message: AppStrings.of(context).selectSessionMsg,
      );
    }

    final s = widget.session!;
    return BlocListener<GenerationBloc, GenerationState>(
      listenWhen: (prev, curr) => curr.images.length > prev.images.length,
      listener: (context, genState) {
        for (final img in genState.images) {
          if (!_addedImageIds.contains(img.id)) {
            _addedImageIds.add(img.id);
            context.read<StudioBloc>().add(StudioImageAdded(s.id, img));
          }
        }
      },
      child: _buildContent(context, s),
    );
  }

  Widget _buildContent(BuildContext context, StudioSession s) {
    final serversState = context.read<ServersBloc>().state;
    final server = _selectedServerId != null
        ? serversState.servers.where((srv) => srv.id == _selectedServerId).firstOrNull
        : null;
    final effectiveServer = server ?? serversState.defaultServer ?? (serversState.servers.isNotEmpty ? serversState.servers.first : null);

    if (serversState.servers.isEmpty) {
      return EmptyState(
        icon: Icons.dns_outlined,
        title: AppStrings.of(context).noComfyServer,
        message: AppStrings.of(context).noComfyServerMsg,
      );
    }

    final catalog = serversState.catalogs[effectiveServer?.id];
    if (catalog == null && effectiveServer != null) {
      context.read<ServersBloc>().add(ServerModelsFetchRequested(effectiveServer.id));
    }

    final visibleLoras = serversState.visibleLorasFor(effectiveServer!.id);
    final triggerWords = serversState.triggerWordsFor(effectiveServer.id);

    return BlocBuilder<GenerationBloc, GenerationState>(
      builder: (context, genState) {
        final isGenerating = genState.status == GenerationStatus.generating;
        return ListView(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          children: [
            _buildSessionHeader(context, s),
            const SizedBox(height: ThemeConstants.spacingMedium),
            PromptInput(controller: _promptController, negativeController: _negativePromptController, maxLength: ComfyConstants.maxPromptLength),
            const SizedBox(height: ThemeConstants.spacingMedium),
            GenerationControls(
              models: catalog?.models as List<String>? ?? [],
              loras: visibleLoras,
              triggerWords: triggerWords,
              maxLoras: effectiveServer.maxLoras,
              selectedModel: _selectedModel,
              selectedLoras: _selectedLoras,
              loraWeights: _loraWeights,
              creativity: _creativity,
              customCfg: _customCfg,
              customSteps: _customSteps,
              customHiresFix: _customHiresFix,
              width: _width,
              height: _height,
              servers: serversState.servers,
              selectedServerId: effectiveServer.id,
              onModelChanged: (m) => setState(() => _selectedModel = m),
              onLorasChanged: (l) => setState(() => _selectedLoras = l),
              onLoraWeightsChanged: (w) => setState(() => _loraWeights = w),
              onCreativityChanged: (c) => setState(() => _creativity = c),
              onCfgChanged: (v) => setState(() => _customCfg = v),
              onStepsChanged: (st) => setState(() => _customSteps = st),
              onHiresFixChanged: (h) => setState(() => _customHiresFix = h),
              onDimensionsChanged: (dims) => setState(() { _width = dims.$1; _height = dims.$2; }),
              onServerChanged: (id) => setState(() {
                _selectedServerId = id;
                _selectedModel = '';
                _selectedLoras = [];
                _loraWeights = {};
              }),
              onRefreshModels: () => context.read<ServersBloc>().add(ServerModelsFetchRequested(effectiveServer.id)),
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _generate,
                icon: isGenerating
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(isGenerating ? AppStrings.of(context).addToQueue : AppStrings.of(context).generate),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            ..._buildActiveJobs(genState),
            if (s.images.isNotEmpty) ...[
              const SizedBox(height: ThemeConstants.spacingMedium),
              Text(AppStrings.of(context).sessionImages, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: ThemeConstants.spacingSmall),
              ImageGrid(
                images: s.images,
                onTap: (image) => _showImage(context, image),
                onDelete: (image) {
                  context.read<StudioBloc>().add(StudioImageRemoved(s.id, image.id));
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSessionHeader(BuildContext context, StudioSession s) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final hasMultipleSessions = widget.sessions.length > 1;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ext.surfaceElevated,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        border: Border.all(color: ext.border, width: 0.5),
      ),
      child: InkWell(
        onTap: hasMultipleSessions ? () => _showSessionPicker(context) : null,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingLarge,
            vertical: ThemeConstants.spacingMedium,
          ),
          child: Row(
            children: [
              Icon(Icons.folder, color: ext.accent, size: 28),
              const SizedBox(width: ThemeConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${s.images.length} ${AppStrings.of(context).imagesLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ext.muted),
                    ),
                  ],
                ),
              ),
              if (hasMultipleSessions)
                Padding(
                  padding: const EdgeInsets.only(right: ThemeConstants.spacingSmall),
                  child: Icon(Icons.unfold_more, color: ext.muted, size: 20),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: ext.muted,
                onPressed: () => _confirmDelete(context, s.id),
                tooltip: AppStrings.of(context).deleteSession,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      builder: (ctx) {
        final ext = Theme.of(ctx).extension<AppColors>()!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemeConstants.spacingLarge,
                ThemeConstants.spacingMedium,
                ThemeConstants.spacingLarge,
                ThemeConstants.spacingSmall,
              ),
              child: Row(
                children: [
                  Text(AppStrings.of(context).sessions, style: Theme.of(ctx).textTheme.titleLarge),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showCreateSessionDialog(context);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(AppStrings.of(context).new_),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  ThemeConstants.spacingSmall,
                  0,
                  ThemeConstants.spacingSmall,
                  ThemeConstants.spacingMedium,
                ),
                itemCount: widget.sessions.length,
                itemBuilder: (ctx, index) {
                  final session = widget.sessions[index];
                  final selected = session.id == widget.session?.id;
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
                          onTap: () {
                            context.read<StudioBloc>().add(StudioSessionSelected(session.id));
                            Navigator.of(ctx).pop();
                          },
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
                                          ? Theme.of(ctx).colorScheme.onSurface
                                          : ext.muted,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${session.images.length}',
                                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                        color: selected ? ext.accent : ext.muted,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildActiveJobs(GenerationState state) {
    final widgets = <Widget>[];

    if (state.currentJob != null) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
        child: ProgressCard(
          job: state.currentJob!,
          onCancel: state.currentJob!.isActive
              ? () => context.read<GenerationBloc>().add(GenerationCancelled(state.currentJob!.id))
              : null,
          onRetry: state.currentJob!.isFailed
              ? () => context.read<GenerationBloc>().add(GenerationRetried(state.currentJob!.id))
              : null,
        ),
      ));
    }

    if (state.queue.isNotEmpty) {
      for (var i = 0; i < state.queue.length; i++) {
        final job = state.queue[i];
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
          child: ProgressCard(
            job: job.copyWith(status: JobStatus.queued),
            onCancel: () => context.read<GenerationBloc>().add(GenerationCancelled(job.id)),
          ),
        ));
      }
    }

    return widgets;
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.of(context).deleteSession),
        content: Text(AppStrings.of(context).deleteSessionMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<StudioBloc>().add(StudioSessionDeleted(id));
              Navigator.of(ctx).pop();
            },
            child: Text(AppStrings.of(context).delete),
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

void _showCreateSessionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      final controller = TextEditingController();
      return AlertDialog(
        title: Text(AppStrings.of(context).newSession),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: AppStrings.of(context).sessionName),
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
            child: Text(AppStrings.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<StudioBloc>().add(StudioSessionCreated(controller.text.trim()));
              }
              Navigator.of(ctx).pop();
            },
            child: Text(AppStrings.of(context).create),
          ),
        ],
      );
    },
  );
}
