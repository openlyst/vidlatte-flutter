import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/llm/llm_bloc.dart';
import '../../../bloc/servers/servers_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/comfy_server.dart';
import '../../../data/models/llm_server.dart';
import '../../../data/models/model_catalog.dart';
import '../../widgets/common/empty_state.dart';
import '../../../i18n/app_strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ThemeConstants.spacingLarge,
          ThemeConstants.spacingMedium,
          ThemeConstants.spacingLarge,
          ThemeConstants.spacingXLarge,
        ),
        children: [
          _ThemeSection(),
          const SizedBox(height: ThemeConstants.spacingLarge),
          _LanguageSection(),
          const SizedBox(height: ThemeConstants.spacingLarge),
          _ServersSection(),
          const SizedBox(height: ThemeConstants.spacingLarge),
          _LlmServersSection(),
          const SizedBox(height: ThemeConstants.spacingLarge),
          _GalleryPrivacySection(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
      decoration: BoxDecoration(
        color: ext.surfaceElevated,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        border: Border.all(color: ext.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineSmall),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          ...children,
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final s = AppStrings.of(context);
    final settings = context.watch<SettingsBloc>().state.settings;
    return _SectionCard(
      title: s.appearance,
      subtitle: s.appearanceSubtitle,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ext.surfaceElevated,
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
            border: Border.all(color: ext.border, width: 0.5),
          ),
          child: Row(
            children: [
              for (final mode in [
                ('system', s.system, Icons.brightness_auto_outlined),
                ('light', s.light, Icons.light_mode_outlined),
                ('dark', s.dark, Icons.dark_mode_outlined),
              ])
                Expanded(
                  child: _ThemeOption(
                    label: mode.$2,
                    icon: mode.$3,
                    selected: settings.themeMode == mode.$1,
                    onTap: () => context
                        .read<SettingsBloc>()
                        .add(ThemeModeChanged(mode.$1)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? ext.accent.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: selected ? ext.accent : ext.muted),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? ext.accent : ext.muted,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final settings = context.watch<SettingsBloc>().state.settings;
    final ext = Theme.of(context).extension<AppColors>()!;

    const options = [
      ('system', 'System', Icons.language),
      ('en', 'English', Icons.language),
      ('zh', '简体中文', Icons.language),
      ('ru', 'Русский', Icons.language),
    ];

    return _SectionCard(
      title: s.language,
      subtitle: s.languageSubtitle,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ext.surfaceElevated,
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
            border: Border.all(color: ext.border, width: 0.5),
          ),
          child: Row(
            children: [
              for (final opt in options)
                Expanded(
                  child: _ThemeOption(
                    label: opt.$2,
                    icon: opt.$3,
                    selected: settings.locale == opt.$1,
                    onTap: () => context
                        .read<SettingsBloc>()
                        .add(LocaleChanged(opt.$1)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServersBloc, ServersState>(
      builder: (context, state) {
        final s = AppStrings.of(context);
        return _SectionCard(
          title: s.comfyuiServers,
          trailing: FilledButton.icon(
            onPressed: () => _showAddServerDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: Text(s.add),
          ),
          children: [
            if (state.servers.isEmpty)
              EmptyState(
                icon: Icons.dns_outlined,
                title: s.noServers,
                message: s.noServersMsg,
              )
            else
              ...state.servers.map((server) => Padding(
                    padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
                    child: _ServerCard(
                      server: server,
                      health: state.healthStatuses[server.id],
                      isDefault: server.id == state.defaultServer?.id,
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showAddServerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ServerFormDialog(
        onSave: (name, url) {
          context.read<ServersBloc>().add(ServerAddRequested(
                name: name,
                url: url,
              ));
        },
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  final ComfyServer server;
  final ServerHealth? health;
  final bool isDefault;

  const _ServerCard({
    required this.server,
    this.health,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    return Container(
      decoration: BoxDecoration(
        color: ext.surfaceElevated,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        border: Border.all(color: ext.border, width: 0.5),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMedium,
          vertical: 4,
        ),
        leading: Icon(
          health?.healthy == true
              ? Icons.cloud_done
              : health?.healthy == false
                  ? Icons.cloud_off
                  : Icons.cloud_queue,
          color: health?.healthy == true
              ? Colors.green
              : health?.healthy == false
                  ? theme.colorScheme.error
                  : ext.muted,
        ),
        title: Row(
          children: [
            Flexible(child: Text(server.name, style: theme.textTheme.titleMedium)),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ext.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.default_,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ext.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(server.url, style: theme.textTheme.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ThemeConstants.spacingMedium,
              0,
              ThemeConstants.spacingMedium,
              ThemeConstants.spacingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: ext.border, height: 1),
                const SizedBox(height: ThemeConstants.spacingSmall),
                if (health != null) ...[
                  _InfoRow(s.status, health!.healthy ? s.healthy : s.unhealthy),
                  if (health!.os != null) _InfoRow(s.os, health!.os!),
                  if (health!.pythonVersion != null)
                    _InfoRow(s.python, health!.pythonVersion!),
                  if (health!.ramTotal != null)
                    _InfoRow(s.ram, '${(health!.ramTotal! / 1024 / 1024 / 1024).toStringAsFixed(1)} GB'),
                  if (health!.error != null)
                    _InfoRow(s.error, health!.error!, isError: true),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                ],
                const SizedBox(height: ThemeConstants.spacingMedium),
                Wrap(
                  spacing: ThemeConstants.spacingSmall,
                  runSpacing: ThemeConstants.spacingSmall,
                  children: [
                    _ActionChip(
                      icon: Icons.health_and_safety,
                      label: s.healthCheck,
                      onTap: () => context
                          .read<ServersBloc>()
                          .add(ServerHealthCheckRequested(server.id)),
                    ),
                    _ActionChip(
                      icon: Icons.download,
                      label: s.fetchModels,
                      onTap: () => context
                          .read<ServersBloc>()
                          .add(ServerModelsFetchRequested(server.id)),
                    ),
                    if (!isDefault)
                      _ActionChip(
                        icon: Icons.star,
                        label: s.setDefault,
                        accent: true,
                        onTap: () => context
                            .read<ServersBloc>()
                            .add(ServerSetDefaultRequested(server.id)),
                      ),
                    _ActionChip(
                      icon: Icons.edit,
                      label: s.edit,
                      onTap: () => _showEditDialog(context, server),
                    ),
                    _ActionChip(
                      icon: Icons.delete_outline,
                      label: s.delete,
                      danger: true,
                      onTap: () => _confirmDelete(context, server.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ComfyServer server) {
    showDialog(
      context: context,
      builder: (ctx) => _ServerFormDialog(
        server: server,
        onSave: (name, url) {
          context.read<ServersBloc>().add(ServerUpdateRequested(
                server.copyWith(name: name, url: url),
              ));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.of(context).deleteServer),
        content: Text(AppStrings.of(context).deleteServerMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<ServersBloc>().add(ServerDeleteRequested(id));
              Navigator.of(ctx).pop();
            },
            child: Text(AppStrings.of(context).delete),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;

  const _InfoRow(this.label, this.value, {this.isError = false});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: ext.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isError ? theme.colorScheme.error : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;
  final bool danger;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final color = danger
        ? theme.colorScheme.error
        : accent
            ? ext.accent
            : ext.muted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServerFormDialog extends StatefulWidget {
  final ComfyServer? server;
  final void Function(String name, String url) onSave;

  const _ServerFormDialog({this.server, required this.onSave});

  @override
  State<_ServerFormDialog> createState() => _ServerFormDialogState();
}

class _ServerFormDialogState extends State<_ServerFormDialog> {
  late final _nameController = TextEditingController(text: widget.server?.name ?? '');
  late final _urlController = TextEditingController(text: widget.server?.url ?? 'http://127.0.0.1:8188');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AlertDialog(
      title: Text(widget.server == null ? s.addServer : s.editServer),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: s.name),
                  validator: (v) => v == null || v.trim().isEmpty ? s.required_ : null,
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: s.url,
                    hintText: 'http://127.0.0.1:8188',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return s.required_;
                    final uri = Uri.tryParse(v.trim());
                    if (uri == null || !uri.hasScheme) return s.invalidUrl;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSave(
                _nameController.text.trim(),
                _urlController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(s.save),
        ),
      ],
    );
  }
}

class _LlmServersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LlmBloc, LlmState>(
      builder: (context, state) {
        final s = AppStrings.of(context);
        return _SectionCard(
          title: s.llmServers,
          subtitle: s.llmServersSubtitle,
          trailing: FilledButton.icon(
            onPressed: () => _showAddLlmServerDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: Text(s.add),
          ),
          children: [
            if (state.servers.isEmpty)
              EmptyState(
                icon: Icons.psychology_outlined,
                title: s.noLlmServers,
                message: s.noLlmServersMsg,
              )
            else
              ...state.servers.map((server) => Padding(
                    padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
                    child: _LlmServerCard(
                      server: server,
                      health: state.healthStatuses[server.id],
                      modelCount: (state.models[server.id] ?? []).length,
                    ),
                  )),
          ],
        );
      },
    );
  }

  void _showAddLlmServerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _LlmServerFormDialog(
        onSave: (name, url, apiKey, defaultModel) {
          context.read<LlmBloc>().add(LlmServerAddRequested(
                name: name,
                url: url,
                apiKey: apiKey,
                defaultModel: defaultModel,
              ));
        },
      ),
    );
  }
}

class _LlmServerCard extends StatelessWidget {
  final LlmServer server;
  final LlmHealthStatus? health;
  final int modelCount;

  const _LlmServerCard({
    required this.server,
    this.health,
    required this.modelCount,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    return Container(
      decoration: BoxDecoration(
        color: ext.surfaceElevated,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        border: Border.all(color: ext.border, width: 0.5),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMedium,
          vertical: 4,
        ),
        leading: Icon(
          health?.healthy == true
              ? Icons.cloud_done
              : health?.healthy == false
                  ? Icons.cloud_off
                  : Icons.cloud_queue,
          color: health?.healthy == true
              ? Colors.green
              : health?.healthy == false
                  ? theme.colorScheme.error
                  : ext.muted,
        ),
        title: Text(server.name, style: theme.textTheme.titleMedium),
        subtitle: Text(server.url, style: theme.textTheme.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ThemeConstants.spacingMedium,
              0,
              ThemeConstants.spacingMedium,
              ThemeConstants.spacingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: ext.border, height: 1),
                const SizedBox(height: ThemeConstants.spacingSmall),
                if (health != null) ...[
                  _LlmInfoRow(s.status, health!.healthy == true ? s.healthy : s.unhealthy),
                  if (health!.error != null)
                    _LlmInfoRow(s.error, health!.error!, isError: true),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                ],
                _LlmInfoRow(s.models, '$modelCount'),
                _LlmInfoRow('${s.default_} ${s.model}', server.defaultModel ?? s.none),
                _LlmInfoRow(s.enabled, server.isEnabled ? s.yes : s.no),
                const SizedBox(height: ThemeConstants.spacingMedium),
                Wrap(
                  spacing: ThemeConstants.spacingSmall,
                  runSpacing: ThemeConstants.spacingSmall,
                  children: [
                    _ActionChip(
                      icon: Icons.health_and_safety,
                      label: s.test,
                      onTap: () => context
                          .read<LlmBloc>()
                          .add(LlmHealthCheckRequested(server.id)),
                    ),
                    _ActionChip(
                      icon: Icons.download,
                      label: s.fetchModels,
                      onTap: () => context
                          .read<LlmBloc>()
                          .add(LlmModelsFetchRequested(server.id)),
                    ),
                    _ActionChip(
                      icon: Icons.edit,
                      label: s.edit,
                      onTap: () => _showEditDialog(context, server),
                    ),
                    _ActionChip(
                      icon: Icons.delete_outline,
                      label: s.delete,
                      danger: true,
                      onTap: () => _confirmDelete(context, server.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, LlmServer server) {
    showDialog(
      context: context,
      builder: (ctx) => _LlmServerFormDialog(
        server: server,
        onSave: (name, url, apiKey, defaultModel) {
          context.read<LlmBloc>().add(LlmServerUpdateRequested(
                server.copyWith(
                  name: name,
                  url: url,
                  apiKey: apiKey,
                  defaultModel: defaultModel,
                ),
              ));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.of(context).deleteLlmServer),
        content: Text(AppStrings.of(context).deleteLlmServerMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<LlmBloc>().add(LlmServerDeleteRequested(id));
              Navigator.of(ctx).pop();
            },
            child: Text(AppStrings.of(context).delete),
          ),
        ],
      ),
    );
  }
}

class _LlmInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isError;

  const _LlmInfoRow(this.label, this.value, {this.isError = false});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: ext.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isError ? theme.colorScheme.error : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LlmServerFormDialog extends StatefulWidget {
  final LlmServer? server;
  final void Function(String name, String url, String? apiKey, String? defaultModel) onSave;

  const _LlmServerFormDialog({this.server, required this.onSave});

  @override
  State<_LlmServerFormDialog> createState() => _LlmServerFormDialogState();
}

class _LlmServerFormDialogState extends State<_LlmServerFormDialog> {
  late final _nameController = TextEditingController(text: widget.server?.name ?? '');
  late final _urlController =
      TextEditingController(text: widget.server?.url ?? 'http://127.0.0.1:1234');
  late final _apiKeyController = TextEditingController(text: widget.server?.apiKey ?? '');
  late final _defaultModelController =
      TextEditingController(text: widget.server?.defaultModel ?? '');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _apiKeyController.dispose();
    _defaultModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return AlertDialog(
      title: Text(widget.server == null ? s.addLlmServer : s.editLlmServer),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: s.name),
                  validator: (v) => v == null || v.trim().isEmpty ? s.required_ : null,
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: s.url,
                    hintText: 'http://127.0.0.1:1234',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return s.required_;
                    final uri = Uri.tryParse(v.trim());
                    if (uri == null || !uri.hasScheme) return s.invalidUrl;
                    return null;
                  },
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: s.apiKeyOptional,
                    hintText: s.apiKeyHint,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                TextFormField(
                  controller: _defaultModelController,
                  decoration: InputDecoration(
                    labelText: s.defaultModelOptional,
                    hintText: s.defaultModelHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSave(
                _nameController.text.trim(),
                _urlController.text.trim(),
                _apiKeyController.text.trim().isEmpty ? null : _apiKeyController.text.trim(),
                _defaultModelController.text.trim().isEmpty
                    ? null
                    : _defaultModelController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(s.save),
        ),
      ],
    );
  }
}

class _GalleryPrivacySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final s = AppStrings.of(context);
        final hasPassword = state.settings.galleryPassword != null;
        return _SectionCard(
          title: s.galleryPrivacy,
          subtitle: hasPassword
              ? s.galleryPrivacyEnabled
              : s.galleryPrivacyDisabled,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline, size: 20, color: Theme.of(context).extension<AppColors>()!.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(hasPassword
                      ? s.galleryProtectedMsg
                      : s.galleryNoPasswordMsg),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showPasswordDialog(context, state.settings.galleryPassword),
                    icon: Icon(hasPassword ? Icons.edit : Icons.lock),
                    label: Text(hasPassword ? s.changePassword : s.setPassword),
                  ),
                ),
                if (hasPassword) ...[
                  const SizedBox(width: ThemeConstants.spacingSmall),
                  TextButton(
                    onPressed: () => _confirmRemovePassword(context),
                    child: Text(s.remove),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog(BuildContext context, String? existingPassword) {
    final pwdController = TextEditingController();
    final confirmController = TextEditingController();
    final oldPwdController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingPassword != null ? AppStrings.of(context).changePassword : AppStrings.of(context).setPassword),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (existingPassword != null) ...[
                TextField(
                  controller: oldPwdController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppStrings.of(context).currentPassword,
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
              ],
              TextField(
                controller: pwdController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppStrings.of(context).newPassword,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingSmall),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppStrings.of(context).confirmPassword,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final pwd = pwdController.text;
              final confirm = confirmController.text;
              if (pwd.isEmpty) return;
              if (pwd != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.of(context).passwordsDoNotMatch)),
                );
                return;
              }
              if (existingPassword != null && oldPwdController.text != existingPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.of(context).currentPasswordIncorrect)),
                );
                return;
              }
              final settings = context.read<SettingsBloc>().state.settings;
              context.read<SettingsBloc>().add(SettingsUpdated(
                settings.copyWith(galleryPassword: pwd),
              ));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(existingPassword != null ? AppStrings.of(context).passwordUpdated : AppStrings.of(context).passwordSet)),
              );
            },
            child: Text(AppStrings.of(context).save),
          ),
        ],
      ),
    );
  }

  void _confirmRemovePassword(BuildContext context) {
    final pwdController = TextEditingController();
    final currentPassword = context.read<SettingsBloc>().state.settings.galleryPassword;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.of(context).removePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.of(context).removePasswordMsg),
            const SizedBox(height: ThemeConstants.spacingSmall),
            TextField(
              controller: pwdController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.of(context).currentPassword,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              if (pwdController.text != currentPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.of(context).incorrectPasswordMsg)),
                );
                return;
              }
              final settings = context.read<SettingsBloc>().state.settings;
              context.read<SettingsBloc>().add(SettingsUpdated(
                settings.copyWith(galleryPassword: null),
              ));
              Navigator.of(ctx).pop();
            },
            child: Text(AppStrings.of(context).remove),
          ),
        ],
      ),
    );
  }
}
