import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../../data/models/lora_metadata.dart';
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

        return Card(
          margin: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
          child: ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: Text(name),
            subtitle: folder.isNotEmpty ? Text(folder) : Text('From: $serverName'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy name',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: model));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied: $name')),
                );
              },
            ),
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
        final theme = Theme.of(context);

        return Card(
          margin: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
          color: isHidden ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : null,
          child: ListTile(
            leading: Icon(
              isHidden ? Icons.style_outlined : Icons.style,
              color: isHidden ? theme.colorScheme.outline : null,
            ),
            title: Text(
              name,
              style: isHidden
                  ? TextStyle(color: theme.colorScheme.outline, decoration: TextDecoration.lineThrough)
                  : null,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (folder.isNotEmpty)
                  Text(folder, style: theme.textTheme.bodySmall)
                else
                  Text('From: $serverName', style: theme.textTheme.bodySmall),
                if (isHidden)
                  Text('Hidden', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline))
                else if (triggers != null && triggers.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: triggers
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .map((t) => Chip(
                              label: Text(t, style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  tooltip: isHidden ? 'Show' : 'Hide',
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
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
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
          ),
        );
      },
    );
  }
}
