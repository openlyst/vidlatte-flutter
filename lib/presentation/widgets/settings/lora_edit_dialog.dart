import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/servers/servers_bloc.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _triggerController = TextEditingController(text: widget.existing?.triggerWords ?? '');
  }

  @override
  void dispose() {
    _triggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColors>()!;
    final name = widget.loraName.split('/').last;
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ext.accentGradientStart, ext.accentGradientEnd],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.style_outlined, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
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
                style: TextStyle(color: ext.muted, fontSize: 13),
              ),
            ),
          TextField(
            controller: _triggerController,
            decoration: const InputDecoration(
              labelText: 'Trigger words',
              hintText: 'Comma-separated, e.g. cat girl, anime style',
            ),
            maxLines: 2,
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
      isEnabled: widget.existing?.isEnabled ?? true,
      updatedAt: DateTime.now(),
    );
    context.read<ServersBloc>().add(LoraMetadataSaveRequested(widget.serverId, [meta]));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved: ${widget.loraName.split('/').last}')),
    );
  }
}
