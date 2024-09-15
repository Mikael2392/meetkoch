import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/core/presentation/app_home.dart';
import 'package:meetkoch/src/features/Home/presentation/home_screen.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Umschalten der Passwortsichtbarkeit
  bool _isLogoAtTop = true;

  @override
  void initState() {
    super.initState();
    // Startet die Animation nach einer kurzen Verzögerung (z. B. 1 Sekunde)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLogoAtTop = false;
      });
    });
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppHome()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Ein unerwarteter Fehler ist aufgetreten.";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            top:
                _isLogoAtTop ? -150 : MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.5 - 70,
            child: const CircleAvatar(
              radius: 70,
              backgroundColor: Color(0xFFBF8AA7),
              backgroundImage: AssetImage('assets/icons/MeetKoch (2).png'),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
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
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              hintText: 'E-Mail',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte gib deine E-Mail ein';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              hintText: 'Passwort',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bitte gib dein Passwort ein';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 188, 180, 133),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 100.0, vertical: 12.0),
                                  ),
                                  child: const Text(
                                    'Anmelden',
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
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
