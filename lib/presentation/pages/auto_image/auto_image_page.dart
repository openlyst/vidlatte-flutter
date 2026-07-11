import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/autogen/autogen_bloc.dart';
import '../../../bloc/llm/llm_bloc.dart';
import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/generated_image.dart';
import '../../widgets/common/empty_state.dart';

class AutoImagePage extends StatefulWidget {
  const AutoImagePage({super.key});

  @override
  State<AutoImagePage> createState() => _AutoImagePageState();
}

class _AutoImagePageState extends State<AutoImagePage> {
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
  final _topicController = TextEditingController();
  final _basePromptController = TextEditingController();
  final _mustIncludeController = TextEditingController();

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
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= ThemeConstants.tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Image'),
        actions: [
          BlocBuilder<AutoGenBloc, AutoGenState>(
            builder: (context, state) {
              if (state.isRunning) {
                return TextButton.icon(
                  onPressed: () =>
                      context.read<AutoGenBloc>().add(const AutoGenStopped()),
                  icon: const Icon(Icons.stop_circle, color: Colors.red),
                  label: const Text('Stop'),
                );
              }
              return TextButton.icon(
                onPressed: _canStart() ? _start : null,
                icon: Icon(Icons.play_circle,
                    color: _canStart() ? ext.accent : ext.muted),
                label: Text('Start',
                    style: TextStyle(
                        color: _canStart() ? ext.accent : ext.muted)),
              );
            },
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                SizedBox(
                  width: 360,
                  child: _buildConfigPanel(),
                ),
                Container(width: 0.5, color: ext.border),
                Expanded(child: _buildOutputPanel()),
              ],
            )
          : _buildOutputPanel(),
      drawer: isWide
          ? null
          : Drawer(
              child: _buildConfigPanel(),
            ),
    );
  }

  bool _canStart() {
    return _selectedLlmServerId != null &&
        _selectedLlmModel != null &&
        _imageModel.isNotEmpty;
  }

  void _start() {
    final serversState = context.read<ServersBloc>().state;
    final serverId = _selectedImageServerId ?? serversState.defaultServer?.id;
    if (serverId != null) {
      final catalog = serversState.catalogs[serverId];
      if (catalog != null &&
          catalog.models.isNotEmpty &&
          !catalog.models.contains(_imageModel)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('"$_imageModel" is not available on the selected server.')),
        );
        return;
      }
    }
    _syncConfig();
    context.read<AutoGenBloc>().add(const AutoGenStarted());
  }

  Widget _buildConfigPanel() {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      children: [
        Text('Auto Image', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 2),
        Text('AI-powered automated image generation',
            style: theme.textTheme.bodySmall),
        const SizedBox(height: ThemeConstants.spacingLarge),

        _buildSectionCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Generation Mode', style: theme.textTheme.labelLarge),
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
                segments: const [
                  ButtonSegment(
                    value: AutoGenMode.auto,
                    icon: Icon(Icons.auto_awesome, size: 16),
                    label: Text('Auto'),
                  ),
                  ButtonSegment(
                    value: AutoGenMode.variation,
                    icon: Icon(Icons.shuffle, size: 16),
                    label: Text('Variation'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (set) => setState(() {
                  _mode = set.first;
                  _syncConfig();
                }),
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              if (_mode == AutoGenMode.auto) ...[
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Topic / Idea (optional)',
                    hintText: 'e.g., cyberpunk city, fantasy portrait...',
                    isDense: true,
                  ),
                  onChanged: (v) => _topic = v,
                ),
                const SizedBox(height: 4),
                Text('Leave empty for completely random prompts',
                    style: theme.textTheme.bodySmall),
              ] else ...[
                TextField(
                  controller: _basePromptController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Base Prompt',
                    hintText:
                        'Paste your prompt here. The AI will create variations...',
                    isDense: true,
                  ),
                  onChanged: (v) => _basePrompt = v,
                ),
                const SizedBox(height: 4),
                Text(
                    'The AI will vary style, lighting, and details while preserving your core content',
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
              Text('Must Include Tags', style: theme.textTheme.labelLarge),
              const SizedBox(height: ThemeConstants.spacingSmall),
              TextField(
                controller: _mustIncludeController,
                decoration: const InputDecoration(
                  hintText: 'e.g., red hair, specific pose...',
                  isDense: true,
                ),
                onChanged: (v) => _mustIncludeTags = v,
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              Row(
                children: [
                  Text('Max Images', style: theme.textTheme.labelLarge),
                  const Spacer(),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: '10',
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        setState(() => _maxImages = n);
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
                      'No LLM servers configured. Add one in Settings.',
                      style: theme.textTheme.bodyMedium),
                ),
              );
            }
            return _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LLM Server', style: theme.textTheme.labelLarge),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLlmServerId ?? state.servers.first.id,
                    decoration: const InputDecoration(isDense: true),
                    items: state.servers
                        .map((s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: (id) {
                      setState(() {
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
                    Text('LLM Model', style: theme.textTheme.labelLarge),
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
                      onChanged: (id) => setState(() => _selectedLlmModel = id),
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
                      'No ComfyUI servers configured. Add one in Settings.',
                      style: theme.textTheme.bodyMedium),
                ),
              );
            }
            return _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image Server', style: theme.textTheme.labelLarge),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  DropdownButtonFormField<String>(
                    initialValue:
                        _selectedImageServerId ?? state.defaultServer?.id,
                    decoration: const InputDecoration(isDense: true),
                    items: state.servers
                        .map((s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    onChanged: (id) {
                      setState(() => _selectedImageServerId = id);
                      if (id != null) {
                        context.read<ServersBloc>()
                            .add(ServerModelsFetchRequested(id));
                      }
                    },
                  ),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  if (_selectedImageServerId != null) ...[
                    Text('Image Model', style: theme.textTheme.labelLarge),
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
                      onChanged: (id) => setState(() => _imageModel = id ?? ''),
                    ),
                    const SizedBox(height: ThemeConstants.spacingSmall),
                    if (state
                            .visibleLorasFor(_selectedImageServerId!)
                            .isNotEmpty) ...[
                      Text('LoRAs', style: theme.textTheme.labelLarge),
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
                                  : Colors.transparent,
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
                                setState(() {
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
      ],
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
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildOutputPanel() {
    final ext = Theme.of(context).extension<AppColors>()!;
    return BlocBuilder<AutoGenBloc, AutoGenState>(
      builder: (context, state) {
        if (state.images.isEmpty &&
            state.status != AutoGenStatus.generatingPrompt) {
          return EmptyState(
            icon: Icons.auto_awesome_outlined,
            title: 'Auto Image',
            message:
                'Configure settings and press Start to begin automated generation.',
            action: isWide(context)
                ? null
                : _GradientButton(
                    onPressed: _canStart() ? _start : null,
                    icon: Icons.play_arrow,
                    label: 'Start Generation',
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
                padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
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

  bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ThemeConstants.tabletBreakpoint;
}

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    colors: [ext.accentGradientStart, ext.accentGradientEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: enabled ? null : ext.muted,
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final AutoGenState state;

  const _StatusBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final statusText = switch (state.status) {
      AutoGenStatus.idle => 'Idle',
      AutoGenStatus.generatingPrompt => 'Generating prompt...',
      AutoGenStatus.generatingImage => 'Generating image...',
      AutoGenStatus.waiting => 'Waiting...',
      AutoGenStatus.paused => 'Paused',
      AutoGenStatus.completed => 'Completed',
      AutoGenStatus.error => 'Error: ${state.errorMessage ?? "Unknown"}',
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
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
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
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}

class _CurrentPromptCard extends StatelessWidget {
  final String prompt;

  const _CurrentPromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
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
              Text('Current Prompt', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingSmall),
          Text(prompt, style: theme.textTheme.bodySmall),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
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
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}
