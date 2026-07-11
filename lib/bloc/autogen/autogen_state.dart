import 'package:equatable/equatable.dart';
import 'package:vidlatte/data/models/generated_image.dart';
import 'autogen_event.dart';

export 'autogen_event.dart';

class AutoGenState extends Equatable {
  final AutoGenStatus status;
  final AutoGenMode mode;
  final String topic;
  final String basePrompt;
  final String mustIncludeTags;
  final int? maxImages;
  final List<String> selectedLoras;
  final String imageModel;
  final String? llmServerId;
  final String? llmModel;
  final String? imageServerId;
  final List<AutoGenImage> images;
  final String currentPrompt;
  final int generatedCount;
  final String? errorMessage;
  final bool isRunning;

  const AutoGenState({
    this.status = AutoGenStatus.idle,
    this.mode = AutoGenMode.auto,
    this.topic = '',
    this.basePrompt = '',
    this.mustIncludeTags = '',
    this.maxImages = 10,
    this.selectedLoras = const [],
    this.imageModel = '',
    this.llmServerId,
    this.llmModel,
    this.imageServerId,
    this.images = const [],
    this.currentPrompt = '',
    this.generatedCount = 0,
    this.errorMessage,
    this.isRunning = false,
  });

  AutoGenState copyWith({
    AutoGenStatus? status,
    AutoGenMode? mode,
    String? topic,
    String? basePrompt,
    String? mustIncludeTags,
    Object? maxImages = _unset,
    List<String>? selectedLoras,
    String? imageModel,
    Object? llmServerId = _unset,
    Object? llmModel = _unset,
    Object? imageServerId = _unset,
    List<AutoGenImage>? images,
    String? currentPrompt,
    int? generatedCount,
    Object? errorMessage = _unset,
    bool? isRunning,
  }) =>
      AutoGenState(
        status: status ?? this.status,
        mode: mode ?? this.mode,
        topic: topic ?? this.topic,
        basePrompt: basePrompt ?? this.basePrompt,
        mustIncludeTags: mustIncludeTags ?? this.mustIncludeTags,
        maxImages: maxImages == _unset ? this.maxImages : maxImages as int?,
        selectedLoras: selectedLoras ?? this.selectedLoras,
        imageModel: imageModel ?? this.imageModel,
        llmServerId: llmServerId == _unset ? this.llmServerId : llmServerId as String?,
        llmModel: llmModel == _unset ? this.llmModel : llmModel as String?,
        imageServerId: imageServerId == _unset ? this.imageServerId : imageServerId as String?,
        images: images ?? this.images,
        currentPrompt: currentPrompt ?? this.currentPrompt,
        generatedCount: generatedCount ?? this.generatedCount,
        errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
        isRunning: isRunning ?? this.isRunning,
      );

  @override
  List<Object?> get props => [
        status, mode, topic, basePrompt, mustIncludeTags, maxImages,
        selectedLoras, imageModel, llmServerId, llmModel, imageServerId,
        images, currentPrompt, generatedCount, errorMessage, isRunning,
      ];
}

class _Sentinel {
  const _Sentinel();
}

const _unset = _Sentinel();
