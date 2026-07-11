import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();
  @override
  List<Object?> get props => [];
}

class GalleryLoadRequested extends GalleryEvent {}

class GallerySearchChanged extends GalleryEvent {
  final String query;

  const GallerySearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class GalleryFilterChanged extends GalleryEvent {
  final GalleryFilter filter;

  const GalleryFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class GalleryImageFavoriteToggled extends GalleryEvent {
  final String imageId;

  const GalleryImageFavoriteToggled(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

class GalleryImageDeleted extends GalleryEvent {
  final String imageId;

  const GalleryImageDeleted(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

class GalleryImageCollectionChanged extends GalleryEvent {
  final String imageId;
  final String? collectionId;

  const GalleryImageCollectionChanged(this.imageId, this.collectionId);

  @override
  List<Object?> get props => [imageId, collectionId];
}

enum GalleryFilter { all, favorites, collection }
