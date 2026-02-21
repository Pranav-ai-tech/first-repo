import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class StudentApi {
  static const String baseUrl = "http://192.168.29.119:8000";

  // ================= LATEST STUDENT =================

  static Future<Map<String, dynamic>> fetchLatestStudent() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final uri =
        Uri.parse("$baseUrl/latest-student?uid=${user.uid}");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        throw Exception(data['error']);
      }

      return data as Map<String, dynamic>;
    } else {
      throw Exception(
          "Server error: ${response.statusCode}");
    }
  }

  // ================= HISTORY =================

  static Future<List<dynamic>> fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final uri =
        Uri.parse("$baseUrl/student-history/${user.uid}");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      return data;
    } else {
      throw Exception(
          "Server error: ${response.statusCode}");
    }
  }
}