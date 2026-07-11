import 'package:equatable/equatable.dart';

import '../../data/models/comfy_server.dart';

abstract class GenerationEvent extends Equatable {
  const GenerationEvent();
  @override
  List<Object?> get props => [];
}

class GenerationSubmitted extends GenerationEvent {
  final ComfyServer server;
  final String prompt;
  final String model;
  final List<String> loras;
  final Creativity creativity;
  final double? cfg;
  final int? steps;
  final bool? hiresFix;
  final int width;
  final int height;
  final int? seed;

  const GenerationSubmitted({
    required this.server,
    required this.prompt,
    required this.model,
    this.loras = const [],
    this.creativity = Creativity.normal,
    this.cfg,
    this.steps,
    this.hiresFix,
    this.width = 1024,
    this.height = 1024,
    this.seed,
  });

  @override
  List<Object?> get props => [server, prompt, model, loras, creativity, cfg, steps, hiresFix, width, height, seed];
}

class GenerationCancelled extends GenerationEvent {
  final String jobId;

  const GenerationCancelled(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class GenerationCleared extends GenerationEvent {}

class GenerationImageDeleted extends GenerationEvent {
  final String imageId;

  const GenerationImageDeleted(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

class GenerationImageFavoriteToggled extends GenerationEvent {
  final String imageId;

  const GenerationImageFavoriteToggled(this.imageId);

  @override
  List<Object?> get props => [imageId];
}
