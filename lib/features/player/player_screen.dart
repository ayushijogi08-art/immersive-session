import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'session_controller.dart';
import '../journal/reflection_screen.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  const SessionPlayerScreen({super.key});

  @override
  ConsumerState<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _opacityAnimation;
  double? _dragValue;

  @override
  void initState() {
    super.initState();
    // Premium "breathing gradient" animation (4-second cycle)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _showEndSessionDialog() {
    final currentAmbience = ref.read(sessionProvider).activeAmbience;
    
    if (currentAmbience == null) return; 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('End Session?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
            // 1. Navigate to Reflection and destroy the middle screens (Details/Player)
             Navigator.pop(context);
              
              // 2. Navigate immediately. We DO NOT wipe the session state here.
              // We leave the state alive so the background screens don't panic.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ReflectionScreen(ambience: currentAmbience),
                ),
                (route) => route.isFirst,
              );
            },
            child: const Text('End', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      final ambience = next.activeAmbience;
      if (ambience != null) {
        final totalSeconds = ambience.durationMinutes* 60; // Convert minutes to seconds
        
        // If the timer naturally reaches the end
        if (next.elapsedSeconds >= totalSeconds) {
          // Force navigate to the Reflection screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ReflectionScreen(ambience: ambience),
            ),
            (route) => route.isFirst,
          );
        }
      }
    });
    final sessionState = ref.watch(sessionProvider);
    final ambience = sessionState.activeAmbience;

    // If session dies (e.g., timer runs out naturally), drop back to previous screen
    if (ambience == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => Navigator.pop(context), // Shrink to mini-player
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Breathing Gradient Animation
          AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Color(0xFF2C3E50), Colors.black],
                      radius: 1.5,
                      center: Alignment.center,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // 2. Player Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    ambience.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ambience.tag,
                    style: const TextStyle(fontSize: 16, color: Colors.white54),
                  ),
                  const SizedBox(height: 48),

                  // Seek Bar (Slider)
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      trackHeight: 2.0,
                    ),
                    child: Slider(
              value: sessionState.elapsedSeconds.toDouble(),
              min: 0,
              max: ambience.durationMinutes * 60.toDouble(), // Use your exact duration variable name here
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
              onChanged: (value) {
                // 1. This instantly moves the visual slider and the audio track
                ref.read(sessionProvider.notifier).seekSession(value);
              },
            ),
                  ),

                  // Time Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatTime(sessionState.elapsedSeconds), style: const TextStyle(color: Colors.white54)),
                      Text(_formatTime(sessionState.totalSeconds), style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Play/Pause Button
                  GestureDetector(
                    onTap: () => ref.read(sessionProvider.notifier).togglePlayPause(),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        sessionState.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // End Session Button
                  TextButton(
                    onPressed: _showEndSessionDialog,
                    child: const Text('End Session', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}