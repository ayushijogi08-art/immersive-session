import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ambience.dart';
import '../../data/repositories/ambience_repository.dart';

// Provider for the Repository instance
final ambienceRepositoryProvider = Provider<AmbienceRepository>((ref) {
  return AmbienceRepository();
});

// FutureProvider to fetch the list of ambiences asynchronously
final ambiencesProvider = FutureProvider<List<Ambience>>((ref) async {
  final repository = ref.read(ambienceRepositoryProvider);
  return repository.getAmbiences();
});