import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetkoch/src/features/login/presentation/screen_1_login.dart';

class Screen2RegistrierenArbeitsgeber extends StatefulWidget {
  const Screen2RegistrierenArbeitsgeber({super.key});

  @override
  _Screen2RegistrierenArbeitsgeberState createState() =>
      _Screen2RegistrierenArbeitsgeberState();
}

class _Screen2RegistrierenArbeitsgeberState
    extends State<Screen2RegistrierenArbeitsgeber> {
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

  // Fix #4: AGB und Datenschutz als echte State-Variablen
  bool _agbAccepted = false;
  bool _datenschutzAccepted = false;

  // Fix #10: dispose() für alle Controller
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firmaController.dispose();
    _vornameController.dispose();
    _nachnameController.dispose();
    _strasseController.dispose();
    _plzController.dispose();
    _landController.dispose();
    _ustIdNrController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  Future<void> _registerEmployer() async {
    // Fix #4: Prüfen ob AGB akzeptiert
    if (!_agbAccepted || !_datenschutzAccepted) {
      setState(() {
        _errorMessage = 'Bitte akzeptiere AGB und Datenschutz.';
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

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
          'role': 'employer',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrierung erfolgreich!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

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
          _errorMessage = 'Ein unerwarteter Fehler ist aufgetreten.';
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
        title: const Text('Registrieren',
            style: TextStyle(color: Color.fromARGB(255, 254, 254, 254))),
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
                        _buildTextField('Vorname Geschäftsführer',
                            controller: _vornameController),
                        _buildTextField('Nachname Geschäftsführer',
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
                        // Fix #4: Echte Switch-Logik
                        _buildSwitchTile('AGB', _agbAccepted, (val) {
                          setState(() => _agbAccepted = val);
                        }),
                        _buildSwitchTile('Datenschutz', _datenschutzAccepted,
                            (val) {
                          setState(() => _datenschutzAccepted = val);
                        }),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_errorMessage!,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _registerEmployer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 203, 173, 89),
                                ),
                                child: const Text('Registrieren',
                                    style: TextStyle(color: Colors.black)),
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
    return Text(title,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 41, 50, 45)));
  }

  Widget _buildTextField(String label,
      {bool isPassword = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Bitte $label eingeben';
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

  // Fix #4: Switch mit echtem State
  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
