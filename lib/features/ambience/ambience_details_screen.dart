import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED IMPORT
import '../../data/models/ambience.dart';
import '../player/session_controller.dart'; // REQUIRED IMPORT
import '../../shared/widgets/mini_player.dart';
import '../player/player_screen.dart';

class AmbienceDetailsScreen extends ConsumerWidget {
  final Ambience ambience;

  const AmbienceDetailsScreen({super.key, required this.ambience});

  @override
  // REQUIRED FIX: Add 'WidgetRef ref' to the build method
  Widget build(BuildContext context, WidgetRef ref) { 
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image (Placeholder container for now)
           Image.asset(
              'assets/images/${ambience.id}.png', // Change .jpg to .png if your images are PNGs
              width: double.infinity,
              height: 350, 
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if the image fails to load
                return Container(
                  width: double.infinity,
                  height: 350,
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white38, size: 40),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ambience.title,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ambience.tag} • ${ambience.durationMinutes} Minutes',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    ambience.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text('Sensory Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ambience.sensoryChips.map((chip) {
                      return Chip(
                        label: Text(chip, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white12,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        // This will now work because 'ref' is in the build method
                        ref.read(sessionProvider.notifier).startSession(ambience);
                        
                        Navigator.push(
                          context,
                           MaterialPageRoute(builder: (context) => const SessionPlayerScreen()),
                        );
                      },
                      child: const Text(
                        'Start Session',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}