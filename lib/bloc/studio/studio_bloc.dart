import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

export 'studio_event.dart';
export 'studio_state.dart';

import '../../data/models/studio_session.dart';
import '../../services/storage_service.dart';
import 'studio_event.dart';
import 'studio_state.dart';

class StudioBloc extends Bloc<StudioEvent, StudioState> {
  final StorageService _storage;
  final Uuid _uuid;

  StudioBloc({
    required this._storage,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        super(const StudioState()) {
    on<StudioLoadRequested>(_onLoad);
    on<StudioSessionCreated>(_onCreated);
    on<StudioSessionUpdated>(_onUpdated);
    on<StudioSessionDeleted>(_onDeleted);
    on<StudioSessionSelected>(_onSelected);
    on<StudioImageAdded>(_onImageAdded);
    on<StudioImageRemoved>(_onImageRemoved);
    on<StudioSessionPromptChanged>(_onPromptChanged);
    on<StudioSessionModelChanged>(_onModelChanged);
    on<StudioSessionLorasChanged>(_onLorasChanged);
  }

  void _onLoad(StudioLoadRequested event, Emitter<StudioState> emit) {
    final sessions = _storage.getSessions();
    emit(state.copyWith(
      sessions: sessions,
      isLoading: false,
      selectedSessionId: sessions.isNotEmpty ? sessions.first.id : null,
    ));
  }

  Future<void> _onCreated(StudioSessionCreated event, Emitter<StudioState> emit) async {
    final now = DateTime.now();
    final session = StudioSession(
      id: _uuid.v4(),
      title: event.title,
      createdAt: now,
      updatedAt: now,
    );
    await _storage.saveSession(session);
    emit(state.copyWith(
      sessions: [session, ...state.sessions],
      selectedSessionId: session.id,
    ));
  }

  Future<void> _onUpdated(StudioSessionUpdated event, Emitter<StudioState> emit) async {
    final updated = event.session.copyWith(updatedAt: DateTime.now());
    await _storage.saveSession(updated);
    final sessions = state.sessions.map((s) => s.id == updated.id ? updated : s).toList();
    emit(state.copyWith(sessions: sessions));
  }

  Future<void> _onDeleted(StudioSessionDeleted event, Emitter<StudioState> emit) async {
    await _storage.deleteSession(event.id);
    final sessions = state.sessions.where((s) => s.id != event.id).toList();
    emit(state.copyWith(
      sessions: sessions,
      selectedSessionId: state.selectedSessionId == event.id
          ? (sessions.isNotEmpty ? sessions.first.id : null)
          : state.selectedSessionId,
    ));
  }

  void _onSelected(StudioSessionSelected event, Emitter<StudioState> emit) {
    emit(state.copyWith(selectedSessionId: event.id));
  }

  Future<void> _onImageAdded(StudioImageAdded event, Emitter<StudioState> emit) async {
    final session = state.sessions.where((s) => s.id == event.sessionId).firstOrNull;
    if (session == null) return;
    final updated = session.copyWith(
      images: [event.image, ...session.images],
      updatedAt: DateTime.now(),
    );
    await _storage.saveSession(updated);
    final sessions = state.sessions.map((s) => s.id == updated.id ? updated : s).toList();
    emit(state.copyWith(sessions: sessions));
  }

  Future<void> _onPromptChanged(StudioSessionPromptChanged event, Emitter<StudioState> emit) async {
    final session = state.sessions.where((s) => s.id == event.sessionId).firstOrNull;
    if (session == null) return;
    final updated = session.copyWith(
      prompt: event.prompt,
      updatedAt: DateTime.now(),
    );
    await _storage.saveSession(updated);
    final sessions = state.sessions.map((s) => s.id == updated.id ? updated : s).toList();
    emit(state.copyWith(sessions: sessions));
  }

  Future<void> _onModelChanged(StudioSessionModelChanged event, Emitter<StudioState> emit) async {
    final session = state.sessions.where((s) => s.id == event.sessionId).firstOrNull;
    if (session == null) return;
    final updated = session.copyWith(
      model: event.model,
      updatedAt: DateTime.now(),
    );
    await _storage.saveSession(updated);
    final sessions = state.sessions.map((s) => s.id == updated.id ? updated : s).toList();
    emit(state.copyWith(sessions: sessions));
  }

  Future<void> _onLorasChanged(StudioSessionLorasChanged event, Emitter<StudioState> emit) async {
    final session = state.sessions.where((s) => s.id == event.sessionId).firstOrNull;
    if (session == null) return;
    final updated = session.copyWith(
      loras: event.loras,
      updatedAt: DateTime.now(),
    );
    await _storage.saveSession(updated);
    final sessions = state.sessions.map((s) => s.id == updated.id ? updated : s).toList();
    emit(state.copyWith(sessions: sessions));
  }

  Future<void> _onImageRemoved(StudioImageRemoved event, Emitter<StudioState> emit) async {
    final session = state.sessions.where((s) => s.id == event.sessionId).firstOrNull;
    if (session == null) return;
    final updated = session.copyWith(
      images: session.images.where((img) => img.id != event.imageId).toList(),
      updatedAt: DateTime.now(),
    );
    await _storage.saveSession(updated);
    final sessions = state.sessions.map((s) => s.id == updated.id ? updated : s).toList();
    emit(state.copyWith(sessions: sessions));
  }
}
