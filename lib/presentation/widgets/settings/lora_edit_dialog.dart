import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../../data/models/lora_metadata.dart';

class LoraEditDialog extends StatefulWidget {
  final String serverId;
  final String loraName;
  final LoraMetadata? existing;

  const LoraEditDialog({
    super.key,
    required this.serverId,
    required this.loraName,
    this.existing,
  });

  @override
  State<LoraEditDialog> createState() => _LoraEditDialogState();
}

class _LoraEditDialogState extends State<LoraEditDialog> {
  late final TextEditingController _triggerController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _triggerController = TextEditingController(text: widget.existing?.triggerWords ?? '');
    _isEnabled = widget.existing?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _triggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.loraName.split('/').last;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.style_outlined),
          const SizedBox(width: 8),
          Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.loraName.contains('/'))
            Padding(
              padding: const EdgeInsets.only(bottom: ThemeConstants.spacingMedium),
              child: Text(
                widget.loraName.substring(0, widget.loraName.lastIndexOf('/')),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          TextField(
            controller: _triggerController,
            decoration: const InputDecoration(
              labelText: 'Trigger words',
              hintText: 'Comma-separated, e.g. cat girl, anime style',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: ThemeConstants.spacingMedium),
          SwitchListTile(
            title: const Text('Visible in Create / Studio / Auto Image'),
            value: _isEnabled,
            onChanged: (v) => setState(() => _isEnabled = v),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final meta = LoraMetadata(
      serverId: widget.serverId,
      loraName: widget.loraName,
      triggerWords: _triggerController.text.trim(),
      isEnabled: _isEnabled,
      updatedAt: DateTime.now(),
    );
    context.read<ServersBloc>().add(LoraMetadataSaveRequested(widget.serverId, [meta]));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved: ${widget.loraName.split('/').last}')),
    );
  }
}
