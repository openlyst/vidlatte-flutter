import 'package:equatable/equatable.dart';

import 'comfy_server.dart';

enum JobStatus { queued, executing, progress, completed, failed, cancelled }

extension JobStatusExtension on JobStatus {
  String get name {
    switch (this) {
      case JobStatus.queued:
        return 'queued';
      case JobStatus.executing:
        return 'executing';
      case JobStatus.progress:
        return 'progress';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.failed:
        return 'failed';
      case JobStatus.cancelled:
        return 'cancelled';
    }
  }

  static JobStatus fromString(String value) {
    switch (value) {
      case 'queued':
        return JobStatus.queued;
      case 'executing':
        return JobStatus.executing;
      case 'progress':
        return JobStatus.progress;
      case 'completed':
        return JobStatus.completed;
      case 'failed':
        return JobStatus.failed;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        return JobStatus.queued;
    }
  }
}

class GenerationJob extends Equatable {
  final String id;
  final String prompt;
  final String model;
  final List<String> loras;
  final Creativity creativity;
  final double? cfg;
  final int steps;
  final bool hiresFix;
  final int width;
  final int height;
  final int seed;
  final String serverId;
  final String? serverUrl;
  final JobStatus status;
  final int? progressValue;
  final int? progressMax;
  final String? currentNode;
  final String? previewBase64;
  final String? resultLocalPath;
  final String? resultFilename;
  final String? resultSubfolder;
  final String? resultType;
  final String? errorMessage;
  final int attempts;
  final int maxAttempts;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const GenerationJob({
    required this.id,
    required this.prompt,
    required this.model,
    this.loras = const [],
    this.creativity = Creativity.normal,
    this.cfg,
    this.steps = 20,
    this.hiresFix = false,
    this.width = 1024,
    this.height = 1024,
    this.seed = 0,
    required this.serverId,
    this.serverUrl,
    this.status = JobStatus.queued,
    this.progressValue,
    this.progressMax,
    this.currentNode,
    this.previewBase64,
    this.resultLocalPath,
    this.resultFilename,
    this.resultSubfolder,
    this.resultType,
    this.errorMessage,
    this.attempts = 0,
    this.maxAttempts = 3,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  GenerationJob copyWith({
    String? id,
    String? prompt,
    String? model,
    List<String>? loras,
    Creativity? creativity,
    double? cfg,
    int? steps,
    bool? hiresFix,
    int? width,
    int? height,
    int? seed,
    String? serverId,
    String? serverUrl,
    JobStatus? status,
    int? progressValue,
    int? progressMax,
    String? currentNode,
    String? previewBase64,
    String? resultLocalPath,
    String? resultFilename,
    String? resultSubfolder,
    String? resultType,
    String? errorMessage,
    int? attempts,
    int? maxAttempts,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return GenerationJob(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      model: model ?? this.model,
      loras: loras ?? this.loras,
      creativity: creativity ?? this.creativity,
      cfg: cfg ?? this.cfg,
      steps: steps ?? this.steps,
      hiresFix: hiresFix ?? this.hiresFix,
      width: width ?? this.width,
      height: height ?? this.height,
      seed: seed ?? this.seed,
      serverId: serverId ?? this.serverId,
      serverUrl: serverUrl ?? this.serverUrl,
      status: status ?? this.status,
      progressValue: progressValue ?? this.progressValue,
      progressMax: progressMax ?? this.progressMax,
      currentNode: currentNode ?? this.currentNode,
      previewBase64: previewBase64 ?? this.previewBase64,
      resultLocalPath: resultLocalPath ?? this.resultLocalPath,
      resultFilename: resultFilename ?? this.resultFilename,
      resultSubfolder: resultSubfolder ?? this.resultSubfolder,
      resultType: resultType ?? this.resultType,
      errorMessage: errorMessage ?? this.errorMessage,
      attempts: attempts ?? this.attempts,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  double? get progressFraction {
    if (progressMax == null || progressMax == 0 || progressValue == null) return null;
    return (progressValue! / progressMax!).clamp(0.0, 1.0);
  }

  bool get isComplete => status == JobStatus.completed;
  bool get isFailed => status == JobStatus.failed;
  bool get isCancelled => status == JobStatus.cancelled;
  bool get isDone => isComplete || isFailed || isCancelled;
  bool get isActive => !isDone;

  @override
  List<Object?> get props => [
        id, prompt, model, loras, creativity, cfg, steps, hiresFix,
        width, height, seed, serverId, serverUrl, status,
        progressValue, progressMax, currentNode, previewBase64,
        resultLocalPath, resultFilename, resultSubfolder, resultType,
        errorMessage, attempts, maxAttempts, createdAt, startedAt, completedAt,
      ];
}
