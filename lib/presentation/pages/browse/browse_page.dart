import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../widgets/common/empty_state.dart';

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
              _LoraList(loras: catalog.loras, serverName: server.name),
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
  final String serverName;

  const _LoraList({required this.loras, required this.serverName});

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

        return Card(
          margin: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
          child: ListTile(
            leading: const Icon(Icons.style_outlined),
            title: Text(name),
            subtitle: folder.isNotEmpty ? Text(folder) : Text('From: $serverName'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy name',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: lora));
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
