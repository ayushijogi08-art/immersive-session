import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalRepository {
  final Box _box = Hive.box('journalBox');
  
// Fetch all saved reflections (Hardened for Web compatibility)
  List<Map<String, dynamic>> getReflections() {
    try {
      final data = _box.get('entries', defaultValue: []);
      if (data == null) return [];
      
      // Explicitly handle dynamic casting which Web requires
      final List<dynamic> rawList = data as List<dynamic>;
      return rawList.map((e) {
        final map = e as Map;
        return map.cast<String, dynamic>();
      }).toList();
    } catch (e) {
      print("Hive cast error: $e");
      return []; // Return empty list instead of crashing UI
    }
  }

  // Save a new reflection to the top of the list
  Future<void> saveReflection(Map<String, dynamic> entry) async {
    final currentEntries = getReflections();
    currentEntries.insert(0, entry); // Add to the beginning (newest first)
    await _box.put('entries', currentEntries);
  }
}

// Global provider for the repository
final journalRepoProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

// StateNotifier to reactively update the UI when a new journal is added
class JournalNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return ref.read(journalRepoProvider).getReflections();
  }

  Future<void> addReflection(Map<String, dynamic> entry) async {
    print("----- HIVE: ATTEMPTING TO SAVE ENTRY -----");
    print(entry);
    
    await ref.read(journalRepoProvider).saveReflection(entry);
    
    final newState = ref.read(journalRepoProvider).getReflections();
    print("----- HIVE: CURRENT DATABASE CONTENTS -----");
    print(newState);
    
    // The spread operator [...] forces Riverpod to recognize a new list and update the UI
    state = [...newState];
    }
}

final journalProvider = NotifierProvider<JournalNotifier, List<Map<String, dynamic>>>(
  JournalNotifier.new,
);