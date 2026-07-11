import 'package:flutter_bloc/flutter_bloc.dart';

export 'servers_event.dart';
export 'servers_state.dart';

import '../../data/models/comfy_server.dart';
import '../../data/models/model_catalog.dart';
import '../../services/comfyui_service.dart';
import '../../services/storage_service.dart';
import 'servers_event.dart';
import 'servers_state.dart';

class ServersBloc extends Bloc<ServersEvent, ServersState> {
  final StorageService _storage;
  final ComfyService _comfy;

  ServersBloc({required this._storage, ComfyService? comfy})
      : _comfy = comfy ?? ComfyService(),
        super(const ServersState()) {
    on<ServersLoadRequested>(_onLoad);
    on<ServerAddRequested>(_onAdd);
    on<ServerUpdateRequested>(_onUpdate);
    on<ServerDeleteRequested>(_onDelete);
    on<ServerSetDefaultRequested>(_onSetDefault);
    on<ServerHealthCheckRequested>(_onHealthCheck);
    on<ServerModelsFetchRequested>(_onModelsFetch);
  }

  void _onLoad(ServersLoadRequested event, Emitter<ServersState> emit) {
    final servers = _storage.getServers();
    final defaultServer = _storage.getDefaultServer();
    emit(state.copyWith(
      status: ServersStatus.loaded,
      servers: servers,
      defaultServer: defaultServer,
    ));
  }

  Future<void> _onAdd(ServerAddRequested event, Emitter<ServersState> emit) async {
    final server = ComfyServer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      url: event.url,
      maxLoras: event.maxLoras,
      steps: event.steps,
      hiresFix: event.hiresFix,
      isDefault: _storage.getServers().isEmpty,
      createdAt: DateTime.now(),
    );
    await _storage.saveServer(server);
    final servers = _storage.getServers();
    emit(state.copyWith(
      status: ServersStatus.loaded,
      servers: servers,
      defaultServer: _storage.getDefaultServer(),
    ));
  }

  Future<void> _onUpdate(ServerUpdateRequested event, Emitter<ServersState> emit) async {
    await _storage.saveServer(event.server);
    final servers = _storage.getServers();
    emit(state.copyWith(
      status: ServersStatus.loaded,
      servers: servers,
      defaultServer: _storage.getDefaultServer(),
    ));
  }

  Future<void> _onDelete(ServerDeleteRequested event, Emitter<ServersState> emit) async {
    await _storage.deleteServer(event.id);
    final servers = _storage.getServers();
    final healthStatuses = Map<String, ServerHealth>.from(state.healthStatuses)..remove(event.id);
    final catalogs = Map<String, ModelCatalog>.from(state.catalogs)..remove(event.id);
    emit(state.copyWith(
      status: ServersStatus.loaded,
      servers: servers,
      defaultServer: _storage.getDefaultServer(),
      healthStatuses: healthStatuses,
      catalogs: catalogs,
    ));
  }

  Future<void> _onSetDefault(ServerSetDefaultRequested event, Emitter<ServersState> emit) async {
    await _storage.setDefaultServer(event.id);
    emit(state.copyWith(
      status: ServersStatus.loaded,
      servers: _storage.getServers(),
      defaultServer: _storage.getDefaultServer(),
    ));
  }

  Future<void> _onHealthCheck(ServerHealthCheckRequested event, Emitter<ServersState> emit) async {
    final server = state.servers.where((s) => s.id == event.id).firstOrNull;
    if (server == null) return;

    final health = await _comfy.checkHealth(server);
    final healthStatuses = Map<String, ServerHealth>.from(state.healthStatuses);
    healthStatuses[event.id] = health;
    emit(state.copyWith(healthStatuses: healthStatuses));
  }

  Future<void> _onModelsFetch(ServerModelsFetchRequested event, Emitter<ServersState> emit) async {
    final server = state.servers.where((s) => s.id == event.id).firstOrNull;
    if (server == null) return;

    try {
      final catalog = await _comfy.getModels(server);
      final catalogs = Map<String, ModelCatalog>.from(state.catalogs);
      catalogs[event.id] = catalog;
      emit(state.copyWith(catalogs: catalogs));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
