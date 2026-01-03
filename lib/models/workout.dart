class Workout {
  final int id;
  final int jumps;
  final int durationSeconds;
  final double calories;
  final DateTime startedAt;
  final String startedAtFormatted;

  Workout.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        jumps = json['jumps'] ?? "",
        durationSeconds = json['duration_seconds'] ?? "",
        calories = (json['calories'] ?? 0).toDouble(),
        startedAtFormatted =json['started_at_formatted'] ?? "",
        startedAt = DateTime.parse(json['started_at'] ?? "");
}
