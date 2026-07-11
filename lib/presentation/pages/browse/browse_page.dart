import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/settings/lora_edit_dialog.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Models', icon: Icon(Icons.layers_outlined)),
            Tab(text: 'LoRAs', icon: Icon(Icons.style_outlined)),
          ],
        ),
      ),
      body: BlocBuilder<ServersBloc, ServersState>(
        builder: (context, state) {
          if (state.servers.isEmpty) {
            return const EmptyState(
              icon: Icons.dns_outlined,
              title: 'No Server Connected',
              message: 'Add a ComfyUI server in Settings to browse available models.',
            );
          }

          final server = state.defaultServer ?? state.servers.first;
          final catalog = state.catalogs[server.id];

          if (catalog == null) {
            context.read<ServersBloc>().add(ServerModelsFetchRequested(server.id));
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _ModelList(models: catalog.models, serverName: server.name),
              _LoraList(
                loras: catalog.loras,
                triggerWords: state.triggerWordsFor(server.id),
                disabledLoras: state.disabledLorasFor(server.id),
                serverId: server.id,
                serverName: server.name,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModelList extends StatelessWidget {
  final List<String> models;
  final String serverName;

  const _ModelList({required this.models, required this.serverName});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;

    if (models.isEmpty) {
      return const EmptyState(
        icon: Icons.layers_clear,
        title: 'No Models Found',
        message: 'Make sure your ComfyUI server has checkpoints loaded.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        final name = model.split('/').last;
        final folder = model.contains('/') ? model.substring(0, model.lastIndexOf('/')) : '';

        return _BrowseCard(
          ext: ext,
          icon: Icons.layers_outlined,
          iconColor: ext.accent,
          title: name,
          subtitle: folder.isNotEmpty ? folder : 'From: $serverName',
          trailing: _CopyButton(
            text: model,
            label: name,
            ext: ext,
          ),
        );
      },
    );
  }
}

class _LoraList extends StatelessWidget {
  final List<String> loras;
  final Map<String, String> triggerWords;
  final Set<String> disabledLoras;
  final String serverId;
  final String serverName;

  const _LoraList({
    required this.loras,
    required this.triggerWords,
    required this.disabledLoras,
    required this.serverId,
    required this.serverName,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;

    if (loras.isEmpty) {
      return const EmptyState(
        icon: Icons.style_outlined,
        title: 'No LoRAs Found',
        message: 'Make sure your ComfyUI server has LoRA models loaded.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      itemCount: loras.length,
      itemBuilder: (context, index) {
        final lora = loras[index];
        final name = lora.split('/').last;
        final folder = lora.contains('/') ? lora.substring(0, lora.lastIndexOf('/')) : '';
        final triggers = triggerWords[lora];
        final isHidden = disabledLoras.contains(lora);

        return _BrowseCard(
          ext: ext,
          dimmed: isHidden,
          icon: isHidden ? Icons.style_outlined : Icons.style,
          iconColor: isHidden ? ext.muted : ext.accent,
          title: name,
          titleStyle: isHidden
              ? TextStyle(color: ext.muted, decoration: TextDecoration.lineThrough)
              : null,
          subtitle: folder.isNotEmpty ? folder : 'From: $serverName',
          subtitleExtra: isHidden
              ? _Badge(text: 'Hidden', color: ext.muted, ext: ext)
              : triggers != null && triggers.isNotEmpty
                  ? _TriggerChips(text: triggers, ext: ext)
                  : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconButton(
                ext: ext,
                icon: isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                tooltip: isHidden ? 'Show' : 'Hide',
                active: !isHidden,
                onPressed: () {
                  final bloc = context.read<ServersBloc>();
                  final disabled = Set<String>.from(bloc.state.disabledLorasFor(serverId));
                  if (isHidden) {
                    disabled.remove(lora);
                  } else {
                    disabled.add(lora);
                  }
                  bloc.add(LoraVisibilitySaveRequested(serverId, disabled));
                },
              ),
              _IconButton(
                ext: ext,
                icon: Icons.edit_outlined,
                tooltip: 'Edit LoRA',
                onPressed: () {
                  final bloc = context.read<ServersBloc>();
                  final existing = bloc.state.loraMetadata[serverId]
                      ?.where((m) => m.loraName == lora)
                      .firstOrNull;
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: LoraEditDialog(
                        serverId: serverId,
                        loraName: lora,
                        existing: existing,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrowseCard extends StatelessWidget {
  final AppColors ext;
  final IconData icon;
  final Color iconColor;
  final String title;
  final TextStyle? titleStyle;
  final String subtitle;
  final Widget? subtitleExtra;
  final Widget? trailing;
  final bool dimmed;

  const _BrowseCard({
    required this.ext,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleExtra,
    this.trailing,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: ext.surfaceElevated.withValues(alpha: dimmed ? 0.5 : 1.0),
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        border: Border.all(color: ext.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: ThemeConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle ?? theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
                if (subtitleExtra != null) ...[
                  const SizedBox(height: ThemeConstants.spacingSmall),
                  subtitleExtra!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: ThemeConstants.spacingSmall),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _TriggerChips extends StatelessWidget {
  final String text;
  final AppColors ext;

  const _TriggerChips({required this.text, required this.ext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Wrap(
      spacing: ThemeConstants.spacingXSmall,
      runSpacing: ThemeConstants.spacingXSmall,
      children: tags
          .map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ext.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
                  border: Border.all(color: ext.accent.withValues(alpha: 0.25), width: 0.5),
                ),
                child: Text(
                  t,
                  style: theme.textTheme.labelSmall?.copyWith(color: ext.accent),
                ),
              ))
          .toList(),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final AppColors ext;

  const _Badge({required this.text, required this.color, required this.ext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
      ),
      child: Text(text, style: theme.textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}

class _IconButton extends StatelessWidget {
  final AppColors ext;
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onPressed;

  const _IconButton({
    required this.ext,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            color: active ? ext.accent.withValues(alpha: 0.12) : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
              side: BorderSide(
                color: active ? ext.accent.withValues(alpha: 0.3) : ext.border,
                width: 0.5,
              ),
            ),
            child: InkWell(
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: 18,
                  color: active ? ext.accent : ext.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String text;
  final String label;
  final AppColors ext;

  const _CopyButton({required this.text, required this.label, required this.ext});

  @override
  Widget build(BuildContext context) {
    return _IconButton(
      ext: ext,
      icon: Icons.copy_outlined,
      tooltip: 'Copy name',
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied: $label')),
        );
      },
    );
  }
}
