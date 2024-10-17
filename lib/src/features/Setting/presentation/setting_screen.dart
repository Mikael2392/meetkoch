import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/BewertungenScreen/BewertungenScreen.dart';
import 'package:meetkoch/src/features/EditProfileScreen/presentation/EditProfileScreen.dart';
import 'package:meetkoch/src/features/Verlauf/VerlaufScreen.dart';
import 'package:meetkoch/src/features/login/presentation/screen_1_login.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String? _profileImage;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _number = '';

  @override
  void initState() {
    super.initState();
    _loadUserDataFromFirestore(); // Benutzerdaten aus Firestore laden
  }

  Future<void> _loadUserDataFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _firstName = userData['vorname'] ?? 'Max';
          _lastName = userData['nachname'] ?? 'Mustermann';
          _email = userData['email'] ?? 'max@example.com';
          _number = userData['telefon'] ?? '1234567890';
          _profileImage = userData['imageUrl']; // Bild-URL laden
        });

        print("Benutzerdaten erfolgreich geladen.");
      } else {
        print("Benutzerdaten nicht gefunden.");
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MeetKochApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Einstellungen',
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
                          ? NetworkImage(_profileImage!)
                          : const AssetImage('assets/icons/default.png')
                              as ImageProvider,
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

              // Account bearbeiten Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  ).then((_) {
                    _loadUserDataFromFirestore(); // Benutzerdaten nach Bearbeitung neu laden
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
                        Icons.account_circle,
                        color: Color(0xFF4B2F3E),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Account bearbeiten',
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

              // Verlauf (Vergangene Aufträge) Button
              GestureDetector(
                onTap: () {
                  // Navigation zu vergangene Aufträge (du kannst hier deine eigene Route einfügen)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const Verlaufscreen(), // Hier musst du die VerlaufScreen definieren
                    ),
                  );
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
                        Icons.history,
                        color: Color(0xFF4B2F3E),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Vergangene Aufträge',
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

              // Bewertungen Button
              GestureDetector(
                onTap: () {
                  // Navigation zu Bewertungen (du kannst hier deine eigene Route einfügen)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const BewertungenScreen(), // Hier musst du die BewertungenScreen definieren
                    ),
                  );
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
                        Icons.star,
                        color: Color(0xFF4B2F3E),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Bewertungen',
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

              // Abmelden Button
              GestureDetector(
                onTap: _signOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2D4C8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Color(0xFF4B2F3E),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Abmelden',
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
            ],
          ),
        ),
      ),
    );
  }
}
