import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'utils/theme_controller.dart';
import 'screens/screen.dart'; // LoginScreen
import 'screens/dashboard_screen.dart';
import 'screens/profilescreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: themeController.themeMode,

      // ☀️ LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A4FB3),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F4FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A4FB3),
          foregroundColor: Colors.white,
        ),
      ),

      // 🌙 DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9A7DFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),

      home: const AuthGate(),
    );
  }
}

/// 🔐 AUTH ROUTING (CLEAN & SAFE)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🚪 Not logged in → Google Login
        if (!snapshot.hasData) {
          return const LoginScreen(
            key: ValueKey('login'),
          );
        }

        final user = snapshot.data!;

        // 🔍 Check if career profile exists
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('profile')
              .doc('career')
              .get(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 📝 First-time user → Profile screen
            if (!profileSnapshot.hasData ||
                !profileSnapshot.data!.exists) {
              return const ProfileScreen(
                key: ValueKey('profile'),
              );
            }

            // 🏠 Logged in → Dashboard
            return const DashboardScreen(
              key: ValueKey('dashboard'),
            );
          },
        );
      },
    );
  }
}