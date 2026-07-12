import 'dart:convert';

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

enum ServerAuthType { none, basic, bearer }

extension ServerAuthTypeExtension on ServerAuthType {
  String get name {
    switch (this) {
      case ServerAuthType.none:
        return 'none';
      case ServerAuthType.basic:
        return 'basic';
      case ServerAuthType.bearer:
        return 'bearer';
    }
  }

  static ServerAuthType fromString(String value) {
    switch (value) {
      case 'basic':
        return ServerAuthType.basic;
      case 'bearer':
        return ServerAuthType.bearer;
      default:
        return ServerAuthType.none;
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
  final ServerAuthType authType;
  final String? authUsername;
  final String? authPassword;
  final String? authToken;
  final DateTime createdAt;

  const ComfyServer({
    required this.id,
    required this.name,
    required this.url,
    this.maxLoras = 5,
    this.steps = 20,
    this.hiresFix = false,
    this.isDefault = false,
    this.authType = ServerAuthType.none,
    this.authUsername,
    this.authPassword,
    this.authToken,
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
    ServerAuthType? authType,
    String? authUsername,
    String? authPassword,
    String? authToken,
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
      authType: authType ?? this.authType,
      authUsername: authUsername ?? this.authUsername,
      authPassword: authPassword ?? this.authPassword,
      authToken: authToken ?? this.authToken,
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
      authType: ServerAuthTypeExtension.fromString(json['authType'] as String? ?? 'none'),
      authUsername: json['authUsername'] as String?,
      authPassword: json['authPassword'] as String?,
      authToken: json['authToken'] as String?,
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
        'authType': authType.name,
        'authUsername': authUsername,
        'authPassword': authPassword,
        'authToken': authToken,
        'createdAt': createdAt.toIso8601String(),
      };

  Map<String, dynamic> authHeaders() {
    switch (authType) {
      case ServerAuthType.basic:
        if (authUsername != null && authPassword != null) {
          final credentials = base64Encode(utf8.encode('$authUsername:$authPassword'));
          return {'Authorization': 'Basic $credentials'};
        }
        return {};
      case ServerAuthType.bearer:
        if (authToken != null) {
          return {'Authorization': 'Bearer $authToken'};
        }
        return {};
      default:
        return {};
    }
  }

  @override
  List<Object?> get props => [id, name, url, maxLoras, steps, hiresFix, isDefault, authType, authUsername, authPassword, authToken, createdAt];
}
