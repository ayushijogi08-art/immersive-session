import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/player/session_controller.dart';
import '../../features/player/player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the global session state
    final sessionState = ref.watch(sessionProvider);

    // If there is no active session, render absolutely nothing.
    if (sessionState.activeAmbience == null) {
      return const SizedBox.shrink(); 
    }

    // Calculate the progress for the thin indicator
    final progress = sessionState.totalSeconds > 0
        ? sessionState.elapsedSeconds / sessionState.totalSeconds
        : 0.0;

    return Container(
      color: Colors.grey[900],
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take only as much vertical space as needed
          children: [
            // Thin progress indicator
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 2,
            ),
            ListTile(
              dense: true,
              title: Text(
                sessionState.activeAmbience!.title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              trailing: IconButton(
                icon: Icon(
                  sessionState.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Toggle play/pause via the global controller
                  ref.read(sessionProvider.notifier).togglePlayPause();
                },
              ),
              onTap: () {
                // TODO: Open the full-screen Session Player
               Navigator.push(
                 context,
                  MaterialPageRoute(builder: (context) => const SessionPlayerScreen()),
               );
              },
            ),
          ],
        ),
      ),
    );
  }
}