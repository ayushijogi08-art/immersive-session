import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ambience_provider.dart';
import '../../data/models/ambience.dart';

// 1. Modern Riverpod 3.0 Notifier for Search
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// 2. Modern Riverpod 3.0 Notifier for Tag Selection
class SelectedTagNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTag(String? tag) {
    state = tag;
  }
}

final selectedTagProvider = NotifierProvider<SelectedTagNotifier, String?>(
  SelectedTagNotifier.new,
);

// 3. Filtered List Logic (remains the same)
final filteredAmbiencesProvider = Provider<AsyncValue<List<Ambience>>>((ref) {
  final ambiencesAsync = ref.watch(ambiencesProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedTag = ref.watch(selectedTagProvider);

  return ambiencesAsync.whenData((ambiences) {
    return ambiences.where((ambience) {
      final matchesSearch = ambience.title.toLowerCase().contains(searchQuery);
      final matchesTag = selectedTag == null || ambience.tag == selectedTag;
      return matchesSearch && matchesTag;
    }).toList();
  });
});