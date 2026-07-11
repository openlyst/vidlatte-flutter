import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../bloc/gallery/gallery_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/collection.dart';
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
  bool _unlockAttempted = false;

  @override
  void initState() {
    super.initState();
    context.read<GalleryBloc>().add(GalleryLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: BlocListener<GalleryBloc, GalleryState>(
        listenWhen: (prev, curr) => _unlockAttempted,
        listener: (context, state) {
          if (!_unlockAttempted) return;
          if (state.isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incorrect password')),
            );
          }
          _unlockAttempted = false;
        },
        child: BlocBuilder<GalleryBloc, GalleryState>(
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
              if (state.filter == GalleryFilter.collection && state.selectedCollectionId == null)
                _buildPlaylistsList(context, ext, state)
              else if (state.filter == GalleryFilter.hidden) ...[
                SliverToBoxAdapter(child: _buildHiddenBanner(context, ext, state)),
                if (state.filteredImages.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.lock_outline,
                      title: 'No Hidden Images',
                      message: 'Hide images from the card menu to see them here.',
                    ),
                  )
                else
                  _buildImageGrid(context, ext, state, crossAxisCount),
              ]
              else ...[
                if (state.filter == GalleryFilter.collection && state.selectedCollectionId != null)
                  SliverToBoxAdapter(child: _buildCollectionBanner(context, ext, state)),
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
                  _buildImageGrid(context, ext, state, crossAxisCount),
              ],
            ],
          );
        },
        ),
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
          const SizedBox(width: ThemeConstants.spacingSmall),
          _FilterSegment(
            label: 'Playlists',
            icon: Icons.playlist_play_rounded,
            selected: state.filter == GalleryFilter.collection,
            onTap: () => context
                .read<GalleryBloc>()
                .add(const GalleryCollectionSelected(null)),
            accent: ext.accent,
            border: ext.border,
            muted: ext.muted,
          ),
          const Spacer(),
          if (state.hasPassword)
            Padding(
              padding: const EdgeInsets.only(right: ThemeConstants.spacingSmall),
              child: _FilterSegment(
                label: state.isLocked ? 'Locked' : 'Unlocked',
                icon: state.isLocked
                    ? Icons.lock_outline
                    : Icons.lock_open_outlined,
                selected: !state.isLocked,
                onTap: () {
                  if (state.isLocked) {
                    _showUnlockDialog(context);
                  } else {
                    context.read<GalleryBloc>().add(GalleryLockRequested());
                  }
                },
                accent: ext.accent,
                border: ext.border,
                muted: ext.muted,
              ),
            ),
          Text(
            '${state.filteredImages.length} images',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionBanner(BuildContext context, AppColors ext, GalleryState state) {
    final collection = state.collections.where((c) => c.id == state.selectedCollectionId).firstOrNull;
    if (collection == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: 4,
      ),
      child: Row(
        children: [
          Icon(Icons.playlist_play, size: 18, color: ext.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              collection.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ext.accent,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18, color: ext.muted),
            onPressed: () => _showRenameDialog(context, collection),
            tooltip: 'Rename',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: ext.muted),
            onPressed: () => _confirmDeleteCollection(context, collection),
            tooltip: 'Delete playlist',
          ),
          IconButton(
            icon: Icon(Icons.arrow_back, size: 18, color: ext.muted),
            onPressed: () => context
                .read<GalleryBloc>()
                .add(const GalleryCollectionSelected(null)),
            tooltip: 'Back to playlists',
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenBanner(BuildContext context, AppColors ext, GalleryState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: 4,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ext.surfaceElevated,
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          border: Border.all(color: ext.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: ext.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Locked',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ext.accent,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_back, size: 18, color: ext.muted),
                onPressed: () => context
                    .read<GalleryBloc>()
                    .add(const GalleryCollectionSelected(null)),
                tooltip: 'Back to playlists',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, AppColors ext, GalleryState state, int crossAxisCount) {
    return SliverPadding(
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
            collections: state.collections,
            isLocked: state.isLocked,
            onTap: (img) => _showImage(context, img),
            onFavorite: (img) => context
                .read<GalleryBloc>()
                .add(GalleryImageFavoriteToggled(img.id)),
            onHide: (img) => context
                .read<GalleryBloc>()
                .add(GalleryImageHiddenToggled(img.id)),
            onDelete: (img) => _confirmDelete(context, img),
            onAddToCollection: (img) => _showCollectionPicker(context, img, state.collections),
          ),
          childCount: state.filteredImages.length,
        ),
      ),
    );
  }

  Widget _buildPlaylistsList(BuildContext context, AppColors ext, GalleryState state) {
    final hasLocked = state.hasPassword;
    if (state.collections.isEmpty && !hasLocked) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.playlist_play,
          title: 'No Playlists',
          message: 'Create a playlist to organize your images.',
          action: FilledButton.icon(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('New Playlist'),
          ),
        ),
      );
    }

    final lockedCount = state.allImages.where((img) => img.isHidden).length;

    return SliverPadding(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                    side: BorderSide(color: ext.border, width: 0.8),
                  ),
                  leading: Icon(Icons.add, color: ext.accent),
                  title: Text('New Playlist', style: TextStyle(color: ext.accent, fontWeight: FontWeight.w600)),
                  onTap: () => _showCreateDialog(context),
                ),
              );
            }
            if (hasLocked && index == 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                  ),
                  tileColor: ext.surfaceElevated,
                  leading: Icon(Icons.lock_outline, color: ext.accent),
                  title: const Text('Locked', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('$lockedCount hidden image${lockedCount == 1 ? '' : 's'}'),
                  onTap: () {
                    if (state.isLocked) {
                      _showUnlockDialog(context);
                    } else {
                      context.read<GalleryBloc>().add(const GalleryFilterChanged(GalleryFilter.hidden));
                    }
                  },
                ),
              );
            }
            final collectionIndex = index - 1 - (hasLocked ? 1 : 0);
            final c = state.collections[collectionIndex];
            final count = state.allImages.where((img) => img.collectionId == c.id).length;
            return Padding(
              padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
                ),
                tileColor: ext.surfaceElevated,
                leading: Icon(Icons.playlist_play, color: ext.accent),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('$count image${count == 1 ? '' : 's'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 18, color: ext.muted),
                      onPressed: () => _showRenameDialog(context, c),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: ext.muted),
                      onPressed: () => _confirmDeleteCollection(context, c),
                    ),
                  ],
                ),
                onTap: () => context
                    .read<GalleryBloc>()
                    .add(GalleryCollectionSelected(c.id)),
              ),
            );
          },
          childCount: state.collections.length + 1 + (hasLocked ? 1 : 0),
        ),
      ),
    );
  }

  void _showPlaylistsPanel(BuildContext context, GalleryState state) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _PlaylistsPanel(
        collections: state.collections,
        allImages: state.allImages,
        selectedCollectionId: state.selectedCollectionId,
        onSelect: (id) {
          context.read<GalleryBloc>().add(GalleryCollectionSelected(id));
          Navigator.of(ctx).pop();
        },
        onCreate: () {
          Navigator.of(ctx).pop();
          _showCreateDialog(context);
        },
        onRename: (collection) {
          Navigator.of(ctx).pop();
          _showRenameDialog(context, collection);
        },
        onDelete: (collection) {
          Navigator.of(ctx).pop();
          _confirmDeleteCollection(context, collection);
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Playlist name',
            hintText: 'e.g. Portraits, Landscapes...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<GalleryBloc>().add(GalleryCollectionCreated(name));
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Collection collection) {
    final controller = TextEditingController(text: collection.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context
                    .read<GalleryBloc>()
                    .add(GalleryCollectionRenamed(collection.id, name));
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollection(BuildContext context, Collection collection) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text(
          'Delete "${collection.name}"? Images will remain in your gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GalleryBloc>().add(GalleryCollectionDeleted(collection.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCollectionPicker(
    BuildContext context,
    GeneratedImage image,
    List<Collection> collections,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          final currentCollections = state.collections;
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  child: Row(
                    children: [
                      Icon(Icons.playlist_add, size: 20, color: Theme.of(context).extension<AppColors>()!.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Add to playlist',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                if (state.hasPassword)
                  ListTile(
                    leading: Icon(
                      image.isHidden ? Icons.lock : Icons.lock_outline,
                      color: image.isHidden ? Theme.of(context).extension<AppColors>()!.accent : null,
                    ),
                    title: const Text('Locked'),
                    onTap: () {
                      context.read<GalleryBloc>().add(GalleryImageHiddenToggled(image.id));
                      Navigator.of(ctx).pop();
                    },
                  ),
                if (currentCollections.isEmpty && !state.hasPassword)
                  const Padding(
                    padding: EdgeInsets.all(ThemeConstants.spacingLarge),
                    child: Text('No playlists yet. Tap "New playlist" below to create one.'),
                  )
                else if (currentCollections.isNotEmpty) ...[
                  const Divider(height: 1),
                  ...currentCollections.map((c) {
                    final selected = c.id == image.collectionId;
                    return ListTile(
                      leading: Icon(
                        selected ? Icons.check_circle : Icons.playlist_play,
                        color: selected ? Theme.of(context).extension<AppColors>()!.accent : null,
                      ),
                      title: Text(c.name),
                      onTap: () {
                        context.read<GalleryBloc>().add(GalleryImageCollectionChanged(
                          image.id,
                          selected ? null : c.id,
                        ));
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                ],
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New playlist'),
                  onTap: () => _showCreateDialog(context),
                ),
              ],
            ),
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

  void _showUnlockDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, size: 22),
            SizedBox(width: 8),
            Text('Gallery Locked'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your password to view hidden images.'),
            const SizedBox(height: ThemeConstants.spacingMedium),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _unlockAttempted = true;
                context
                    .read<GalleryBloc>()
                    .add(GalleryUnlockAttempted(value));
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final password = controller.text;
              _unlockAttempted = true;
              context
                  .read<GalleryBloc>()
                  .add(GalleryUnlockAttempted(password));
              Navigator.of(ctx).pop();
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}

class _PlaylistsPanel extends StatelessWidget {
  final List<Collection> collections;
  final List<GeneratedImage> allImages;
  final String? selectedCollectionId;
  final void Function(String) onSelect;
  final VoidCallback onCreate;
  final void Function(Collection) onRename;
  final void Function(Collection) onDelete;

  const _PlaylistsPanel({
    required this.collections,
    required this.allImages,
    required this.selectedCollectionId,
    required this.onSelect,
    required this.onCreate,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            child: Row(
              children: [
                Icon(Icons.playlist_play, size: 22, color: ext.accent),
                const SizedBox(width: 8),
                Text('Playlists', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (collections.isEmpty)
            const Padding(
              padding: EdgeInsets.all(ThemeConstants.spacingXLarge),
              child: Text('No playlists yet. Tap "New" to create one.'),
            )
          else
            ...collections.map((c) {
              final count = allImages.where((img) => img.collectionId == c.id).length;
              final selected = c.id == selectedCollectionId;
              return ListTile(
                leading: Icon(
                  Icons.playlist_play,
                  color: selected ? ext.accent : ext.muted,
                ),
                title: Text(
                  c.name,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? ext.accent : null,
                  ),
                ),
                subtitle: Text('$count image${count == 1 ? '' : 's'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 18, color: ext.muted),
                      onPressed: () => onRename(c),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 18, color: ext.muted),
                      onPressed: () => onDelete(c),
                    ),
                  ],
                ),
                onTap: () => onSelect(c.id),
              );
            }),
          const SizedBox(height: ThemeConstants.spacingSmall),
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
  final List<Collection> collections;
  final bool isLocked;
  final void Function(GeneratedImage) onTap;
  final void Function(GeneratedImage) onFavorite;
  final void Function(GeneratedImage) onHide;
  final void Function(GeneratedImage) onDelete;
  final void Function(GeneratedImage) onAddToCollection;

  const _GalleryImageCard({
    required this.image,
    required this.collections,
    required this.isLocked,
    required this.onTap,
    required this.onFavorite,
    required this.onHide,
    required this.onDelete,
    required this.onAddToCollection,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: () => onTap(image),
      onLongPress: () => onAddToCollection(image),
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
                      icon: Icons.playlist_add,
                      onTap: () => onAddToCollection(image),
                      color: image.collectionId != null ? ext.accent : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    if (!isLocked) ...[
                      _ActionButton(
                        icon: image.isHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onTap: () => onHide(image),
                        color: image.isHidden ? ext.accent : Colors.white,
                      ),
                      const SizedBox(width: 4),
                    ],
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
