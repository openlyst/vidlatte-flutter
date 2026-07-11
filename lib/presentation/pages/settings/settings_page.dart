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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ThemeConstants.spacingLarge,
          ThemeConstants.spacingMedium,
          ThemeConstants.spacingLarge,
          ThemeConstants.floatingNavTotalHeight,
        ),
        children: [
          _ThemeSection(),
          const SizedBox(height: ThemeConstants.spacingLarge),
          _ServersSection(),
          const SizedBox(height: ThemeConstants.spacingLarge),
          _LlmServersSection(),
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
    final settings = context.watch<SettingsBloc>().state.settings;
    return _SectionCard(
      title: 'Appearance',
      subtitle: 'Choose how Vidlatte looks.',
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
              for (final mode in const [
                ('system', 'System', Icons.brightness_auto_outlined),
                ('light', 'Light', Icons.light_mode_outlined),
                ('dark', 'Dark', Icons.dark_mode_outlined),
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

class _ServersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServersBloc, ServersState>(
      builder: (context, state) {
        return _SectionCard(
          title: 'ComfyUI Servers',
          trailing: FilledButton.icon(
            onPressed: () => _showAddServerDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
          children: [
            if (state.servers.isEmpty)
              const EmptyState(
                icon: Icons.dns_outlined,
                title: 'No Servers',
                message: 'Add a ComfyUI server to start generating images.',
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
                  'Default',
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
                  _InfoRow('Status', health!.healthy ? 'Healthy' : 'Unhealthy'),
                  if (health!.os != null) _InfoRow('OS', health!.os!),
                  if (health!.pythonVersion != null)
                    _InfoRow('Python', health!.pythonVersion!),
                  if (health!.ramTotal != null)
                    _InfoRow('RAM', '${(health!.ramTotal! / 1024 / 1024 / 1024).toStringAsFixed(1)} GB'),
                  if (health!.error != null)
                    _InfoRow('Error', health!.error!, isError: true),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                ],
                const SizedBox(height: ThemeConstants.spacingMedium),
                Wrap(
                  spacing: ThemeConstants.spacingSmall,
                  runSpacing: ThemeConstants.spacingSmall,
                  children: [
                    _ActionChip(
                      icon: Icons.health_and_safety,
                      label: 'Health Check',
                      onTap: () => context
                          .read<ServersBloc>()
                          .add(ServerHealthCheckRequested(server.id)),
                    ),
                    _ActionChip(
                      icon: Icons.download,
                      label: 'Fetch Models',
                      onTap: () => context
                          .read<ServersBloc>()
                          .add(ServerModelsFetchRequested(server.id)),
                    ),
                    if (!isDefault)
                      _ActionChip(
                        icon: Icons.star,
                        label: 'Set Default',
                        accent: true,
                        onTap: () => context
                            .read<ServersBloc>()
                            .add(ServerSetDefaultRequested(server.id)),
                      ),
                    _ActionChip(
                      icon: Icons.edit,
                      label: 'Edit',
                      onTap: () => _showEditDialog(context, server),
                    ),
                    _ActionChip(
                      icon: Icons.delete_outline,
                      label: 'Delete',
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
        title: const Text('Delete Server'),
        content: const Text('Are you sure you want to remove this server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ServersBloc>().add(ServerDeleteRequested(id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
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
    return AlertDialog(
      title: Text(widget.server == null ? 'Add Server' : 'Edit Server'),
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
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'http://127.0.0.1:8188',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final uri = Uri.tryParse(v.trim());
                    if (uri == null || !uri.hasScheme) return 'Invalid URL';
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
          child: const Text('Cancel'),
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
          child: const Text('Save'),
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
        return _SectionCard(
          title: 'LLM Servers',
          subtitle: 'Connect to LM Studio or any OpenAI-compatible server for prompt generation.',
          trailing: FilledButton.icon(
            onPressed: () => _showAddLlmServerDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
          children: [
            if (state.servers.isEmpty)
              const EmptyState(
                icon: Icons.psychology_outlined,
                title: 'No LLM Servers',
                message: 'Add an LLM server to enable Auto Image generation.',
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
                  _LlmInfoRow('Status', health!.healthy == true ? 'Healthy' : 'Unhealthy'),
                  if (health!.error != null)
                    _LlmInfoRow('Error', health!.error!, isError: true),
                  const SizedBox(height: ThemeConstants.spacingSmall),
                ],
                _LlmInfoRow('Models', '$modelCount'),
                _LlmInfoRow('Default Model', server.defaultModel ?? 'None'),
                _LlmInfoRow('Enabled', server.isEnabled ? 'Yes' : 'No'),
                const SizedBox(height: ThemeConstants.spacingMedium),
                Wrap(
                  spacing: ThemeConstants.spacingSmall,
                  runSpacing: ThemeConstants.spacingSmall,
                  children: [
                    _ActionChip(
                      icon: Icons.health_and_safety,
                      label: 'Test',
                      onTap: () => context
                          .read<LlmBloc>()
                          .add(LlmHealthCheckRequested(server.id)),
                    ),
                    _ActionChip(
                      icon: Icons.download,
                      label: 'Fetch Models',
                      onTap: () => context
                          .read<LlmBloc>()
                          .add(LlmModelsFetchRequested(server.id)),
                    ),
                    _ActionChip(
                      icon: Icons.edit,
                      label: 'Edit',
                      onTap: () => _showEditDialog(context, server),
                    ),
                    _ActionChip(
                      icon: Icons.delete_outline,
                      label: 'Delete',
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
        title: const Text('Delete LLM Server'),
        content: const Text('Are you sure you want to remove this server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<LlmBloc>().add(LlmServerDeleteRequested(id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
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
    return AlertDialog(
      title: Text(widget.server == null ? 'Add LLM Server' : 'Edit LLM Server'),
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
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'http://127.0.0.1:1234',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final uri = Uri.tryParse(v.trim());
                    if (uri == null || !uri.hasScheme) return 'Invalid URL';
                    return null;
                  },
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                TextFormField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key (optional)',
                    hintText: 'Leave empty for local servers',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                TextFormField(
                  controller: _defaultModelController,
                  decoration: const InputDecoration(
                    labelText: 'Default Model (optional)',
                    hintText: 'e.g., llama-3-8b-instruct',
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
          child: const Text('Cancel'),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}
