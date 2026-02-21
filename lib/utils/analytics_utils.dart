class AnalyticsUtils {
  /// ✅ SIMPLE & CORRECT CGPA TREND
  static Map<String, String> cgpaTrendWithDelta(List<double> history) {
    if (history.length < 2) {
      return {
        'trend': 'Not enough data',
        'delta': '',
      };
    }

    // 🔹 ONLY last two values
    final double previous = history[history.length - 2];
    final double current = history.last;

    final double diff = current - previous;

    // OPTIONAL: tiny tolerance to avoid floating noise
    const double epsilon = 0.001;

    if (diff > epsilon) {
      return {
        'trend': 'Increasing',
        'delta': '+${diff.toStringAsFixed(2)}',
      };
    }

    if (diff < -epsilon) {
      return {
        'trend': 'Declining',
        'delta': diff.toStringAsFixed(2),
      };
    }

    return {
      'trend': 'Stable',
      'delta': '0.00',
    };
  }

  // ================= CAREER PATHS (UNCHANGED) =================
  static List<String> inferCareerPaths(
    Map<String, bool> skills,
    double projectCount,
  ) {
    final selected =
        skills.entries.where((e) => e.value).map((e) => e.key).toSet();

    final List<String> paths = [];

    if (selected.containsAll(['Python', 'SQL', 'Statistics'])) {
      paths.add('Data / Business Analytics');
    }

    if (selected.containsAll(['Python', 'Machine Learning']) &&
        projectCount >= 2) {
      paths.add('Data Science / AI');
    }

    if (selected.contains('Java') && projectCount >= 2) {
      paths.add('Software Development');
    }

    if (selected.containsAll(
        ['Power BI / Tableau', 'Data Visualization'])) {
      paths.add('Business Intelligence');
    }

    if (paths.isEmpty) {
      paths.add('Select skills and add projects to see suggestions');
    }

    return paths;
  }
}