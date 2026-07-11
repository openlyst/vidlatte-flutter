import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../data/models/comfy_server.dart';

class GenerationControls extends StatelessWidget {
  final List<String> models;
  final List<String> loras;
  final int maxLoras;
  final String selectedModel;
  final List<String> selectedLoras;
  final Creativity creativity;
  final int? customSteps;
  final bool? customHiresFix;
  final int width;
  final int height;
  final List<ComfyServer> servers;
  final String selectedServerId;

  final ValueChanged<String> onModelChanged;
  final ValueChanged<List<String>> onLorasChanged;
  final ValueChanged<Creativity> onCreativityChanged;
  final ValueChanged<int?> onStepsChanged;
  final ValueChanged<bool?> onHiresFixChanged;
  final ValueChanged<(int, int)> onDimensionsChanged;
  final ValueChanged<String> onServerChanged;

  const GenerationControls({
    super.key,
    required this.models,
    required this.loras,
    required this.maxLoras,
    required this.selectedModel,
    required this.selectedLoras,
    required this.creativity,
    required this.customSteps,
    required this.customHiresFix,
    required this.width,
    required this.height,
    required this.servers,
    required this.selectedServerId,
    required this.onModelChanged,
    required this.onLorasChanged,
    required this.onCreativityChanged,
    required this.onStepsChanged,
    required this.onHiresFixChanged,
    required this.onDimensionsChanged,
    required this.onServerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ServerSelector(
          servers: servers,
          selectedId: selectedServerId,
          onChanged: onServerChanged,
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),
        _ModelSelector(
          models: models,
          selectedModel: selectedModel,
          onChanged: onModelChanged,
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),
        if (loras.isNotEmpty) ...[
          _LoraSelector(
            loras: loras,
            selectedLoras: selectedLoras,
            maxLoras: maxLoras,
            onChanged: onLorasChanged,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
        ],
        _CreativitySelector(
          creativity: creativity,
          onChanged: onCreativityChanged,
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),
        _AdvancedControls(
          customSteps: customSteps,
          customHiresFix: customHiresFix,
          width: width,
          height: height,
          onStepsChanged: onStepsChanged,
          onHiresFixChanged: onHiresFixChanged,
          onDimensionsChanged: onDimensionsChanged,
        ),
      ],
    );
  }
}

class _ServerSelector extends StatelessWidget {
  final List<ComfyServer> servers;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const _ServerSelector({
    required this.servers,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (servers.length <= 1) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Server', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ThemeConstants.spacingSmall),
        DropdownButtonFormField<String>(
          initialValue: selectedId,
          decoration: const InputDecoration(hintText: 'Select server'),
          items: servers.map((s) {
            return DropdownMenuItem(value: s.id, child: Text(s.name));
          }).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}

class _ModelSelector extends StatelessWidget {
  final List<String> models;
  final String selectedModel;
  final ValueChanged<String> onChanged;

  const _ModelSelector({
    required this.models,
    required this.selectedModel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Model', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ThemeConstants.spacingSmall),
        DropdownButtonFormField<String>(
          initialValue: selectedModel.isEmpty ? null : selectedModel,
          decoration: InputDecoration(
            hintText: models.isEmpty ? 'Loading models...' : 'Select a model',
          ),
          items: models.map((m) {
            final name = m.split('/').last;
            return DropdownMenuItem(value: m, child: Text(name, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}

class _LoraSelector extends StatelessWidget {
  final List<String> loras;
  final List<String> selectedLoras;
  final int maxLoras;
  final ValueChanged<List<String>> onChanged;

  const _LoraSelector({
    required this.loras,
    required this.selectedLoras,
    required this.maxLoras,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('LoRAs', style: theme.textTheme.titleMedium),
            const SizedBox(width: ThemeConstants.spacingSmall),
            Text(
              '${selectedLoras.length}/$maxLoras',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        Wrap(
          spacing: ThemeConstants.spacingSmall,
          runSpacing: ThemeConstants.spacingSmall,
          children: loras.map((lora) {
            final selected = selectedLoras.contains(lora);
            final name = lora.split('/').last;
            return FilterChip(
              label: Text(name),
              selected: selected,
              onSelected: (selected) {
                if (selected) {
                  if (selectedLoras.length < maxLoras) {
                    onChanged([...selectedLoras, lora]);
                  }
                } else {
                  onChanged(selectedLoras.where((l) => l != lora).toList());
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CreativitySelector extends StatelessWidget {
  final Creativity creativity;
  final ValueChanged<Creativity> onChanged;

  const _CreativitySelector({required this.creativity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Creativity (CFG)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ThemeConstants.spacingSmall),
        SegmentedButton<Creativity>(
          segments: Creativity.values.map((c) {
            return ButtonSegment(value: c, label: Text(c.label));
          }).toList(),
          selected: {creativity},
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}

class _AdvancedControls extends StatefulWidget {
  final int? customSteps;
  final bool? customHiresFix;
  final int width;
  final int height;
  final ValueChanged<int?> onStepsChanged;
  final ValueChanged<bool?> onHiresFixChanged;
  final ValueChanged<(int, int)> onDimensionsChanged;

  const _AdvancedControls({
    required this.customSteps,
    required this.customHiresFix,
    required this.width,
    required this.height,
    required this.onStepsChanged,
    required this.onHiresFixChanged,
    required this.onDimensionsChanged,
  });

  @override
  State<_AdvancedControls> createState() => _AdvancedControlsState();
}

class _AdvancedControlsState extends State<_AdvancedControls> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Text('Advanced', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: ThemeConstants.spacingMedium),
          _DimensionSelector(
            width: widget.width,
            height: widget.height,
            onChanged: widget.onDimensionsChanged,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          _StepsSelector(
            customSteps: widget.customSteps,
            onChanged: widget.onStepsChanged,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          SwitchListTile(
            title: const Text('Hires Fix'),
            subtitle: const Text('Upscale by 1.5x after generation'),
            value: widget.customHiresFix ?? false,
            onChanged: (v) => widget.onHiresFixChanged(v),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ],
    );
  }
}

class _DimensionSelector extends StatelessWidget {
  final int width;
  final int height;
  final ValueChanged<(int, int)> onChanged;

  const _DimensionSelector({
    required this.width,
    required this.height,
    required this.onChanged,
  });

  static const _presets = [
    (512, 512, '512 × 512'),
    (768, 768, '768 × 768'),
    (1024, 1024, '1024 × 1024'),
    (768, 1024, '768 × 1024'),
    (1024, 768, '1024 × 768'),
    (1024, 1536, '1024 × 1536'),
    (1536, 1024, '1536 × 1024'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dimensions', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: ThemeConstants.spacingSmall),
        Wrap(
          spacing: ThemeConstants.spacingSmall,
          runSpacing: ThemeConstants.spacingSmall,
          children: _presets.map((preset) {
            final ($w, $h, label) = preset;
            final selected = width == $w && height == $h;
            return FilterChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => onChanged(($w, $h)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StepsSelector extends StatelessWidget {
  final int? customSteps;
  final ValueChanged<int?> onChanged;

  const _StepsSelector({required this.customSteps, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Steps (${customSteps ?? 'server default'})', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: (customSteps ?? ComfyConstants.defaultSteps).toDouble(),
          min: ComfyConstants.minSteps.toDouble(),
          max: ComfyConstants.maxSteps.toDouble(),
          divisions: ComfyConstants.maxSteps - 1,
          label: '${customSteps ?? ComfyConstants.defaultSteps}',
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
