import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/autogen/autogen_bloc.dart';
import '../../../bloc/llm/llm_bloc.dart';
import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
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
                  onPressed: () => context.read<AutoGenBloc>().add(const AutoGenStopped()),
                  icon: const Icon(Icons.stop_circle, color: Colors.red),
                  label: const Text('Stop'),
                );
              }
              return TextButton.icon(
                onPressed: _canStart() ? _start : null,
                icon: const Icon(Icons.play_circle),
                label: const Text('Start'),
              );
            },
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                SizedBox(
                  width: 340,
                  child: _buildConfigPanel(),
                ),
                const VerticalDivider(width: 1),
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
      if (catalog != null && catalog.models.isNotEmpty && !catalog.models.contains(_imageModel)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$_imageModel" is not available on the selected server.')),
        );
        return;
      }
    }
    _syncConfig();
    context.read<AutoGenBloc>().add(const AutoGenStarted());
  }

  Widget _buildConfigPanel() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      children: [
        Text('Auto Image', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text('AI-powered automated image generation',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: ThemeConstants.spacingMedium),

        // Mode selection
        Text('Generation Mode', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        SegmentedButton<AutoGenMode>(
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

        // Topic (auto mode) or Base prompt (variation mode)
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
              style: Theme.of(context).textTheme.bodySmall),
        ] else ...[
          TextField(
            controller: _basePromptController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Base Prompt',
              hintText: 'Paste your prompt here. The AI will create variations...',
              isDense: true,
            ),
            onChanged: (v) => _basePrompt = v,
          ),
          const SizedBox(height: 4),
          Text('The AI will vary style, lighting, and details while preserving your core content',
              style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: ThemeConstants.spacingMedium),

        // Must include tags
        TextField(
          controller: _mustIncludeController,
          decoration: const InputDecoration(
            labelText: 'Must Include Tags',
            hintText: 'e.g., red hair, specific pose...',
            isDense: true,
          ),
          onChanged: (v) => _mustIncludeTags = v,
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),

        // Max images
        Row(
          children: [
            Text('Max Images', style: Theme.of(context).textTheme.labelLarge),
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
        const SizedBox(height: ThemeConstants.spacingMedium),

        // LLM Server
        BlocBuilder<LlmBloc, LlmState>(
          builder: (context, state) {
            if (state.servers.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No LLM servers configured. Add one in Settings.'),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LLM Server', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLlmServerId ?? state.servers.first.id,
                  decoration: const InputDecoration(isDense: true),
                  items: state.servers
                      .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
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
                  Text('LLM Model', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
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
            );
          },
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),

        // Image Server & Model
        BlocBuilder<ServersBloc, ServersState>(
          builder: (context, state) {
            if (state.servers.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No ComfyUI servers configured. Add one in Settings.'),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Image Server', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedImageServerId ?? state.defaultServer?.id,
                  decoration: const InputDecoration(isDense: true),
                  items: state.servers
                      .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                      .toList(),
                  onChanged: (id) {
                    setState(() => _selectedImageServerId = id);
                    if (id != null) {
                      context.read<ServersBloc>().add(ServerModelsFetchRequested(id));
                    }
                  },
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                if (_selectedImageServerId != null) ...[
                  Text('Image Model', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _imageModel.isEmpty ? null : _imageModel,
                    decoration: const InputDecoration(isDense: true),
                    items: (state.catalogs[_selectedImageServerId]?.models ?? [])
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.replaceAll('.safetensors', '').replaceAll('_', ' ')),
                            ))
                        .toList(),
                    onChanged: (id) => setState(() => _imageModel = id ?? ''),
                  ),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  // LoRAs
                  if ((state.catalogs[_selectedImageServerId]?.loras ?? []).isNotEmpty) ...[
                    Text('LoRAs', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 160),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: (state.catalogs[_selectedImageServerId]?.loras ?? [])
                            .map((lora) {
                          final name = lora.split('/').last;
                          return CheckboxListTile(
                            dense: true,
                            title: Text(name, overflow: TextOverflow.ellipsis),
                            value: _selectedLoras.contains(lora),
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildOutputPanel() {
    return BlocBuilder<AutoGenBloc, AutoGenState>(
      builder: (context, state) {
        if (state.images.isEmpty && state.status != AutoGenStatus.generatingPrompt) {
          return EmptyState(
            icon: Icons.auto_awesome_outlined,
            title: 'Auto Image',
            message: 'Configure settings and press Start to begin automated generation.',
            action: isWide(context)
                ? null
                : FilledButton.icon(
                    onPressed: _canStart() ? _start : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Generation'),
                  ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Status bar
            SliverToBoxAdapter(
              child: _StatusBar(state: state),
            ),
            // Current prompt
            if (state.currentPrompt.isNotEmpty)
              SliverToBoxAdapter(
                child: _CurrentPromptCard(prompt: state.currentPrompt),
              ),
            // Image grid
            if (state.images.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AutoImageCard(image: state.images[index]),
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

class _StatusBar extends StatelessWidget {
  final AutoGenState state;

  const _StatusBar({required this.state});

  @override
  Widget build(BuildContext context) {
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
      _ => Theme.of(context).colorScheme.secondary,
    };

    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      child: Row(
        children: [
          if (state.isRunning)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(statusText, style: Theme.of(context).textTheme.bodyMedium)),
          Text('${state.generatedCount}/${state.maxImages ?? "∞"}',
              style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _CurrentPromptCard extends StatelessWidget {
  final String prompt;

  const _CurrentPromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_snippet, size: 16, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 4),
                Text('Current Prompt', style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 4),
            Text(prompt, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _AutoImageCard extends StatelessWidget {
  final AutoGenImage image;

  const _AutoImageCard({required this.image});

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: Icon(Icons.broken_image, size: 32)),
              ),
            )
          else
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (image.status == ImageStatus.pending || image.status == ImageStatus.processing)
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
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
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
