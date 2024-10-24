import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für die Datumsausgabe
import 'package:meetkoch/src/features/auftragsdaten/presentation/AuftragsdatenScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Benutzerinformationen laden
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data();
        print("Benutzerinformationen: $userData");
      } else {
        print("Benutzerinformationen nicht gefunden.");
      }
    }
  }

  // Methode zum Abrufen des Profilbildes des Benutzers
  Future<Widget> _getUserProfileImage(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    String? userImage = userDoc['imageUrl'];

    return CircleAvatar(
      radius: 30,
      backgroundImage: userImage != null && userImage.isNotEmpty
          ? NetworkImage(userImage)
          : const AssetImage('assets/icons/default.png')
              as ImageProvider, // Standardbild
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('auftraege')
            .snapshots(), // Stream für die 'auftraege'-Sammlung
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Fehler beim Laden der Daten',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Wenn keine Aufträge vorhanden sind
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Keine Aufträge gefunden',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Liste der Aufträge aus dem Snapshot erstellen
          final auftraege = snapshot.data!.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

          return ListView.separated(
            itemCount: auftraege.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, index) {
              // Zugriff auf Teilnehmerdaten
              int currentParticipants =
                  auftraege[index]["currentParticipants"] ?? 0;
              int maxParticipants = auftraege[index]["maxParticipants"] ?? 0;

              // Zugriff auf das Datum, wenn vorhanden
              DateTime? startDate;
              if (auftraege[index]['startDate'] != null) {
                startDate =
                    (auftraege[index]['startDate'] as Timestamp).toDate();
              }

              return FutureBuilder<Widget>(
                future: _getUserProfileImage(auftraege[index]['userId']),
                builder: (context, profileImageSnapshot) {
                  if (profileImageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Ladeanzeige, solange das Bild geladen wird
                  }

                  return ListTile(
                    leading: profileImageSnapshot.hasData
                        ? profileImageSnapshot.data!
                        : const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                                'assets/icons/default.png'), // Standardbild
                          ),
                    title: Text(auftraege[index]["name"] ?? 'Kein Name'),
                    tileColor: const Color.fromARGB(255, 206, 157, 183),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auftraege[index]["city"] ?? 'Unbekannte Stadt'),
                        // Anzeige der Teilnehmerzahl
                        Text(
                          "$currentParticipants von $maxParticipants Teilnehmern",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Anzeige des Datums, wenn vorhanden
                        if (startDate != null)
                          Text(
                            'Datum: ${DateFormat('dd.MM.yyyy').format(startDate)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuftragDetailScreen(
                            auftrag: auftraege[index], // Übergabe des Auftrags
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
