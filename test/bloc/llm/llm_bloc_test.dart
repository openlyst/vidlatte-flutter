import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidlatte/bloc/llm/llm_bloc.dart';
import 'package:vidlatte/bloc/llm/llm_event.dart';
import 'package:vidlatte/bloc/llm/llm_state.dart';
import 'package:vidlatte/data/models/llm_model.dart';
import 'package:vidlatte/data/models/llm_server.dart';
import 'package:vidlatte/services/llm_service.dart';
import 'package:vidlatte/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}
class MockLlmService extends Mock implements LlmService {}

void main() {
  late MockStorageService storage;
  late MockLlmService llm;

  final server = LlmServer(
    id: 'llm-1',
    name: 'Test LLM',
    url: 'http://127.0.0.1:1234',
    isEnabled: true,
    createdAt: DateTime(2025, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(server);
  });

  setUp(() {
    storage = MockStorageService();
    llm = MockLlmService();
  });

  group('LlmBloc', () {
    blocTest<LlmBloc, LlmState>(
      'loads servers on LlmLoadRequested',
      build: () {
        when(() => storage.getLlmServers()).thenReturn([server]);
        return LlmBloc(storage: storage, llm: llm);
      },
      act: (bloc) => bloc.add(const LlmLoadRequested()),
      expect: () => [
        isA<LlmState>()
            .having((s) => s.servers.length, 'servers', 1)
            .having((s) => s.selectedServerId, 'selected', 'llm-1'),
      ],
    );

    blocTest<LlmBloc, LlmState>(
      'adds server on LlmServerAddRequested',
      build: () {
        when(() => storage.saveLlmServer(any())).thenAnswer((_) async {});
        when(() => storage.getLlmServers()).thenReturn([server]);
        return LlmBloc(storage: storage, llm: llm);
      },
      act: (bloc) => bloc.add(const LlmServerAddRequested(
        name: 'New Server',
        url: 'http://localhost:1234',
      )),
      verify: (_) {
        verify(() => storage.saveLlmServer(any())).called(1);
      },
    );

    blocTest<LlmBloc, LlmState>(
      'deletes server on LlmServerDeleteRequested',
      build: () {
        when(() => storage.deleteLlmServer(any())).thenAnswer((_) async {});
        when(() => storage.getLlmServers()).thenReturn([]);
        return LlmBloc(storage: storage, llm: llm)
          ..emit(LlmState(
            status: LlmStatus.loaded,
            servers: [server],
            selectedServerId: 'llm-1',
          ));
      },
      act: (bloc) => bloc.add(const LlmServerDeleteRequested('llm-1')),
      expect: () => [
        isA<LlmState>()
            .having((s) => s.servers, 'servers', isEmpty)
            .having((s) => s.selectedServerId, 'selected', isNull),
      ],
    );

    blocTest<LlmBloc, LlmState>(
      'fetches models on LlmModelsFetchRequested',
      build: () {
        when(() => storage.getLlmServer(any())).thenReturn(server);
        when(() => llm.getModels(any())).thenAnswer((_) async => [
              const LlmModel(identifier: 'model-1', displayName: 'Model 1', isLoaded: true),
            ]);
        return LlmBloc(storage: storage, llm: llm)
          ..emit(LlmState(
            status: LlmStatus.loaded,
            servers: [server],
            selectedServerId: 'llm-1',
          ));
      },
      act: (bloc) => bloc.add(const LlmModelsFetchRequested('llm-1')),
      expect: () => [
        isA<LlmState>()
            .having((s) => s.models['llm-1']?.length, 'models', 1)
            .having((s) => s.selectedModel, 'selectedModel', 'model-1'),
      ],
    );

    blocTest<LlmBloc, LlmState>(
      'updates health on LlmHealthCheckRequested',
      build: () {
        when(() => storage.getLlmServer(any())).thenReturn(server);
        when(() => llm.testConnection(any())).thenAnswer((_) async => true);
        return LlmBloc(storage: storage, llm: llm)
          ..emit(LlmState(
            status: LlmStatus.loaded,
            servers: [server],
            selectedServerId: 'llm-1',
          ));
      },
      act: (bloc) => bloc.add(const LlmHealthCheckRequested('llm-1')),
      expect: () => [
        isA<LlmState>()
            .having((s) => s.healthStatuses['llm-1']?.healthy, 'healthy', true),
      ],
    );

    blocTest<LlmBloc, LlmState>(
      'selects model on LlmModelSelected',
      build: () => LlmBloc(storage: storage, llm: llm),
      act: (bloc) => bloc.add(const LlmModelSelected('llm-1', 'my-model')),
      expect: () => [
        isA<LlmState>()
            .having((s) => s.selectedServerId, 'server', 'llm-1')
            .having((s) => s.selectedModel, 'model', 'my-model'),
      ],
    );

    blocTest<LlmBloc, LlmState>(
      'toggles server on LlmServerToggleRequested',
      build: () {
        when(() => storage.getLlmServer(any())).thenReturn(server);
        when(() => storage.saveLlmServer(any())).thenAnswer((_) async {});
        when(() => storage.getLlmServers()).thenReturn([server.copyWith(isEnabled: false)]);
        return LlmBloc(storage: storage, llm: llm)
          ..emit(LlmState(
            status: LlmStatus.loaded,
            servers: [server],
            selectedServerId: 'llm-1',
          ));
      },
      act: (bloc) => bloc.add(const LlmServerToggleRequested('llm-1')),
      expect: () => [
        isA<LlmState>()
            .having((s) => s.servers.first.isEnabled, 'isEnabled', false),
      ],
    );
  });
}
