import '../../data/models/ambience.dart';

class SessionState {
  final Ambience? activeAmbience;
  final bool isPlaying;
  final int elapsedSeconds;
  final int totalSeconds;
  final bool isFinished;

  SessionState({
    this.activeAmbience,
    this.isPlaying = false,
    this.elapsedSeconds = 0,
    this.totalSeconds = 0,
    this.isFinished = false,
  });

  SessionState copyWith({
    Ambience? activeAmbience,
    bool? isPlaying,
    int? elapsedSeconds,
    int? totalSeconds,
    bool? isFinished,
  }) {
    return SessionState(
      activeAmbience: activeAmbience ?? this.activeAmbience,
      isPlaying: isPlaying ?? this.isPlaying,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}