import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/EditProfileScreen/presentation/EditProfileScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  File? _profileImage;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _number = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _firstName = prefs.getString('first_name') ?? 'Max';
      _lastName = prefs.getString('last_name') ?? 'Mustermann';
      _email = prefs.getString('email') ?? 'max@example.com';
      _number = prefs.getString('number') ?? '1234567890';

      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Setting',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF4B2F3E),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Benutzerprofil-Container
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2D4C8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const NetworkImage(
                                'https://via.placeholder.com/150',
                              ) as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_firstName $_lastName',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B2F3E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4B2F3E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _number,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4B2F3E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Option zum Bearbeiten des Profils
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ).then((_) {
                      // Nach dem Zurückkommen von EditProfileScreen die Daten neu laden
                      _loadProfileData();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2D4C8),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lock,
                          color: Color(0xFF4B2F3E),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B2F3E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
