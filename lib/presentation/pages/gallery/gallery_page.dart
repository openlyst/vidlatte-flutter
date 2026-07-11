import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../bloc/gallery/gallery_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
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
    final ext = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          if (state.allImages.isEmpty) {
            return CustomScrollView(
              slivers: [
                _buildHeader(context, ext, state),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: 'Gallery is Empty',
                    message: 'Generated images will appear here automatically.',
                  ),
                ),
              ],
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
              _buildHeader(context, ext, state),
              SliverToBoxAdapter(child: _buildFilterBar(context, ext, state)),
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
                  padding: const EdgeInsets.fromLTRB(
                    ThemeConstants.spacingMedium,
                    ThemeConstants.spacingSmall,
                    ThemeConstants.spacingMedium,
                    ThemeConstants.spacingLarge,
                  ),
                  sliver: SliverMasonryGrid(
                    gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                    ),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
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

  Widget _buildHeader(BuildContext context, AppColors ext, GalleryState state) {
    return SliverAppBar(
      expandedHeight: 132,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: ThemeConstants.spacingMedium,
          bottom: ThemeConstants.spacingSmall,
        ),
        title: const Text('Gallery'),
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ThemeConstants.spacingMedium,
              ThemeConstants.spacingLarge,
              ThemeConstants.spacingMedium,
              ThemeConstants.spacingXLarge,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (q) {
                context.read<GalleryBloc>().add(GallerySearchChanged(q));
                setState(() {});
              },
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search by prompt, model, or LoRA...',
                prefixIcon: Icon(Icons.search, color: ext.muted, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: ext.muted, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<GalleryBloc>()
                              .add(const GallerySearchChanged(''));
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, AppColors ext, GalleryState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: Row(
        children: [
          _FilterSegment(
            label: 'All',
            selected: state.filter == GalleryFilter.all,
            onTap: () => context
                .read<GalleryBloc>()
                .add(const GalleryFilterChanged(GalleryFilter.all)),
            accent: ext.accent,
            border: ext.border,
            muted: ext.muted,
          ),
          const SizedBox(width: ThemeConstants.spacingSmall),
          _FilterSegment(
            label: 'Favorites',
            icon: Icons.favorite_rounded,
            selected: state.filter == GalleryFilter.favorites,
            onTap: () => context
                .read<GalleryBloc>()
                .add(const GalleryFilterChanged(GalleryFilter.favorites)),
            accent: ext.accent,
            border: ext.border,
            muted: ext.muted,
          ),
          const Spacer(),
          Text(
            '${state.filteredImages.length} images',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
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
        content: const Text(
            'This will permanently remove the image from your device.'),
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

class _FilterSegment extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  final Color border;
  final Color muted;

  const _FilterSegment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.accent,
    required this.border,
    required this.muted,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: ThemeConstants.animationNormal,
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMedium,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.4) : border,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? accent : muted,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? accent : muted,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
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
    final ext = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: () => onTap(image),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: ext.border, width: 0.5),
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              if (image.localPath != null)
                Image.file(
                  File(image.localPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: ext.surfaceElevated,
                    child: Center(
                      child: Icon(Icons.broken_image_outlined,
                          size: 36, color: ext.muted),
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  color: ext.surfaceElevated,
                  child: Center(
                    child:
                        Icon(Icons.image_outlined, size: 36, color: ext.muted),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: ThemeConstants.spacingSmall,
                right: ThemeConstants.spacingSmall,
                child: Row(
                  children: [
                    _ActionButton(
                      icon: image.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      onTap: () => onFavorite(image),
                      color: image.isFavorite ? ext.accent : Colors.white,
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
              if (image.prompt.isNotEmpty)
                Positioned(
                  left: ThemeConstants.spacingSmall,
                  right: ThemeConstants.spacingSmall,
                  bottom: ThemeConstants.spacingSmall,
                  child: Text(
                    image.prompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          height: 1.3,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius:
                  BorderRadius.circular(ThemeConstants.borderRadiusSmall),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}
