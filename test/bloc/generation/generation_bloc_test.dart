import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidlatte/bloc/generation/generation_bloc.dart';
import 'package:vidlatte/bloc/generation/generation_event.dart';
import 'package:vidlatte/bloc/generation/generation_state.dart';
import 'package:vidlatte/data/models/comfy_server.dart';
import 'package:vidlatte/data/models/generated_image.dart';
import 'package:vidlatte/services/comfyui_service.dart';
import 'package:vidlatte/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}
class MockComfyService extends Mock implements ComfyService {}

void main() {
  late MockStorageService storage;
  late MockComfyService comfy;

  final server = ComfyServer(
    id: 's1',
    name: 'Test',
    url: 'http://127.0.0.1:8188',
    isDefault: true,
    createdAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    storage = MockStorageService();
    comfy = MockComfyService();
    registerFallbackValue(server);
    registerFallbackValue(Creativity.normal);
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(GeneratedImage(
      id: 'fallback',
      prompt: '',
      model: '',
      createdAt: DateTime(2025, 1, 1),
    ));
  });

  group('GenerationBloc', () {
    blocTest<GenerationBloc, GenerationState>(
      'emits generating then success on successful generation',
      build: () {
        when(() => comfy.generateImage(
              any(),
              prompt: any(named: 'prompt'),
              model: any(named: 'model'),
              loras: any(named: 'loras'),
              creativity: any(named: 'creativity'),
              steps: any(named: 'steps'),
              hiresFix: any(named: 'hiresFix'),
              width: any(named: 'width'),
              height: any(named: 'height'),
              seed: any(named: 'seed'),
              onPreview: any(named: 'onPreview'),
            )).thenAnswer((_) async => ComfyJobResult(
              success: true,
              filename: 'test.png',
              imageBytes: Uint8List.fromList([1, 2, 3]),
            ));
        when(() => storage.saveImageFile(any(), any()))
            .thenAnswer((_) async => '/path/to/image.png');
        when(() => storage.saveImage(any())).thenAnswer((_) async {});
        return GenerationBloc(storage: storage, comfy: comfy);
      },
      act: (bloc) => bloc.add(GenerationSubmitted(
        server: server,
        prompt: 'a cat',
        model: 'model.safetensors',
      )),
      skip: 1,
      expect: () => [
        isA<GenerationState>()
            .having((s) => s.status, 'status', GenerationStatus.success)
            .having((s) => s.images.length, 'images', 1),
      ],
    );

    blocTest<GenerationBloc, GenerationState>(
      'emits error on failed generation',
      build: () {
        when(() => comfy.generateImage(
              any(),
              prompt: any(named: 'prompt'),
              model: any(named: 'model'),
              loras: any(named: 'loras'),
              creativity: any(named: 'creativity'),
              steps: any(named: 'steps'),
              hiresFix: any(named: 'hiresFix'),
              width: any(named: 'width'),
              height: any(named: 'height'),
              seed: any(named: 'seed'),
              onPreview: any(named: 'onPreview'),
            )).thenAnswer((_) async => const ComfyJobResult(
              success: false,
              error: 'Connection refused',
            ));
        return GenerationBloc(storage: storage, comfy: comfy);
      },
      act: (bloc) => bloc.add(GenerationSubmitted(
        server: server,
        prompt: 'a cat',
        model: 'model.safetensors',
      )),
      skip: 1,
      expect: () => [
        isA<GenerationState>()
            .having((s) => s.status, 'status', GenerationStatus.error)
            .having((s) => s.errorMessage, 'error', 'Connection refused'),
      ],
    );

    blocTest<GenerationBloc, GenerationState>(
      'clears active jobs on GenerationCleared',
      build: () => GenerationBloc(storage: storage, comfy: comfy)
        ..emit(const GenerationState(
          status: GenerationStatus.generating,
          activeJobs: [],
        )),
      act: (bloc) => bloc.add(GenerationCleared()),
      expect: () => [
        const GenerationState(
          status: GenerationStatus.idle,
          activeJobs: [],
        ),
      ],
    );

    blocTest<GenerationBloc, GenerationState>(
      'toggles favorite on GenerationImageFavoriteToggled',
      build: () {
        final image = GeneratedImage(
          id: 'img-1',
          prompt: 'test',
          model: 'model',
          isFavorite: false,
          createdAt: DateTime(2025, 1, 1),
        );
        when(() => storage.toggleFavorite(any())).thenAnswer((_) async {});
        return GenerationBloc(storage: storage, comfy: comfy)
          ..emit(GenerationState(images: [image]));
      },
      act: (bloc) => bloc.add(const GenerationImageFavoriteToggled('img-1')),
      expect: () => [
        isA<GenerationState>()
            .having((s) => s.images.first.isFavorite, 'favorite', true),
      ],
    );

    blocTest<GenerationBloc, GenerationState>(
      'deletes image on GenerationImageDeleted',
      build: () {
        final image = GeneratedImage(
          id: 'img-1',
          prompt: 'test',
          model: 'model',
          createdAt: DateTime(2025, 1, 1),
        );
        when(() => storage.deleteImage(any())).thenAnswer((_) async {});
        return GenerationBloc(storage: storage, comfy: comfy)
          ..emit(GenerationState(images: [image]));
      },
      act: (bloc) => bloc.add(const GenerationImageDeleted('img-1')),
      expect: () => [
        isA<GenerationState>()
            .having((s) => s.images, 'images', isEmpty),
      ],
    );
  });
}
