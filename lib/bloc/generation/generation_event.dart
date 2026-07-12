import 'package:equatable/equatable.dart';

import '../../data/models/comfy_server.dart';
import '../../data/models/generation_job.dart';

abstract class GenerationEvent extends Equatable {
  const GenerationEvent();
  @override
  List<Object?> get props => [];
}

class GenerationSubmitted extends GenerationEvent {
  final ComfyServer server;
  final String prompt;
  final String negativePrompt;
  final String model;
  final List<String> loras;
  final Map<String, double> loraWeights;
  final Creativity creativity;
  final double? cfg;
  final int? steps;
  final bool? hiresFix;
  final int width;
  final int height;
  final int? seed;
  final String? refImageFilename;
  final String? refImageSubfolder;
  final String? refImageType;
  final double denoise;
  final String? controlnetModel;
  final String? controlImageFilename;
  final String? controlImageSubfolder;
  final String? controlImageType;
  final double controlnetStrength;

  const GenerationSubmitted({
    required this.server,
    required this.prompt,
    this.negativePrompt = '',
    required this.model,
    this.loras = const [],
    this.loraWeights = const {},
    this.creativity = Creativity.normal,
    this.cfg,
    this.steps,
    this.hiresFix,
    this.width = 768,
    this.height = 768,
    this.seed,
    this.refImageFilename,
    this.refImageSubfolder,
    this.refImageType,
    this.denoise = 0.5,
    this.controlnetModel,
    this.controlImageFilename,
    this.controlImageSubfolder,
    this.controlImageType,
    this.controlnetStrength = 1.0,
  });

  @override
  List<Object?> get props => [server, prompt, negativePrompt, model, loras, loraWeights, creativity, cfg, steps, hiresFix, width, height, seed, refImageFilename, refImageSubfolder, refImageType, denoise, controlnetModel, controlImageFilename, controlImageSubfolder, controlImageType, controlnetStrength];
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

class GenerationReordered extends GenerationEvent {
  final List<GenerationJob> queue;

  const GenerationReordered(this.queue);

  @override
  List<Object?> get props => [queue];
}

class GenerationRetried extends GenerationEvent {
  final String jobId;

  const GenerationRetried(this.jobId);

  @override
  List<Object?> get props => [jobId];
}
