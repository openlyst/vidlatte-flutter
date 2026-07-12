import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/comfy_server.dart';
import '../../../i18n/app_strings.dart';
import 'lora_picker_dialog.dart';

class GenerationControls extends StatelessWidget {
  final List<String> models;
  final List<String> loras;
  final Map<String, String> triggerWords;
  final int maxLoras;
  final String selectedModel;
  final List<String> selectedLoras;
  final Creativity creativity;
  final double? customCfg;
  final int? customSteps;
  final bool? customHiresFix;
  final int width;
  final int height;
  final List<ComfyServer> servers;
  final String selectedServerId;

  final ValueChanged<String> onModelChanged;
  final ValueChanged<List<String>> onLorasChanged;
  final ValueChanged<Creativity> onCreativityChanged;
  final ValueChanged<double?> onCfgChanged;
  final ValueChanged<int?> onStepsChanged;
  final ValueChanged<bool?> onHiresFixChanged;
  final ValueChanged<(int, int)> onDimensionsChanged;
  final ValueChanged<String> onServerChanged;

  const GenerationControls({
    super.key,
    required this.models,
    required this.loras,
    this.triggerWords = const {},
    required this.maxLoras,
    required this.selectedModel,
    required this.selectedLoras,
    required this.creativity,
    this.customCfg,
    required this.customSteps,
    required this.customHiresFix,
    required this.width,
    required this.height,
    required this.servers,
    required this.selectedServerId,
    required this.onModelChanged,
    required this.onLorasChanged,
    required this.onCreativityChanged,
    required this.onCfgChanged,
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
        if (servers.length > 1) ...[
          _ServerSelector(
            servers: servers,
            selectedId: selectedServerId,
            onChanged: onServerChanged,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
        ],
        _ModelSelector(
          models: models,
          selectedModel: selectedModel,
          onChanged: onModelChanged,
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),
        if (loras.isNotEmpty) ...[
          _LoraSummary(
            loras: loras,
            triggerWords: triggerWords,
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
          customCfg: customCfg,
          customSteps: customSteps,
          customHiresFix: customHiresFix,
          width: width,
          height: height,
          onCfgChanged: onCfgChanged,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.of(context).server, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ThemeConstants.spacingSmall),
        DropdownButtonFormField<String>(
          initialValue: selectedId,
          decoration: InputDecoration(hintText: AppStrings.of(context).selectServer),
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
        Text(AppStrings.of(context).model, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ThemeConstants.spacingSmall),
        DropdownButtonFormField<String>(
          initialValue: selectedModel.isEmpty ? null : selectedModel,
          decoration: InputDecoration(
            hintText: models.isEmpty ? AppStrings.of(context).loadingModels : AppStrings.of(context).selectModelHint,
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

class _LoraSummary extends StatelessWidget {
  final List<String> loras;
  final Map<String, String> triggerWords;
  final List<String> selectedLoras;
  final int maxLoras;
  final ValueChanged<List<String>> onChanged;

  const _LoraSummary({
    required this.loras,
    required this.triggerWords,
    required this.selectedLoras,
    required this.maxLoras,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppStrings.of(context).loras, style: theme.textTheme.titleMedium),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: selectedLoras.isNotEmpty
                    ? ext.accent.withValues(alpha: 0.15)
                    : ext.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${selectedLoras.length}/$maxLoras',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selectedLoras.isNotEmpty ? ext.accent : ext.muted,
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _openPicker(context),
              icon: const Icon(Icons.tune, size: 18),
              label: Text(AppStrings.of(context).select),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        if (selectedLoras.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppStrings.of(context).noLorasSelected,
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedLoras.map((lora) {
                final name = lora.split('/').last;
                final hasTriggers = (triggerWords[lora] ?? '').isNotEmpty;
                return Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 12)),
                      if (hasTriggers) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.bolt, size: 12, color: ext.accent),
                      ],
                    ],
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => onChanged(selectedLoras.where((l) => l != lora).toList()),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _openPicker(BuildContext context) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => LoraPickerDialog(
        loras: loras,
        triggerWords: triggerWords,
        selectedLoras: selectedLoras,
        maxLoras: maxLoras,
      ),
    );
    if (result != null) {
      onChanged(result);
    }
  }
}

class _CreativitySelector extends StatelessWidget {
  final Creativity creativity;
  final ValueChanged<Creativity> onChanged;

  const _CreativitySelector({required this.creativity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final index = creativity.index;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppStrings.of(context).creativityCfg, style: theme.textTheme.titleMedium),
            const Spacer(),
            Text(
              '${creativity.label} · ${creativity.cfgScale}',
              style: theme.textTheme.bodySmall?.copyWith(color: ext.accent, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Slider(
          value: index.toDouble(),
          min: 0,
          max: (Creativity.values.length - 1).toDouble(),
          divisions: Creativity.values.length - 1,
          label: creativity.label,
          onChanged: (v) => onChanged(Creativity.values[v.round()]),
        ),
      ],
    );
  }
}

class _AdvancedControls extends StatefulWidget {
  final double? customCfg;
  final int? customSteps;
  final bool? customHiresFix;
  final int width;
  final int height;
  final ValueChanged<double?> onCfgChanged;
  final ValueChanged<int?> onStepsChanged;
  final ValueChanged<bool?> onHiresFixChanged;
  final ValueChanged<(int, int)> onDimensionsChanged;

  const _AdvancedControls({
    this.customCfg,
    required this.customSteps,
    required this.customHiresFix,
    required this.width,
    required this.height,
    required this.onCfgChanged,
    required this.onStepsChanged,
    required this.onHiresFixChanged,
    required this.onDimensionsChanged,
  });

  @override
  State<_AdvancedControls> createState() => _AdvancedControlsState();
}

class _AdvancedControlsState extends State<_AdvancedControls> {
  bool _expanded = false;
  late final TextEditingController _cfgController;
  bool _useCustomCfg = false;

  @override
  void initState() {
    super.initState();
    _useCustomCfg = widget.customCfg != null;
    _cfgController = TextEditingController(
      text: widget.customCfg != null ? widget.customCfg.toString() : '',
    );
  }

  @override
  void dispose() {
    _cfgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Text(AppStrings.of(context).advanced, style: Theme.of(context).textTheme.titleMedium),
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
          SwitchListTile(
            title: Text(AppStrings.of(context).customCfg),
            subtitle: Text(_useCustomCfg
                ? AppStrings.of(context).customCfgSubtitleOn
                : AppStrings.of(context).customCfgSubtitleOff),
            value: _useCustomCfg,
            onChanged: (v) {
              setState(() => _useCustomCfg = v);
              if (v) {
                final parsed = double.tryParse(_cfgController.text);
                widget.onCfgChanged(parsed ?? 7.0);
              } else {
                widget.onCfgChanged(null);
              }
            },
            contentPadding: EdgeInsets.zero,
          ),
          if (_useCustomCfg) ...[
            TextField(
              controller: _cfgController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                labelText: AppStrings.of(context).cfgScale,
                hintText: 'e.g. 7.0',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) {
                  widget.onCfgChanged(parsed);
                }
              },
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
          ],
          _StepsSelector(
            customSteps: widget.customSteps,
            onChanged: widget.onStepsChanged,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          SwitchListTile(
            title: Text(AppStrings.of(context).hiresFix),
            subtitle: Text(AppStrings.of(context).hiresFixSubtitle),
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
        Text(AppStrings.of(context).dimensions, style: Theme.of(context).textTheme.titleSmall),
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
        Text('${AppStrings.of(context).stepsWithDefault} (${customSteps ?? 'server default'})', style: Theme.of(context).textTheme.titleSmall),
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
