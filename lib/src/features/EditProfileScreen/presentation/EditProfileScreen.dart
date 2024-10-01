import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

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
        });

        // Handle profile image if it's stored as a URL
        // You would handle downloading or using a local placeholder.
      }
    }
  }

  Future<void> _saveProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'vorname': _firstNameController.text,
        'nachname': _lastNameController.text,
        'email': _emailController.text,
        'telefon': _numberController.text,
        // Optionally, handle the image here (e.g., upload it to Firebase Storage)
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
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B2F3E),
                  ),
                  child: const Text('Edit'),
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
            const Spacer(),
            Center(
              child: ElevatedButton(
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
