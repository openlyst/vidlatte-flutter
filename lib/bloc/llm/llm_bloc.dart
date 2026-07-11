import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/llm_model.dart';
import '../../data/models/llm_server.dart';
import '../../services/llm_service.dart';
import '../../services/storage_service.dart';
import 'llm_event.dart';
import 'llm_state.dart';

export 'llm_event.dart';
export 'llm_state.dart';

class LlmBloc extends Bloc<LlmEvent, LlmState> {
  final StorageService _storage;
  final LlmService _llm;
  final Uuid _uuid;

  LlmBloc({
    required StorageService storage,
    LlmService? llm,
    Uuid? uuid,
  })  : _storage = storage,
        _llm = llm ?? LlmService(),
        _uuid = uuid ?? const Uuid(),
        super(const LlmState()) {
    on<LlmLoadRequested>(_onLoad);
    on<LlmServerAddRequested>(_onAdd);
    on<LlmServerUpdateRequested>(_onUpdate);
    on<LlmServerDeleteRequested>(_onDelete);
    on<LlmServerToggleRequested>(_onToggle);
    on<LlmModelsFetchRequested>(_onFetchModels);
    on<LlmHealthCheckRequested>(_onHealthCheck);
    on<LlmModelSelected>(_onModelSelected);
  }

  void _onLoad(LlmLoadRequested event, Emitter<LlmState> emit) {
    final servers = _storage.getLlmServers();
    emit(state.copyWith(
      status: LlmStatus.loaded,
      servers: servers,
      selectedServerId: servers.isNotEmpty ? servers.first.id : null,
    ));
  }

  Future<void> _onAdd(LlmServerAddRequested event, Emitter<LlmState> emit) async {
    final server = LlmServer(
      id: _uuid.v4(),
      name: event.name,
      url: event.url,
      apiKey: event.apiKey,
      defaultModel: event.defaultModel,
      isEnabled: true,
      createdAt: DateTime.now(),
    );
    await _storage.saveLlmServer(server);
    final servers = _storage.getLlmServers();
    emit(state.copyWith(
      status: LlmStatus.loaded,
      servers: servers,
      selectedServerId: server.id,
    ));
  }

  Future<void> _onUpdate(LlmServerUpdateRequested event, Emitter<LlmState> emit) async {
    await _storage.saveLlmServer(event.server);
    emit(state.copyWith(
      status: LlmStatus.loaded,
      servers: _storage.getLlmServers(),
    ));
  }

  Future<void> _onDelete(LlmServerDeleteRequested event, Emitter<LlmState> emit) async {
    await _storage.deleteLlmServer(event.id);
    final servers = _storage.getLlmServers();
    emit(state.copyWith(
      status: LlmStatus.loaded,
      servers: servers,
      selectedServerId: state.selectedServerId == event.id
          ? (servers.isNotEmpty ? servers.first.id : null)
          : state.selectedServerId,
    ));
  }

  Future<void> _onToggle(LlmServerToggleRequested event, Emitter<LlmState> emit) async {
    final server = _storage.getLlmServer(event.id);
    if (server == null) return;
    final updated = server.copyWith(isEnabled: !server.isEnabled);
    await _storage.saveLlmServer(updated);
    emit(state.copyWith(
      status: LlmStatus.loaded,
      servers: _storage.getLlmServers(),
    ));
  }

  Future<void> _onFetchModels(LlmModelsFetchRequested event, Emitter<LlmState> emit) async {
    final server = _storage.getLlmServer(event.serverId);
    if (server == null) return;
    try {
      final models = await _llm.getModels(server);
      final newModels = Map<String, List<LlmModel>>.from(state.models);
      newModels[event.serverId] = models;
      emit(state.copyWith(
        models: newModels,
        selectedModel: state.selectedModel == null && models.isNotEmpty
            ? models.first.identifier
            : state.selectedModel,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LlmStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onHealthCheck(LlmHealthCheckRequested event, Emitter<LlmState> emit) async {
    final server = _storage.getLlmServer(event.serverId);
    if (server == null) return;
    final health = LlmHealthStatus(
      serverId: event.serverId,
      checkedAt: DateTime.now(),
    );
    try {
      final ok = await _llm.testConnection(server);
      final newHealth = Map<String, LlmHealthStatus>.from(state.healthStatuses);
      newHealth[event.serverId] = LlmHealthStatus(
        serverId: event.serverId,
        healthy: ok,
        checkedAt: DateTime.now(),
      );
      emit(state.copyWith(healthStatuses: newHealth));
    } catch (e) {
      final newHealth = Map<String, LlmHealthStatus>.from(state.healthStatuses);
      newHealth[event.serverId] = LlmHealthStatus(
        serverId: event.serverId,
        healthy: false,
        error: e.toString(),
        checkedAt: DateTime.now(),
      );
      emit(state.copyWith(healthStatuses: newHealth));
    }
  }

  void _onModelSelected(LlmModelSelected event, Emitter<LlmState> emit) {
    emit(state.copyWith(
      selectedServerId: event.serverId,
      selectedModel: event.modelIdentifier,
    ));
  }
}
