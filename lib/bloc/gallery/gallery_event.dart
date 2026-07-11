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

class GalleryCollectionCreated extends GalleryEvent {
  final String name;
  final String? description;

  const GalleryCollectionCreated(this.name, {this.description});

  @override
  List<Object?> get props => [name, description];
}

class GalleryCollectionRenamed extends GalleryEvent {
  final String collectionId;
  final String name;

  const GalleryCollectionRenamed(this.collectionId, this.name);

  @override
  List<Object?> get props => [collectionId, name];
}

class GalleryCollectionDeleted extends GalleryEvent {
  final String collectionId;

  const GalleryCollectionDeleted(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

class GalleryCollectionSelected extends GalleryEvent {
  final String? collectionId;

  const GalleryCollectionSelected(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

class GalleryImageHiddenToggled extends GalleryEvent {
  final String imageId;

  const GalleryImageHiddenToggled(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

class GalleryUnlockAttempted extends GalleryEvent {
  final String password;

  const GalleryUnlockAttempted(this.password);

  @override
  List<Object?> get props => [password];
}

class GalleryLockRequested extends GalleryEvent {}

enum GalleryFilter { all, favorites, collection }
