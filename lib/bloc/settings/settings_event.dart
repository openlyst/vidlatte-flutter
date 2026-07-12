import 'package:equatable/equatable.dart';

import '../../data/models/app_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class SettingsUpdated extends SettingsEvent {
  final AppSettings settings;

  const SettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ThemeModeChanged extends SettingsEvent {
  final String themeMode;

  const ThemeModeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class DefaultServerChanged extends SettingsEvent {
  final String? serverId;

  const DefaultServerChanged(this.serverId);

  @override
  List<Object?> get props => [serverId];
}

class LastModelChanged extends SettingsEvent {
  final String model;

  const LastModelChanged(this.model);

  @override
  List<Object?> get props => [model];
}

class LastLorasChanged extends SettingsEvent {
  final List<String> loras;

  const LastLorasChanged(this.loras);

  @override
  List<Object?> get props => [loras];
}

class LastCreativityChanged extends SettingsEvent {
  final String creativity;

  const LastCreativityChanged(this.creativity);

  @override
  List<Object?> get props => [creativity];
}

class LocaleChanged extends SettingsEvent {
  final String locale;

  const LocaleChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}
