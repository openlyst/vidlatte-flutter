import 'package:equatable/equatable.dart';

import 'generated_image.dart';

class StudioSession extends Equatable {
  final String id;
  final String title;
  final String prompt;
  final String model;
  final List<String> loras;
  final List<GeneratedImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudioSession({
    required this.id,
    required this.title,
    this.prompt = '',
    this.model = '',
    this.loras = const [],
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  StudioSession copyWith({
    String? id,
    String? title,
    String? prompt,
    String? model,
    List<String>? loras,
    List<GeneratedImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudioSession(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      model: model ?? this.model,
      loras: loras ?? this.loras,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StudioSession.fromJson(Map<String, dynamic> json) {
    return StudioSession(
      id: json['id'] as String,
      title: json['title'] as String,
      prompt: json['prompt'] as String? ?? '',
      model: json['model'] as String? ?? '',
      loras: (json['loras'] as List?)?.map((e) => e as String).toList() ?? [],
      images: (json['images'] as List?)
              ?.map((e) => GeneratedImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'prompt': prompt,
        'model': model,
        'loras': loras,
        'images': images.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, title, prompt, model, loras, images, createdAt, updatedAt];
}
