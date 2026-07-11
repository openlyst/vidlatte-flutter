import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidlatte/bloc/settings/settings_bloc.dart';
import 'package:vidlatte/bloc/settings/settings_event.dart';
import 'package:vidlatte/bloc/settings/settings_state.dart';
import 'package:vidlatte/data/models/app_settings.dart';
import 'package:vidlatte/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService storage;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    storage = MockStorageService();
    when(() => storage.saveSettings(any())).thenAnswer((_) async {});
  });

  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'loads settings on SettingsLoadRequested',
      build: () {
        when(() => storage.getSettings()).thenReturn(
          const AppSettings(themeMode: 'dark', lastModel: 'test.safetensors'),
        );
        return SettingsBloc(storage: storage);
      },
      act: (bloc) => bloc.add(SettingsLoadRequested()),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.themeMode, 'themeMode', 'dark')
            .having((s) => s.settings.lastModel, 'lastModel', 'test.safetensors'),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes theme mode',
      build: () => SettingsBloc(storage: storage),
      act: (bloc) => bloc.add(const ThemeModeChanged('dark')),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.themeMode, 'themeMode', 'dark'),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes default server',
      build: () => SettingsBloc(storage: storage),
      act: (bloc) => bloc.add(const DefaultServerChanged('server-1')),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.defaultServerId, 'defaultServerId', 'server-1'),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes last model',
      build: () => SettingsBloc(storage: storage),
      act: (bloc) => bloc.add(const LastModelChanged('new_model.safetensors')),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.lastModel, 'lastModel', 'new_model.safetensors'),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes last loras',
      build: () => SettingsBloc(storage: storage),
      act: (bloc) => bloc.add(const LastLorasChanged(['lora1', 'lora2'])),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.lastLoras, 'lastLoras', ['lora1', 'lora2']),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'changes last creativity',
      build: () => SettingsBloc(storage: storage),
      act: (bloc) => bloc.add(const LastCreativityChanged('max')),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.lastCreativity, 'lastCreativity', 'max'),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'updates full settings',
      build: () => SettingsBloc(storage: storage),
      act: (bloc) => bloc.add(const SettingsUpdated(
        AppSettings(themeMode: 'light', saveToGallery: false),
      )),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.themeMode, 'themeMode', 'light')
            .having((s) => s.settings.saveToGallery, 'saveToGallery', false),
      ],
    );
  });
}
