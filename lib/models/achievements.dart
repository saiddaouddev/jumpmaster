class Achievement {
  final int id;
  final String key;
  final String title;
  final String description;
  final bool unlocked;

  Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.unlocked,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      key: json['key'],
      title: json['title'],
      description: json['description'] ?? '',
      unlocked: json['unlocked'] ?? false,
    );
  }
}
