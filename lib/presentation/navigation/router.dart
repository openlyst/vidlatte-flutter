import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/auto_image/auto_image_page.dart';
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
            pageBuilder: (context, state) => _noTransitionPage(const CreatePage()),
            builder: (context, state) => const CreatePage(),
          ),
          GoRoute(
            path: '/gallery',
            pageBuilder: (context, state) => _noTransitionPage(const GalleryPage()),
            builder: (context, state) => const GalleryPage(),
          ),
          GoRoute(
            path: '/studio',
            pageBuilder: (context, state) => _noTransitionPage(const StudioPage()),
            builder: (context, state) => const StudioPage(),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _noTransitionPage(const SettingsPage()),
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/auto-image',
        pageBuilder: (context, state) => _noTransitionPage(const AutoImagePage()),
        builder: (context, state) => const AutoImagePage(),
      ),
      GoRoute(
        path: '/browse',
        pageBuilder: (context, state) => _noTransitionPage(const BrowsePage()),
        builder: (context, state) => const BrowsePage(),
      ),
    ],
  );

  static CustomTransitionPage _noTransitionPage(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  static int _indexFromLocation(String location) {
    for (var i = 0; i < AppDestination.values.length; i++) {
      if (location.startsWith(AppDestination.values[i].path)) return i;
    }
    return 0;
  }
}
