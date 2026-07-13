import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/autogen/autogen_bloc.dart';
import '../../../bloc/llm/llm_bloc.dart';
import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/generated_image.dart';
import '../../widgets/common/empty_state.dart';
import '../../../i18n/app_strings.dart';

class AutoImageController {
  VoidCallback? _start;
  VoidCallback? _stop;
  bool Function()? _canStart;
  VoidCallback? onChanged;

  void _attach({
    required VoidCallback start,
    required VoidCallback stop,
    required bool Function() canStart,
  }) {
    _start = start;
    _stop = stop;
    _canStart = canStart;
  }

  void _notifyChanged() => onChanged?.call();

  bool get canStart => _canStart?.call() ?? false;
  void start() => _start?.call();
  void stop() => _stop?.call();
}

class AutoImageContent extends StatefulWidget {
  final AutoImageController controller;
  final VoidCallback? onCanStartChanged;

  const AutoImageContent({
    super.key,
    required this.controller,
    this.onCanStartChanged,
  });

  @override
  State<AutoImageContent> createState() => _AutoImageContentState();
}

class _AutoImageContentState extends State<AutoImageContent> {
  AutoGenMode _mode = AutoGenMode.auto;
  String _topic = '';
  String _basePrompt = '';
  String _mustIncludeTags = '';
  int? _maxImages = 10;
  List<String> _selectedLoras = [];
  String _imageModel = '';
  String? _selectedLlmServerId;
  String? _selectedLlmModel;
  String? _selectedImageServerId;
  int _width = ComfyConstants.defaultWidth;
  int _height = ComfyConstants.defaultHeight;
  int _steps = ComfyConstants.defaultSteps;
  bool _hiresFix = false;
  final _topicController = TextEditingController();
  final _basePromptController = TextEditingController();
  final _mustIncludeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final autoGenState = context.read<AutoGenBloc>().state;
    _mode = autoGenState.mode;
    _topic = autoGenState.topic;
    _basePrompt = autoGenState.basePrompt;
    _mustIncludeTags = autoGenState.mustIncludeTags;
    _maxImages = autoGenState.maxImages;
    _selectedLoras = List.from(autoGenState.selectedLoras);
    _imageModel = autoGenState.imageModel;
    _selectedLlmServerId = autoGenState.llmServerId;
    _selectedLlmModel = autoGenState.llmModel;
    _selectedImageServerId = autoGenState.imageServerId;
    _width = autoGenState.width;
    _height = autoGenState.height;
    _steps = autoGenState.steps ?? ComfyConstants.defaultSteps;
    _hiresFix = autoGenState.hiresFix ?? false;
    _topicController.text = _topic;
    _basePromptController.text = _basePrompt;
    _mustIncludeController.text = _mustIncludeTags;

    final llmState = context.read<LlmBloc>().state;
    if (_selectedLlmServerId == null && llmState.servers.isNotEmpty) {
      _selectedLlmServerId = llmState.servers.first.id;
    }

    final serversState = context.read<ServersBloc>().state;
    _selectedImageServerId ??= serversState.defaultServer?.id ??
        (serversState.servers.isNotEmpty ? serversState.servers.first.id : null);

    if (_selectedLlmServerId != null) {
      context.read<LlmBloc>().add(LlmModelsFetchRequested(_selectedLlmServerId!));
    }
    if (_selectedImageServerId != null) {
      context.read<ServersBloc>().add(ServerModelsFetchRequested(_selectedImageServerId!));
    }

    widget.controller._attach(
      start: _start,
      stop: _stop,
      canStart: _canStart,
    );
    widget.controller.onChanged = () {
      setState(() {});
      widget.onCanStartChanged?.call();
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[AutoImageContent] initState postFrame - canStart=${_canStart()}');
      widget.controller._notifyChanged();
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    _basePromptController.dispose();
    _mustIncludeController.dispose();
    super.dispose();
  }

  void _syncConfig() {
    context.read<AutoGenBloc>().add(AutoGenConfigChanged(
          mode: _mode,
          topic: _topic,
          basePrompt: _basePrompt,
          mustIncludeTags: _mustIncludeTags,
          maxImages: _maxImages,
          selectedLoras: _selectedLoras,
          imageModel: _imageModel,
          llmServerId: _selectedLlmServerId,
          llmModel: _selectedLlmModel,
          imageServerId: _selectedImageServerId,
          width: _width,
          height: _height,
          steps: _steps,
          hiresFix: _hiresFix,
        ));
  }

  bool _canStart() {
    final can = _selectedLlmServerId != null &&
        _selectedLlmModel != null &&
        _imageModel.isNotEmpty;
    debugPrint('[AutoImageContent] _canStart -> $can (llmServer=$_selectedLlmServerId, llmModel=$_selectedLlmModel, imageModel=$_imageModel)');
    return can;
  }

  void _start() {
    debugPrint('[AutoImageContent] _start called');
    final serversState = context.read<ServersBloc>().state;
    final serverId = _selectedImageServerId ?? serversState.defaultServer?.id;
    debugPrint('[AutoImageContent] _start serverId=$serverId imageModel=$_imageModel');
    if (serverId != null) {
      final catalog = serversState.catalogs[serverId];
      if (catalog != null &&
          catalog.models.isNotEmpty &&
          !catalog.models.contains(_imageModel)) {
        debugPrint('[AutoImageContent] _start model not on server, aborting');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppStrings.of(context).modelNotOnServerRaw(_imageModel))),
        );
        return;
      }
    }
    _syncConfig();
    debugPrint('[AutoImageContent] _start adding AutoGenStarted');
    context.read<AutoGenBloc>().add(const AutoGenStarted());
  }

  void _stop() {
    context.read<AutoGenBloc>().add(const AutoGenStopped());
  }

  void _setState(VoidCallback fn) {
    setState(fn);
    widget.controller._notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= ThemeConstants.tabletBreakpoint;

    if (isWide) {
      return Row(
        children: [
          SizedBox(width: 360, child: _buildConfigPanel()),
          Container(width: 0.5, color: ext.border),
          Expanded(child: _buildOutputPanel()),
        ],
      );
    }
    return Scaffold(
      endDrawer: Drawer(
        width: 340,
        child: _buildConfigPanel(),
      ),
      body: Builder(
        builder: (scaffoldContext) => Stack(
          children: [
            _buildOutputPanel(),
            Positioned(
              top: ThemeConstants.spacingSmall,
              right: ThemeConstants.spacingSmall,
              child: FloatingActionButton.small(
                onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                child: const Icon(Icons.tune),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigPanel() {
    final s = AppStrings.of(context);
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      children: [
        Text(s.autoImageTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 2),
        Text(s.autoImageSubtitle,
            style: theme.textTheme.bodySmall),
        const SizedBox(height: ThemeConstants.spacingLarge),

        _buildSectionCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.generationMode, style: theme.textTheme.labelLarge),
              const SizedBox(height: ThemeConstants.spacingSmall),
              SegmentedButton<AutoGenMode>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return ext.accent.withValues(alpha: 0.15);
                    }
                    return ext.surfaceElevated;
                  }),
                  side: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(color: ext.accent, width: 1);
                    }
                    return BorderSide(color: ext.border, width: 0.5);
                  }),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.borderRadiusSmall),
                  )),
                ),
                segments: [
                  ButtonSegment(
                    value: AutoGenMode.auto,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(s.auto),
                  ),
                  ButtonSegment(
                    value: AutoGenMode.variation,
                    icon: const Icon(Icons.shuffle, size: 16),
                    label: Text(s.variation),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (set) => _setState(() {
                  _mode = set.first;
                  _syncConfig();
                }),
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              if (_mode == AutoGenMode.auto) ...[
                TextField(
                  controller: _topicController,
                  decoration: InputDecoration(
                    labelText: s.topicOptional,
                    hintText: s.topicHint,
                    isDense: true,
                  ),
                  onChanged: (v) => _topic = v,
                ),
                const SizedBox(height: 4),
                Text(s.leaveEmptyRandom,
                    style: theme.textTheme.bodySmall),
              ] else ...[
                TextField(
                  controller: _basePromptController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: s.basePrompt,
                    hintText: s.basePromptHint,
                    isDense: true,
                  ),
                  onChanged: (v) => _basePrompt = v,
                ),
                const SizedBox(height: 4),
                Text(
                    s.variationDesc,
                    style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),

        _buildSectionCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.mustIncludeTags, style: theme.textTheme.labelLarge),
              const SizedBox(height: ThemeConstants.spacingSmall),
              TextField(
                controller: _mustIncludeController,
                decoration: InputDecoration(
                  hintText: s.mustIncludeHint,
                  isDense: true,
                ),
                onChanged: (v) => _mustIncludeTags = v,
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              Row(
                children: [
                  Text(s.maxImages, style: theme.textTheme.labelLarge),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: s.maxImagesHint,
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        _setState(() => _maxImages = n);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),

        BlocBuilder<LlmBloc, LlmState>(
          builder: (context, state) {
            if (state.servers.isEmpty) {
              return _buildSectionCard(
                context,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: ThemeConstants.spacingSmall),
                  child: Text(
                      s.noLlmServersConfigured,
                      style: theme.textTheme.bodyMedium),
                ),
              );
            }
            return _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.llmServer, style: theme.textTheme.labelLarge),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLlmServerId,
                    decoration: const InputDecoration(isDense: true),
                    items: state.servers
                        .map((s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: (id) {
                      _setState(() {
                        _selectedLlmServerId = id;
                        _selectedLlmModel = null;
                      });
                      if (id != null) {
                        context.read<LlmBloc>().add(LlmModelsFetchRequested(id));
                      }
                    },
                  ),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  if (_selectedLlmServerId != null &&
                      (state.models[_selectedLlmServerId] ?? []).isNotEmpty) ...[
                    Row(
                      children: [
                        Text(s.llmModel, style: theme.textTheme.labelLarge),
                        const Spacer(),
                        IconButton(
                          onPressed: () => context.read<LlmBloc>().add(LlmModelsFetchRequested(_selectedLlmServerId!)),
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: 'Refresh',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: ThemeConstants.spacingSmall),
                    DropdownButtonFormField<String>(
                      value: _selectedLlmModel,
                      decoration: const InputDecoration(isDense: true),
                      items: (state.models[_selectedLlmServerId] ?? [])
                          .map((m) => DropdownMenuItem(
                                value: m.identifier,
                                child: Text(m.displayName),
                              ))
                          .toList(),
                      onChanged: (id) => _setState(() => _selectedLlmModel = id),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),

        BlocBuilder<ServersBloc, ServersState>(
          builder: (context, state) {
            if (state.servers.isEmpty) {
              return _buildSectionCard(
                context,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: ThemeConstants.spacingSmall),
                  child: Text(
                      s.noComfyServersConfigured,
                      style: theme.textTheme.bodyMedium),
                ),
              );
            }
            return _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.imageServer, style: theme.textTheme.labelLarge),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedImageServerId,
                    decoration: const InputDecoration(isDense: true),
                    items: state.servers
                        .map((s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: (id) {
                      _setState(() => _selectedImageServerId = id);
                      if (id != null) {
                        context.read<ServersBloc>()
                            .add(ServerModelsFetchRequested(id));
                      }
                    },
                  ),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  if (_selectedImageServerId != null) ...[
                    Row(
                      children: [
                        Text(s.imageModel, style: theme.textTheme.labelLarge),
                        const Spacer(),
                        IconButton(
                          onPressed: () => context.read<ServersBloc>().add(ServerModelsFetchRequested(_selectedImageServerId!)),
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: 'Refresh',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: ThemeConstants.spacingSmall),
                    DropdownButtonFormField<String>(
                      value: _imageModel.isEmpty ? null : _imageModel,
                      decoration: const InputDecoration(isDense: true),
                      items: (state.catalogs[_selectedImageServerId]?.models ??
                              [])
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m
                                    .replaceAll('.safetensors', '')
                                    .replaceAll('_', ' ')),
                              ))
                          .toList(),
                      onChanged: (id) => _setState(() => _imageModel = id ?? ''),
                    ),
                    const SizedBox(height: ThemeConstants.spacingSmall),
                    if (state
                            .visibleLorasFor(_selectedImageServerId!)
                            .isNotEmpty) ...[
                      Text(s.loras, style: theme.textTheme.labelLarge),
                      const SizedBox(height: ThemeConstants.spacingSmall),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 160),
                        decoration: BoxDecoration(
                          color: ext.surfaceElevated,
                          border: Border.all(color: ext.border, width: 0.5),
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.borderRadiusSmall),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: state
                              .visibleLorasFor(_selectedImageServerId!)
                              .map((lora) {
                            final name = lora.split('/').last;
                            final triggers = state
                                .triggerWordsFor(_selectedImageServerId!)[lora];
                            final hasTriggers =
                                triggers != null && triggers.isNotEmpty;
                            final selected = _selectedLoras.contains(lora);
                            return CheckboxListTile(
                              dense: true,
                              activeColor: ext.accent,
                              checkColor: Colors.white,
                              tileColor: selected
                                  ? ext.accent.withValues(alpha: 0.08)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.borderRadiusSmall),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                      child: Text(name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: selected
                                                  ? ext.accent
                                                  : null))),
                                  if (hasTriggers)
                                    Icon(Icons.bolt, size: 14, color: ext.accent),
                                ],
                              ),
                              subtitle: hasTriggers
                                  ? Text(triggers,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                  : null,
                              value: selected,
                              onChanged: (checked) {
                                _setState(() {
                                  if (checked == true) {
                                    _selectedLoras.add(lora);
                                  } else {
                                    _selectedLoras.remove(lora);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
        _buildGenerationSettingsCard(context),
      ],
    );
  }

  static const _dimensionPresets = [
    (512, 512, '512 × 512'),
    (768, 768, '768 × 768'),
    (1024, 1024, '1024 × 1024'),
    (768, 1024, '768 × 1024'),
    (1024, 768, '1024 × 768'),
    (1024, 1536, '1024 × 1536'),
    (1536, 1024, '1536 × 1024'),
  ];

  Widget _buildGenerationSettingsCard(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    return _buildSectionCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.advanced, style: theme.textTheme.labelLarge),
          const SizedBox(height: ThemeConstants.spacingSmall),
          Text(s.dimensions, style: theme.textTheme.bodySmall),
          const SizedBox(height: ThemeConstants.spacingSmall),
          Wrap(
            spacing: ThemeConstants.spacingSmall,
            runSpacing: ThemeConstants.spacingSmall,
            children: _dimensionPresets.map((preset) {
              final ($w, $h, label) = preset;
              final selected = _width == $w && _height == $h;
              return FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => _setState(() {
                  _width = $w;
                  _height = $h;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          Text('${s.stepsWithDefault} ($_steps)', style: theme.textTheme.bodySmall),
          Slider(
            value: _steps.toDouble(),
            min: ComfyConstants.minSteps.toDouble(),
            max: ComfyConstants.maxSteps.toDouble(),
            divisions: ComfyConstants.maxSteps - ComfyConstants.minSteps,
            label: '$_steps',
            onChanged: (v) => _setState(() => _steps = v.round()),
          ),
          const SizedBox(height: ThemeConstants.spacingSmall),
          SwitchListTile(
            title: Text(s.hiresFix),
            subtitle: Text(s.hiresFixSubtitle),
            value: _hiresFix,
            onChanged: (v) => _setState(() => _hiresFix = v),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required Widget child}) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: ext.surfaceElevated,
        border: Border.all(color: ext.border, width: 0.5),
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
      ),
      child: child,
    );
  }

  Widget _buildOutputPanel() {
    final s = AppStrings.of(context);
    final ext = Theme.of(context).extension<AppColors>()!;
    final isWide = MediaQuery.sizeOf(context).width >= ThemeConstants.tabletBreakpoint;
    return BlocBuilder<AutoGenBloc, AutoGenState>(
      builder: (context, state) {
        if (state.images.isEmpty && !state.isRunning) {
          return EmptyState(
            icon: Icons.auto_awesome_outlined,
            title: s.autoImageTitle,
            message:
                s.autoImageEmptyMsg,
            action: isWide
                ? null
                : FilledButton.icon(
                    onPressed: _canStart() ? _start : null,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(s.startGeneration),
                  ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _StatusBar(state: state),
            ),
            if (state.currentPrompt.isNotEmpty)
              SliverToBoxAdapter(
                child: _CurrentPromptCard(prompt: state.currentPrompt),
              ),
            if (state.images.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  ThemeConstants.spacingMedium,
                  ThemeConstants.spacingMedium,
                  ThemeConstants.spacingMedium,
                  ThemeConstants.bottomNavTotal,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    crossAxisSpacing: ThemeConstants.spacingSmall,
                    mainAxisSpacing: ThemeConstants.spacingSmall,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AutoImageCard(
                        image: state.images[index], accent: ext.accent),
                    childCount: state.images.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  final AutoGenState state;

  const _StatusBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final statusText = switch (state.status) {
      AutoGenStatus.idle => s.idle,
      AutoGenStatus.generatingPrompt => s.generatingPrompt,
      AutoGenStatus.generatingImage => s.generatingImage,
      AutoGenStatus.waiting => s.waiting,
      AutoGenStatus.paused => s.paused,
      AutoGenStatus.completed => s.completed,
      AutoGenStatus.error => '${s.error}: ${state.errorMessage ?? "Unknown"}',
    };

    final color = switch (state.status) {
      AutoGenStatus.error => Colors.red,
      AutoGenStatus.completed => Colors.green,
      AutoGenStatus.paused => Colors.orange,
      _ => ext.accent,
    };

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingMedium,
              vertical: ThemeConstants.spacingSmall),
          padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingMedium,
              vertical: ThemeConstants.spacingSmall),
          decoration: BoxDecoration(
            color: ext.surfaceElevated.withValues(alpha: 0.7),
            border: Border.all(color: ext.border, width: 0.5),
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          ),
          child: Row(
            children: [
              if (state.isRunning)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: ext.accent),
                )
              else
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: ThemeConstants.spacingSmall),
              Expanded(
                  child: Text(statusText, style: theme.textTheme.bodyMedium)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingSmall,
                    vertical: 4),
                decoration: BoxDecoration(
                  color: ext.accent.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.borderRadiusSmall),
                ),
                child: Text(
                  '${state.generatedCount}/${state.maxImages ?? "∞"}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: ext.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentPromptCard extends StatelessWidget {
  final String prompt;

  const _CurrentPromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMedium,
          vertical: ThemeConstants.spacingSmall),
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: ext.surfaceElevated,
        border: Border.all(color: ext.border, width: 0.5),
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_snippet, size: 16, color: ext.accent),
              const SizedBox(width: ThemeConstants.spacingSmall),
              Text(s.currentPrompt, style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingSmall),
          Text(prompt, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AutoImageCard extends StatelessWidget {
  final AutoGenImage image;
  final Color accent;

  const _AutoImageCard({required this.image, required this.accent});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image.localPath != null)
            Image.file(
              File(image.localPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: ext.surfaceElevated,
                child: Center(
                    child: Icon(Icons.broken_image, size: 32, color: ext.muted)),
              ),
            )
          else
            Container(
              color: ext.surfaceElevated,
              child: CircularProgressIndicator(color: accent),
            ),
          if (image.status == ImageStatus.pending ||
              image.status == ImageStatus.processing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7)
                  ],
                ),
              ),
              child: Text(
                image.prompt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
