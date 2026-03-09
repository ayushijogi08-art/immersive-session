import 'package:arvyax_assignment/features/player/session_controller.dart';
import 'package:flutter/material.dart';
import '../../data/models/ambience.dart';
import '../../data/repositories/journal_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  final Ambience ambience;

  const ReflectionScreen({super.key, required this.ambience});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final TextEditingController _journalController = TextEditingController();
  String? _selectedMood;
  final List<String> _moods = ['Calm', 'Grounded', 'Energized', 'Sleepy']; // Explicitly required moods

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _saveReflection() {
    if (_selectedMood == null || _journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood and write a reflection.')),
      );
      return;
    }
    final entry = {
      'date': DateTime.now().toIso8601String(),
      'ambienceTitle': widget.ambience.title,
      'mood': _selectedMood,
      'text': _journalController.text.trim(),
    };

    ref.read(journalProvider.notifier).addReflection(entry);
    // TODO: Phase 4 - Persist to Hive database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflection saved.')),
    );
    
    ref.read(sessionProvider.notifier).stopSession();

    // Pop back to home screen after saving
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      final ambience = next.activeAmbience;
      if (ambience != null) {
        final totalSeconds = ambience.durationMinutes * 60; // Convert minutes to seconds
        
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Reflection', style: TextStyle(fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false, // User must complete or skip, no back arrow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Complete: ${widget.ambience.title}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'What is gently present with you right now?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
            ),
            const SizedBox(height: 32),
            
            // Mood Selector
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return ChoiceChip(
                  label: Text(mood, style: const TextStyle(fontSize: 16)),
                  selected: isSelected,
                  selectedColor: Colors.white,
                  labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                  backgroundColor: Colors.white10,
                  onSelected: (selected) {
                    setState(() => _selectedMood = selected ? mood : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Journal Input
            TextField(
              controller: _journalController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Type your thoughts here...',
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: _saveReflection,
                child: const Text('Save Reflection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                
              ),
            ),
            const SizedBox(height: 16),
            
            // Skip Button
           // Skip Button
            Center(
              child: TextButton(
                onPressed: () {
                  // 1. Kill the session
                  ref.read(sessionProvider.notifier).stopSession();
                  // 2. Navigate back to home
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
              ),
            )
          ],
        ),
      ),
    );
  }
}