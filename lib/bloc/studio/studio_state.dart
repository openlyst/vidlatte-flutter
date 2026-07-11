import 'package:equatable/equatable.dart';

import '../../data/models/studio_session.dart';

class StudioState extends Equatable {
  final List<StudioSession> sessions;
  final String? selectedSessionId;
  final bool isLoading;

  const StudioState({
    this.sessions = const [],
    this.selectedSessionId,
    this.isLoading = false,
  });

  StudioSession? get selectedSession {
    if (selectedSessionId == null) return null;
    return sessions.where((s) => s.id == selectedSessionId).firstOrNull;
  }

  StudioState copyWith({
    List<StudioSession>? sessions,
    String? selectedSessionId,
    bool? isLoading,
  }) {
    return StudioState(
      sessions: sessions ?? this.sessions,
      selectedSessionId: selectedSessionId ?? this.selectedSessionId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [sessions, selectedSessionId, isLoading];
}
