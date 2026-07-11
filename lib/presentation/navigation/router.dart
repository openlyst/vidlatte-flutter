import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/browse/browse_page.dart';
import '../pages/create/create_page.dart';
import '../pages/gallery/gallery_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/studio/studio_page.dart';
import '../widgets/shell/app_shell.dart';

class AppRouter {
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final config = GoRouter(
    navigatorKey: _shellNavigatorKey,
    initialLocation: '/create',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final index = _indexFromLocation(state.uri.toString());
          return AppShell(child: child, currentIndex: index);
        },
        routes: [
          GoRoute(
            path: '/create',
            builder: (context, state) => const CreatePage(),
          ),
          GoRoute(
            path: '/studio',
            builder: (context, state) => const StudioPage(),
          ),
          GoRoute(
            path: '/gallery',
            builder: (context, state) => const GalleryPage(),
          ),
          GoRoute(
            path: '/browse',
            builder: (context, state) => const BrowsePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );

  static int _indexFromLocation(String location) {
    for (var i = 0; i < AppDestination.values.length; i++) {
      if (location.startsWith(AppDestination.values[i].path)) return i;
    }
    return 0;
  }
}
