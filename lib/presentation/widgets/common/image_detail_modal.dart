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

    final serversState = context.read<ServersBloc>().state;
    final catalog = serversState.catalogs[server.id];
    final upscaleModels = catalog?.upscaleModels ?? [];

    if (upscaleModels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noUpscaleModels)),
      );
      return;
    }

    String? selectedModel;
    if (upscaleModels.length == 1) {
      selectedModel = upscaleModels.first;
    } else {
      selectedModel = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.upscaleModel),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: upscaleModels.length,
              itemBuilder: (ctx, i) {
                final m = upscaleModels[i];
                return ListTile(
                  title: Text(m.split('/').last),
                  onTap: () => Navigator.of(ctx).pop(m),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
          ],
        ),
      );
    }

    if (selectedModel == null) return;

    setState(() {
      _processing = true;
      _processMsg = s.upscaleImage;
    });

    try {
      final comfy = ComfyService();
      final result = await comfy.upscale(
        server,
        filename: widget.image.comfyFilename!,
        subfolder: widget.image.comfySubfolder ?? '',
        type: widget.image.comfyType ?? 'output',
        model: selectedModel,
      );
      comfy.dispose();

      if (result.success && result.imageBytes != null) {
        _saveResult(result);
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
    } catch (e) {
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
