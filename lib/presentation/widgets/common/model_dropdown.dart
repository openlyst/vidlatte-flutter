import 'package:flutter/material.dart';

class ModelDropdown extends StatelessWidget {
  final List<String> models;
  final String? selectedModel;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? hintText;
  final bool refreshing;
  final VoidCallback? onRefresh;
  final bool displayAsFilename;

  const ModelDropdown({
    super.key,
    required this.models,
    required this.selectedModel,
    required this.onChanged,
    required this.label,
    this.hintText,
    this.refreshing = false,
    this.onRefresh,
    this.displayAsFilename = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            if (onRefresh != null) ...[
              const Spacer(),
              IconButton(
                onPressed: refreshing ? null : onRefresh,
                icon: refreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedModel,
          decoration: InputDecoration(
            hintText: hintText,
            isDense: true,
          ),
          items: models.map((m) {
            final display = displayAsFilename
                ? m.split('/').last
                : m;
            return DropdownMenuItem(
              value: m,
              child: Text(display, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
