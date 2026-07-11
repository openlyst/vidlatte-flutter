import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/generated_image.dart';

class ImageDetailModal extends StatelessWidget {
  final GeneratedImage image;

  const ImageDetailModal({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge),
            child: image.localPath != null
                ? PhotoView(
                    imageProvider: FileImage(File(image.localPath!)),
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
                        image.prompt,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (image.loras.isNotEmpty) ...[
                            Icon(Icons.bolt, size: 12, color: ext.accent),
                            const SizedBox(width: 4),
                            Text(
                              '${image.loras.length} LoRAs',
                              style: TextStyle(color: ext.accent, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text('·', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              '${image.model.split('/').last} · ${image.width}x${image.height} · seed: ${image.seed}',
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
