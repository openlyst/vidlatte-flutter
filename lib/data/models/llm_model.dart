import 'package:equatable/equatable.dart';

class LlmModel extends Equatable {
  final String identifier;
  final String displayName;
  final bool isLoaded;

  const LlmModel({
    required this.identifier,
    required this.displayName,
    this.isLoaded = false,
  });

  factory LlmModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['identifier'] as String? ?? '';
    return LlmModel(
      identifier: id,
      displayName: json['displayName'] as String? ?? id,
      isLoaded: (json['isLoaded'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [identifier, displayName, isLoaded];
}

class LlmChatMessage extends Equatable {
  final String role;
  final String content;

  const LlmChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  factory LlmChatMessage.system(String content) => LlmChatMessage(role: 'system', content: content);
  factory LlmChatMessage.user(String content) => LlmChatMessage(role: 'user', content: content);
  factory LlmChatMessage.assistant(String content) =>
      LlmChatMessage(role: 'assistant', content: content);

  @override
  List<Object?> get props => [role, content];
}

class LlmChatResult extends Equatable {
  final bool success;
  final String content;
  final String? error;

  const LlmChatResult({
    required this.success,
    this.content = '',
    this.error,
  });

  @override
  List<Object?> get props => [success, content, error];
}
