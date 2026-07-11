import 'package:equatable/equatable.dart';

enum Creativity { low, normal, high, max }

extension CreativityExtension on Creativity {
  String get label {
    switch (this) {
      case Creativity.low:
        return 'Low';
      case Creativity.normal:
        return 'Normal';
      case Creativity.high:
        return 'High';
      case Creativity.max:
        return 'Max';
    }
  }

  double get cfgScale {
    switch (this) {
      case Creativity.low:
        return 11;
      case Creativity.normal:
        return 7;
      case Creativity.high:
        return 4;
      case Creativity.max:
        return 1.5;
    }
  }
}

class ComfyServer extends Equatable {
  final String id;
  final String name;
  final String url;
  final int maxLoras;
  final int steps;
  final bool hiresFix;
  final bool isDefault;
  final DateTime createdAt;

  const ComfyServer({
    required this.id,
    required this.name,
    required this.url,
    this.maxLoras = 5,
    this.steps = 20,
    this.hiresFix = false,
    this.isDefault = false,
    required this.createdAt,
  });

  ComfyServer copyWith({
    String? id,
    String? name,
    String? url,
    int? maxLoras,
    int? steps,
    bool? hiresFix,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return ComfyServer(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      maxLoras: maxLoras ?? this.maxLoras,
      steps: steps ?? this.steps,
      hiresFix: hiresFix ?? this.hiresFix,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ComfyServer.fromJson(Map<String, dynamic> json) {
    return ComfyServer(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      maxLoras: json['maxLoras'] as int? ?? 5,
      steps: json['steps'] as int? ?? 20,
      hiresFix: json['hiresFix'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'maxLoras': maxLoras,
        'steps': steps,
        'hiresFix': hiresFix,
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, url, maxLoras, steps, hiresFix, isDefault, createdAt];
}
