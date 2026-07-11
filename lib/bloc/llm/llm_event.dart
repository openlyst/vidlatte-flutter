import 'package:equatable/equatable.dart';
import 'package:vidlatte/data/models/llm_model.dart';
import 'package:vidlatte/data/models/llm_server.dart';

sealed class LlmEvent extends Equatable {
  const LlmEvent();
  @override
  List<Object?> get props => [];
}

class LlmLoadRequested extends LlmEvent {
  const LlmLoadRequested();
}

class LlmServerAddRequested extends LlmEvent {
  final String name;
  final String url;
  final String? apiKey;
  final String? defaultModel;
  const LlmServerAddRequested({
    required this.name,
    required this.url,
    this.apiKey,
    this.defaultModel,
  });
  @override
  List<Object?> get props => [name, url, apiKey, defaultModel];
}

class LlmServerUpdateRequested extends LlmEvent {
  final LlmServer server;
  const LlmServerUpdateRequested(this.server);
  @override
  List<Object?> get props => [server];
}

class LlmServerDeleteRequested extends LlmEvent {
  final String id;
  const LlmServerDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class LlmServerToggleRequested extends LlmEvent {
  final String id;
  const LlmServerToggleRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class LlmModelsFetchRequested extends LlmEvent {
  final String serverId;
  const LlmModelsFetchRequested(this.serverId);
  @override
  List<Object?> get props => [serverId];
}

class LlmHealthCheckRequested extends LlmEvent {
  final String serverId;
  const LlmHealthCheckRequested(this.serverId);
  @override
  List<Object?> get props => [serverId];
}

class LlmModelSelected extends LlmEvent {
  final String? serverId;
  final String modelIdentifier;
  const LlmModelSelected(this.serverId, this.modelIdentifier);
  @override
  List<Object?> get props => [serverId, modelIdentifier];
}
