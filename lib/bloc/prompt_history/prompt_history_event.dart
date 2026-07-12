import 'package:equatable/equatable.dart';

abstract class PromptHistoryEvent extends Equatable {
  const PromptHistoryEvent();
  @override
  List<Object?> get props => [];
}

class PromptHistoryLoadRequested extends PromptHistoryEvent {}

class PromptHistoryEntryAdded extends PromptHistoryEvent {
  final String prompt;
  final String? negativePrompt;
  final String? model;
  final List<String> loras;

  const PromptHistoryEntryAdded({
    required this.prompt,
    this.negativePrompt,
    this.model,
    this.loras = const [],
  });

  @override
  List<Object?> get props => [prompt, negativePrompt, model, loras];
}

class PromptHistoryEntryDeleted extends PromptHistoryEvent {
  final String id;

  const PromptHistoryEntryDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class PromptHistoryCleared extends PromptHistoryEvent {}
