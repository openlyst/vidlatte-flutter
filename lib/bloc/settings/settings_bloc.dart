import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/storage_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final StorageService _storage;

  SettingsBloc({required this._storage})
      : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsUpdated>(_onUpdated);
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<DefaultServerChanged>(_onDefaultServerChanged);
    on<LastModelChanged>(_onLastModelChanged);
    on<LastLorasChanged>(_onLastLorasChanged);
    on<LastCreativityChanged>(_onLastCreativityChanged);
  }

  void _onLoad(SettingsLoadRequested event, Emitter<SettingsState> emit) {
    emit(state.copyWith(settings: _storage.getSettings()));
  }

  Future<void> _onUpdated(SettingsUpdated event, Emitter<SettingsState> emit) async {
    await _storage.saveSettings(event.settings);
    emit(state.copyWith(settings: event.settings));
  }

  Future<void> _onThemeModeChanged(ThemeModeChanged event, Emitter<SettingsState> emit) async {
    final updated = state.settings.copyWith(themeMode: event.themeMode);
    await _storage.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onDefaultServerChanged(DefaultServerChanged event, Emitter<SettingsState> emit) async {
    final updated = state.settings.copyWith(defaultServerId: event.serverId);
    await _storage.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onLastModelChanged(LastModelChanged event, Emitter<SettingsState> emit) async {
    final updated = state.settings.copyWith(lastModel: event.model);
    await _storage.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onLastLorasChanged(LastLorasChanged event, Emitter<SettingsState> emit) async {
    final updated = state.settings.copyWith(lastLoras: event.loras);
    await _storage.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onLastCreativityChanged(LastCreativityChanged event, Emitter<SettingsState> emit) async {
    final updated = state.settings.copyWith(lastCreativity: event.creativity);
    await _storage.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }
}
