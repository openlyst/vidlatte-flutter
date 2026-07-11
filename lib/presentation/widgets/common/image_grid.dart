import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../config/constants.dart';
import '../../../data/models/generated_image.dart';

class ImageGrid extends StatelessWidget {
  final List<GeneratedImage> images;
  final void Function(GeneratedImage) onTap;
  final void Function(GeneratedImage)? onFavorite;
  final void Function(GeneratedImage)? onDelete;
  final int crossAxisCount;

  const ImageGrid({
    super.key,
    required this.images,
    required this.onTap,
    this.onFavorite,
    this.onDelete,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final count = width >= ThemeConstants.desktopBreakpoint
        ? 4
        : width >= ThemeConstants.tabletBreakpoint
            ? 3
            : 2;

    return MasonryGridView.count(
      crossAxisCount: count,
      mainAxisSpacing: ThemeConstants.spacingSmall,
      crossAxisSpacing: ThemeConstants.spacingSmall,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return _ImageCard(
          image: image,
          onTap: () => onTap(image),
          onFavorite: onFavorite != null ? () => onFavorite!(image) : null,
          onDelete: onDelete != null ? () => onDelete!(image) : null,
        );
      },
    );
  }
}

class _ImageCard extends StatelessWidget {
  final GeneratedImage image;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const _ImageCard({
    required this.image,
    required this.onTap,
    this.onFavorite,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (image.localPath != null)
              Image.file(
                File(image.localPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
                ),
              )
            else
              Container(
                height: 200,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(child: Icon(Icons.image_outlined, size: 40)),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  if (onFavorite != null)
                    _IconButton(
                      icon: image.isFavorite ? Icons.favorite : Icons.favorite_border,
                      onTap: onFavorite!,
                      color: image.isFavorite ? Colors.red : Colors.white,
                    ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 4),
                    _IconButton(
                      icon: Icons.delete_outline,
                      onTap: onDelete!,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _IconButton({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
