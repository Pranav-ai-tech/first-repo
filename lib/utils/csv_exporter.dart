import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExporter {
  static Future<void> exportUserDataToCsv() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;

      // 🔹 User profile
      final userDoc =
          await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // 🔹 Performance history (OLDEST → LATEST)
      final historySnap = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('performance')
          .orderBy('timestamp', descending: false)
          .get();

      if (historySnap.docs.isEmpty) return;

      final allSkills = [
        'SQL',
        'Excel',
        'Statistics',
        'Power BI / Tableau',
        'Machine Learning',
        'Data Preprocessing',
        'Git / GitHub',
        'Firebase',
        'Python',
        'Java',
        'Dart',
      ];

      final rows = <List<dynamic>>[
        [
          'Name',
          'Email',
          'CGPA',
          'Attendance',
          'Projects',
          ...allSkills,
          'Timestamp',
        ]
      ];

      for (final doc in historySnap.docs) {
        final data = doc.data();

        final skills = (data['skills'] is List)
            ? List<String>.from(data['skills'])
            : <String>[];

        final ts = data['timestamp'];
        final timestamp = ts is Timestamp
            ? ts.toDate().toIso8601String()
            : DateTime.now().toIso8601String(); // fallback

        rows.add([
          userData['name'] ?? user.displayName ?? '',
          userData['email'] ?? user.email ?? '',
          data['cgpa'] ?? 0,
          data['attendance'] ?? 0,
          data['projects'] ?? 0,
          ...allSkills.map((s) => skills.contains(s) ? 1 : 0),
          timestamp,
        ]);
      }

      final csvData = const ListToCsvConverter().convert(rows);

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/student_performance.csv');

      await file.writeAsString(csvData, flush: true);

      debugPrint('✅ CSV saved at: ${file.path}');
      debugPrint('✅ Latest timestamp: ${rows.last.last}');

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Student Performance Data (CSV)',
      );
    } catch (e, s) {
      debugPrint('❌ CSV export failed: $e');
      debugPrint(s.toString());
    }
  }
}
