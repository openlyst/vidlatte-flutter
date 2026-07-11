import 'package:flutter_bloc/flutter_bloc.dart';

export 'gallery_event.dart';
export 'gallery_state.dart';

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
