import 'package:equatable/equatable.dart';

import '../../data/models/prompt_history_entry.dart';

class PromptHistoryState extends Equatable {
  final List<PromptHistoryEntry> entries;
  final bool isLoading;

  const PromptHistoryState({
    this.entries = const [],
    this.isLoading = false,
  });

  PromptHistoryState copyWith({
    List<PromptHistoryEntry>? entries,
    bool? isLoading,
  }) {
    return PromptHistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [entries, isLoading];
}
