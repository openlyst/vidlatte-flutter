import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/generated_image.dart';
import '../../../i18n/app_strings.dart';
import '../../../services/comfyui_service.dart';
import '../../../services/storage_service.dart';

class ImageDetailModal extends StatefulWidget {
  final GeneratedImage image;

  const ImageDetailModal({super.key, required this.image});

  @override
  State<ImageDetailModal> createState() => _ImageDetailModalState();
}

class _ImageDetailModalState extends State<ImageDetailModal> {
  bool _processing = false;
  String? _processMsg;

  void _faceRestore() async {
    final s = AppStrings.of(context);
    final server = _getServer();
    if (server == null) return;

    setState(() {
      _processing = true;
      _processMsg = s.faceRestore;
    });

    try {
      final comfy = ComfyService();
      final result = await comfy.faceRestore(
        server,
        filename: widget.image.comfyFilename!,
        subfolder: widget.image.comfySubfolder ?? '',
        type: widget.image.comfyType ?? 'output',
      );
      comfy.dispose();

      if (result.success && result.imageBytes != null) {
        _saveResult(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.faceRestoreDone)),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.faceRestoreFailed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.faceRestoreFailed)),
        );
      }
    }

    if (mounted) setState(() => _processing = false);
  }

  void _upscale() async {
    final s = AppStrings.of(context);
    final server = _getServer();
    if (server == null) return;

    var upscaleModels = context.read<ServersBloc>().state.catalogs[server.id]?.upscaleModels ?? [];

    if (upscaleModels.isEmpty) {
      setState(() {
        _processing = true;
        _processMsg = s.upscaleImage;
      });
      try {
        final comfy = ComfyService();
        final catalog = await comfy.getModels(server);
        comfy.dispose();
        upscaleModels = catalog.upscaleModels;
        if (!mounted) return;
        context.read<ServersBloc>().add(ServerModelsFetchRequested(server.id));
      } catch (_) {
        if (mounted) setState(() => _processing = false);
      }
      if (upscaleModels.isEmpty) {
        if (mounted) {
          setState(() => _processing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.noUpscaleModels)),
          );
        }
        return;
      }
      if (mounted) setState(() => _processing = false);
    }

    final result = await showDialog<_UpscaleDialogResult>(
      context: context,
      builder: (ctx) => _UpscaleDialog(
        models: upscaleModels,
        server: server,
        title: s.upscaleImage,
        modelLabel: s.upscaleModel,
        scaleLabel: s.upscaleScale,
      ),
    );

    if (result == null) return;

    setState(() {
      _processing = true;
      _processMsg = s.upscaleImage;
    });

    try {
      final comfy = ComfyService();
      final res = await comfy.upscale(
        server,
        filename: widget.image.comfyFilename!,
        subfolder: widget.image.comfySubfolder ?? '',
        type: widget.image.comfyType ?? 'output',
        model: result.model,
        scale: result.scale,
      );
      comfy.dispose();

      if (res.success && res.imageBytes != null) {
        _saveResult(res);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.upscaleDone)),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.upscaleFailed)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.upscaleFailed)),
        );
      }
    }

    if (mounted) setState(() => _processing = false);
  }

  dynamic _getServer() {
    final serversState = context.read<ServersBloc>().state;
    final server = serversState.servers.where((s) => s.url == widget.image.serverUrl).firstOrNull;
    if (server == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).comfyNoServerError)),
      );
      return null;
    }
    return server;
  }

  void _saveResult(ComfyJobResult result) async {
    final storage = context.read<StorageService>();
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    final filename = 'post_$uuid.png';
    final localPath = await storage.saveImageFile(result.imageBytes!, filename);

    final newImage = widget.image.copyWith(
      id: uuid,
      localPath: localPath,
      comfyFilename: result.filename,
      comfySubfolder: result.subfolder,
      comfyType: result.type,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );
    await storage.saveImage(newImage);
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final s = AppStrings.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge),
            child: widget.image.localPath != null
                ? PhotoView(
                    imageProvider: FileImage(File(widget.image.localPath!)),
                    backgroundDecoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge),
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  )
                : Container(
                    color: ext.surfaceElevated,
                    child: Center(child: Icon(Icons.broken_image, size: 64, color: ext.muted)),
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          if (widget.image.comfyFilename != null)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _processing ? null : _faceRestore,
                          icon: const Icon(Icons.face_retouching_natural, color: Colors.white, size: 20),
                          tooltip: s.faceRestore,
                        ),
                        IconButton(
                          onPressed: _processing ? null : _upscale,
                          icon: const Icon(Icons.hd_outlined, color: Colors.white, size: 20),
                          tooltip: s.upscaleImage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_processing)
            Positioned.fill(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            _processMsg ?? s.processing,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.processingMsg,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(ThemeConstants.borderRadiusLarge),
                bottomRight: Radius.circular(ThemeConstants.borderRadiusLarge),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(ThemeConstants.borderRadiusLarge),
                      bottomRight: Radius.circular(ThemeConstants.borderRadiusLarge),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.image.prompt,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (widget.image.loras.isNotEmpty) ...[
                            Icon(Icons.bolt, size: 12, color: ext.accent),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.image.loras.length} ${s.lorasCount}',
                              style: TextStyle(color: ext.accent, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text('·', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              s.imageMeta(widget.image.model.split('/').last, widget.image.width, widget.image.height, widget.image.seed),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpscaleDialogResult {
  final String model;
  final double scale;

  const _UpscaleDialogResult({required this.model, required this.scale});
}

class _UpscaleDialog extends StatefulWidget {
  final List<String> models;
  final dynamic server;
  final String title;
  final String modelLabel;
  final String scaleLabel;

  const _UpscaleDialog({
    required this.models,
    required this.server,
    required this.title,
    required this.modelLabel,
    required this.scaleLabel,
  });

  @override
  State<_UpscaleDialog> createState() => _UpscaleDialogState();
}

class _UpscaleDialogState extends State<_UpscaleDialog> {
  late List<String> _models;
  late String _selectedModel;
  double _scale = 2.0;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _models = widget.models;
    _selectedModel = _models.first;
  }

  Future<void> _refreshModels() async {
    setState(() => _refreshing = true);
    try {
      final comfy = ComfyService();
      final catalog = await comfy.getModels(widget.server);
      comfy.dispose();
      final fresh = catalog.upscaleModels;
      if (fresh.isNotEmpty) {
        setState(() {
          _models = fresh;
          _selectedModel = fresh.first;
        });
      }
    } catch (_) {}
    setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.modelLabel,
                  style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              IconButton(
                onPressed: _refreshing ? null : _refreshModels,
                icon: _refreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedModel,
            isExpanded: true,
            items: _models.map((m) {
              return DropdownMenuItem(
                value: m,
                child: Text(m.split('/').last, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedModel = v!),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(widget.scaleLabel,
                  style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Text(
                '${_scale.toStringAsFixed(1)}x',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _scale,
            min: 1.0,
            max: 8.0,
            divisions: 14,
            label: '${_scale.toStringAsFixed(1)}x',
            onChanged: (v) => setState(() => _scale = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _UpscaleDialogResult(model: _selectedModel, scale: _scale),
          ),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
