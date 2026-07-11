import 'package:equatable/equatable.dart';

import '../../data/models/comfy_server.dart';
import '../../data/models/model_catalog.dart';

enum ServersStatus { initial, loading, loaded, error }

class ServersState extends Equatable {
  final ServersStatus status;
  final List<ComfyServer> servers;
  final ComfyServer? defaultServer;
  final Map<String, ServerHealth> healthStatuses;
  final Map<String, ModelCatalog> catalogs;
  final String? errorMessage;

  const ServersState({
    this.status = ServersStatus.initial,
    this.servers = const [],
    this.defaultServer,
    this.healthStatuses = const {},
    this.catalogs = const {},
    this.errorMessage,
  });

  ServersState copyWith({
    ServersStatus? status,
    List<ComfyServer>? servers,
    ComfyServer? defaultServer,
    Map<String, ServerHealth>? healthStatuses,
    Map<String, ModelCatalog>? catalogs,
    String? errorMessage,
  }) {
    return ServersState(
      status: status ?? this.status,
      servers: servers ?? this.servers,
      defaultServer: defaultServer ?? this.defaultServer,
      healthStatuses: healthStatuses ?? this.healthStatuses,
      catalogs: catalogs ?? this.catalogs,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, servers, defaultServer, healthStatuses, catalogs, errorMessage];
}
