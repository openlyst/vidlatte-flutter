import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../../data/models/comfy_server.dart';
import '../../../data/models/lora_metadata.dart';

class LoraManagerDialog extends StatefulWidget {
  final ComfyServer server;

  const LoraManagerDialog({super.key, required this.server});

  @override
  State<LoraManagerDialog> createState() => _LoraManagerDialogState();
}

class _LoraManagerDialogState extends State<LoraManagerDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _triggerControllers = <String, TextEditingController>{};
  final _disabledLoras = <String>{};
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMetadata();
  }

  void _loadMetadata() {
    final bloc = context.read<ServersBloc>();
    bloc.add(LoraMetadataLoadRequested(widget.server.id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    for (final c in _triggerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _triggerController(String loraName) {
    return _triggerControllers.putIfAbsent(loraName, () {
      final bloc = context.read<ServersBloc>();
      final state = bloc.state;
      final metas = state.loraMetadata[widget.server.id] ?? [];
      final existing = metas.where((m) => m.loraName == loraName).firstOrNull;
      return TextEditingController(text: existing?.triggerWords ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServersBloc, ServersState>(
      builder: (context, state) {
        final catalog = state.catalogs[widget.server.id];
        final loras = catalog?.loras ?? [];
        final metas = state.loraMetadata[widget.server.id] ?? [];

        if (metas.isNotEmpty) {
          for (final m in metas) {
            if (!m.isEnabled) _disabledLoras.add(m.loraName);
          }
        }

        return Dialog(
          child: SizedBox(
            width: 600,
            height: 600,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  child: Row(
                    children: [
                      Icon(Icons.style_outlined, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Manage LoRAs', style: Theme.of(context).textTheme.titleLarge),
                            Text(widget.server.name,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.edit_note), text: 'Trigger Words'),
                    Tab(icon: Icon(Icons.visibility), text: 'Visibility'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _TriggersTab(
                        loras: loras,
                        triggerControllerFor: _triggerController,
                        onSave: _saveTriggers,
                        saving: _saving,
                      ),
                      _VisibilityTab(
                        loras: loras,
                        disabledLoras: _disabledLoras,
                        searchQuery: _searchQuery,
                        onSearchChanged: (v) => setState(() => _searchQuery = v),
                        onToggle: (lora, visible) => setState(() {
                          if (visible) {
                            _disabledLoras.remove(lora);
                          } else {
                            _disabledLoras.add(lora);
                          }
                        }),
                        onSave: _saveVisibility,
                        saving: _saving,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveTriggers() async {
    setState(() => _saving = true);
    final triggers = <String, String>{};
    for (final entry in _triggerControllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        triggers[entry.key] = value;
      }
    }
    context.read<ServersBloc>().add(LoraTriggerWordsSaveRequested(widget.server.id, triggers));
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trigger words saved')),
      );
    }
  }

  Future<void> _saveVisibility() async {
    setState(() => _saving = true);
    context.read<ServersBloc>().add(
          LoraVisibilitySaveRequested(widget.server.id, Set.from(_disabledLoras)),
        );
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visibility saved')),
      );
    }
  }
}

class _TriggersTab extends StatelessWidget {
  final List<String> loras;
  final TextEditingController Function(String) triggerControllerFor;
  final VoidCallback onSave;
  final bool saving;

  const _TriggersTab({
    required this.loras,
    required this.triggerControllerFor,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    if (loras.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No LoRAs found on this server. Fetch models first.'),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
          child: Text(
            'Trigger words appear when selecting a LoRA in Create, Studio, and Auto Image.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
            itemCount: loras.length,
            itemBuilder: (context, index) {
              final lora = loras[index];
              final name = lora.split('/').last;
              return Padding(
                padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Tooltip(
                        message: lora,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.spacingSmall),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: triggerControllerFor(lora),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Trigger words...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
          child: FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('Save Triggers'),
          ),
        ),
      ],
    );
  }
}

class _VisibilityTab extends StatelessWidget {
  final List<String> loras;
  final Set<String> disabledLoras;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final void Function(String lora, bool visible) onToggle;
  final VoidCallback onSave;
  final bool saving;

  const _VisibilityTab({
    required this.loras,
    required this.disabledLoras,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onToggle,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    if (loras.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No LoRAs found on this server. Fetch models first.'),
        ),
      );
    }

    final filtered = searchQuery.isEmpty
        ? loras
        : loras.where((l) => l.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
          child: TextField(
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Search LoRAs...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingSmall),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hidden LoRAs won\'t appear in Create, Studio, or Auto Image.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final lora = filtered[index];
              final name = lora.split('/').last;
              final visible = !disabledLoras.contains(lora);
              return SwitchListTile(
                title: Text(name, overflow: TextOverflow.ellipsis),
                subtitle: Text(visible ? 'Visible' : 'Hidden',
                    style: TextStyle(
                      color: visible ? null : Theme.of(context).colorScheme.outline,
                    )),
                value: visible,
                onChanged: (v) => onToggle(lora, v),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
          child: FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('Save Visibility'),
          ),
        ),
      ],
    );
  }
}
