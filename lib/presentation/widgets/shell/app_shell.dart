import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';

enum AppDestination {
  create(Icons.auto_awesome, 'Create', '/create'),
  studio(Icons.dashboard_outlined, 'Studio', '/studio'),
  gallery(Icons.photo_library_outlined, 'Gallery', '/gallery'),
  browse(Icons.explore_outlined, 'Browse', '/browse'),
  settings(Icons.settings_outlined, 'Settings', '/settings');

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;

  const AppDestination(this.icon, this.label, this.path) : selectedIcon = icon;
}

class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= ThemeConstants.desktopBreakpoint) {
      return _DesktopShell(child: child, currentIndex: currentIndex);
    }

    if (width >= ThemeConstants.tabletBreakpoint) {
      return _TabletShell(child: child, currentIndex: currentIndex);
    }

    return _PhoneShell(child: child, currentIndex: currentIndex);
  }
}

class _PhoneShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const _PhoneShell({required this.child, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(AppDestination.values[index].path),
        destinations: AppDestination.values.map((d) {
          return NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
          );
        }).toList(),
      ),
    );
  }
}

class _TabletShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const _TabletShell({required this.child, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => context.go(AppDestination.values[index].path),
            extended: false,
            labelType: NavigationRailLabelType.all,
            leading: _Logo(),
            destinations: AppDestination.values.map((d) {
              return NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: Text(d.label),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const _DesktopShell({required this.child, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(currentIndex: currentIndex),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;

  const _DesktopSidebar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingMedium),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: ThemeConstants.spacingLarge),
            child: _Logo(),
          ),
          const SizedBox(height: ThemeConstants.spacingLarge),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
              itemCount: AppDestination.values.length,
              itemBuilder: (context, index) {
                final dest = AppDestination.values[index];
                final selected = index == currentIndex;
                return _SidebarItem(
                  icon: dest.icon,
                  label: dest.label,
                  selected: selected,
                  onTap: () => context.go(dest.path),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? theme.colorScheme.secondary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingMedium,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: ThemeConstants.spacingMedium),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? theme.colorScheme.secondary : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'V',
              style: TextStyle(
                color: theme.colorScheme.onSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: ThemeConstants.spacingSmall),
        Text(
          AppConfig.appName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
