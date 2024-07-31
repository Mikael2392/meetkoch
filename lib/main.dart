import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/features1/presentation/screen_1_login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MeetKochApp(),
    );
  }
}
