import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'session_state.dart';
import '../../data/models/ambience.dart';

class SessionNotifier extends Notifier<SessionState> {
  late AudioPlayer _audioPlayer;
  Timer? _sessionTimer;

  @override
  SessionState build() {
    _audioPlayer = AudioPlayer();
    _initAudioSession();
    
    // Cleanup when the provider is destroyed
    ref.onDispose(() {
      _sessionTimer?.cancel();
      _audioPlayer.dispose();
    });
    
    return SessionState();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // Force the audio to loop continuously as required
    await _audioPlayer.setLoopMode(LoopMode.one);
  }

  Future<void> startSession(Ambience ambience) async {
    // Stop any existing session
    stopSession();

    final totalSecs = ambience.durationMinutes * 60;
    
    state = SessionState(
      activeAmbience: ambience,
      isPlaying: true,
      totalSeconds: totalSecs,
      elapsedSeconds: 0,
    );

    try {
      // Load the local audio asset. 
      // NOTE: We use a placeholder here. In a real app, you'd map ambience.id to specific files.
      await _audioPlayer.setAsset('assets/audio/${ambience.id}.mp3');
      _audioPlayer.play();
      
      // Start the independent session timer
      _startTimer();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.elapsedSeconds >= state.totalSeconds) {
        _endSession();
      } else {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      _audioPlayer.pause();
      _sessionTimer?.cancel();
      state = state.copyWith(isPlaying: false);
    } else {
      _audioPlayer.play();
      _startTimer();
      state = state.copyWith(isPlaying: true);
    }
  }

  void seekSession(double seconds) {
    // We only seek the session timer, the audio continues to loop independently
    state = state.copyWith(elapsedSeconds: seconds.toInt());
  }
  
  void _endSession() {
    stopSession();
    // Flag the session as finished so the UI can navigate to the Reflection screen
    state = state.copyWith(isFinished: true); 
  }

  void stopSession() {
    _sessionTimer?.cancel();
    _audioPlayer.stop();
    state = SessionState(); // Reset state
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);