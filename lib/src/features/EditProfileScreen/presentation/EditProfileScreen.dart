import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  String? imageUrl;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  bool _isLoading = false; // Ladezustand

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _firstNameController.text = userData['vorname'] ?? '';
          _lastNameController.text = userData['nachname'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _numberController.text = userData['telefon'] ?? '';
          imageUrl = userData['imageUrl'];
        });
      }
    }
  }

  Future<void> _saveProfileData() async {
    setState(() {
      _isLoading = true; // Ladezustand aktivieren
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (_image != null) {
        try {
          // Bild in Firebase Storage hochladen
          FirebaseStorage storage = FirebaseStorage.instance;
          Reference ref =
              storage.ref().child('user_images').child('${user.uid}.jpg');

          // Bild hochladen
          UploadTask uploadTask = ref.putFile(_image!);

          // Warte auf Abschluss des Uploads
          TaskSnapshot snapshot = await uploadTask;
          print(
              'Upload erfolgreich: ${snapshot.bytesTransferred} Bytes hochgeladen.');

          // URL abrufen
          String downloadUrl = await snapshot.ref.getDownloadURL();
          print('Bild-URL: $downloadUrl');

          setState(() {
            imageUrl = downloadUrl; // URL setzen
          });

          // URL in Firestore speichern
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'imageUrl': imageUrl,
          });

          print('Bild-URL erfolgreich in Firestore gespeichert.');
        } catch (e) {
          print('Fehler beim Hochladen des Bildes: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Hochladen des Bildes: $e')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Speichere die anderen Benutzerdaten in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'vorname': _firstNameController.text,
        'nachname': _lastNameController.text,
        'email': _emailController.text,
        'telefon': _numberController.text,
        if (imageUrl != null) 'imageUrl': imageUrl, // Bild-URL speichern
      });

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daten erfolgreich gespeichert!')),
      );

      Navigator.pop(context, true);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print('Bild ausgewählt: ${pickedFile.path}');
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('Kein Bild ausgewählt.');
    }
  }

  Future<void> _deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete(); // Benutzerdaten löschen
        await user.delete(); // Firebase-Benutzer löschen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konto erfolgreich gelöscht!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen des Kontos: $e')),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konto löschen'),
          content: const Text(
              'Bist du sicher, dass du dein Konto löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog schließen
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount(); // Konto löschen
                Navigator.of(context).pop(); // Dialog schließen
              },
              child: const Text('Ja, löschen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) const CircularProgressIndicator(), // Ladeindikator
            if (!_isLoading)
              Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _image != null
                            ? FileImage(
                                _image!) // Lokales Bild aus dem ImagePicker
                            : (imageUrl != null
                                ? NetworkImage(imageUrl!)
                                    as ImageProvider // Falls Bild-URL vorhanden ist
                                : AssetImage(
                                    'assets/icons/default.png')), // Fallback: Default-Bild aus Assets
                        child: _image == null && imageUrl == null
                            ? const Icon(Icons.person,
                                size:
                                    40) // Standard-Icon anzeigen, wenn kein Bild verfügbar ist
                            : null,
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2F3E),
                        ),
                        child: const Text('Bild auswählen'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Vorname',
                      filled: true,
                      fillColor: Color(0xFFD2D4C8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nachname',
                      filled: true,
                      fillColor: Color(0xFFD2D4C8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true, // E-Mail nicht änderbar
                    decoration: const InputDecoration(
                      labelText: 'E-Mail',
                      filled: true,
                      fillColor: Color(0xFFD2D4C8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Nummer',
                      filled: true,
                      fillColor: Color(0xFFD2D4C8),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveProfileData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B2F3E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Speichern',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showDeleteAccountDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B2F3E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Konto löschen',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
