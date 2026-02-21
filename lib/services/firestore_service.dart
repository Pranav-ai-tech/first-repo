import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= CURRENT USER =================
  String? get _uid => _auth.currentUser?.uid;

  // ================= LOAD USER DATA =================
  Future<Map<String, dynamic>?> getUserData() async {
    if (_uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      print("Error loading user data: $e");
      return null;
    }
  }

  // ================= LOAD PERFORMANCE HISTORY =================
  Future<List<Map<String, dynamic>>> getPerformanceHistory() async {
    if (_uid == null) return [];

    try {
      final snap = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('performance')
          .orderBy('timestamp', descending: false)
          .get();

      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print("Error loading performance history: $e");
      return [];
    }
  }

  // ================= UPDATE PERFORMANCE =================
  Future<void> updatePerformance({
    required double cgpa,
    required int attendance,
    required int projects,
    required List<String> skills,
  }) async {
    if (_uid == null) return;

    try {
      final userRef = _firestore.collection('users').doc(_uid);

      // 🔥 1️⃣ Update main user document (latest snapshot)
      await userRef.set({
        'cgpa': cgpa,
        'attendance': attendance,
        'projects': projects,
        'skills': skills,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 🔥 2️⃣ Add history record (CRITICAL FOR ANALYTICS)
      await userRef.collection('performance').add({
        'cgpa': cgpa,
        'attendance': attendance,
        'projects': projects,
        'skills': skills,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ Performance updated successfully");
    } catch (e) {
      print("❌ Error updating performance: $e");
    }
  }
}
