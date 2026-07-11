import 'package:equatable/equatable.dart';
import 'package:vidlatte/data/models/llm_model.dart';
import 'package:vidlatte/data/models/llm_server.dart';

enum LlmStatus { initial, loaded, loading, error }

class LlmHealthStatus extends Equatable {
  final String serverId;
  final bool? healthy;
  final String? error;
  final DateTime checkedAt;

  const LlmHealthStatus({
    required this.serverId,
    this.healthy,
    this.error,
    required this.checkedAt,
  });

  @override
  List<Object?> get props => [serverId, healthy, error, checkedAt];
}

class LlmState extends Equatable {
  final LlmStatus status;
  final List<LlmServer> servers;
  final Map<String, List<LlmModel>> models;
  final Map<String, LlmHealthStatus> healthStatuses;
  final String? selectedServerId;
  final String? selectedModel;
  final String? errorMessage;

  const LlmState({
    this.status = LlmStatus.initial,
    this.servers = const [],
    this.models = const {},
    this.healthStatuses = const {},
    this.selectedServerId,
    this.selectedModel,
    this.errorMessage,
  });

  LlmServer? get selectedServer {
    if (selectedServerId == null) return null;
    return servers.where((s) => s.id == selectedServerId).firstOrNull;
  }

  List<LlmModel> get modelsForSelected =>
      selectedServerId == null ? [] : (models[selectedServerId] ?? []);

  LlmState copyWith({
    LlmStatus? status,
    List<LlmServer>? servers,
    Map<String, List<LlmModel>>? models,
    Map<String, LlmHealthStatus>? healthStatuses,
    Object? selectedServerId = _unset,
    Object? selectedModel = _unset,
    Object? errorMessage = _unset,
  }) =>
      LlmState(
        status: status ?? this.status,
        servers: servers ?? this.servers,
        models: models ?? this.models,
        healthStatuses: healthStatuses ?? this.healthStatuses,
        selectedServerId: selectedServerId == _unset
            ? this.selectedServerId
            : selectedServerId as String?,
        selectedModel: selectedModel == _unset
            ? this.selectedModel
            : selectedModel as String?,
        errorMessage: errorMessage == _unset
            ? this.errorMessage
            : errorMessage as String?,
      );

  @override
  List<Object?> get props =>
      [status, servers, models, healthStatuses, selectedServerId, selectedModel, errorMessage];
}

class _Sentinel {
  const _Sentinel();
}

const _unset = _Sentinel();
