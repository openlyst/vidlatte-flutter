import 'package:equatable/equatable.dart';

import '../../data/models/app_settings.dart';

class SettingsState extends Equatable {
  final AppSettings settings;
  final bool isLoading;

  const SettingsState({
    this.settings = const AppSettings(),
    this.isLoading = false,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading];
}
