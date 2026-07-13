import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../bloc/servers/servers_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/generated_image.dart';
import '../../../i18n/app_strings.dart';
import '../../../services/comfyui_service.dart';
import '../../../services/storage_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/create/mask_editor.dart';

class InpaintPage extends StatefulWidget {
  const InpaintPage({super.key});

  @override
  State<InpaintPage> createState() => _InpaintPageState();
}

class _InpaintPageState extends State<InpaintPage> {
  Uint8List? _imageBytes;
  double _brushSize = 30;
  bool _isEraser = false;
  double _denoise = 0.75;
  String _selectedModel = '';
  bool _loadedSettings = false;
  final _promptController = TextEditingController();
  final _negativeController = TextEditingController();
  final _maskKey = GlobalKey<MaskEditorState>();
  final _picker = ImagePicker();
  bool _uploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedSettings) {
      _loadedSettings = true;
      final settings = context.read<SettingsBloc>().state.settings;
      if (settings.lastModel.isNotEmpty) {
        _selectedModel = settings.lastModel;
      }
    }
  }

  void _pickImage() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final bytes = await result.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  void _generate() async {
    if (_imageBytes == null) {
      debugPrint('[inpaint] _generate called with no image bytes');
      return;
    }
    final s = AppStrings.of(context);

    final serversState = context.read<ServersBloc>().state;
    if (serversState.servers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.comfyNoServerError)),
      );
      return;
    }
    final server = serversState.servers.first;

    if (_selectedModel.isEmpty) {
      debugPrint('[inpaint] no model selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.selectModel)),
        );
      }
      return;
    }

    final maskState = _maskKey.currentState;
    if (maskState == null) {
      debugPrint('[inpaint] MaskEditor state is null — widget not mounted yet');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mask editor not ready, try again')),
        );
      }
      return;
    }

    setState(() => _uploading = true);

    try {
      final comfy = ComfyService();
      final ts = DateTime.now().millisecondsSinceEpoch;

      debugPrint('[inpaint] uploading source image');
      final uploadedImage = await comfy.uploadImage(
        server,
        _imageBytes!,
        'vidlatte_inpaint_$ts.png',
      );
      debugPrint('[inpaint] uploaded image: ${uploadedImage.filename}');

      debugPrint('[inpaint] exporting mask');
      final maskBytes = await maskState.exportMask();
      debugPrint('[inpaint] mask bytes length: ${maskBytes.length}');

      if (maskBytes.isEmpty) {
        debugPrint('[inpaint] mask is empty — image may still be loading');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image still loading, try again in a moment')),
          );
        }
        comfy.dispose();
        if (mounted) setState(() => _uploading = false);
        return;
      }

      debugPrint('[inpaint] uploading mask');
      final uploadedMask = await comfy.uploadImage(
        server,
        maskBytes,
        'vidlatte_mask_$ts.png',
      );
      debugPrint('[inpaint] uploaded mask: ${uploadedMask.filename}');

      debugPrint('[inpaint] submitting inpaint workflow');
      final result = await comfy.inpaint(
        server,
        imageFilename: uploadedImage.filename,
        imageSubfolder: uploadedImage.subfolder,
        imageType: uploadedImage.type,
        maskFilename: uploadedMask.filename,
        maskSubfolder: uploadedMask.subfolder,
        maskType: uploadedMask.type,
        prompt: _promptController.text.trim(),
        negativePrompt: _negativeController.text.trim(),
        model: _selectedModel,
        denoise: _denoise,
      );
      debugPrint('[inpaint] result success=${result.success} hasBytes=${result.imageBytes != null}');
      comfy.dispose();

      if (result.success && result.imageBytes != null) {
        final storage = context.read<StorageService>();
        final uuid = DateTime.now().millisecondsSinceEpoch.toString();
        final filename = 'inpaint_$uuid.png';
        final localPath = await storage.saveImageFile(result.imageBytes!, filename);

        final newImage = GeneratedImage(
          id: uuid,
          prompt: _promptController.text.trim(),
          negativePrompt: _negativeController.text.trim(),
          model: _selectedModel,
          loras: const [],
          loraWeights: const {},
          width: 0,
          height: 0,
          seed: 0,
          comfyFilename: result.filename,
          comfySubfolder: result.subfolder,
          comfyType: result.type,
          localPath: localPath,
          serverUrl: server.url,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        );
        await storage.saveImage(newImage);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.inpaint)),
          );
          context.go('/gallery');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.faceRestoreFailed)),
        );
      }
    } catch (e, st) {
      debugPrint('[inpaint] error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inpaint failed: $e')),
        );
      }
    }

    if (mounted) setState(() => _uploading = false);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _negativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final ext = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.inpaint),
        actions: [
          if (_imageBytes != null)
            IconButton(
              onPressed: _uploading ? null : _generate,
              icon: _uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              tooltip: s.generate,
            ),
        ],
      ),
      body: _imageBytes == null
          ? EmptyState(
              icon: Icons.brush,
              title: s.noInpaintImage,
              message: s.inpaintHint,
              action: FilledButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text(s.selectInpaintImage),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingMedium,
                    vertical: ThemeConstants.spacingSmall,
                  ),
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: s.enterPrompt,
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                ),
                BlocBuilder<ServersBloc, ServersState>(
                  builder: (context, serversState) {
                    final server = serversState.servers.isNotEmpty
                        ? serversState.servers.first
                        : null;
                    final models = server != null
                        ? (serversState.catalogs[server.id]?.models ?? [])
                        : <String>[];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.spacingMedium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(s.model, style: Theme.of(context).textTheme.labelMedium),
                              const Spacer(),
                              IconButton(
                                onPressed: server != null
                                    ? () => context.read<ServersBloc>().add(ServerModelsFetchRequested(server.id))
                                    : null,
                                icon: const Icon(Icons.refresh, size: 20),
                                tooltip: 'Refresh',
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedModel.isEmpty ? null : _selectedModel,
                            decoration: InputDecoration(
                              hintText: models.isEmpty ? s.loadingModels : s.selectModelHint,
                              isDense: true,
                            ),
                            items: models.map((m) {
                              return DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis));
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedModel = v ?? ''),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.spacingMedium,
                    ),
                    child: MaskEditor(
                      exportKey: _maskKey,
                      imageBytes: _imageBytes!,
                      brushSize: _brushSize,
                      isEraser: _isEraser,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.brush, size: 18, color: ext.muted),
                          Expanded(
                            child: Slider(
                              value: _brushSize,
                              min: 5,
                              max: 100,
                              divisions: 19,
                              label: '${_brushSize.round()}',
                              onChanged: (v) => setState(() => _brushSize = v),
                            ),
                          ),
                          Text('${_brushSize.round()}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      Row(
                        children: [
                          FilterChip(
                            label: Text(s.maskEraser),
                            selected: _isEraser,
                            onSelected: (v) => setState(() => _isEraser = v),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _maskKey.currentState?.clearMask(),
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: Text(s.clearMask),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.swap_horiz, size: 18),
                            label: Text(s.selectInpaintImage),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(s.inpaintDenoise, style: Theme.of(context).textTheme.bodySmall),
                          const Spacer(),
                          Text(
                            '${(_denoise * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: ext.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _denoise,
                        min: 0.1,
                        max: 1.0,
                        divisions: 18,
                        label: '${(_denoise * 100).round()}%',
                        onChanged: (v) => setState(() => _denoise = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
