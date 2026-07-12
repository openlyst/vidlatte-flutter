import 'package:flutter_bloc/flutter_bloc.dart';

export 'prompt_history_event.dart';
export 'prompt_history_state.dart';

import '../../data/models/prompt_history_entry.dart';
import '../../services/storage_service.dart';
import 'prompt_history_event.dart';
import 'prompt_history_state.dart';

class PromptHistoryBloc extends Bloc<PromptHistoryEvent, PromptHistoryState> {
  final StorageService _storage;

  PromptHistoryBloc({required this._storage})
      : super(const PromptHistoryState(isLoading: true)) {
    on<PromptHistoryLoadRequested>(_onLoad);
    on<PromptHistoryEntryAdded>(_onEntryAdded);
    on<PromptHistoryEntryDeleted>(_onEntryDeleted);
    on<PromptHistoryCleared>(_onCleared);
  }

  void _onLoad(PromptHistoryLoadRequested event, Emitter<PromptHistoryState> emit) {
    emit(state.copyWith(
      entries: _storage.getPromptHistory(),
      isLoading: false,
    ));
  }

  Future<void> _onEntryAdded(PromptHistoryEntryAdded event, Emitter<PromptHistoryState> emit) async {
    final entry = PromptHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      prompt: event.prompt,
      negativePrompt: event.negativePrompt,
      model: event.model,
      loras: event.loras,
      createdAt: DateTime.now(),
    );
    await _storage.savePromptHistoryEntry(entry);
    emit(state.copyWith(entries: _storage.getPromptHistory()));
  }

  Future<void> _onEntryDeleted(PromptHistoryEntryDeleted event, Emitter<PromptHistoryState> emit) async {
    await _storage.deletePromptHistoryEntry(event.id);
    emit(state.copyWith(entries: _storage.getPromptHistory()));
  }

  Future<void> _onCleared(PromptHistoryCleared event, Emitter<PromptHistoryState> emit) async {
    await _storage.clearPromptHistory();
    emit(state.copyWith(entries: _storage.getPromptHistory()));
  }
}
