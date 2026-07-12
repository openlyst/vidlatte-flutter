import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/autogen/autogen_bloc.dart';
import 'bloc/gallery/gallery_bloc.dart';
import 'bloc/generation/generation_bloc.dart';
import 'bloc/llm/llm_bloc.dart';
import 'bloc/prompt_history/prompt_history_bloc.dart';
import 'bloc/servers/servers_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/studio/studio_bloc.dart';
import 'config/theme.dart';
import 'i18n/app_localizations.dart';
import 'presentation/navigation/router.dart';
import 'services/storage_service.dart';

class VidlatteApp extends StatelessWidget {
  final StorageService storageService;

  const VidlatteApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsBloc(storage: storageService)..add(SettingsLoadRequested()),
        ),
        BlocProvider(
          create: (_) => ServersBloc(storage: storageService)..add(ServersLoadRequested()),
        ),
        BlocProvider(
          create: (_) => GenerationBloc(storage: storageService),
        ),
        BlocProvider(
          create: (_) => GalleryBloc(storage: storageService)..add(GalleryLoadRequested()),
        ),
        BlocProvider(
          create: (_) => StudioBloc(storage: storageService)..add(StudioLoadRequested()),
        ),
        BlocProvider(
          create: (_) => LlmBloc(storage: storageService)..add(const LlmLoadRequested()),
        ),
        BlocProvider(
          create: (_) => AutoGenBloc(storage: storageService),
        ),
        BlocProvider(
          create: (_) => PromptHistoryBloc(storage: storageService)..add(PromptHistoryLoadRequested()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final themeMode = switch (state.settings.themeMode) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          };
          final locale = state.settings.locale == 'system'
              ? null
              : Locale(state.settings.locale);
          return MaterialApp.router(
            title: 'Vidlatte',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supported) {
              for (final loc in supported) {
                if (loc.languageCode == deviceLocale?.languageCode) {
                  return loc;
                }
              }
              return const Locale('en');
            },
            routerConfig: AppRouter.config,
          );
        },
      ),
    );
  }
}
