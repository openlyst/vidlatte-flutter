import 'package:flutter_bloc/flutter_bloc.dart';

export 'gallery_event.dart';
export 'gallery_state.dart';

import '../../data/models/collection.dart';
import '../../data/models/generated_image.dart';
import '../../services/storage_service.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final StorageService _storage;

  GalleryBloc({required this._storage})
      : super(const GalleryState()) {
    on<GalleryLoadRequested>(_onLoad);
    on<GallerySearchChanged>(_onSearch);
    on<GalleryFilterChanged>(_onFilter);
    on<GalleryImageFavoriteToggled>(_onFavoriteToggled);
    on<GalleryImageDeleted>(_onImageDeleted);
    on<GalleryImageCollectionChanged>(_onCollectionChanged);
    on<GalleryCollectionCreated>(_onCollectionCreated);
    on<GalleryCollectionRenamed>(_onCollectionRenamed);
    on<GalleryCollectionDeleted>(_onCollectionDeleted);
    on<GalleryCollectionSelected>(_onCollectionSelected);
  }

  void _onLoad(GalleryLoadRequested event, Emitter<GalleryState> emit) {
    final images = _storage.getImages();
    final collections = _storage.getCollections();
    emit(state.copyWith(
      allImages: images,
      collections: collections,
      filteredImages: _applyFilter(images, state.filter, state.searchQuery, state.selectedCollectionId),
      isLoading: false,
    ));
  }

  void _onSearch(GallerySearchChanged event, Emitter<GalleryState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      filteredImages: _applyFilter(state.allImages, state.filter, event.query, state.selectedCollectionId),
    ));
  }

  void _onFilter(GalleryFilterChanged event, Emitter<GalleryState> emit) {
    final collectionId = event.filter == GalleryFilter.collection
        ? state.selectedCollectionId
        : null;
    emit(state.copyWith(
      filter: event.filter,
      selectedCollectionId: collectionId,
      filteredImages: _applyFilter(state.allImages, event.filter, state.searchQuery, collectionId),
    ));
  }

  Future<void> _onFavoriteToggled(GalleryImageFavoriteToggled event, Emitter<GalleryState> emit) async {
    await _storage.toggleFavorite(event.imageId);
    final images = _storage.getImages();
    emit(state.copyWith(
      allImages: images,
      filteredImages: _applyFilter(images, state.filter, state.searchQuery, state.selectedCollectionId),
    ));
  }

  Future<void> _onImageDeleted(GalleryImageDeleted event, Emitter<GalleryState> emit) async {
    await _storage.deleteImage(event.imageId);
    final images = _storage.getImages();
    emit(state.copyWith(
      allImages: images,
      filteredImages: _applyFilter(images, state.filter, state.searchQuery, state.selectedCollectionId),
    ));
  }

  Future<void> _onCollectionChanged(GalleryImageCollectionChanged event, Emitter<GalleryState> emit) async {
    await _storage.setImageCollection(event.imageId, event.collectionId);
    final images = _storage.getImages();
    emit(state.copyWith(
      allImages: images,
      filteredImages: _applyFilter(images, state.filter, state.searchQuery, state.selectedCollectionId),
    ));
  }

  Future<void> _onCollectionCreated(GalleryCollectionCreated event, Emitter<GalleryState> emit) async {
    final now = DateTime.now();
    final collection = Collection(
      id: now.millisecondsSinceEpoch.toString(),
      name: event.name,
      description: event.description,
      createdAt: now,
      updatedAt: now,
    );
    await _storage.saveCollection(collection);
    final collections = _storage.getCollections();
    emit(state.copyWith(collections: collections));
  }

  Future<void> _onCollectionRenamed(GalleryCollectionRenamed event, Emitter<GalleryState> emit) async {
    final collections = state.collections;
    final target = collections.where((c) => c.id == event.collectionId).firstOrNull;
    if (target == null) return;
    await _storage.saveCollection(target.copyWith(
      name: event.name,
      updatedAt: DateTime.now(),
    ));
    final updated = _storage.getCollections();
    emit(state.copyWith(collections: updated));
  }

  Future<void> _onCollectionDeleted(GalleryCollectionDeleted event, Emitter<GalleryState> emit) async {
    await _storage.deleteCollection(event.collectionId);
    final collections = _storage.getCollections();
    final images = _storage.getImages();
    final filter = state.selectedCollectionId == event.collectionId
        ? GalleryFilter.all
        : state.filter;
    final selectedId = state.selectedCollectionId == event.collectionId
        ? null
        : state.selectedCollectionId;
    emit(state.copyWith(
      collections: collections,
      allImages: images,
      filter: filter,
      selectedCollectionId: selectedId,
      filteredImages: _applyFilter(images, filter, state.searchQuery, selectedId),
    ));
  }

  void _onCollectionSelected(GalleryCollectionSelected event, Emitter<GalleryState> emit) {
    final filter = event.collectionId != null ? GalleryFilter.collection : GalleryFilter.all;
    emit(state.copyWith(
      selectedCollectionId: event.collectionId,
      filter: filter,
      filteredImages: _applyFilter(state.allImages, filter, state.searchQuery, event.collectionId),
    ));
  }

  List<GeneratedImage> _applyFilter(
    List<GeneratedImage> images,
    GalleryFilter filter,
    String query,
    String? collectionId,
  ) {
    var result = images;

    switch (filter) {
      case GalleryFilter.favorites:
        result = result.where((img) => img.isFavorite).toList();
      case GalleryFilter.collection:
        if (collectionId != null) {
          result = result.where((img) => img.collectionId == collectionId).toList();
        }
      case GalleryFilter.all:
        break;
    }

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      result = result.where((img) {
        return img.prompt.toLowerCase().contains(lowerQuery) ||
            img.model.toLowerCase().contains(lowerQuery) ||
            img.loras.any((l) => l.toLowerCase().contains(lowerQuery));
      }).toList();
    }

    return result;
  }
}
