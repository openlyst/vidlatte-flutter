import 'package:equatable/equatable.dart';

import '../../data/models/generated_image.dart';
import '../../data/models/generation_job.dart';

enum GenerationStatus { idle, generating, success, error }

class GenerationState extends Equatable {
  final GenerationStatus status;
  final List<GenerationJob> activeJobs;
  final List<GeneratedImage> images;
  final String? errorMessage;

  const GenerationState({
    this.status = GenerationStatus.idle,
    this.activeJobs = const [],
    this.images = const [],
    this.errorMessage,
  });

  GenerationState copyWith({
    GenerationStatus? status,
    List<GenerationJob>? activeJobs,
    List<GeneratedImage>? images,
    String? errorMessage,
  }) {
    return GenerationState(
      status: status ?? this.status,
      activeJobs: activeJobs ?? this.activeJobs,
      images: images ?? this.images,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, activeJobs, images, errorMessage];
}
