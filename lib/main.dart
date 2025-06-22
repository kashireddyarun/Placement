import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure you have this file

import 'login_page.dart';
import 'signup_page.dart';
import 'student_dashboard.dart';
import 'staff_dashboard_1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Ensure firebase_options.dart exists
  );
  print("Firebase initialized successfully.");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      title: 'Agni Student Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/student_dashboard': (context) => StudentDashboardPage(),
        '/staff_dashboard': (context) => StaffDashboardPage(),
      },
    );
  }
}
