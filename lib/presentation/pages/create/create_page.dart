import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/generation/generation_bloc.dart';
import '../../../bloc/servers/servers_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/comfy_server.dart';
import '../../../data/models/generated_image.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/image_detail_modal.dart';
import '../../widgets/common/image_grid.dart';
import '../../widgets/create/generation_controls.dart';
import '../../widgets/create/prompt_input.dart';
import '../../widgets/create/progress_card.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _promptController = TextEditingController();
  String _selectedModel = '';
  List<String> _selectedLoras = [];
  Creativity _creativity = Creativity.normal;
  double? _customCfg;
  int? _customSteps;
  bool? _customHiresFix;
  int _width = ComfyConstants.defaultWidth;
  int _height = ComfyConstants.defaultHeight;
  String? _selectedServerId;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = context.read<SettingsBloc>().state.settings;
    setState(() {
      _selectedModel = settings.lastModel;
      _selectedLoras = settings.lastLoras;
      _creativity = _parseCreativity(settings.lastCreativity);
      _customSteps = settings.lastCustomSteps;
      _customHiresFix = settings.lastHiresFix;
      _selectedServerId = settings.defaultServerId;
    });
    _promptController.text = '';
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
    _promptController.dispose();
    super.dispose();
  }

  void _persistSettings() {
    context.read<SettingsBloc>().add(LastModelChanged(_selectedModel));
    context.read<SettingsBloc>().add(LastLorasChanged(_selectedLoras));
    context.read<SettingsBloc>().add(LastCreativityChanged(_creativity.name));
    if (_customSteps != null) {
      context.read<SettingsBloc>().add(SettingsUpdated(
            context.read<SettingsBloc>().state.settings.copyWith(lastCustomSteps: _customSteps),
          ));
    }
    if (_customHiresFix != null) {
      context.read<SettingsBloc>().add(SettingsUpdated(
            context.read<SettingsBloc>().state.settings.copyWith(lastHiresFix: _customHiresFix),
          ));
    }
  }

  void _generate() {
    final serversState = context.read<ServersBloc>().state;
    ComfyServer? server;
    if (_selectedServerId != null) {
      server = serversState.servers.where((s) => s.id == _selectedServerId).firstOrNull;
    }
    server ??= serversState.defaultServer ?? (serversState.servers.isNotEmpty ? serversState.servers.first : null);

    if (server == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ErrorMessages.comfyNoServer)),
      );
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a prompt first.')),
      );
      return;
    }

    final catalog = serversState.catalogs[server.id];
    if (_selectedModel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a model first.')),
      );
      return;
    }

    if (catalog != null && catalog.models.isNotEmpty && !catalog.models.contains(_selectedModel)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$_selectedModel" is not available on ${server.name}. Select a model from the list.')),
      );
      return;
    }

    _persistSettings();

    context.read<GenerationBloc>().add(GenerationSubmitted(
          server: server,
          prompt: _promptController.text.trim(),
          model: _selectedModel,
          loras: _selectedLoras,
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= ThemeConstants.tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(title: const Text('Create')),
      body: BlocBuilder<ServersBloc, ServersState>(
        builder: (context, serversState) {
          if (serversState.servers.isEmpty) {
            return const EmptyState(
              icon: Icons.dns_outlined,
              title: 'No ComfyUI Server',
              message: 'Add a ComfyUI server in Settings to start generating images.',
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
    );
  }

  Widget _buildConfigPanel(
    BuildContext context,
    GenerationState genState,
    ServersState serversState,
    ComfyServer server,
    dynamic catalog,
  ) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final visibleLoras = serversState.visibleLorasFor(server.id);
    final triggerWords = serversState.triggerWordsFor(server.id);
    final isGenerating = genState.status == GenerationStatus.generating;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PromptInput(
          controller: _promptController,
          maxLength: ComfyConstants.maxPromptLength,
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms),
        const SizedBox(height: ThemeConstants.spacingMedium),
        GenerationControls(
          models: catalog?.models as List<String>? ?? [],
          loras: visibleLoras,
          triggerWords: triggerWords,
          maxLoras: server.maxLoras,
          selectedModel: _selectedModel,
          selectedLoras: _selectedLoras,
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
          onCreativityChanged: (c) => setState(() => _creativity = c),
          onCfgChanged: (v) => setState(() => _customCfg = v),
          onStepsChanged: (s) => setState(() => _customSteps = s),
          onHiresFixChanged: (h) => setState(() => _customHiresFix = h),
          onDimensionsChanged: (dims) => setState(() { _width = dims.$1; _height = dims.$2; }),
          onServerChanged: (id) => setState(() {
            _selectedServerId = id;
            _selectedModel = '';
            _selectedLoras = [];
          }),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms),
        const SizedBox(height: ThemeConstants.spacingLarge),
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGenerating
                    ? [ext.muted, ext.muted]
                    : [ext.accentGradientStart, ext.accentGradientEnd],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
              boxShadow: isGenerating
                  ? null
                  : [
                      BoxShadow(
                        color: ext.accent.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: FilledButton.icon(
              onPressed: isGenerating ? null : _generate,
              icon: isGenerating
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(isGenerating ? 'Generating...' : 'Generate'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms),
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
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
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
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
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
    return state.activeJobs.map((job) {
      return Padding(
        padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
        child: ProgressCard(job: job),
      );
    }).toList();
  }

  List<Widget> _buildResults(BuildContext context, GenerationState state) {
    if (state.images.isEmpty && state.activeJobs.isEmpty) {
      return [
        const SizedBox(height: ThemeConstants.spacingXXLarge),
        const EmptyState(
          icon: Icons.image_outlined,
          title: 'No Images Yet',
          message: 'Write a prompt and hit Generate to create your first image.',
        ),
      ];
    }
    return [
      if (state.images.isNotEmpty) ...[
        Text('Results', style: Theme.of(context).textTheme.titleLarge),
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
    if (state.images.isEmpty && state.activeJobs.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.image_outlined,
          title: 'No Images Yet',
          message: 'Write a prompt and hit Generate to create your first image.',
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      children: [
        if (state.images.isNotEmpty) ...[
          Text('Results', style: Theme.of(context).textTheme.titleLarge),
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
}
