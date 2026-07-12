import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String themeMode;
  final String locale;
  final String? defaultServerId;
  final String lastModel;
  final List<String> lastLoras;
  final String lastCreativity;
  final int? lastCustomSteps;
  final bool? lastHiresFix;
  final double? lastCustomCfg;
  final int lastWidth;
  final int lastHeight;
  final String lastPrompt;
  final String lastNegativePrompt;
  final Map<String, double> lastLoraWeights;
  final bool saveToGallery;
  final bool downloadLocally;
  final String? galleryPassword;

  const AppSettings({
    this.themeMode = 'system',
    this.locale = 'system',
    this.defaultServerId,
    this.lastModel = '',
    this.lastLoras = const [],
    this.lastCreativity = 'normal',
    this.lastCustomSteps,
    this.lastHiresFix,
    this.lastCustomCfg,
    this.lastWidth = 768,
    this.lastHeight = 768,
    this.lastPrompt = '',
    this.lastNegativePrompt = '',
    this.lastLoraWeights = const {},
    this.saveToGallery = true,
    this.downloadLocally = true,
    this.galleryPassword,
  });

  AppSettings copyWith({
    String? themeMode,
    String? locale,
    String? defaultServerId,
    String? lastModel,
    List<String>? lastLoras,
    String? lastCreativity,
    int? lastCustomSteps,
    bool? lastHiresFix,
    double? lastCustomCfg,
    int? lastWidth,
    int? lastHeight,
    String? lastPrompt,
    String? lastNegativePrompt,
    Map<String, double>? lastLoraWeights,
    bool? saveToGallery,
    bool? downloadLocally,
    Object? galleryPassword = _sentinel,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      defaultServerId: defaultServerId ?? this.defaultServerId,
      lastModel: lastModel ?? this.lastModel,
      lastLoras: lastLoras ?? this.lastLoras,
      lastCreativity: lastCreativity ?? this.lastCreativity,
      lastCustomSteps: lastCustomSteps ?? this.lastCustomSteps,
      lastHiresFix: lastHiresFix ?? this.lastHiresFix,
      lastCustomCfg: lastCustomCfg ?? this.lastCustomCfg,
      lastWidth: lastWidth ?? this.lastWidth,
      lastHeight: lastHeight ?? this.lastHeight,
      lastPrompt: lastPrompt ?? this.lastPrompt,
      lastNegativePrompt: lastNegativePrompt ?? this.lastNegativePrompt,
      lastLoraWeights: lastLoraWeights ?? this.lastLoraWeights,
      saveToGallery: saveToGallery ?? this.saveToGallery,
      downloadLocally: downloadLocally ?? this.downloadLocally,
      galleryPassword: identical(galleryPassword, _sentinel)
          ? this.galleryPassword
          : galleryPassword as String?,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] as String? ?? 'system',
      locale: json['locale'] as String? ?? 'system',
      defaultServerId: json['defaultServerId'] as String?,
      lastModel: json['lastModel'] as String? ?? '',
      lastLoras: (json['lastLoras'] as List?)?.map((e) => e as String).toList() ?? [],
      lastCreativity: json['lastCreativity'] as String? ?? 'normal',
      lastCustomSteps: json['lastCustomSteps'] as int?,
      lastHiresFix: json['lastHiresFix'] as bool?,
      lastCustomCfg: (json['lastCustomCfg'] as num?)?.toDouble(),
      lastWidth: json['lastWidth'] as int? ?? 768,
      lastHeight: json['lastHeight'] as int? ?? 768,
      lastPrompt: json['lastPrompt'] as String? ?? '',
      lastNegativePrompt: json['lastNegativePrompt'] as String? ?? '',
      lastLoraWeights: (json['lastLoraWeights'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
      saveToGallery: json['saveToGallery'] as bool? ?? true,
      downloadLocally: json['downloadLocally'] as bool? ?? true,
      galleryPassword: json['galleryPassword'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'locale': locale,
        'defaultServerId': defaultServerId,
        'lastModel': lastModel,
        'lastLoras': lastLoras,
        'lastCreativity': lastCreativity,
        'lastCustomSteps': lastCustomSteps,
        'lastHiresFix': lastHiresFix,
        'lastCustomCfg': lastCustomCfg,
        'lastWidth': lastWidth,
        'lastHeight': lastHeight,
        'lastPrompt': lastPrompt,
        'lastNegativePrompt': lastNegativePrompt,
        'lastLoraWeights': lastLoraWeights,
        'saveToGallery': saveToGallery,
        'downloadLocally': downloadLocally,
        'galleryPassword': galleryPassword,
      };

  @override
  List<Object?> get props => [
        themeMode, locale, defaultServerId, lastModel, lastLoras, lastCreativity,
        lastCustomSteps, lastHiresFix, lastCustomCfg, lastWidth, lastHeight,
        lastPrompt, lastNegativePrompt, lastLoraWeights, saveToGallery, downloadLocally, galleryPassword,
      ];
}

const _sentinel = Object();
