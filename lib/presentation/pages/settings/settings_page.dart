import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/llm/llm_bloc.dart';
import '../../../bloc/servers/servers_bloc.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../config/constants.dart';
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
        children: [
          _ThemeSection(),
          const Divider(),
          _ServersSection(),
          const Divider(),
          _LlmServersSection(),
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsBloc>().state.settings;
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: ThemeConstants.spacingSmall),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'system', label: Text('System')),
              ButtonSegment(value: 'light', label: Text('Light')),
              ButtonSegment(value: 'dark', label: Text('Dark')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (set) =>
                context.read<SettingsBloc>().add(ThemeModeChanged(set.first)),
          ),
        ],
      ),
    );
  }
}

class _ServersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServersBloc, ServersState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('ComfyUI Servers', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () => _showAddServerDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              if (state.servers.isEmpty)
                const EmptyState(
                  icon: Icons.dns_outlined,
                  title: 'No Servers',
                  message: 'Add a ComfyUI server to start generating images.',
                )
              else
                ...state.servers.map((server) => _ServerCard(
                      server: server,
                      health: state.healthStatuses[server.id],
                      isDefault: server.id == state.defaultServer?.id,
                    )),
            ],
          ),
        );
      },
    );
  }

  void _showAddServerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ServerFormDialog(
        onSave: (name, url, maxLoras, steps, hiresFix) {
          context.read<ServersBloc>().add(ServerAddRequested(
                name: name,
                url: url,
                maxLoras: maxLoras,
                steps: steps,
                hiresFix: hiresFix,
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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
      child: ExpansionTile(
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
                  : null,
        ),
        title: Row(
          children: [
            Text(server.name),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(server.url, style: theme.textTheme.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                _InfoRow('Max LoRAs', '${server.maxLoras}'),
                _InfoRow('Default Steps', '${server.steps}'),
                _InfoRow('Hires Fix', server.hiresFix ? 'Enabled' : 'Disabled'),
                const SizedBox(height: ThemeConstants.spacingMedium),
                Wrap(
                  spacing: ThemeConstants.spacingSmall,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => context
                          .read<ServersBloc>()
                          .add(ServerHealthCheckRequested(server.id)),
                      icon: const Icon(Icons.health_and_safety),
                      label: const Text('Health Check'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => context
                          .read<ServersBloc>()
                          .add(ServerModelsFetchRequested(server.id)),
                      icon: const Icon(Icons.download),
                      label: const Text('Fetch Models'),
                    ),
                    if (!isDefault)
                      FilledButton.tonalIcon(
                        onPressed: () => context
                            .read<ServersBloc>()
                            .add(ServerSetDefaultRequested(server.id)),
                        icon: const Icon(Icons.star),
                        label: const Text('Set Default'),
                      ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showEditDialog(context, server),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _confirmDelete(context, server.id),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
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
        onSave: (name, url, maxLoras, steps, hiresFix) {
          context.read<ServersBloc>().add(ServerUpdateRequested(
                server.copyWith(
                  name: name,
                  url: url,
                  maxLoras: maxLoras,
                  steps: steps,
                  hiresFix: hiresFix,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodySmall),
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

class _ServerFormDialog extends StatefulWidget {
  final ComfyServer? server;
  final void Function(String name, String url, int maxLoras, int steps, bool hiresFix) onSave;

  const _ServerFormDialog({this.server, required this.onSave});

  @override
  State<_ServerFormDialog> createState() => _ServerFormDialogState();
}

class _ServerFormDialogState extends State<_ServerFormDialog> {
  late final _nameController = TextEditingController(text: widget.server?.name ?? '');
  late final _urlController = TextEditingController(text: widget.server?.url ?? 'http://127.0.0.1:8188');
  late int _maxLoras = widget.server?.maxLoras ?? 5;
  late int _steps = widget.server?.steps ?? 20;
  late bool _hiresFix = widget.server?.hiresFix ?? false;
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
                const SizedBox(height: ThemeConstants.spacingSmall),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _maxLoras.toString(),
                        decoration: const InputDecoration(labelText: 'Max LoRAs'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _maxLoras = int.tryParse(v) ?? 5,
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.spacingSmall),
                    Expanded(
                      child: TextFormField(
                        initialValue: _steps.toString(),
                        decoration: const InputDecoration(labelText: 'Default Steps'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _steps = int.tryParse(v) ?? 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ThemeConstants.spacingSmall),
                SwitchListTile(
                  title: const Text('Hires Fix'),
                  value: _hiresFix,
                  onChanged: (v) => setState(() => _hiresFix = v),
                  contentPadding: EdgeInsets.zero,
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
                _maxLoras,
                _steps,
                _hiresFix,
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
        return Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('LLM Servers', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () => _showAddLlmServerDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConstants.spacingSmall),
              Text(
                'Connect to LM Studio or any OpenAI-compatible server for prompt generation.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              if (state.servers.isEmpty)
                const EmptyState(
                  icon: Icons.psychology_outlined,
                  title: 'No LLM Servers',
                  message: 'Add an LLM server to enable Auto Image generation.',
                )
              else
                ...state.servers.map((server) => _LlmServerCard(
                      server: server,
                      health: state.healthStatuses[server.id],
                      modelCount: (state.models[server.id] ?? []).length,
                    )),
            ],
          ),
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
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
      child: ExpansionTile(
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
                  : null,
        ),
        title: Text(server.name),
        subtitle: Text(server.url, style: theme.textTheme.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => context
                          .read<LlmBloc>()
                          .add(LlmHealthCheckRequested(server.id)),
                      icon: const Icon(Icons.health_and_safety),
                      label: const Text('Test'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => context
                          .read<LlmBloc>()
                          .add(LlmModelsFetchRequested(server.id)),
                      icon: const Icon(Icons.download),
                      label: const Text('Fetch Models'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showEditDialog(context, server),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _confirmDelete(context, server.id),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.bodySmall),
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
