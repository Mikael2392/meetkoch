import 'package:flutter/material.dart';
import 'package:meetkoch/src/core/presentation/app_home.dart';
import 'package:meetkoch/src/features/registrieren/presentation/screen_1_registrieren.dart';
import 'dart:async'; // Für den Delayed-Timer

class MeetKochApp extends StatelessWidget {
  const MeetKochApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MeetKochHome(),
    );
  }
}

class MeetKochHome extends StatefulWidget {
  const MeetKochHome({super.key});

  @override
  State<MeetKochHome> createState() => _MeetKochHomeState();
}

class _MeetKochHomeState extends State<MeetKochHome> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLogoAtTop = true; // Variable zur Kontrolle der Logo-Position

  @override
  void initState() {
    super.initState();

    // Starte die Animation nach einer kurzen Verzögerung (z.B. 1 Sekunde)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLogoAtTop = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Hintergrunddekoration
          Container(
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
          ),
          // Animierter Avatar
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            top: _isLogoAtTop
                ? -150
                : MediaQuery.of(context).size.height *
                    0.15, // Position animiert von oben
            left: MediaQuery.of(context).size.width * 0.5 -
                70, // Zentrieren des Logos
            child: const CircleAvatar(
              radius: 70,
              backgroundColor: Color(0xFFBF8AA7),
              backgroundImage: AssetImage('assets/icons/MeetKoch (2).png'),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  const Text(
                    'MeetKoch',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8AA7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            hintText: 'Username, Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppHome(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 188, 180, 133),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100.0, vertical: 12.0),
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 200),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationScreen1(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 188, 180, 133),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100.0, vertical: 12.0),
                          ),
                          child: const Text(
                            'Registrieren',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
