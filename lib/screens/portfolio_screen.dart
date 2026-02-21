import 'package:flutter/material.dart';

enum PortfolioTrack {
  businessAnalytics,
  dataScience,
  management,
  softwareAnalytics,
}

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  PortfolioTrack selectedTrack = PortfolioTrack.businessAnalytics;

  String get trackTitle {
    switch (selectedTrack) {
      case PortfolioTrack.dataScience:
        return 'Data Science Portfolio';
      case PortfolioTrack.management:
        return 'Management / MBA Portfolio';
      case PortfolioTrack.softwareAnalytics:
        return 'Software + Analytics Portfolio';
      default:
        return 'Business Analytics Portfolio';
    }
  }

  String get trackDescription {
    switch (selectedTrack) {
      case PortfolioTrack.dataScience:
        return
            'Projects focused on statistical reasoning, correlations, and modeling readiness.';
      case PortfolioTrack.management:
        return
            'Projects interpreted through KPIs, decisions, and strategic outcomes.';
      case PortfolioTrack.softwareAnalytics:
        return
            'Projects focused on system design, data flow, and analytics-driven UX.';
      default:
        return
            'Projects interpreted through business insights, KPI tracking, and decision support.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Analytics Portfolio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PortfolioHeader(
            title: trackTitle,
            description: trackDescription,
            selectedTrack: selectedTrack,
            onChanged: (track) {
              setState(() => selectedTrack = track);
            },
          ),
          const SizedBox(height: 24),

          _AnalyticsProjectCard(
            title: 'Student Performance Analytics Dashboard',
            items: const [
              _MetricItem('🎯 Problem',
                  'Identify factors affecting student performance and retention'),
              _MetricItem('📂 Data',
                  'CGPA, Attendance %, Project Count (simulated dataset)'),
              _MetricItem(
                  '🛠 Tools', 'Python, Pandas, Matplotlib, Excel'),
              _MetricItem('📊 Technique',
                  'Descriptive analytics, correlation analysis, KPI tracking'),
              _MetricItem('💡 Insight',
                  'Attendance below 75% strongly correlates with CGPA decline'),
            ],
            roleFocus: _roleFocus(
              selectedTrack,
              businessAnalytics:
                  'Converted academic KPIs into decision-support insights.',
              dataScience:
                  'Analyzed relationships between variables for modeling readiness.',
              management:
                  'Translated analytics into retention and policy recommendations.',
              softwareAnalytics:
                  'Designed analytics-driven dashboards for end users.',
            ),
          ),

          _AnalyticsProjectCard(
            title: 'Business KPI Mobile Dashboard',
            items: const [
              _MetricItem('🎯 Problem',
                  'Enable students to track academic KPIs in real time'),
              _MetricItem(
                  '📂 Data', 'User-entered academic performance metrics'),
              _MetricItem('🛠 Tools', 'Flutter, Firebase, Firestore'),
              _MetricItem('📊 Technique',
                  'Real-time visualization, conditional insights'),
              _MetricItem('💡 Impact',
                  'Improved clarity of trends and self-assessment'),
            ],
            roleFocus: _roleFocus(
              selectedTrack,
              businessAnalytics:
                  'Delivered real-time KPIs for performance monitoring.',
              dataScience:
                  'Prepared structured data for downstream analytics.',
              management:
                  'Improved transparency for informed academic decisions.',
              softwareAnalytics:
                  'Built scalable analytics using Firebase architecture.',
            ),
          ),

          _AnalyticsProjectCard(
            title: 'Sales Forecasting & Trend Analysis',
            items: const [
              _MetricItem(
                  '🎯 Problem', 'Forecast sales for planning decisions'),
              _MetricItem('📂 Data', 'Historical monthly sales data'),
              _MetricItem('🛠 Tools', 'Excel, Regression Models'),
              _MetricItem(
                  '📊 Technique', 'Trend analysis, linear regression'),
              _MetricItem('💡 Impact',
                  'Improved inventory and planning efficiency'),
            ],
            roleFocus: _roleFocus(
              selectedTrack,
              businessAnalytics:
                  'Supported operational planning using forecasts.',
              dataScience:
                  'Modeled time-series behavior using regression.',
              management:
                  'Enabled data-backed planning decisions.',
              softwareAnalytics:
                  'Demonstrated analytics logic suitable for automation.',
            ),
          ),
        ],
      ),
    );
  }
}

// ================= HEADER =================

class _PortfolioHeader extends StatelessWidget {
  final String title;
  final String description;
  final PortfolioTrack selectedTrack;
  final ValueChanged<PortfolioTrack> onChanged;

  const _PortfolioHeader({
    required this.title,
    required this.description,
    required this.selectedTrack,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: PortfolioTrack.values.map((track) {
              final isSelected = track == selectedTrack;
              return ChoiceChip(
                label: Text(
                  track.name
                      .replaceAllMapped(
                          RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
                      .trim(),
                ),
                selected: isSelected,
                onSelected: (_) => onChanged(track),
                selectedColor: colors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colors.onPrimary
                      : colors.onSurface,
                ),
              );
            }).toList(),
          )
        ]),
      ),
    );
  }
}

// ================= PROJECT CARD =================

class _AnalyticsProjectCard extends StatelessWidget {
  final String title;
  final List<_MetricItem> items;
  final String roleFocus;

  const _AnalyticsProjectCard({
    required this.title,
    required this.items,
    required this.roleFocus,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items,
          const Divider(height: 24),
          Text(
            '🎯 Role Focus',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: colors.primary),
          ),
          const SizedBox(height: 4),
          Text(roleFocus),
        ]),
      ),
    );
  }
}

// ================= METRIC ITEM =================

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: const TextStyle(height: 1.4),
      ),
    );
  }
}

// ================= ROLE FOCUS HELPER =================

String _roleFocus(
  PortfolioTrack track, {
  required String businessAnalytics,
  required String dataScience,
  required String management,
  required String softwareAnalytics,
}) {
  switch (track) {
    case PortfolioTrack.dataScience:
      return dataScience;
    case PortfolioTrack.management:
      return management;
    case PortfolioTrack.softwareAnalytics:
      return softwareAnalytics;
    default:
      return businessAnalytics;
  }
}