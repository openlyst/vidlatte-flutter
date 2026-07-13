import 'package:equatable/equatable.dart';
import 'package:vidlatte/data/models/generated_image.dart';

enum AutoGenStatus { idle, generatingPrompt, generatingImage, waiting, paused, completed, error }

enum AutoGenMode { auto, variation }

class AutoGenImage extends Equatable {
  final String id;
  final String prompt;
  final ImageStatus status;
  final String? localPath;
  final DateTime createdAt;

  const AutoGenImage({
    required this.id,
    required this.prompt,
    this.status = ImageStatus.pending,
    this.localPath,
    required this.createdAt,
  });

  AutoGenImage copyWith({
    ImageStatus? status,
    String? localPath,
  }) =>
      AutoGenImage(
        id: id,
        prompt: prompt,
        status: status ?? this.status,
        localPath: localPath ?? this.localPath,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, prompt, status, localPath, createdAt];
}

sealed class AutoGenEvent extends Equatable {
  const AutoGenEvent();
  @override
  List<Object?> get props => [];
}

class AutoGenStarted extends AutoGenEvent {
  const AutoGenStarted();
}

class AutoGenStopped extends AutoGenEvent {
  const AutoGenStopped();
}

class AutoGenReset extends AutoGenEvent {
  const AutoGenReset();
}

class AutoGenConfigChanged extends AutoGenEvent {
  final AutoGenMode mode;
  final String topic;
  final String basePrompt;
  final String mustIncludeTags;
  final int? maxImages;
  final bool infiniteImages;
  final List<String> selectedLoras;
  final String imageModel;
  final String? llmServerId;
  final String? llmModel;
  final String? imageServerId;
  final int width;
  final int height;
  final int? steps;
  final bool? hiresFix;

  const AutoGenConfigChanged({
    required this.mode,
    required this.topic,
    required this.basePrompt,
    required this.mustIncludeTags,
    required this.maxImages,
    required this.infiniteImages,
    required this.selectedLoras,
    required this.imageModel,
    this.llmServerId,
    this.llmModel,
    this.imageServerId,
    required this.width,
    required this.height,
    this.steps,
    this.hiresFix,
  });

  @override
  List<Object?> get props => [
        mode, topic, basePrompt, mustIncludeTags, maxImages,
        infiniteImages, selectedLoras, imageModel, llmServerId, llmModel, imageServerId,
        width, height, steps, hiresFix,
      ];
}

class AutoGenImageUpdated extends AutoGenEvent {
  final String id;
  final ImageStatus status;
  final String? localPath;
  const AutoGenImageUpdated(this.id, this.status, {this.localPath});
  @override
  List<Object?> get props => [id, status, localPath];
}

class AutoGenPromptGenerated extends AutoGenEvent {
  final String prompt;
  const AutoGenPromptGenerated(this.prompt);
  @override
  List<Object?> get props => [prompt];
}

class AutoGenImageStarted extends AutoGenEvent {
  final AutoGenImage image;
  const AutoGenImageStarted(this.image);
  @override
  List<Object?> get props => [image];
}

class AutoGenErrorOccurred extends AutoGenEvent {
  final String message;
  const AutoGenErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

class AutoGenCompleted extends AutoGenEvent {
  const AutoGenCompleted();
}
