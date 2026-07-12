import 'package:equatable/equatable.dart';

import 'comfy_server.dart';

enum ImageStatus { pending, processing, completed, failed }

extension ImageStatusExtension on ImageStatus {
  String get name {
    switch (this) {
      case ImageStatus.pending:
        return 'pending';
      case ImageStatus.processing:
        return 'processing';
      case ImageStatus.completed:
        return 'completed';
      case ImageStatus.failed:
        return 'failed';
    }
  }

  static ImageStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ImageStatus.pending;
      case 'processing':
        return ImageStatus.processing;
      case 'completed':
        return ImageStatus.completed;
      case 'failed':
        return ImageStatus.failed;
      default:
        return ImageStatus.pending;
    }
  }
}

class GeneratedImage extends Equatable {
  final String id;
  final String prompt;
  final String negativePrompt;
  final String model;
  final List<String> loras;
  final Map<String, double> loraWeights;
  final Creativity creativity;
  final int? steps;
  final bool hiresFix;
  final int width;
  final int height;
  final int seed;
  final ImageStatus status;
  final String? localPath;
  final String? serverUrl;
  final String? comfyFilename;
  final String? comfySubfolder;
  final String? comfyType;
  final String? errorMessage;
  final bool isFavorite;
  final bool isHidden;
  final String? collectionId;
  final DateTime createdAt;
  final DateTime? completedAt;

  const GeneratedImage({
    required this.id,
    required this.prompt,
    this.negativePrompt = '',
    required this.model,
    this.loras = const [],
    this.loraWeights = const {},
    this.creativity = Creativity.normal,
    this.steps,
    this.hiresFix = false,
    this.width = 1024,
    this.height = 1024,
    this.seed = 0,
    this.status = ImageStatus.pending,
    this.localPath,
    this.serverUrl,
    this.comfyFilename,
    this.comfySubfolder,
    this.comfyType,
    this.errorMessage,
    this.isFavorite = false,
    this.isHidden = false,
    this.collectionId,
    required this.createdAt,
    this.completedAt,
  });

  GeneratedImage copyWith({
    String? id,
    String? prompt,
    String? negativePrompt,
    String? model,
    List<String>? loras,
    Map<String, double>? loraWeights,
    Creativity? creativity,
    int? steps,
    bool? hiresFix,
    int? width,
    int? height,
    int? seed,
    ImageStatus? status,
    String? localPath,
    String? serverUrl,
    String? comfyFilename,
    String? comfySubfolder,
    String? comfyType,
    String? errorMessage,
    bool? isFavorite,
    bool? isHidden,
    String? collectionId,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return GeneratedImage(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      model: model ?? this.model,
      loras: loras ?? this.loras,
      loraWeights: loraWeights ?? this.loraWeights,
      creativity: creativity ?? this.creativity,
      steps: steps ?? this.steps,
      hiresFix: hiresFix ?? this.hiresFix,
      width: width ?? this.width,
      height: height ?? this.height,
      seed: seed ?? this.seed,
      status: status ?? this.status,
      localPath: localPath ?? this.localPath,
      serverUrl: serverUrl ?? this.serverUrl,
      comfyFilename: comfyFilename ?? this.comfyFilename,
      comfySubfolder: comfySubfolder ?? this.comfySubfolder,
      comfyType: comfyType ?? this.comfyType,
      errorMessage: errorMessage ?? this.errorMessage,
      isFavorite: isFavorite ?? this.isFavorite,
      isHidden: isHidden ?? this.isHidden,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      negativePrompt: json['negativePrompt'] as String? ?? '',
      model: json['model'] as String,
      loras: (json['loras'] as List?)?.map((e) => e as String).toList() ?? [],
      loraWeights: (json['loraWeights'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
      creativity: _parseCreativity(json['creativity'] as String? ?? 'normal'),
      steps: json['steps'] as int?,
      hiresFix: json['hiresFix'] as bool? ?? false,
      width: json['width'] as int? ?? 1024,
      height: json['height'] as int? ?? 1024,
      seed: json['seed'] as int? ?? 0,
      status: ImageStatusExtension.fromString(json['status'] as String? ?? 'pending'),
      localPath: json['localPath'] as String?,
      serverUrl: json['serverUrl'] as String?,
      comfyFilename: json['comfyFilename'] as String?,
      comfySubfolder: json['comfySubfolder'] as String?,
      comfyType: json['comfyType'] as String?,
      errorMessage: json['errorMessage'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
      collectionId: json['collectionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'negativePrompt': negativePrompt,
        'model': model,
        'loras': loras,
        'loraWeights': loraWeights,
        'creativity': creativity.name,
        'steps': steps,
        'hiresFix': hiresFix,
        'width': width,
        'height': height,
        'seed': seed,
        'status': status.name,
        'localPath': localPath,
        'serverUrl': serverUrl,
        'comfyFilename': comfyFilename,
        'comfySubfolder': comfySubfolder,
        'comfyType': comfyType,
        'errorMessage': errorMessage,
        'isFavorite': isFavorite,
        'isHidden': isHidden,
        'collectionId': collectionId,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  static Creativity _parseCreativity(String value) {
    switch (value) {
      case 'low':
        return Creativity.low;
      case 'high':
        return Creativity.high;
      case 'max':
        return Creativity.max;
      default:
        return Creativity.normal;
    }
  }

  @override
  List<Object?> get props => [
        id, prompt, negativePrompt, model, loras, loraWeights, creativity, steps, hiresFix,
        width, height, seed, status, localPath, serverUrl,
        comfyFilename, comfySubfolder, comfyType, errorMessage,
        isFavorite, isHidden, collectionId, createdAt, completedAt,
      ];
}
