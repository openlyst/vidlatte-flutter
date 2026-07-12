import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/theme.dart';
import '../../../i18n/app_strings.dart';

class Img2ImgInput extends StatefulWidget {
  final Uint8List? refImageBytes;
  final double denoise;
  final ValueChanged<Uint8List?> onImageChanged;
  final ValueChanged<double> onDenoiseChanged;

  const Img2ImgInput({
    super.key,
    this.refImageBytes,
    required this.denoise,
    required this.onImageChanged,
    required this.onDenoiseChanged,
  });

  @override
  State<Img2ImgInput> createState() => _Img2ImgInputState();
}

class _Img2ImgInputState extends State<Img2ImgInput> {
  final _picker = ImagePicker();

  void _pickFile() async {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.refImageBytes != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  widget.refImageBytes!,
                  height: 160,
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
          Row(
            children: [
              Text(s.denoiseStrength, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                '${(widget.denoise * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: ext.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: widget.denoise,
            min: 0.1,
            max: 1.0,
            divisions: 18,
            label: '${(widget.denoise * 100).round()}%',
            onChanged: widget.onDenoiseChanged,
          ),
          Text(
            s.denoiseHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ext.muted, fontSize: 11),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload, size: 18),
                  label: Text(s.uploadImage),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await context.push<Uint8List>('/gallery?pick=true');
                    if (result != null) {
                      widget.onImageChanged(result);
                    }
                  },
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: Text(s.pickFromGallery),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
