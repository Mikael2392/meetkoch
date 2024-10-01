import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuftragDetailScreen extends StatelessWidget {
  final Map<String, dynamic> auftrag;

  const AuftragDetailScreen({super.key, required this.auftrag});

  // Methode zum Aktualisieren der Teilnehmeranzahl
  Future<void> _updateParticipants(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user =
        FirebaseAuth.instance.currentUser; // Aktuellen Benutzer abrufen

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Du musst eingeloggt sein, um den Auftrag anzunehmen.'),
        ),
      );
      return;
    }

    int currentParticipants = auftrag['currentParticipants'] ?? 0;
    int maxParticipants = auftrag['maxParticipants'] ?? 0;

    if (currentParticipants < maxParticipants) {
      currentParticipants++;

      // Auftrag in Firestore aktualisieren: Teilnehmerzahl, als angenommen markieren und Benutzer zuweisen
      await _firestore.collection('auftraege').doc(auftrag['id']).update({
        'currentParticipants': currentParticipants,
        'isAccepted': true, // Auftrag als angenommen markieren
        'assignedUser': user.uid, // Auftrag dem aktuellen Benutzer zuweisen
      });

      // Wenn die maximale Teilnehmerzahl erreicht ist, Auftrag löschen
      if (currentParticipants == maxParticipants) {
        await _firestore.collection('auftraege').doc(auftrag['id']).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Maximale Teilnehmerzahl erreicht. Auftrag gelöscht!'),
          ),
        );
        Navigator.pop(context); // Zurück zum vorherigen Screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auftrag wurde angenommen!'),
          ),
        );
        Navigator.pop(context); // Zurück zum vorherigen Screen
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximale Teilnehmerzahl bereits erreicht!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentParticipants = auftrag['currentParticipants'] ?? 0;
    int maxParticipants = auftrag['maxParticipants'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auftrag Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              auftrag['name'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Stadt:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              auftrag['city'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Beschreibung:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              auftrag['description'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Teilnehmer:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$currentParticipants von $maxParticipants Teilnehmern',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updateParticipants(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 188, 180, 133),
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 12.0),
              ),
              child: const Text('Auftrag übernehmen',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
