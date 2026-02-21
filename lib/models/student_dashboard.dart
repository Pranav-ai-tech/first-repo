class StudentDashboard {
  final String name;
  final double cgpa;
  final int attendance;
  final int projects;
  final List<String> skills;
  final DateTime timestamp;

  const StudentDashboard({
    required this.name,
    required this.cgpa,
    required this.attendance,
    required this.projects,
    required this.skills,
    required this.timestamp,
  });

  /// Empty state (useful for loading screens)
  factory StudentDashboard.empty() {
    return StudentDashboard(
      name: '',
      cgpa: 0.0,
      attendance: 0,
      projects: 0,
      skills: const [],
      timestamp: DateTime.now(),
    );
  }

  /// Firestore → Model
  factory StudentDashboard.fromFirestore(Map<String, dynamic> data) {
    return StudentDashboard(
      name: data['name'] ?? '',
      cgpa: (data['cgpa'] as num).toDouble(),
      attendance: data['attendance'] ?? 0,
      projects: data['projects'] ?? 0,
      skills: List<String>.from(data['skills'] ?? []),
      timestamp: data['timestamp'].toDate(),
    );
  }
}
