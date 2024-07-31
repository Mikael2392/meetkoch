import 'package:flutter/material.dart';
import 'dart:ui'; // Für BackdropFilter

class Screen2RegistrierenArbeitsgeber extends StatelessWidget {
  const Screen2RegistrierenArbeitsgeber({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrieren',
          style: TextStyle(
              color: Color.fromARGB(255, 167, 188, 168)), // Textfarbe AppBar
        ),
        backgroundColor: const Color(0xFF4B2F3E), // Hintergrundfarbe der AppBar
        iconTheme:
            const IconThemeData(color: Colors.black), // Farbe der AppBar Icons
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
            _buildBlurryContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Stammdaten'),
                  _buildTextField('Firma'),
                  _buildTextField('Vorname Geschäftsführer'),
                  _buildTextField('Nachname Geschäftsführer'),
                  _buildTextField('Strasse + Nr'),
                  _buildTextField('PLZ'),
                  _buildTextField('Deutschland'),
                  _buildTextField('UST. Id Nr. / St. Nr.'),
                  _buildTextField('Telefon'),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildBlurryContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Zugangsdaten'),
                  _buildTextField('E-Mail'),
                  _buildTextField('Passwort', isPassword: true),
                  _buildTextField('Passwort wiederholen', isPassword: true),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildBlurryContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Registrierung abschliessen'),
                  _buildSwitchTile('AGB'),
                  _buildSwitchTile('Datenschutz'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle registration logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 203, 173, 89),
                    ),
                    child: const Text(
                      'Registrieren',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurryContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 210, 212, 201)
                .withOpacity(0.7), // Opazität des Containers
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 41, 50, 45),
      ),
    );
  }

  Widget _buildTextField(String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16)),
        Switch(value: false, onChanged: (bool newValue) {}),
      ],
    );
  }
}
