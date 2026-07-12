import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/prompt_history/prompt_history_bloc.dart';
import '../../../config/theme.dart';
import '../../../data/models/prompt_history_entry.dart';
import '../../../i18n/app_strings.dart';
import '../common/empty_state.dart';

class PromptHistorySheet extends StatefulWidget {
  const PromptHistorySheet({super.key});

  @override
  State<PromptHistorySheet> createState() => _PromptHistorySheetState();
}

class _PromptHistorySheetState extends State<PromptHistorySheet> {
  String _search = '';

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);

    return BlocBuilder<PromptHistoryBloc, PromptHistoryState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final entries = _search.isEmpty
            ? state.entries
            : state.entries
                .where((e) => e.prompt.toLowerCase().contains(_search.toLowerCase()))
                .toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Row(
                    children: [
                      Text(s.promptHistory, style: theme.textTheme.titleLarge),
                      const Spacer(),
                      if (state.entries.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            context.read<PromptHistoryBloc>().add(PromptHistoryCleared());
                          },
                          icon: const Icon(Icons.delete_sweep, size: 18),
                          label: Text(s.clearHistory),
                        ),
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
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: s.searchPrompts,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const Divider(height: 24),
                Expanded(
                  child: state.entries.isEmpty
                      ? EmptyState(
                          icon: Icons.history,
                          title: s.noPromptHistory,
                          message: s.noPromptHistoryMsg,
                        )
                      : entries.isEmpty
                          ? Center(
                              child: Text(s.noResults, style: theme.textTheme.bodyMedium),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                return _HistoryTile(
                                  entry: entry,
                                  timeAgo: _timeAgo(entry.createdAt),
                                  onTap: () => Navigator.of(context).pop(entry),
                                  onDelete: () {
                                    context.read<PromptHistoryBloc>().add(PromptHistoryEntryDeleted(entry.id));
                                  },
                                );
                              },
                            ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PromptHistoryEntry entry;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.entry,
    required this.timeAgo,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppColors>()!;

    return ListTile(
      onTap: onTap,
      title: Text(
        entry.prompt,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 8,
          children: [
            if (entry.model != null && entry.model!.isNotEmpty)
              _MetaChip(
                icon: Icons.tune,
                label: entry.model!.split('/').last,
                color: ext.accent,
              ),
            _MetaChip(
              icon: Icons.schedule,
              label: timeAgo,
              color: ext.muted,
            ),
            if (entry.loras.isNotEmpty)
              _MetaChip(
                icon: Icons.layers,
                label: '${entry.loras.length} LoRA${entry.loras.length == 1 ? '' : 's'}',
                color: ext.muted,
              ),
          ],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: onDelete,
        tooltip: AppStrings.of(context).delete,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
