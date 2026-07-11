import 'package:equatable/equatable.dart';

class ModelInfo extends Equatable {
  final String name;
  final String serverId;

  const ModelInfo({
    required this.name,
    required this.serverId,
  });

  @override
  List<Object?> get props => [name, serverId];
}

class LoraInfo extends Equatable {
  final String name;
  final String serverId;
  final String? triggerWords;

  const LoraInfo({
    required this.name,
    required this.serverId,
    this.triggerWords,
  });

  @override
  List<Object?> get props => [name, serverId, triggerWords];
}

class ModelCatalog extends Equatable {
  final String serverId;
  final List<String> models;
  final List<String> loras;
  final int maxLoras;
  final DateTime fetchedAt;

  const ModelCatalog({
    required this.serverId,
    required this.models,
    required this.loras,
    required this.maxLoras,
    required this.fetchedAt,
  });

  @override
  List<Object?> get props => [serverId, models, loras, maxLoras, fetchedAt];
}

class ServerHealth extends Equatable {
  final String serverId;
  final bool healthy;
  final String? error;
  final String? os;
  final String? pythonVersion;
  final int? ramTotal;
  final int? ramFree;
  final List<String>? devices;
  final DateTime checkedAt;

  const ServerHealth({
    required this.serverId,
    required this.healthy,
    this.error,
    this.os,
    this.pythonVersion,
    this.ramTotal,
    this.ramFree,
    this.devices,
    required this.checkedAt,
  });

  @override
  List<Object?> get props => [serverId, healthy, error, checkedAt];
}
