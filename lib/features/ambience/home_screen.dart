import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ambience_filter_provider.dart';
import 'ambience_details_screen.dart';
import '../../shared/widgets/mini_player.dart';
import '../journal/history_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAmbiencesAsync = ref.watch(filteredAmbiencesProvider);
    final tags = ['Focus', 'Calm', 'Sleep', 'Reset'];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Premium dark theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ambiences', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            tooltip: 'Journal History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => ref.read(searchQueryProvider.notifier).setQuery(value),
            ),
            const SizedBox(height: 16),

            // 2. Tag Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tags.map((tag) {
                  final isSelected = ref.watch(selectedTagProvider) == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedTagProvider.notifier).setTag(selected ? tag : null);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Grid / List View with AsyncValue handling
            Expanded(
              child: filteredAmbiencesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (ambiences) {
                  if (ambiences.isEmpty) {
                    return _buildEmptyState(ref);
                  }
                  return ListView.builder(
                    itemCount: ambiences.length,
                    itemBuilder: (context, index) {
                      final ambience = ambiences[index];
                      // Placeholder UI for the card. We will extract this to a shared widget later.
                      return Card(
                        color: Colors.white12,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(ambience.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${ambience.tag} • ${ambience.durationMinutes} min'),
                          trailing: const Icon(Icons.play_circle_fill, color: Colors.white),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                 builder: (context) => AmbienceDetailsScreen(ambience: ambience),
                               ),
                             );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  // Required Empty State Logic
  Widget _buildEmptyState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No ambiences found', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).setQuery('');
              ref.read(selectedTagProvider.notifier).setTag(null);
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}