import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidlatte/bloc/servers/servers_bloc.dart';
import 'package:vidlatte/bloc/servers/servers_event.dart';
import 'package:vidlatte/bloc/servers/servers_state.dart';
import 'package:vidlatte/data/models/comfy_server.dart';
import 'package:vidlatte/data/models/lora_metadata.dart';
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

  final meta1 = LoraMetadata(
    serverId: 's1',
    loraName: 'lora_a.safetensors',
    triggerWords: 'cat girl',
    isEnabled: true,
    updatedAt: DateTime(2025, 7, 10),
  );

  final meta2 = LoraMetadata(
    serverId: 's1',
    loraName: 'lora_b.safetensors',
    triggerWords: '',
    isEnabled: false,
    updatedAt: DateTime(2025, 7, 10),
  );

  setUpAll(() {
    registerFallbackValue(server);
    registerFallbackValue(LoraMetadata(
      serverId: 'fallback',
      loraName: 'fallback.safetensors',
      updatedAt: DateTime(2025, 1, 1),
    ));
  });

  setUp(() {
    storage = MockStorageService();
    comfy = MockComfyService();
  });

  group('ServersBloc LoRA metadata', () {
    blocTest<ServersBloc, ServersState>(
      'loads lora metadata on LoraMetadataLoadRequested',
      build: () => ServersBloc(storage: storage, comfy: comfy)
        ..emit(ServersState(
          status: ServersStatus.loaded,
          servers: [server],
          defaultServer: server,
        )),
      setUp: () {
        when(() => storage.getAllLoraMetadata('s1')).thenReturn([meta1, meta2]);
      },
      act: (bloc) => bloc.add(const LoraMetadataLoadRequested('s1')),
      expect: () => [
        isA<ServersState>()
            .having((s) => s.loraMetadata['s1']?.length, 'meta count', 2)
            .having((s) => s.triggerWordsFor('s1')['lora_a.safetensors'], 'trigger', 'cat girl')
            .having((s) => s.disabledLorasFor('s1'), 'disabled', {'lora_b.safetensors'}),
      ],
    );

    blocTest<ServersBloc, ServersState>(
      'saves trigger words on LoraTriggerWordsSaveRequested',
      build: () {
        when(() => storage.getAllLoraMetadata('s1')).thenReturn([]);
        when(() => storage.saveLoraMetadata(any())).thenAnswer((_) async {});
        return ServersBloc(storage: storage, comfy: comfy)
          ..emit(ServersState(
            status: ServersStatus.loaded,
            servers: [server],
            defaultServer: server,
          ));
      },
      act: (bloc) => bloc.add(const LoraTriggerWordsSaveRequested('s1', {
            'lora_a.safetensors': 'anime style',
          })),
      verify: (_) {
        verify(() => storage.saveLoraMetadata(any())).called(1);
      },
    );

    blocTest<ServersBloc, ServersState>(
      'saves visibility on LoraVisibilitySaveRequested',
      build: () {
        when(() => storage.getAllLoraMetadata('s1')).thenReturn([meta1]);
        when(() => storage.saveLoraMetadata(any())).thenAnswer((_) async {});
        return ServersBloc(storage: storage, comfy: comfy)
          ..emit(ServersState(
            status: ServersStatus.loaded,
            servers: [server],
            defaultServer: server,
            catalogs: {
              's1': ModelCatalog(
                serverId: 's1',
                models: ['model.safetensors'],
                loras: ['lora_a.safetensors', 'lora_b.safetensors'],
                maxLoras: 5,
                fetchedAt: DateTime(2025, 7, 10),
              ),
            },
          ));
      },
      act: (bloc) => bloc.add(const LoraVisibilitySaveRequested('s1', {'lora_b.safetensors'})),
      verify: (_) {
        verify(() => storage.saveLoraMetadata(any())).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<ServersBloc, ServersState>(
      'visibleLorasFor filters disabled loras',
      build: () => ServersBloc(storage: storage, comfy: comfy)
        ..emit(ServersState(
          status: ServersStatus.loaded,
          servers: [server],
          defaultServer: server,
          catalogs: {
            's1': ModelCatalog(
              serverId: 's1',
              models: [],
              loras: ['lora_a.safetensors', 'lora_b.safetensors', 'lora_c.safetensors'],
              maxLoras: 5,
              fetchedAt: DateTime(2025, 7, 10),
            ),
          },
          loraMetadata: {
            's1': [
              meta1,
              meta2,
              LoraMetadata(
                serverId: 's1',
                loraName: 'lora_c.safetensors',
                isEnabled: true,
                updatedAt: DateTime(2025, 7, 10),
              ),
            ],
          },
        )),
      verify: (bloc) {
        expect(bloc.state.visibleLorasFor('s1'),
            ['lora_a.safetensors', 'lora_c.safetensors']);
        expect(bloc.state.disabledLorasFor('s1'), {'lora_b.safetensors'});
      },
    );
  });
}
