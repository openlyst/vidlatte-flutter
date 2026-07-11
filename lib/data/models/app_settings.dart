import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String themeMode;
  final String? defaultServerId;
  final String lastModel;
  final List<String> lastLoras;
  final String lastCreativity;
  final int? lastCustomSteps;
  final bool? lastHiresFix;
  final bool saveToGallery;
  final bool downloadLocally;

  const AppSettings({
    this.themeMode = 'system',
    this.defaultServerId,
    this.lastModel = '',
    this.lastLoras = const [],
    this.lastCreativity = 'normal',
    this.lastCustomSteps,
    this.lastHiresFix,
    this.saveToGallery = true,
    this.downloadLocally = true,
  });

  AppSettings copyWith({
    String? themeMode,
    String? defaultServerId,
    String? lastModel,
    List<String>? lastLoras,
    String? lastCreativity,
    int? lastCustomSteps,
    bool? lastHiresFix,
    bool? saveToGallery,
    bool? downloadLocally,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultServerId: defaultServerId ?? this.defaultServerId,
      lastModel: lastModel ?? this.lastModel,
      lastLoras: lastLoras ?? this.lastLoras,
      lastCreativity: lastCreativity ?? this.lastCreativity,
      lastCustomSteps: lastCustomSteps ?? this.lastCustomSteps,
      lastHiresFix: lastHiresFix ?? this.lastHiresFix,
      saveToGallery: saveToGallery ?? this.saveToGallery,
      downloadLocally: downloadLocally ?? this.downloadLocally,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] as String? ?? 'system',
      defaultServerId: json['defaultServerId'] as String?,
      lastModel: json['lastModel'] as String? ?? '',
      lastLoras: (json['lastLoras'] as List?)?.map((e) => e as String).toList() ?? [],
      lastCreativity: json['lastCreativity'] as String? ?? 'normal',
      lastCustomSteps: json['lastCustomSteps'] as int?,
      lastHiresFix: json['lastHiresFix'] as bool?,
      saveToGallery: json['saveToGallery'] as bool? ?? true,
      downloadLocally: json['downloadLocally'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'defaultServerId': defaultServerId,
        'lastModel': lastModel,
        'lastLoras': lastLoras,
        'lastCreativity': lastCreativity,
        'lastCustomSteps': lastCustomSteps,
        'lastHiresFix': lastHiresFix,
        'saveToGallery': saveToGallery,
        'downloadLocally': downloadLocally,
      };

  @override
  List<Object?> get props => [
        themeMode, defaultServerId, lastModel, lastLoras, lastCreativity,
        lastCustomSteps, lastHiresFix, saveToGallery, downloadLocally,
      ];
}
