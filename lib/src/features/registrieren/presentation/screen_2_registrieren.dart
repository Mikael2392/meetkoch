import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetkoch/src/features/Home/presentation/home_screen.dart';
import 'package:meetkoch/src/features/login/presentation/screen_1_login.dart';

class RegistrationScreenFreiberufler extends StatefulWidget {
  const RegistrationScreenFreiberufler({super.key});

  @override
  _RegistrationScreenFreiberuflerState createState() =>
      _RegistrationScreenFreiberuflerState();
}

class _RegistrationScreenFreiberuflerState
    extends State<RegistrationScreenFreiberufler> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firmaController = TextEditingController();
  final TextEditingController _vornameController = TextEditingController();
  final TextEditingController _nachnameController = TextEditingController();
  final TextEditingController _strasseController = TextEditingController();
  final TextEditingController _plzController = TextEditingController();
  final TextEditingController _landController = TextEditingController();
  final TextEditingController _ustIdNrController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _registerFreelancer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Register user
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save user info with the role of 'freelancer'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text.trim(),
          'firma': _firmaController.text.trim(),
          'vorname': _vornameController.text.trim(),
          'nachname': _nachnameController.text.trim(),
          'strasse': _strasseController.text.trim(),
          'plz': _plzController.text.trim(),
          'land': _landController.text.trim(),
          'ustIdNr': _ustIdNrController.text.trim(),
          'telefon': _telefonController.text.trim(),
          'userId': userCredential.user!.uid,
          'role': 'freelancer', // Assign freelancer role
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Freelancer Registrierung erfolgreich!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        // Navigate to freelancer dashboard or home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MeetKochApp()),
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
      appBar: AppBar(
        title: const Text(
          'Registrieren',
          style: TextStyle(color: Color.fromARGB(255, 167, 188, 168)),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4B2F3E), Color(0xFFB16F92)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildNormalContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Stammdaten'),
                        _buildTextField('Firma', controller: _firmaController),
                        _buildTextField('Vorname',
                            controller: _vornameController),
                        _buildTextField('Nachname',
                            controller: _nachnameController),
                        _buildTextField('Strasse + Nr',
                            controller: _strasseController),
                        _buildTextField('PLZ', controller: _plzController),
                        _buildTextField('Deutschland',
                            controller: _landController),
                        _buildTextField('UST. Id Nr. / St. Nr.',
                            controller: _ustIdNrController),
                        _buildTextField('Telefon',
                            controller: _telefonController),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNormalContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Zugangsdaten'),
                        _buildTextField('E-Mail', controller: _emailController),
                        _buildTextField('Passwort',
                            isPassword: true, controller: _passwordController),
                        _buildTextField('Passwort wiederholen',
                            isPassword: true,
                            controller: _confirmPasswordController),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNormalContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Registrierung abschließen'),
                        _buildSwitchTile('AGB'),
                        _buildSwitchTile('Datenschutz'),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _registerFreelancer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 203, 173, 89),
                                ),
                                child: const Text(
                                  'Registrieren',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                              ),
                      ],
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

  Widget _buildNormalContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFD2D4C8),
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: child,
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

  Widget _buildTextField(String label,
      {bool isPassword = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bitte $label eingeben';
          }
          if (label == 'E-Mail' &&
              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Bitte eine gültige E-Mail eingeben';
          }
          if (label.contains('Passwort') && value.length < 6) {
            return 'Passwort muss mindestens 6 Zeichen lang sein';
          }
          if (label == 'Passwort wiederholen' &&
              value != _passwordController.text) {
            return 'Passwörter stimmen nicht überein';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSwitchTile(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Switch(value: true, onChanged: (bool newValue) {}),
      ],
    );
  }
}
