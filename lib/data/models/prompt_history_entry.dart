import 'package:equatable/equatable.dart';

class PromptHistoryEntry extends Equatable {
  final String id;
  final String prompt;
  final String? negativePrompt;
  final String? model;
  final List<String> loras;
  final DateTime createdAt;

  const PromptHistoryEntry({
    required this.id,
    required this.prompt,
    this.negativePrompt,
    this.model,
    this.loras = const [],
    required this.createdAt,
  });

  PromptHistoryEntry copyWith({
    String? id,
    String? prompt,
    String? negativePrompt,
    String? model,
    List<String>? loras,
    DateTime? createdAt,
  }) {
    return PromptHistoryEntry(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      model: model ?? this.model,
      loras: loras ?? this.loras,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PromptHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PromptHistoryEntry(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      negativePrompt: json['negativePrompt'] as String?,
      model: json['model'] as String?,
      loras: (json['loras'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'negativePrompt': negativePrompt,
        'model': model,
        'loras': loras,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, prompt, negativePrompt, model, loras, createdAt];
}
