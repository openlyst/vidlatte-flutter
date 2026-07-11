import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';

enum AppDestination {
  create(Icons.auto_awesome_outlined, Icons.auto_awesome, 'Create', '/create'),
  gallery(Icons.photo_library_outlined, Icons.photo_library, 'Gallery', '/gallery'),
  studio(Icons.dashboard_outlined, Icons.dashboard, 'Studio', '/studio'),
  settings(Icons.settings_outlined, Icons.settings, 'Settings', '/settings');

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;

  const AppDestination(this.icon, this.selectedIcon, this.label, this.path);
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
    final ext = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: ext.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ext.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: AppDestination.values.asMap().entries.map((entry) {
                final index = entry.key;
                final dest = entry.value;
                final selected = index == currentIndex;
                return Expanded(
                  child: _FloatingNavItem(
                    icon: selected ? dest.selectedIcon : dest.icon,
                    label: dest.label,
                    selected: selected,
                    onTap: () => context.go(dest.path),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ext.accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: selected ? ext.accent : ext.muted),
              if (selected) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ext.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
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
          _NavRail(currentIndex: currentIndex),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  final int currentIndex;

  const _NavRail({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const _GradientLogo(size: 36),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: AppDestination.values.length,
              itemBuilder: (context, index) {
                final dest = AppDestination.values[index];
                final selected = index == currentIndex;
                return _RailIconItem(
                  icon: selected ? dest.selectedIcon : dest.icon,
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

class _RailIconItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RailIconItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 52,
          decoration: BoxDecoration(
            color: selected ? ext.accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: selected ? ext.accent : ext.muted),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? ext.accent : ext.muted,
                ),
              ),
            ],
          ),
        ),
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
    final ext = Theme.of(context).extension<AppColors>()!;
    return Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: _GradientLogo(size: 40, showText: true),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: AppDestination.values.length,
              itemBuilder: (context, index) {
                final dest = AppDestination.values[index];
                final selected = index == currentIndex;
                return _SidebarItem(
                  icon: selected ? dest.selectedIcon : dest.icon,
                  label: dest.label,
                  selected: selected,
                  onTap: () => context.go(dest.path),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ext.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ext.border, width: 0.5),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ext.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Local', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                      Text('ComfyUI', style: TextStyle(fontSize: 11, color: ext.muted)),
                    ],
                  ),
                ),
              ],
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
    final ext = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? ext.accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? ext.accent : ext.muted),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? ext.accent : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const _GradientLogo({required this.size, this.showText = false});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: ext.accent,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Center(
            child: Text(
              'V',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.55,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            AppConfig.appName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}
