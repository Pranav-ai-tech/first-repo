import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/student_api.dart';
import '../utils/analytics_utils.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  double cgpa = 0;
  double attendance = 0;
  int projects = 0;

  List<double> cgpaHistory = [];
  List<double> attendanceHistory = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  // ================= DATA LOAD =================

  Future<void> _loadInsights() async {
    try {
      // 🔥 Get latest record
      final latestData = await StudentApi.fetchLatestStudent();

      // 🔥 Get full history
      final history = await StudentApi.fetchHistory();

      if (!mounted) return;

      setState(() {
        cgpa = (latestData['CGPA'] ?? 0).toDouble();
        attendance = (latestData['Attendance'] ?? 0).toDouble();
        projects = (latestData['Projects'] ?? 0).toInt();

        // 🔥 Build full history lists
        cgpaHistory = history
            .map<double>((e) => (e['cgpa'] ?? 0).toDouble())
            .toList();

        attendanceHistory = history
            .map<double>((e) => (e['attendance'] ?? 0).toDouble())
            .toList();

        loading = false;
      });
    } catch (e) {
      debugPrint("Insights load error: $e");
      if (!mounted) return;
      setState(() {
        error = 'Failed to load insights';
        loading = false;
      });
    }
  }

  // ================= ANALYTICS =================

  String cgpaTrendWithDelta() {
    final result = AnalyticsUtils.cgpaTrendWithDelta(cgpaHistory);

    if (result['delta'] == null || result['delta']!.isEmpty) {
      return result['trend'] ?? 'Stable';
    }

    return '${result['trend']} (${result['delta']})';
  }

  String attendanceCgpaTrend() {
    if (attendanceHistory.length < 2 || cgpaHistory.length < 2) {
      return 'Insufficient data';
    }

    final aDiff =
        attendanceHistory.last - attendanceHistory[attendanceHistory.length - 2];
    final gDiff =
        cgpaHistory.last - cgpaHistory[cgpaHistory.length - 2];

    if (aDiff > 0 && gDiff > 0) return 'Positive correlation';
    if (aDiff < 0 && gDiff < 0) return 'Negative correlation';
    if (aDiff > 0 && gDiff < 0) {
      return 'Attendance improving, CGPA declining';
    }
    if (aDiff < 0 && gDiff > 0) {
      return 'CGPA resilient despite attendance drop';
    }

    return 'No significant change';
  }

  String projectAssessment() {
    if (projects == 0) return 'No practical exposure';
    if (projects <= 2) return 'Limited practical exposure';
    if (projects <= 5) return 'Adequate practical exposure';
    return 'Strong practical exposure';
  }

  String riskLevel() {
    if (cgpa < 6 && attendance < 70) return 'High Risk';
    if (cgpa < 6 && projects == 0) return 'High Risk';

    final trend =
        AnalyticsUtils.cgpaTrendWithDelta(cgpaHistory)['trend'];

    if (trend == 'Declining') return 'Medium Risk';
    if (attendance < 75) return 'Medium Risk';
    if (projects <= 2) return 'Medium Risk';

    return 'Low Risk';
  }

  String whatIfScenario() {
    switch (riskLevel()) {
      case 'High Risk':
        return 'Immediate intervention required: improve academics, attendance, and projects.';
      case 'Medium Risk':
        return 'Performance can improve with better consistency and hands-on practice.';
      default:
        return 'Current academic behavior is likely to sustain performance.';
    }
  }

  List<String> recommendedActions() {
    final actions = <String>[];

    if (cgpa < 7) actions.add('Adopt structured study planning.');
    if (attendance < 75) actions.add('Improve attendance consistency.');
    if (projects <= 2) actions.add('Engage in additional hands-on projects.');

    if (actions.isEmpty) {
      actions.add('Maintain current academic discipline.');
    }
    return actions;
  }

  String insightConfidence() {
    if (cgpaHistory.length >= 5) return 'High';
    if (cgpaHistory.length >= 3) return 'Medium';
    return 'Low';
  }

  // ================= PDF =================

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Actionable Insights Report',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('CGPA Trend: ${cgpaTrendWithDelta()}'),
            pw.Text('Attendance vs CGPA: ${attendanceCgpaTrend()}'),
            pw.Text('Projects Completed: $projects'),
            pw.SizedBox(height: 12),
            pw.Text('Risk Level: ${riskLevel()}'),
            pw.Text('Prediction: ${whatIfScenario()}'),
            pw.Text('Confidence: ${insightConfidence()}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actionable Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _sectionCard(
            context,
            'Descriptive Analytics',
            Icons.bar_chart,
            [
              _metric(context, 'CGPA Trend', cgpaTrendWithDelta()),
              _metric(context, 'Attendance vs CGPA',
                  attendanceCgpaTrend()),
              _metric(context, 'Projects Completed',
                  projects.toString()),
            ],
          ),
          _sectionCard(
            context,
            'Diagnostic Analytics',
            Icons.warning_amber,
            [
              _metric(context, 'Risk Level', riskLevel()),
              _metric(context, 'Project Assessment',
                  projectAssessment()),
            ],
          ),
          _sectionCard(
            context,
            'Predictive Analytics',
            Icons.trending_up,
            [
              Text(whatIfScenario(),
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              Chip(label: Text('Confidence: ${insightConfidence()}')),
            ],
          ),
          _sectionCard(
            context,
            'Prescriptive Analytics',
            Icons.check_circle_outline,
            recommendedActions()
                .map((a) => Text('• $a'))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ]),
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}