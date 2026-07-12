import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/theme.dart';
import '../../../i18n/app_strings.dart';

class ControlNetInput extends StatefulWidget {
  final List<String> controlnetModels;
  final String? selectedModel;
  final Uint8List? controlImageBytes;
  final double strength;
  final ValueChanged<String?> onModelChanged;
  final ValueChanged<Uint8List?> onImageChanged;
  final ValueChanged<double> onStrengthChanged;

  const ControlNetInput({
    super.key,
    required this.controlnetModels,
    this.selectedModel,
    this.controlImageBytes,
    required this.strength,
    required this.onModelChanged,
    required this.onImageChanged,
    required this.onStrengthChanged,
  });

  @override
  State<ControlNetInput> createState() => _ControlNetInputState();
}

class _ControlNetInputState extends State<ControlNetInput> {
  final _picker = ImagePicker();

  void _pickImage() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final bytes = await result.readAsBytes();
      widget.onImageChanged(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final ext = Theme.of(context).extension<AppColors>()!;

    if (widget.controlnetModels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          s.noControlnetModels,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ext.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.selectedModel,
          decoration: InputDecoration(
            labelText: s.controlnetModel,
            isDense: true,
            prefixIcon: const Icon(Icons.account_tree, size: 18),
          ),
          items: widget.controlnetModels
              .map((m) => DropdownMenuItem(value: m, child: Text(m.split('/').last, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: widget.onModelChanged,
        ),
        const SizedBox(height: 8),
        if (widget.controlImageBytes != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  widget.controlImageBytes!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filled(
                  onPressed: () => widget.onImageChanged(null),
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    minimumSize: const Size(28, 28),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ] else
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload, size: 18),
            label: Text(s.selectControlImage),
          ),
        if (widget.selectedModel != null && widget.controlImageBytes != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(s.controlnetStrength, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                '${(widget.strength * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: ext.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: widget.strength,
            min: 0.0,
            max: 2.0,
            divisions: 20,
            label: '${(widget.strength * 100).round()}%',
            onChanged: widget.onStrengthChanged,
          ),
        ],
      ],
    );
  }
}
