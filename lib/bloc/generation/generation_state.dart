import 'package:equatable/equatable.dart';

import '../../data/models/generated_image.dart';
import '../../data/models/generation_job.dart';

enum GenerationStatus { idle, generating, success, error }

class GenerationState extends Equatable {
  final GenerationStatus status;
  final List<GenerationJob> queue;
  final GenerationJob? currentJob;
  final List<GeneratedImage> images;
  final String? errorMessage;

  const GenerationState({
    this.status = GenerationStatus.idle,
    this.queue = const [],
    this.currentJob,
    this.images = const [],
    this.errorMessage,
  });

  List<GenerationJob> get activeJobs {
    final jobs = <GenerationJob>[];
    if (currentJob != null && !currentJob!.isDone) jobs.add(currentJob!);
    jobs.addAll(queue);
    return jobs;
  }

  bool get isProcessing => currentJob != null && !currentJob!.isDone;

  GenerationState copyWith({
    GenerationStatus? status,
    List<GenerationJob>? queue,
    Object? currentJob = _sentinel,
    List<GeneratedImage>? images,
    Object? errorMessage = _errorSentinel,
  }) {
    return GenerationState(
      status: status ?? this.status,
      queue: queue ?? this.queue,
      currentJob: identical(currentJob, _sentinel)
          ? this.currentJob
          : currentJob as GenerationJob?,
      images: images ?? this.images,
      errorMessage: identical(errorMessage, _errorSentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, queue, currentJob, images, errorMessage];
}

const _sentinel = Object();
const _errorSentinel = Object();
