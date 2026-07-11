import 'package:equatable/equatable.dart';

import '../../data/models/comfy_server.dart';
import '../../data/models/lora_metadata.dart';
import '../../data/models/model_catalog.dart';

enum ServersStatus { initial, loading, loaded, error }

class ServersState extends Equatable {
  final ServersStatus status;
  final List<ComfyServer> servers;
  final ComfyServer? defaultServer;
  final Map<String, ServerHealth> healthStatuses;
  final Map<String, ModelCatalog> catalogs;
  final Map<String, List<LoraMetadata>> loraMetadata;
  final String? errorMessage;

  const ServersState({
    this.status = ServersStatus.initial,
    this.servers = const [],
    this.defaultServer,
    this.healthStatuses = const {},
    this.catalogs = const {},
    this.loraMetadata = const {},
    this.errorMessage,
  });

  Map<String, String> triggerWordsFor(String serverId) {
    final metas = loraMetadata[serverId] ?? [];
    return {for (final m in metas) m.loraName: m.triggerWords};
  }

  Set<String> disabledLorasFor(String serverId) {
    final metas = loraMetadata[serverId] ?? [];
    return metas.where((m) => !m.isEnabled).map((m) => m.loraName).toSet();
  }

  List<String> visibleLorasFor(String serverId) {
    final catalog = catalogs[serverId];
    if (catalog == null) return [];
    final disabled = disabledLorasFor(serverId);
    return catalog.loras.where((l) => !disabled.contains(l)).toList();
  }

  ServersState copyWith({
    ServersStatus? status,
    List<ComfyServer>? servers,
    ComfyServer? defaultServer,
    Map<String, ServerHealth>? healthStatuses,
    Map<String, ModelCatalog>? catalogs,
    Map<String, List<LoraMetadata>>? loraMetadata,
    String? errorMessage,
  }) {
    return ServersState(
      status: status ?? this.status,
      servers: servers ?? this.servers,
      defaultServer: defaultServer ?? this.defaultServer,
      healthStatuses: healthStatuses ?? this.healthStatuses,
      catalogs: catalogs ?? this.catalogs,
      loraMetadata: loraMetadata ?? this.loraMetadata,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, servers, defaultServer, healthStatuses, catalogs, loraMetadata, errorMessage];
}
