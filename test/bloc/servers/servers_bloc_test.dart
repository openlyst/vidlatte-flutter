import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidlatte/bloc/servers/servers_bloc.dart';
import 'package:vidlatte/bloc/servers/servers_event.dart';
import 'package:vidlatte/bloc/servers/servers_state.dart';
import 'package:vidlatte/data/models/comfy_server.dart';
import 'package:vidlatte/data/models/model_catalog.dart';
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
  });

  group('ServersBloc', () {
    blocTest<ServersBloc, ServersState>(
      'emits loaded state with servers on load',
      build: () {
        when(() => storage.getServers()).thenReturn([server]);
        when(() => storage.getDefaultServer()).thenReturn(server);
        return ServersBloc(storage: storage, comfy: comfy);
      },
      act: (bloc) => bloc.add(ServersLoadRequested()),
      expect: () => [
        ServersState(
          status: ServersStatus.loaded,
          servers: [server],
          defaultServer: server,
        ),
      ],
    );

    blocTest<ServersBloc, ServersState>(
      'adds server on ServerAddRequested',
      build: () {
        when(() => storage.getServers()).thenReturn([]);
        when(() => storage.saveServer(any())).thenAnswer((_) async {});
        when(() => storage.getDefaultServer()).thenReturn(server);
        return ServersBloc(storage: storage, comfy: comfy);
      },
      act: (bloc) => bloc.add(const ServerAddRequested(
        name: 'New Server',
        url: 'http://localhost:8188',
      )),
      verify: (_) {
        verify(() => storage.saveServer(any())).called(1);
      },
    );

    blocTest<ServersBloc, ServersState>(
      'deletes server on ServerDeleteRequested',
      build: () {
        when(() => storage.getServers()).thenReturn([]);
        when(() => storage.getDefaultServer()).thenReturn(null);
        when(() => storage.deleteServer(any())).thenAnswer((_) async {});
        when(() => storage.deleteAllLoraMetadata(any())).thenAnswer((_) async {});
        return ServersBloc(storage: storage, comfy: comfy)
          ..emit(ServersState(
            status: ServersStatus.loaded,
            servers: [server],
            defaultServer: server,
          ));
      },
      act: (bloc) => bloc.add(const ServerDeleteRequested('s1')),
      expect: () => [
        isA<ServersState>()
            .having((s) => s.servers, 'servers', isEmpty)
            .having((s) => s.status, 'status', ServersStatus.loaded),
      ],
    );

    blocTest<ServersBloc, ServersState>(
      'updates health status on health check',
      build: () {
        when(() => comfy.checkHealth(any())).thenAnswer((_) async => ServerHealth(
              serverId: 's1',
              healthy: true,
              checkedAt: DateTime(2025, 1, 1),
            ));
        return ServersBloc(storage: storage, comfy: comfy)
          ..emit(ServersState(
            status: ServersStatus.loaded,
            servers: [server],
            defaultServer: server,
          ));
      },
      act: (bloc) => bloc.add(const ServerHealthCheckRequested('s1')),
      expect: () => [
        isA<ServersState>()
            .having((s) => s.healthStatuses['s1']?.healthy, 'healthy', true),
      ],
    );

    blocTest<ServersBloc, ServersState>(
      'fetches models on ServerModelsFetchRequested',
      build: () {
        when(() => comfy.getModels(any())).thenAnswer((_) async => ModelCatalog(
              serverId: 's1',
              models: ['model1.safetensors'],
              loras: ['lora1.safetensors'],
              maxLoras: 5,
              fetchedAt: DateTime(2025, 1, 1),
            ));
        return ServersBloc(storage: storage, comfy: comfy)
          ..emit(ServersState(
            status: ServersStatus.loaded,
            servers: [server],
            defaultServer: server,
          ));
      },
      act: (bloc) => bloc.add(const ServerModelsFetchRequested('s1')),
      expect: () => [
        isA<ServersState>()
            .having((s) => s.catalogs['s1']?.models, 'models', ['model1.safetensors']),
      ],
    );
  });
}
