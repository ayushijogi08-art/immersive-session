class Ambience {
  final String id;
  final String title;
  final String tag;
  final int durationMinutes;
  final String thumbnailUrl;
  final String description;
  final List<String> sensoryChips;

  Ambience({
    required this.id,
    required this.title,
    required this.tag,
    required this.durationMinutes,
    required this.thumbnailUrl,
    required this.description,
    required this.sensoryChips,
  });

  factory Ambience.fromJson(Map<String, dynamic> json) {
    return Ambience(
      id: json['id'],
      title: json['title'],
      tag: json['tag'],
      durationMinutes: json['duration_minutes'],
      thumbnailUrl: json['thumbnail_url'],
      description: json['description'],
      sensoryChips: List<String>.from(json['sensory_chips']),
    );
  }
}