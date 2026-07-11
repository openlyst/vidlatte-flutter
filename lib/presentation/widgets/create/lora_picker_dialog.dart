import 'package:flutter/material.dart';

import '../../../config/constants.dart';

class LoraPickerDialog extends StatefulWidget {
  final List<String> loras;
  final Map<String, String> triggerWords;
  final List<String> selectedLoras;
  final int maxLoras;

  const LoraPickerDialog({
    super.key,
    required this.loras,
    required this.triggerWords,
    required this.selectedLoras,
    required this.maxLoras,
  });

  @override
  State<LoraPickerDialog> createState() => _LoraPickerDialogState();
}

class _LoraPickerDialogState extends State<LoraPickerDialog> {
  late List<String> _selected;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedLoras);
  }

  List<String> get _filtered {
    if (_search.isEmpty) return widget.loras;
    final q = _search.toLowerCase();
    return widget.loras.where((l) {
      final name = l.split('/').last.toLowerCase();
      final triggers = (widget.triggerWords[l] ?? '').toLowerCase();
      return name.contains(q) || triggers.contains(q) || l.toLowerCase().contains(q);
    }).toList();
  }

  void _toggle(String lora) {
    setState(() {
      if (_selected.contains(lora)) {
        _selected.remove(lora);
      } else if (_selected.length < widget.maxLoras) {
        _selected.add(lora);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Max ${widget.maxLoras} LoRAs selected')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: SizedBox(
        width: 640,
        height: 640,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Text('Select LoRAs', style: theme.textTheme.titleLarge),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_selected.length}/${widget.maxLoras}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Search by name or trigger words...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selected.map((lora) {
                      final name = lora.split('/').last;
                      return Chip(
                        label: Text(name, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _toggle(lora),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ),
              ),
            const Divider(height: 24),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        _search.isEmpty ? 'No LoRAs available' : 'No matches',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final lora = _filtered[index];
                        final name = lora.split('/').last;
                        final folder = lora.contains('/') ? lora.substring(0, lora.lastIndexOf('/')) : '';
                        final triggers = widget.triggerWords[lora];
                        final hasTriggers = triggers != null && triggers.isNotEmpty;
                        final isSelected = _selected.contains(lora);

                        return ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggle(lora),
                          ),
                          title: Text(name, overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (folder.isNotEmpty)
                                Text(folder, style: theme.textTheme.bodySmall),
                              if (hasTriggers)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Wrap(
                                    spacing: 4,
                                    children: triggers
                                        .split(',')
                                        .map((t) => t.trim())
                                        .where((t) => t.isNotEmpty)
                                        .map((t) => Text(
                                              t,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: theme.colorScheme.secondary,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                            ],
                          ),
                          trailing: hasTriggers
                              ? Icon(Icons.bolt, size: 16, color: theme.colorScheme.secondary)
                              : null,
                          onTap: () => _toggle(lora),
                          dense: true,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
