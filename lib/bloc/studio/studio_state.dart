import 'package:equatable/equatable.dart';

import '../../data/models/studio_session.dart';

class _Sentinel {
  const _Sentinel();
}

const _unset = _Sentinel();

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
    Object? selectedSessionId = _unset,
    bool? isLoading,
  }) {
    return StudioState(
      sessions: sessions ?? this.sessions,
      selectedSessionId: selectedSessionId == _unset
          ? this.selectedSessionId
          : selectedSessionId as String?,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [sessions, selectedSessionId, isLoading];
}
