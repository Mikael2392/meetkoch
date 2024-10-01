import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/Detail/presentation/detailScreen.dart';

class AuftraegeListe extends StatelessWidget {
  const AuftraegeListe({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user =
        FirebaseAuth.instance.currentUser; // Aktuellen Benutzer abrufen

    // Überprüfen, ob ein Benutzer eingeloggt ist
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

    // Query, um nur die angenommenen Aufträge des Benutzers anzuzeigen
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
            .where('isAccepted', isEqualTo: true) // Nur angenommene Aufträge
            .where('assignedUser',
                isEqualTo: user!.uid) // Nur Aufträge des aktuellen Benutzers
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(auftrag['image'] as String),
                ),
                title: Text(auftrag['name'] as String),
                tileColor: const Color.fromARGB(255, 206, 157, 183),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auftrag['city'] as String),
                    Text(
                      auftrag['description'] as String,
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
