import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/Detail/presentation/detailScreen.dart';

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

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(
                    auftraege[index]["image"] ?? 'assets/default.png',
                  ),
                ),
                title: Text(auftraege[index]["name"] ?? 'Kein Name'),
                tileColor: const Color.fromARGB(255, 206, 157, 183),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auftraege[index]["city"] ?? 'Unbekannte Stadt'),
                    Text(
                      auftraege[index]["description"] ?? 'Keine Beschreibung',
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Anzeige der Teilnehmerzahl
                    Text(
                      "$currentParticipants von $maxParticipants Teilnehmern",
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
