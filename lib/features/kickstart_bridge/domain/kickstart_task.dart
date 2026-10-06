class KickstartTask {
  final String title;
  final DateTime createdAt;
  final int durationSeconds;
  final bool isCompleted;

  const KickstartTask({
    required this.title,
    required this.createdAt,
    this.durationSeconds = 120,
    this.isCompleted = false,
  });

  KickstartTask copyWith({
    String? title,
    DateTime? createdAt,
    int? durationSeconds,
    bool? isCompleted,
  }) {
    return KickstartTask(
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
