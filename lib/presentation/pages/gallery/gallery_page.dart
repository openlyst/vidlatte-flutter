import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../bloc/gallery/gallery_bloc.dart';
import '../../../config/constants.dart';
import '../../../data/models/generated_image.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/image_detail_modal.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(
              left: ThemeConstants.spacingMedium,
              right: ThemeConstants.spacingMedium,
              bottom: ThemeConstants.spacingSmall,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => context.read<GalleryBloc>().add(GallerySearchChanged(q)),
              decoration: InputDecoration(
                hintText: 'Search by prompt, model, or LoRA...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<GalleryBloc>().add(GallerySearchChanged(''));
                        },
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          if (state.allImages.isEmpty) {
            return const EmptyState(
              icon: Icons.photo_library_outlined,
              title: 'Gallery is Empty',
              message: 'Generated images will appear here automatically.',
            );
          }

          final width = MediaQuery.sizeOf(context).width;
          final crossAxisCount = width >= ThemeConstants.desktopBreakpoint
              ? 4
              : width >= ThemeConstants.tabletBreakpoint
                  ? 3
                  : 2;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingMedium,
                    vertical: ThemeConstants.spacingSmall,
                  ),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: state.filter == GalleryFilter.all,
                        onSelected: (_) => context
                            .read<GalleryBloc>()
                            .add(const GalleryFilterChanged(GalleryFilter.all)),
                      ),
                      const SizedBox(width: ThemeConstants.spacingSmall),
                      FilterChip(
                        label: const Text('Favorites'),
                        selected: state.filter == GalleryFilter.favorites,
                        onSelected: (_) => context
                            .read<GalleryBloc>()
                            .add(const GalleryFilterChanged(GalleryFilter.favorites)),
                      ),
                      const Spacer(),
                      Text('${state.filteredImages.length} images',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              if (state.filteredImages.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: 'No Results',
                    message: 'Try a different search or filter.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  sliver: SliverMasonryGrid(
                    gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _GalleryImageCard(
                        image: state.filteredImages[index],
                        onTap: (img) => _showImage(context, img),
                        onFavorite: (img) => context
                            .read<GalleryBloc>()
                            .add(GalleryImageFavoriteToggled(img.id)),
                        onDelete: (img) => _confirmDelete(context, img),
                      ),
                      childCount: state.filteredImages.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showImage(BuildContext context, GeneratedImage image) {
    showDialog(
      context: context,
      builder: (_) => ImageDetailModal(image: image),
    );
  }

  void _confirmDelete(BuildContext context, GeneratedImage image) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('This will permanently remove the image from your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GalleryBloc>().add(GalleryImageDeleted(image.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _GalleryImageCard extends StatelessWidget {
  final GeneratedImage image;
  final void Function(GeneratedImage) onTap;
  final void Function(GeneratedImage) onFavorite;
  final void Function(GeneratedImage) onDelete;

  const _GalleryImageCard({
    required this.image,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTap(image),
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
                  _ActionButton(
                    icon: image.isFavorite ? Icons.favorite : Icons.favorite_border,
                    onTap: () => onFavorite(image),
                    color: image.isFavorite ? Colors.red : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    onTap: () => onDelete(image),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({required this.icon, required this.onTap, required this.color});

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
