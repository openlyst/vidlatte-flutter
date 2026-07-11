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
    );
  }

  @override
  List<Object?> get props => [
        allImages, filteredImages, collections, searchQuery,
        filter, selectedCollectionId, isLoading, hasPassword, isLocked,
      ];
}

const _sentinel = Object();
