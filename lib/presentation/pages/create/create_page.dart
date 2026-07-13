import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/autogen/autogen_bloc.dart';
import '../../../bloc/generation/generation_bloc.dart';
import '../../../bloc/prompt_history/prompt_history_bloc.dart';
import '../../../bloc/servers/servers_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/comfy_server.dart';
import '../../../data/models/generated_image.dart';
import '../../../services/comfyui_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/image_detail_modal.dart';
import '../../widgets/common/image_grid.dart';
import '../../widgets/create/auto_image_content.dart';
import '../../widgets/create/controlnet_input.dart';
import '../../widgets/create/generation_controls.dart';
import '../../widgets/create/img2img_input.dart';
import '../../widgets/create/prompt_input.dart';
import '../../widgets/create/progress_card.dart';
import '../../widgets/create/prompt_history_sheet.dart';
import '../../widgets/create/queue_card.dart';
import '../../../data/models/prompt_history_entry.dart';
import '../../../i18n/app_strings.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
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

  bool _loadedSettings = false;
  bool _isAutoImageMode = false;
  bool _isImg2Img = false;
  Uint8List? _refImageBytes;
  double _denoise = 0.5;
  bool _useControlNet = false;
  String? _controlnetModel;
  Uint8List? _controlImageBytes;
  double _controlnetStrength = 1.0;
  final _autoImageController = AutoImageController();

  void _onAutoImageChanged() {
    if (_isAutoImageMode) setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  void _loadSettings() {
    if (_loadedSettings) return;
    final settings = context.read<SettingsBloc>().state.settings;
    _loadedSettings = true;
    setState(() {
      _selectedModel = settings.lastModel;
      _selectedLoras = settings.lastLoras;
      _loraWeights = Map.from(settings.lastLoraWeights);
      _creativity = _parseCreativity(settings.lastCreativity);
      _customCfg = settings.lastCustomCfg;
      _customSteps = settings.lastCustomSteps;
      _customHiresFix = settings.lastHiresFix;
      _width = settings.lastWidth;
      _height = settings.lastHeight;
      _selectedServerId = settings.defaultServerId;
    });
    _promptController.text = settings.lastPrompt;
    _negativePromptController.text = settings.lastNegativePrompt;
  }

  Creativity _parseCreativity(String value) {
    switch (value) {
      case 'low':
        return Creativity.low;
      case 'high':
        return Creativity.high;
      case 'max':
        return Creativity.max;
      default:
        return Creativity.normal;
    }
  }

  @override
  void dispose() {
    _persistSettings();
    _promptController.dispose();
    _negativePromptController.dispose();
    super.dispose();
  }

  void _persistSettings() {
    try {
      final bloc = context.read<SettingsBloc>();
      final updated = bloc.state.settings.copyWith(
        lastModel: _selectedModel,
        lastLoras: _selectedLoras,
        lastLoraWeights: _loraWeights,
        lastCreativity: _creativity.name,
        lastCustomCfg: _customCfg,
        lastCustomSteps: _customSteps,
        lastHiresFix: _customHiresFix,
        lastWidth: _width,
        lastHeight: _height,
        lastPrompt: _promptController.text.trim(),
        lastNegativePrompt: _negativePromptController.text.trim(),
      );
      bloc.add(SettingsUpdated(updated));
    } catch (_) {}
  }

  Future<void> _showPromptHistory() async {
    final result = await showModalBottomSheet<PromptHistoryEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const PromptHistorySheet(),
    );
    if (result != null && mounted) {
      setState(() {
        _promptController.text = result.prompt;
        _negativePromptController.text = result.negativePrompt ?? '';
      });
    }
  }

  Future<void> _generate() async {
    final serversState = context.read<ServersBloc>().state;
    ComfyServer? server;
    if (_selectedServerId != null) {
      server = serversState.servers.where((s) => s.id == _selectedServerId).firstOrNull;
    }
    server ??= serversState.defaultServer ?? (serversState.servers.isNotEmpty ? serversState.servers.first : null);

    final s = AppStrings.of(context);
    if (server == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.comfyNoServerError)),
      );
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.enterPrompt)),
      );
      return;
    }

    final catalog = serversState.catalogs[server.id];
    if (_selectedModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.selectModel)),
      );
      return;
    }

    if (catalog != null && catalog.models.isNotEmpty && !catalog.models.contains(_selectedModel)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.modelNotAvailableRaw(_selectedModel, server.name))),
      );
      return;
    }

    _persistSettings();

    context.read<PromptHistoryBloc>().add(PromptHistoryEntryAdded(
          prompt: _promptController.text.trim(),
          negativePrompt: _negativePromptController.text.trim().isEmpty
              ? null
              : _negativePromptController.text.trim(),
          model: _selectedModel,
          loras: _selectedLoras,
        ));

    String? refFilename;
    String? refSubfolder;
    String? refType;

    String? controlnetModel;
    String? controlImageFilename;
    String? controlImageSubfolder;
    String? controlImageType;

    if (_isImg2Img && _refImageBytes != null) {
      try {
        final comfy = ComfyService();
        final uploaded = await comfy.uploadImage(
          server,
          _refImageBytes!,
          'vidlatte_ref_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        refFilename = uploaded.filename;
        refSubfolder = uploaded.subfolder;
        refType = uploaded.type;
        comfy.dispose();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
        return;
      }
    }

    if (_useControlNet && _controlnetModel != null && _controlImageBytes != null) {
      try {
        final comfy = ComfyService();
        final uploaded = await comfy.uploadImage(
          server,
          _controlImageBytes!,
          'vidlatte_control_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        controlImageFilename = uploaded.filename;
        controlImageSubfolder = uploaded.subfolder;
        controlImageType = uploaded.type;
        controlnetModel = _controlnetModel;
        comfy.dispose();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Control image upload failed: $e')),
          );
        }
        return;
      }
    }

    if (!mounted) return;

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
          refImageFilename: refFilename,
          refImageSubfolder: refSubfolder,
          refImageType: refType,
          denoise: _denoise,
          controlnetModel: controlnetModel,
          controlImageFilename: controlImageFilename,
          controlImageSubfolder: controlImageSubfolder,
          controlImageType: controlImageType,
          controlnetStrength: _controlnetStrength,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= ThemeConstants.tabletBreakpoint;
    final ext = Theme.of(context).extension<AppColors>()!;
    final s = AppStrings.of(context);

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (prev, curr) => !_loadedSettings && (curr.settings.lastModel.isNotEmpty || curr.settings.lastPrompt.isNotEmpty),
      listener: (context, state) => _loadSettings(),
      child: Scaffold(
      appBar: AppBar(
        title: Text(_isAutoImageMode ? s.autoImageTitle : s.createTitle),
        actions: [
          if (!_isAutoImageMode) ...[
            IconButton(
              icon: const Icon(Icons.explore_outlined),
              tooltip: s.browseModelsLoras,
              onPressed: () => context.go('/browse'),
            ),
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: s.promptHistoryTooltip,
              onPressed: _showPromptHistory,
            ),
            IconButton(
              icon: const Icon(Icons.brush),
              tooltip: s.inpaint,
              onPressed: () => context.push('/inpaint'),
            ),
            IconButton(
              icon: const Icon(Icons.bolt_outlined),
              tooltip: s.autoImageTooltip,
              onPressed: () => setState(() => _isAutoImageMode = true),
            ),
          ] else ...[
            BlocBuilder<AutoGenBloc, AutoGenState>(
              builder: (context, state) {
                if (state.isRunning) {
                  return TextButton.icon(
                    onPressed: () => _autoImageController.stop(),
                    icon: const Icon(Icons.stop_circle, color: Colors.red),
                    label: Text(s.stop),
                  );
                }
                return TextButton.icon(
                  onPressed: _autoImageController.canStart
                      ? () => _autoImageController.start()
                      : null,
                  icon: Icon(Icons.play_circle,
                      color: _autoImageController.canStart ? ext.accent : ext.muted),
                  label: Text(s.start,
                      style: TextStyle(
                          color: _autoImageController.canStart ? ext.accent : ext.muted)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: s.backToCreate,
              onPressed: () => setState(() => _isAutoImageMode = false),
            ),
          ],
        ],
      ),
      body: _isAutoImageMode
          ? AutoImageContent(
              controller: _autoImageController,
              onCanStartChanged: _onAutoImageChanged,
            )
          : BlocBuilder<ServersBloc, ServersState>(
              builder: (context, serversState) {
                if (serversState.servers.isEmpty) {
                  return EmptyState(
                    icon: Icons.dns_outlined,
                    title: s.noComfyServer,
                    message: s.noComfyServerMsg,
                  );
                }

                final server = _selectedServerId != null
                    ? serversState.servers.where((s) => s.id == _selectedServerId).firstOrNull
                    : null;
                final effectiveServer = server ?? serversState.defaultServer ?? serversState.servers.first;
                final catalog = serversState.catalogs[effectiveServer.id];

                if (catalog == null) {
                  context.read<ServersBloc>().add(ServerModelsFetchRequested(effectiveServer.id));
                }

                return BlocBuilder<GenerationBloc, GenerationState>(
                  builder: (context, genState) {
                    if (isWide) {
                      return _wideLayout(context, genState, serversState, effectiveServer, catalog);
                    }
                    return _narrowLayout(context, genState, serversState, effectiveServer, catalog);
                  },
                );
              },
            ),
      ),
    );
  }

  Widget _buildConfigPanel(
    BuildContext context,
    GenerationState genState,
    ServersState serversState,
    ComfyServer server,
    dynamic catalog,
  ) {
    final visibleLoras = serversState.visibleLorasFor(server.id);
    final triggerWords = serversState.triggerWordsFor(server.id);
    final isGenerating = genState.status == GenerationStatus.generating;
    final s = AppStrings.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PromptInput(
          controller: _promptController,
          negativeController: _negativePromptController,
          maxLength: ComfyConstants.maxPromptLength,
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        _buildModeToggle(context),
        if (_isImg2Img) ...[
          const SizedBox(height: ThemeConstants.spacingSmall),
          Img2ImgInput(
            refImageBytes: _refImageBytes,
            denoise: _denoise,
            onImageChanged: (bytes) => setState(() => _refImageBytes = bytes),
            onDenoiseChanged: (v) => setState(() => _denoise = v),
          ),
        ],
        const SizedBox(height: ThemeConstants.spacingSmall),
        _buildControlNetToggle(context),
        if (_useControlNet) ...[
          const SizedBox(height: ThemeConstants.spacingSmall),
          ControlNetInput(
            controlnetModels: catalog?.controlnets as List<String>? ?? [],
            selectedModel: _controlnetModel,
            controlImageBytes: _controlImageBytes,
            strength: _controlnetStrength,
            onModelChanged: (m) => setState(() => _controlnetModel = m),
            onImageChanged: (bytes) => setState(() => _controlImageBytes = bytes),
            onStrengthChanged: (v) => setState(() => _controlnetStrength = v),
            onRefreshModels: () => context.read<ServersBloc>().add(ServerModelsFetchRequested(server.id)),
          ),
        ],
        const SizedBox(height: ThemeConstants.spacingMedium),
        GenerationControls(
          models: catalog?.models as List<String>? ?? [],
          loras: visibleLoras,
          triggerWords: triggerWords,
          maxLoras: server.maxLoras,
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
          selectedServerId: server.id,
          onModelChanged: (m) => setState(() => _selectedModel = m),
          onLorasChanged: (l) => setState(() => _selectedLoras = l),
          onLoraWeightsChanged: (w) => setState(() => _loraWeights = w),
          onCreativityChanged: (c) => setState(() => _creativity = c),
          onCfgChanged: (v) => setState(() => _customCfg = v),
          onStepsChanged: (s) => setState(() => _customSteps = s),
          onHiresFixChanged: (h) => setState(() => _customHiresFix = h),
          onDimensionsChanged: (dims) => setState(() { _width = dims.$1; _height = dims.$2; }),
          onServerChanged: (id) => setState(() {
            _selectedServerId = id;
            _selectedModel = '';
            _selectedLoras = [];
            _loraWeights = {};
          }),
          onRefreshModels: () => context.read<ServersBloc>().add(ServerModelsFetchRequested(server.id)),
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
            label: Text(isGenerating ? s.addToQueue : s.generate),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),
        ..._buildActiveJobs(genState),
      ],
    );
  }

  Widget _narrowLayout(
    BuildContext context,
    GenerationState genState,
    ServersState serversState,
    ComfyServer server,
    dynamic catalog,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ThemeConstants.spacingMedium,
        ThemeConstants.spacingMedium,
        ThemeConstants.spacingMedium,
        ThemeConstants.bottomNavTotal,
      ),
      children: [
        _buildConfigPanel(context, genState, serversState, server, catalog),
        const SizedBox(height: ThemeConstants.spacingLarge),
        ..._buildResults(context, genState),
      ],
    );
  }

  Widget _wideLayout(
    BuildContext context,
    GenerationState genState,
    ServersState serversState,
    ComfyServer server,
    dynamic catalog,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 400,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              ThemeConstants.spacingMedium,
              ThemeConstants.spacingMedium,
              ThemeConstants.spacingMedium,
              ThemeConstants.bottomNavTotal,
            ),
            children: [
              _buildConfigPanel(context, genState, serversState, server, catalog),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _buildResultsArea(context, genState),
        ),
      ],
    );
  }

  List<Widget> _buildActiveJobs(GenerationState state) {
    final widgets = <Widget>[];
    final s = AppStrings.of(context);

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
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: ThemeConstants.spacingSmall, bottom: 4),
        child: Row(
          children: [
            Icon(Icons.queue_music, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              '${s.queue} (${state.queue.length})',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ));
      for (var i = 0; i < state.queue.length; i++) {
        final job = state.queue[i];
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
          child: QueueCard(
            job: job,
            position: i + 1,
            onCancel: () => context.read<GenerationBloc>().add(GenerationCancelled(job.id)),
          ),
        ));
      }
    }

    return widgets;
  }

  List<Widget> _buildResults(BuildContext context, GenerationState state) {
    final s = AppStrings.of(context);
    if (state.images.isEmpty && state.activeJobs.isEmpty) {
      return [
        const SizedBox(height: ThemeConstants.spacingXXLarge),
        EmptyState(
          icon: Icons.image_outlined,
          title: s.noImagesYet,
          message: s.noImagesYetMsg,
        ),
      ];
    }
    return [
      if (state.images.isNotEmpty) ...[
        Text(s.results, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: ThemeConstants.spacingSmall),
        ImageGrid(
          images: state.images,
          onTap: (image) => _showImageDetail(context, image),
          onFavorite: (image) {
            context.read<GenerationBloc>().add(GenerationImageFavoriteToggled(image.id));
          },
          onDelete: (image) {
            context.read<GenerationBloc>().add(GenerationImageDeleted(image.id));
          },
        ),
      ],
    ];
  }

  Widget _buildResultsArea(BuildContext context, GenerationState state) {
    final s = AppStrings.of(context);
    if (state.images.isEmpty && state.activeJobs.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.image_outlined,
          title: s.noImagesYet,
          message: s.noImagesYetMsg,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      children: [
        if (state.images.isNotEmpty) ...[
          Text(s.results, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: ThemeConstants.spacingSmall),
          ImageGrid(
            images: state.images,
            onTap: (image) => _showImageDetail(context, image),
            onFavorite: (image) {
              context.read<GenerationBloc>().add(GenerationImageFavoriteToggled(image.id));
            },
            onDelete: (image) {
              context.read<GenerationBloc>().add(GenerationImageDeleted(image.id));
            },
          ),
        ],
      ],
    );
  }

  void _showImageDetail(BuildContext context, GeneratedImage image) {
    showDialog(
      context: context,
      builder: (_) => ImageDetailModal(image: image),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    final s = AppStrings.of(context);
    final ext = Theme.of(context).extension<AppColors>()!;
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          icon: const Icon(Icons.text_fields, size: 18),
          label: Text(s.txt2img),
        ),
        ButtonSegment(
          value: true,
          icon: const Icon(Icons.image, size: 18),
          label: Text(s.img2img),
        ),
      ],
      selected: {_isImg2Img},
      onSelectionChanged: (selection) {
        setState(() {
          _isImg2Img = selection.first;
          if (!_isImg2Img) _refImageBytes = null;
        });
      },
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -3, vertical: -2),
      ),
    );
  }

  Widget _buildControlNetToggle(BuildContext context) {
    final s = AppStrings.of(context);
    return SwitchListTile(
      title: Text(s.controlnet, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(s.controlnetHint, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
      value: _useControlNet,
      onChanged: (v) => setState(() {
        _useControlNet = v;
        if (!v) {
          _controlnetModel = null;
          _controlImageBytes = null;
        }
      }),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
