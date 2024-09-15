import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/login/presentation/screen_1_login.dart'; // Verweise auf deine MeetKochApp

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Timer für 3 Sekunden, bevor zur MeetKochApp navigiert wird
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const MeetKochApp(), // Navigiere zur MeetKochApp
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4B2F3E),
              Color(0xFFB16F92),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bild des Logos
            CircleAvatar(
              radius: 70,
              backgroundColor: Color(0xFFBF8AA7),
              backgroundImage: AssetImage('assets/icons/MeetKoch (2).png'),
            ),
            SizedBox(height: 20),
            Text(
              'MeetKoch',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8AA7),
              ),
            ),
            SizedBox(height: 40),

            // Animierter Ladeindikator
            CircularProgressIndicator(
              color: Colors.white, // Farbe des Ladeindikators
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
