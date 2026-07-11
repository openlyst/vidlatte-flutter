import 'package:equatable/equatable.dart';

class LoraMetadata extends Equatable {
  final String serverId;
  final String loraName;
  final String triggerWords;
  final bool isEnabled;
  final DateTime updatedAt;

  const LoraMetadata({
    required this.serverId,
    required this.loraName,
    this.triggerWords = '',
    this.isEnabled = true,
    required this.updatedAt,
  });

  String get displayName => loraName.split('/').last;

  LoraMetadata copyWith({
    String? triggerWords,
    bool? isEnabled,
    DateTime? updatedAt,
  }) =>
      LoraMetadata(
        serverId: serverId,
        loraName: loraName,
        triggerWords: triggerWords ?? this.triggerWords,
        isEnabled: isEnabled ?? this.isEnabled,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'serverId': serverId,
        'loraName': loraName,
        'triggerWords': triggerWords,
        'isEnabled': isEnabled,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory LoraMetadata.fromJson(Map<String, dynamic> json) => LoraMetadata(
        serverId: json['serverId'] as String,
        loraName: json['loraName'] as String,
        triggerWords: (json['triggerWords'] as String?) ?? '',
        isEnabled: (json['isEnabled'] as bool?) ?? true,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [serverId, loraName, triggerWords, isEnabled, updatedAt];
}
