import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für die Datumsausgabe
import 'package:meetkoch/src/features/Detail/presentation/detailScreen.dart';

class AuftraegeListe extends StatelessWidget {
  const AuftraegeListe({super.key});

  // Funktion zum Abrufen des Profilbildes des Benutzers
  Future<Widget> _getUserProfileImage(String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user =
        FirebaseAuth.instance.currentUser; // Aktuellen Benutzer abrufen

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meine Aufträge'),
        ),
        body: const Center(
          child: Text('Bitte melde dich an, um deine Aufträge zu sehen.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meine Aufträge',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('auftraege')
            .where('isAccepted', isEqualTo: true)
            .where('assignedUser', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var auftraege = snapshot.data!.docs;

          if (auftraege.isEmpty) {
            return const Center(
              child: Text(
                'Keine Aufträge verfügbar',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.separated(
            itemCount: auftraege.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, index) {
              var auftrag = auftraege[index];

              // Datum des Auftrags, falls vorhanden
              DateTime? startDate;
              if (auftrag['startDate'] != null) {
                startDate = (auftrag['startDate'] as Timestamp).toDate();
              }

              return FutureBuilder<Widget>(
                future: _getUserProfileImage(auftrag['userId']),
                builder: (context, profileImageSnapshot) {
                  if (profileImageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  return ListTile(
                    leading: profileImageSnapshot.hasData
                        ? profileImageSnapshot.data!
                        : const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage('assets/icons/default.png'),
                          ),
                    title: Text(auftrag['name'] ?? 'Kein Name'),
                    tileColor: const Color.fromARGB(255, 206, 157, 183),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auftrag['city'] ?? 'Unbekannte Stadt'),
                        // Datum anzeigen, wenn vorhanden
                        if (startDate != null)
                          Text(
                            'Datum: ${DateFormat('dd.MM.yyyy').format(startDate)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    isThreeLine: true,
                    onTap: () {
                      // Weiterleitung zur Detailansicht des Auftrags
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuftragDetailScreen(
                            auftrag: auftrag.data() as Map<String, dynamic>,
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
