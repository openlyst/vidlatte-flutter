import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidlatte/bloc/autogen/autogen_bloc.dart';
import 'package:vidlatte/bloc/autogen/autogen_event.dart';
import 'package:vidlatte/bloc/autogen/autogen_state.dart';
import 'package:vidlatte/data/models/comfy_server.dart';
import 'package:vidlatte/data/models/generated_image.dart';
import 'package:vidlatte/data/models/llm_server.dart';
import 'package:vidlatte/services/comfyui_service.dart';
import 'package:vidlatte/services/llm_service.dart';
import 'package:vidlatte/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}
class MockLlmService extends Mock implements LlmService {}
class MockComfyService extends Mock implements ComfyService {}

void main() {
  late MockStorageService storage;
  late MockLlmService llm;
  late MockComfyService comfy;

  final llmServer = LlmServer(
    id: 'llm-1',
    name: 'Test',
    url: 'http://127.0.0.1:1234',
    isEnabled: true,
    createdAt: DateTime(2025, 1, 1),
  );

  final comfyServer = ComfyServer(
    id: 's1',
    name: 'Comfy',
    url: 'http://127.0.0.1:8188',
    isDefault: true,
    createdAt: DateTime(2025, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(llmServer);
    registerFallbackValue(comfyServer);
    registerFallbackValue(Creativity.normal);
  });

  setUp(() {
    storage = MockStorageService();
    llm = MockLlmService();
    comfy = MockComfyService();
  });

  group('AutoGenBloc', () {
    blocTest<AutoGenBloc, AutoGenState>(
      'updates config on AutoGenConfigChanged',
      build: () => AutoGenBloc(storage: storage, llm: llm, comfy: comfy),
      act: (bloc) => bloc.add(const AutoGenConfigChanged(
        mode: AutoGenMode.variation,
        topic: 'cyberpunk',
        basePrompt: 'a cat',
        mustIncludeTags: 'red hair',
        maxImages: 5,
        infiniteImages: true,
        selectedLoras: ['lora1'],
        imageModel: 'model.safetensors',
        llmServerId: 'llm-1',
        llmModel: 'llama-3',
        imageServerId: 's1',
        width: 1024,
        height: 1024,
        steps: 30,
        hiresFix: true,
      )),
      expect: () => [
        isA<AutoGenState>()
            .having((s) => s.mode, 'mode', AutoGenMode.variation)
            .having((s) => s.topic, 'topic', 'cyberpunk')
            .having((s) => s.maxImages, 'maxImages', 5)
            .having((s) => s.infiniteImages, 'infiniteImages', true)
            .having((s) => s.imageModel, 'imageModel', 'model.safetensors')
            .having((s) => s.llmServerId, 'llmServerId', 'llm-1')
            .having((s) => s.width, 'width', 1024)
            .having((s) => s.height, 'height', 1024)
            .having((s) => s.steps, 'steps', 30)
            .having((s) => s.hiresFix, 'hiresFix', true),
      ],
    );

    blocTest<AutoGenBloc, AutoGenState>(
      'stops on AutoGenStopped',
      build: () => AutoGenBloc(storage: storage, llm: llm, comfy: comfy)
        ..emit(const AutoGenState(isRunning: true, status: AutoGenStatus.generatingPrompt)),
      act: (bloc) => bloc.add(const AutoGenStopped()),
      expect: () => [
        isA<AutoGenState>()
            .having((s) => s.isRunning, 'isRunning', false)
            .having((s) => s.status, 'status', AutoGenStatus.paused),
      ],
    );

    blocTest<AutoGenBloc, AutoGenState>(
      'resets on AutoGenReset',
      build: () => AutoGenBloc(storage: storage, llm: llm, comfy: comfy)
        ..emit(const AutoGenState(
          isRunning: true,
          status: AutoGenStatus.generatingPrompt,
          generatedCount: 5,
        )),
      act: (bloc) => bloc.add(const AutoGenReset()),
      expect: () => [
        isA<AutoGenState>()
            .having((s) => s.isRunning, 'isRunning', false)
            .having((s) => s.status, 'status', AutoGenStatus.idle)
            .having((s) => s.generatedCount, 'generatedCount', 0),
      ],
    );

    blocTest<AutoGenBloc, AutoGenState>(
      'updates image on AutoGenImageUpdated',
      build: () {
        final image = AutoGenImage(
          id: 'img-1',
          prompt: 'test',
          createdAt: DateTime(2025, 1, 1),
        );
        return AutoGenBloc(storage: storage, llm: llm, comfy: comfy)
          ..emit(AutoGenState(images: [image]));
      },
      act: (bloc) => bloc.add(const AutoGenImageUpdated('img-1', ImageStatus.completed, localPath: '/path.png')),
      expect: () => [
        isA<AutoGenState>()
            .having((s) => s.images.first.status, 'status', ImageStatus.completed)
            .having((s) => s.images.first.localPath, 'localPath', '/path.png')
            .having((s) => s.generatedCount, 'generatedCount', 1),
      ],
    );

    blocTest<AutoGenBloc, AutoGenState>(
      'adds image on AutoGenImageStarted',
      build: () => AutoGenBloc(storage: storage, llm: llm, comfy: comfy),
      act: (bloc) => bloc.add(AutoGenImageStarted(AutoGenImage(
        id: 'img-1',
        prompt: 'test',
        createdAt: DateTime(2025, 1, 1),
      ))),
      expect: () => [
        isA<AutoGenState>()
            .having((s) => s.images.length, 'images', 1)
            .having((s) => s.images.first.id, 'id', 'img-1'),
      ],
    );

    blocTest<AutoGenBloc, AutoGenState>(
      'sets current prompt on AutoGenPromptGenerated',
      build: () => AutoGenBloc(storage: storage, llm: llm, comfy: comfy),
      act: (bloc) => bloc.add(const AutoGenPromptGenerated('a beautiful sunset')),
      expect: () => [
        isA<AutoGenState>()
            .having((s) => s.currentPrompt, 'prompt', 'a beautiful sunset')
            .having((s) => s.status, 'status', AutoGenStatus.generatingImage),
      ],
    );

    blocTest<AutoGenBloc, AutoGenState>(
      'sets error on AutoGenErrorOccurred',
      build: () => AutoGenBloc(storage: storage, llm: llm, comfy: comfy),
      act: (bloc) => bloc.add(const AutoGenErrorOccurred('Connection failed')),
      expect: () => [
        isA<AutoGenState>()
            .having((s) => s.status, 'status', AutoGenStatus.error)
            .having((s) => s.errorMessage, 'error', 'Connection failed')
            .having((s) => s.isRunning, 'isRunning', false),
      ],
    );

    blocTest<AutoGenBloc, AutoGenState>(
      'completes on AutoGenCompleted',
      build: () => AutoGenBloc(storage: storage, llm: llm, comfy: comfy)
        ..emit(const AutoGenState(isRunning: true)),
      act: (bloc) => bloc.add(const AutoGenCompleted()),
      expect: () => [
        isA<AutoGenState>()
            .having((s) => s.status, 'status', AutoGenStatus.completed)
            .having((s) => s.isRunning, 'isRunning', false),
      ],
    );
  });
}
