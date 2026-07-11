import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidlatte/bloc/studio/studio_bloc.dart';
import 'package:vidlatte/bloc/studio/studio_event.dart';
import 'package:vidlatte/bloc/studio/studio_state.dart';
import 'package:vidlatte/data/models/generated_image.dart';
import 'package:vidlatte/data/models/studio_session.dart';
import 'package:vidlatte/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService storage;

  final session = StudioSession(
    id: 'sess-1',
    title: 'Project A',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(session);
  });

  setUp(() {
    storage = MockStorageService();
    when(() => storage.saveSession(any())).thenAnswer((_) async {});
    when(() => storage.deleteSession(any())).thenAnswer((_) async {});
  });

  group('StudioBloc', () {
    blocTest<StudioBloc, StudioState>(
      'loads sessions on StudioLoadRequested',
      build: () {
        when(() => storage.getSessions()).thenReturn([session]);
        return StudioBloc(storage: storage);
      },
      act: (bloc) => bloc.add(StudioLoadRequested()),
      expect: () => [
        isA<StudioState>()
            .having((s) => s.sessions.length, 'sessions', 1)
            .having((s) => s.selectedSessionId, 'selected', 'sess-1'),
      ],
    );

    blocTest<StudioBloc, StudioState>(
      'creates session on StudioSessionCreated',
      build: () {
        when(() => storage.getSessions()).thenReturn([session]);
        return StudioBloc(storage: storage);
      },
      act: (bloc) => bloc.add(const StudioSessionCreated('New Project')),
      expect: () => [
        isA<StudioState>()
            .having((s) => s.sessions.length, 'sessions', 1)
            .having((s) => s.sessions.first.title, 'title', 'New Project')
            .having((s) => s.selectedSessionId, 'selected', isNotNull),
      ],
    );

    blocTest<StudioBloc, StudioState>(
      'selects session on StudioSessionSelected',
      build: () => StudioBloc(storage: storage)
        ..emit(StudioState(sessions: [session], selectedSessionId: 'sess-1')),
      act: (bloc) => bloc.add(const StudioSessionSelected(null)),
      expect: () => [
        isA<StudioState>()
            .having((s) => s.selectedSessionId, 'selected', isNull),
      ],
    );

    blocTest<StudioBloc, StudioState>(
      'deletes session on StudioSessionDeleted',
      build: () {
        when(() => storage.getSessions()).thenReturn([]);
        return StudioBloc(storage: storage)
          ..emit(StudioState(sessions: [session], selectedSessionId: 'sess-1'));
      },
      act: (bloc) => bloc.add(const StudioSessionDeleted('sess-1')),
      expect: () => [
        isA<StudioState>()
            .having((s) => s.sessions, 'sessions', isEmpty)
            .having((s) => s.selectedSessionId, 'selected', isNull),
      ],
    );

    blocTest<StudioBloc, StudioState>(
      'adds image to session on StudioImageAdded',
      build: () {
        when(() => storage.getSessions()).thenReturn([]);
        return StudioBloc(storage: storage)
          ..emit(StudioState(sessions: [session], selectedSessionId: 'sess-1'));
      },
      act: (bloc) {
        final image = GeneratedImage(
          id: 'img-1',
          prompt: 'test',
          model: 'model',
          createdAt: DateTime(2025, 1, 1),
        );
        bloc.add(StudioImageAdded('sess-1', image));
      },
      expect: () => [
        isA<StudioState>()
            .having((s) => s.sessions.first.images.length, 'images', 1),
      ],
    );

    blocTest<StudioBloc, StudioState>(
      'updates prompt on StudioSessionPromptChanged',
      build: () {
        when(() => storage.getSessions()).thenReturn([]);
        return StudioBloc(storage: storage)
          ..emit(StudioState(sessions: [session], selectedSessionId: 'sess-1'));
      },
      act: (bloc) => bloc.add(const StudioSessionPromptChanged('sess-1', 'new prompt')),
      expect: () => [
        isA<StudioState>()
            .having((s) => s.sessions.first.prompt, 'prompt', 'new prompt'),
      ],
    );

    blocTest<StudioBloc, StudioState>(
      'updates model on StudioSessionModelChanged',
      build: () {
        when(() => storage.getSessions()).thenReturn([]);
        return StudioBloc(storage: storage)
          ..emit(StudioState(sessions: [session], selectedSessionId: 'sess-1'));
      },
      act: (bloc) => bloc.add(const StudioSessionModelChanged('sess-1', 'new_model.safetensors')),
      expect: () => [
        isA<StudioState>()
            .having((s) => s.sessions.first.model, 'model', 'new_model.safetensors'),
      ],
    );

    blocTest<StudioBloc, StudioState>(
      'selectedSession getter returns correct session',
      build: () => StudioBloc(storage: storage)
        ..emit(StudioState(sessions: [session], selectedSessionId: 'sess-1')),
      verify: (bloc) {
        expect(bloc.state.selectedSession?.id, 'sess-1');
      },
    );
  });
}
