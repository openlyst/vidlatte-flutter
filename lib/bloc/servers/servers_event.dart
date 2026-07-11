import 'package:equatable/equatable.dart';

import '../../data/models/comfy_server.dart';

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
