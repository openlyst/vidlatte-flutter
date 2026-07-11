import 'package:equatable/equatable.dart';

import '../../data/models/generated_image.dart';
import '../../data/models/studio_session.dart';

abstract class StudioEvent extends Equatable {
  const StudioEvent();
  @override
  List<Object?> get props => [];
}

class StudioLoadRequested extends StudioEvent {}

class StudioSessionCreated extends StudioEvent {
  final String title;

  const StudioSessionCreated(this.title);

  @override
  List<Object?> get props => [title];
}

class StudioSessionUpdated extends StudioEvent {
  final StudioSession session;

  const StudioSessionUpdated(this.session);

  @override
  List<Object?> get props => [session];
}

class StudioSessionDeleted extends StudioEvent {
  final String id;

  const StudioSessionDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class StudioSessionSelected extends StudioEvent {
  final String? id;

  const StudioSessionSelected(this.id);

  @override
  List<Object?> get props => [id];
}

class StudioImageAdded extends StudioEvent {
  final String sessionId;
  final GeneratedImage image;

  const StudioImageAdded(this.sessionId, this.image);

  @override
  List<Object?> get props => [sessionId, image];
}

class StudioSessionPromptChanged extends StudioEvent {
  final String sessionId;
  final String prompt;

  const StudioSessionPromptChanged(this.sessionId, this.prompt);

  @override
  List<Object?> get props => [sessionId, prompt];
}

class StudioSessionModelChanged extends StudioEvent {
  final String sessionId;
  final String model;

  const StudioSessionModelChanged(this.sessionId, this.model);

  @override
  List<Object?> get props => [sessionId, model];
}

class StudioSessionLorasChanged extends StudioEvent {
  final String sessionId;
  final List<String> loras;

  const StudioSessionLorasChanged(this.sessionId, this.loras);

  @override
  List<Object?> get props => [sessionId, loras];
}

class StudioImageRemoved extends StudioEvent {
  final String sessionId;
  final String imageId;

  const StudioImageRemoved(this.sessionId, this.imageId);

  @override
  List<Object?> get props => [sessionId, imageId];
}
