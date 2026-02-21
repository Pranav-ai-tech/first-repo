import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/theme_controller.dart';
import '../utils/analytics_utils.dart';
import '../utils/csv_exporter.dart';

import 'performance_chart.dart';
import 'profilescreen.dart';
import 'community_screen.dart';
import 'insights_screen.dart';
import 'portfolio_screen.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardHome(),
    ProfileScreen(),
    CommunityScreen(),
    InsightsScreen(),
    PortfolioScreen(),
  ];

  Future<void> _logout() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (mode) =>
                context.read<ThemeController>().setTheme(mode),
            itemBuilder: (_) => const [
              PopupMenuItem(value: ThemeMode.light, child: Text('☀️ Light')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('🌙 Dark')),
              PopupMenuItem(value: ThemeMode.system, child: Text('🖥 System')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Portfolio'),
        ],
      ),
    );
  }
}

/* ================= DASHBOARD HOME ================= */

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final cgpaController = TextEditingController();
  final attendanceController = TextEditingController();
  final projectController = TextEditingController();

  double cgpaValue = 0;
  double attendanceValue = 0;
  int projectValue = 0;

  List<double> cgpaHistory = [];
  bool analyticsLoading = true;

  final Map<String, Map<String, bool>> skills = {
    'Programming': {'Python': false, 'Java': false, 'Dart': false},
    'Data & Analytics': {
      'SQL': false,
      'Excel': false,
      'Statistics': false,
      'Power BI / Tableau': false,
    },
    'AI / ML': {
      'Machine Learning': false,
      'Data Preprocessing': false,
    },
    'Tools': {'Git / GitHub': false, 'Firebase': false},
  };

  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadUserSummary();
    _loadPerformanceHistory();
  }

  Future<void> _loadUserSummary() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      cgpaValue = (data['cgpa'] ?? 0).toDouble();
      attendanceValue = (data['attendance'] ?? 0).toDouble();
      projectValue = (data['projects'] ?? 0).toInt();

      cgpaController.text = cgpaValue.toString();
      attendanceController.text = attendanceValue.toString();
      projectController.text = projectValue.toString();

      final savedSkills =
          (data['skills'] is List) ? List<String>.from(data['skills']) : [];

      skills.forEach((_, group) {
        group.forEach((skill, _) {
          group[skill] = savedSkills.contains(skill);
        });
      });
    });
  }

  List<String> _extractSelectedSkills() {
    final selected = <String>[];
    skills.forEach((_, group) {
      group.forEach((skill, isSelected) {
        if (isSelected) selected.add(skill);
      });
    });
    return selected;
  }

  List<String> _careerSuggestions() {
    final s = _extractSelectedSkills();
    final List<String> suggestions = [];

    if (s.contains('SQL') && s.contains('Excel') && s.contains('Statistics')) {
      suggestions.add('📊 Data Analyst / Business Analyst');
    }
    if (s.contains('Machine Learning') && cgpaValue >= 8) {
      suggestions.add('🤖 AI / ML Engineer');
    }
    if ((s.contains('Dart') || s.contains('Java')) && projectValue >= 2) {
      suggestions.add('💻 Software / App Developer');
    }
    if (suggestions.isEmpty) {
      suggestions.add('🎯 Build more focused skills & projects');
    }
    return suggestions;
  }

  Future<void> _loadPerformanceHistory() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('performance')
        .orderBy('timestamp')
        .get();

    setState(() {
      cgpaHistory =
          snap.docs.map((d) => (d['cgpa'] as num).toDouble()).toList();
      analyticsLoading = false;
    });
  }

  Future<void> _updatePerformance() async {
    if (user == null) return;

    final now = Timestamp.now();
    final selectedSkills = _extractSelectedSkills();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set({
      'cgpa': double.parse(cgpaController.text),
      'attendance': double.parse(attendanceController.text),
      'projects': int.parse(projectController.text),
      'skills': selectedSkills,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('performance')
        .add({
      'cgpa': double.parse(cgpaController.text),
      'attendance': double.parse(attendanceController.text),
      'projects': int.parse(projectController.text),
      'skills': selectedSkills,
      'timestamp': now,
    });

    await _loadUserSummary();
    await _loadPerformanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = AnalyticsUtils.cgpaTrendWithDelta(cgpaHistory);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        /// INPUTS
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _input('CGPA', cgpaController),
                _input('Attendance (%)', attendanceController),
                _input('Projects', projectController),
                ElevatedButton(
                  onPressed: _updatePerformance,
                  child: const Text('Update Performance'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// PERFORMANCE CHART
        PerformanceChart(
          cgpa: cgpaValue,
          attendance: attendanceValue,
          projects: projectValue.toDouble(),
        ),

        const SizedBox(height: 16),

        /// 🧠 SKILLS (RESTORED)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🧠 Skills',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...skills.entries.map((group) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        ...group.value.keys.map((skill) {
                          return CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(skill),
                            value: group.value[skill],
                            onChanged: (v) =>
                                setState(() => group.value[skill] = v!),
                          );
                        }),
                        const Divider(),
                      ],
                    )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// ANALYTICS
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              cgpaHistory.length < 2
                  ? '📈 CGPA Progress: Not enough data'
                  : '📈 CGPA Progress: ${analytics['trend']} (${analytics['delta']})',
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// CAREER
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎓 Career Suggestions',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ..._careerSuggestions().map((e) => Text('• $e')),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// CSV EXPORT
        ElevatedButton.icon(
          onPressed: () async {
            await CsvExporter.exportUserDataToCsv();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV exported successfully')),
              );
            }
          },
          icon: const Icon(Icons.download),
          label: const Text('Export as CSV'),
        ),
      ],
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
