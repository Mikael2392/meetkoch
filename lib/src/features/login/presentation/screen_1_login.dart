import 'package:flutter/material.dart';
import 'package:meetkoch/src/core/presentation/app_home.dart';
import 'package:meetkoch/src/features/registrieren/presentation/screen_1_registrieren.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  const CircleAvatar(
                    radius: 70,
                    backgroundColor: Color(0xFFBF8AA7),
                    backgroundImage:
                        AssetImage('assets/icons/MeetKoch (2).png'),
                  ),
                  const SizedBox(height: 20),
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
                            errorStyle: const TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter an email.";
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegex.hasMatch(value)) {
                              return "Please enter a valid email address.";
                            }
                            return null;
                          },
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
                            errorStyle: const TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password.";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters long.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AppHome(),
                                ),
                              );
                            }
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
        ),
      ),
    );
  }
}
