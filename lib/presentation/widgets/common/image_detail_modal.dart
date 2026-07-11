import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../config/constants.dart';
import '../../../data/models/generated_image.dart';

class ImageDetailModal extends StatelessWidget {
  final GeneratedImage image;

  const ImageDetailModal({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge),
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  )
                : Container(
                    color: theme.colorScheme.surface,
                    child: const Center(child: Icon(Icons.broken_image, size: 64)),
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
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
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${image.model} · ${image.width}x${image.height} · seed: ${image.seed}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
