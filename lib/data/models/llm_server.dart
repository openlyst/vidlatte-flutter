import 'package:equatable/equatable.dart';

class LlmServer extends Equatable {
  final String id;
  final String name;
  final String url;
  final String? apiKey;
  final String? defaultModel;
  final bool isEnabled;
  final DateTime createdAt;

  const LlmServer({
    required this.id,
    required this.name,
    required this.url,
    this.apiKey,
    this.defaultModel,
    this.isEnabled = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'apiKey': apiKey,
        'defaultModel': defaultModel,
        'isEnabled': isEnabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LlmServer.fromJson(Map<String, dynamic> json) => LlmServer(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        apiKey: json['apiKey'] as String?,
        defaultModel: json['defaultModel'] as String?,
        isEnabled: (json['isEnabled'] as bool?) ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  LlmServer copyWith({
    String? id,
    String? name,
    String? url,
    Object? apiKey = _unset,
    Object? defaultModel = _unset,
    bool? isEnabled,
    DateTime? createdAt,
  }) =>
      LlmServer(
        id: id ?? this.id,
        name: name ?? this.name,
        url: url ?? this.url,
        apiKey: apiKey == _unset ? this.apiKey : apiKey as String?,
        defaultModel: defaultModel == _unset ? this.defaultModel : defaultModel as String?,
        isEnabled: isEnabled ?? this.isEnabled,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, name, url, apiKey, defaultModel, isEnabled, createdAt];
}

class _Sentinel {
  const _Sentinel();
}

const _unset = _Sentinel();
