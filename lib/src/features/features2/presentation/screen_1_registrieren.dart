import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/features2/presentation/screen_2_registrieren.dart';
import 'package:meetkoch/src/features/features2/presentation/screen_2_registrieren_arbeitsgeber.dart';

class RegistrationScreen1 extends StatelessWidget {
  const RegistrationScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrieren',
          style: TextStyle(
            color: Color.fromARGB(255, 167, 188, 168),
          ),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildNormalContainer(
              title: "Auftraggeber / Gastronomiebetrieb",
              text:
                  "Ich möchte mich als Auftraggeber registrieren und selber mein Personalgesuch einstellen, um passendes gastronomisches Fachpersonal oder selbständige Gastronomen für meinen speziellen Bedarf vermittelt zu bekommen.",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const Screen2RegistrierenArbeitsgeber(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildNormalContainer(
              title: "Freiberufler / Selbstständiger / AÜ",
              text:
                  "Ich möchte mich als Koch, Küchenchef, Küchendirektor, Servicekraft oder sonstiges gastronomisches Fachpersonal registrieren.",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RegistrationScreenFreiberufler(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalContainer({
    required String title,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFD2D4C8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 41, 50, 45),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 209, 203, 164),
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
            ),
            child: const Text(
              'Registrieren',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
