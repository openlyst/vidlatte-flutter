import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidlatte/bloc/gallery/gallery_bloc.dart';
import 'package:vidlatte/bloc/gallery/gallery_event.dart';
import 'package:vidlatte/bloc/gallery/gallery_state.dart';
import 'package:vidlatte/data/models/generated_image.dart';
import 'package:vidlatte/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService storage;

  final images = [
    GeneratedImage(
      id: 'img-1',
      prompt: 'a cat sitting on a chair',
      model: 'sd_xl.safetensors',
      isFavorite: true,
      createdAt: DateTime(2025, 1, 2),
    ),
    GeneratedImage(
      id: 'img-2',
      prompt: 'a dog running in the park',
      model: 'sd_15.safetensors',
      isFavorite: false,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  setUp(() {
    storage = MockStorageService();
  });

  group('GalleryBloc', () {
    blocTest<GalleryBloc, GalleryState>(
      'loads all images on GalleryLoadRequested',
      build: () {
        when(() => storage.getImages()).thenReturn(images);
        when(() => storage.getCollections()).thenReturn([]);
        return GalleryBloc(storage: storage);
      },
      act: (bloc) => bloc.add(GalleryLoadRequested()),
      expect: () => [
        isA<GalleryState>()
            .having((s) => s.allImages.length, 'allImages', 2)
            .having((s) => s.filteredImages.length, 'filteredImages', 2),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'filters by search query',
      build: () {
        when(() => storage.getImages()).thenReturn(images);
        when(() => storage.getCollections()).thenReturn([]);
        return GalleryBloc(storage: storage)
          ..emit(GalleryState(
            allImages: images,
            filteredImages: images,
          ));
      },
      act: (bloc) => bloc.add(const GallerySearchChanged('cat')),
      expect: () => [
        isA<GalleryState>()
            .having((s) => s.filteredImages.length, 'filtered', 1)
            .having((s) => s.filteredImages.first.id, 'id', 'img-1'),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'filters by favorites',
      build: () {
        when(() => storage.getImages()).thenReturn(images);
        when(() => storage.getCollections()).thenReturn([]);
        return GalleryBloc(storage: storage)
          ..emit(GalleryState(
            allImages: images,
            filteredImages: images,
          ));
      },
      act: (bloc) => bloc.add(const GalleryFilterChanged(GalleryFilter.favorites)),
      expect: () => [
        isA<GalleryState>()
            .having((s) => s.filter, 'filter', GalleryFilter.favorites)
            .having((s) => s.filteredImages.length, 'filtered', 1)
            .having((s) => s.filteredImages.first.isFavorite, 'isFavorite', true),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'search matches model name',
      build: () {
        when(() => storage.getImages()).thenReturn(images);
        when(() => storage.getCollections()).thenReturn([]);
        return GalleryBloc(storage: storage)
          ..emit(GalleryState(
            allImages: images,
            filteredImages: images,
          ));
      },
      act: (bloc) => bloc.add(const GallerySearchChanged('sd_xl')),
      expect: () => [
        isA<GalleryState>()
            .having((s) => s.filteredImages.length, 'filtered', 1)
            .having((s) => s.filteredImages.first.id, 'id', 'img-1'),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'toggles favorite',
      build: () {
        when(() => storage.toggleFavorite(any())).thenAnswer((_) async {});
        when(() => storage.getImages()).thenReturn([
          images[0].copyWith(isFavorite: false),
          images[1],
        ]);
        when(() => storage.getCollections()).thenReturn([]);
        return GalleryBloc(storage: storage)
          ..emit(GalleryState(
            allImages: images,
            filteredImages: images,
          ));
      },
      act: (bloc) => bloc.add(const GalleryImageFavoriteToggled('img-1')),
      expect: () => [
        isA<GalleryState>()
            .having((s) => s.allImages.first.isFavorite, 'favorite', false),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'deletes image',
      build: () {
        when(() => storage.deleteImage(any())).thenAnswer((_) async {});
        when(() => storage.getImages()).thenReturn([images[1]]);
        when(() => storage.getCollections()).thenReturn([]);
        return GalleryBloc(storage: storage)
          ..emit(GalleryState(
            allImages: images,
            filteredImages: images,
          ));
      },
      act: (bloc) => bloc.add(const GalleryImageDeleted('img-1')),
      expect: () => [
        isA<GalleryState>()
            .having((s) => s.allImages.length, 'allImages', 1)
            .having((s) => s.allImages.first.id, 'id', 'img-2'),
      ],
    );
  });
}
