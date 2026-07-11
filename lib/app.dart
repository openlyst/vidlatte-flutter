import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/autogen/autogen_bloc.dart';
import 'bloc/gallery/gallery_bloc.dart';
import 'bloc/generation/generation_bloc.dart';
import 'bloc/llm/llm_bloc.dart';
import 'bloc/servers/servers_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/studio/studio_bloc.dart';
import 'config/theme.dart';
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
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final themeMode = switch (state.settings.themeMode) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          };
          return MaterialApp.router(
            title: 'Vidlatte',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.config,
          );
        },
      ),
    );
  }
}
