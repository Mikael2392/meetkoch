import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufträge'),
        backgroundColor: Colors.grey[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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
            SizedBox(height: 20),
            _buildSectionTitle('Zugangsdaten'),
            _buildTextField('E-Mail'),
            _buildTextField('Passwort', isPassword: true),
            _buildTextField('Passwort wiederholen', isPassword: true),
            SizedBox(height: 20),
            _buildSectionTitle('Registrierung abschliessen'),
            _buildSwitchTile('AGB'),
            _buildSwitchTile('Datenschutz'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle registration logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
              child: const Text('Registrieren',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
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
