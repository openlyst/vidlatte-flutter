import 'package:equatable/equatable.dart';

import '../../data/models/collection.dart';
import '../../data/models/generated_image.dart';
import 'gallery_event.dart';

class GalleryState extends Equatable {
  final List<GeneratedImage> allImages;
  final List<GeneratedImage> filteredImages;
  final List<Collection> collections;
  final String searchQuery;
  final GalleryFilter filter;
  final String? selectedCollectionId;
  final bool isLoading;
  final bool hasPassword;
  final bool isLocked;
  final bool isSelectMode;
  final Set<String> selectedImageIds;

  const GalleryState({
    this.allImages = const [],
    this.filteredImages = const [],
    this.collections = const [],
    this.searchQuery = '',
    this.filter = GalleryFilter.all,
    this.selectedCollectionId,
    this.isLoading = false,
    this.hasPassword = false,
    this.isLocked = false,
    this.isSelectMode = false,
    this.selectedImageIds = const {},
  });

  GalleryState copyWith({
    List<GeneratedImage>? allImages,
    List<GeneratedImage>? filteredImages,
    List<Collection>? collections,
    String? searchQuery,
    GalleryFilter? filter,
    Object? selectedCollectionId = _sentinel,
    bool? isLoading,
    bool? hasPassword,
    bool? isLocked,
    bool? isSelectMode,
    Set<String>? selectedImageIds,
  }) {
    return GalleryState(
      allImages: allImages ?? this.allImages,
      filteredImages: filteredImages ?? this.filteredImages,
      collections: collections ?? this.collections,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      selectedCollectionId: identical(selectedCollectionId, _sentinel)
          ? this.selectedCollectionId
          : selectedCollectionId as String?,
      isLoading: isLoading ?? this.isLoading,
      hasPassword: hasPassword ?? this.hasPassword,
      isLocked: isLocked ?? this.isLocked,
      isSelectMode: isSelectMode ?? this.isSelectMode,
      selectedImageIds: selectedImageIds ?? this.selectedImageIds,
    );
  }

  @override
  List<Object?> get props => [
        allImages, filteredImages, collections, searchQuery,
        filter, selectedCollectionId, isLoading, hasPassword, isLocked,
        isSelectMode, selectedImageIds,
      ];
}

const _sentinel = Object();
