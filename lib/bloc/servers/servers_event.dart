import 'package:equatable/equatable.dart';

import '../../data/models/comfy_server.dart';
import '../../data/models/lora_metadata.dart';

abstract class ServersEvent extends Equatable {
  const ServersEvent();
  @override
  List<Object?> get props => [];
}

class ServersLoadRequested extends ServersEvent {}

class ServerAddRequested extends ServersEvent {
  final String name;
  final String url;
  final int maxLoras;
  final int steps;
  final bool hiresFix;

  const ServerAddRequested({
    required this.name,
    required this.url,
    this.maxLoras = 5,
    this.steps = 20,
    this.hiresFix = false,
  });

  @override
  List<Object?> get props => [name, url, maxLoras, steps, hiresFix];
}

class ServerUpdateRequested extends ServersEvent {
  final ComfyServer server;

  const ServerUpdateRequested(this.server);

  @override
  List<Object?> get props => [server];
}

class ServerDeleteRequested extends ServersEvent {
  final String id;

  const ServerDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ServerSetDefaultRequested extends ServersEvent {
  final String id;

  const ServerSetDefaultRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ServerHealthCheckRequested extends ServersEvent {
  final String id;

  const ServerHealthCheckRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ServerModelsFetchRequested extends ServersEvent {
  final String id;

  const ServerModelsFetchRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class LoraMetadataLoadRequested extends ServersEvent {
  final String serverId;
  const LoraMetadataLoadRequested(this.serverId);
  @override
  List<Object?> get props => [serverId];
}

class LoraMetadataSaveRequested extends ServersEvent {
  final String serverId;
  final List<LoraMetadata> items;
  const LoraMetadataSaveRequested(this.serverId, this.items);
  @override
  List<Object?> get props => [serverId, items];
}

class LoraTriggerWordsSaveRequested extends ServersEvent {
  final String serverId;
  final Map<String, String> triggerWords;
  const LoraTriggerWordsSaveRequested(this.serverId, this.triggerWords);
  @override
  List<Object?> get props => [serverId, triggerWords];
}

class LoraVisibilitySaveRequested extends ServersEvent {
  final String serverId;
  final Set<String> disabledLoras;
  const LoraVisibilitySaveRequested(this.serverId, this.disabledLoras);
  @override
  List<Object?> get props => [serverId, disabledLoras];
}
