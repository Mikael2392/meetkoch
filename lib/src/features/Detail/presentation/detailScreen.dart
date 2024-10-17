import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuftragDetailScreen extends StatefulWidget {
  final Map<String, dynamic> auftrag;

  const AuftragDetailScreen({super.key, required this.auftrag});

  @override
  _AuftragDetailScreenState createState() => _AuftragDetailScreenState();
}

class _AuftragDetailScreenState extends State<AuftragDetailScreen> {
  bool hasAcceptedThisJob =
      false; // Überprüfung, ob der Benutzer diesen Auftrag angenommen hat

  @override
  void initState() {
    super.initState();
    _checkIfUserHasAcceptedThisJob(); // Überprüfen, ob der Benutzer diesen Auftrag bereits angenommen hat
  }

  // Methode zum Überprüfen, ob der Benutzer diesen Auftrag angenommen hat
  Future<void> _checkIfUserHasAcceptedThisJob() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      // Überprüfen, ob der Benutzer den aktuellen Auftrag angenommen hat
      final DocumentSnapshot result = await _firestore
          .collection('auftraege')
          .doc(widget.auftrag['id'])
          .get();

      if (result.exists) {
        Map<String, dynamic> data = result.data() as Map<String, dynamic>;
        if (data['assignedUser'] == user.uid) {
          setState(() {
            hasAcceptedThisJob = true;
          });
          print('Benutzer hat diesen Auftrag bereits angenommen.');
        } else {
          print('Benutzer hat diesen Auftrag noch nicht angenommen.');
        }
      }
    }
  }

  // Methode zum Aktualisieren der Teilnehmeranzahl
  Future<void> _updateParticipants(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Du musst eingeloggt sein, um den Auftrag anzunehmen.'),
        ),
      );
      return;
    }

    int currentParticipants = widget.auftrag['currentParticipants'] ?? 0;
    int maxParticipants = widget.auftrag['maxParticipants'] ?? 0;

    if (currentParticipants < maxParticipants) {
      currentParticipants++;

      // Auftrag in Firestore aktualisieren: Teilnehmerzahl, als angenommen markieren und Benutzer zuweisen
      await _firestore
          .collection('auftraege')
          .doc(widget.auftrag['id'])
          .update({
        'currentParticipants': currentParticipants,
        'isAccepted': true,
        'assignedUser': user.uid,
      });

      if (currentParticipants == maxParticipants) {
        await _firestore
            .collection('auftraege')
            .doc(widget.auftrag['id'])
            .update({
          'isVisible': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Maximale Teilnehmerzahl erreicht. Auftrag ist jetzt abgeschlossen!'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auftrag wurde angenommen!'),
          ),
        );
        Navigator.pop(context);
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
    int currentParticipants = widget.auftrag['currentParticipants'] ?? 0;
    int maxParticipants = widget.auftrag['maxParticipants'] ?? 0;

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
              widget.auftrag['name'] ?? '',
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
              widget.auftrag['city'] ?? '',
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
              widget.auftrag['description'] ?? '',
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
              onPressed: hasAcceptedThisJob
                  ? null // Deaktiviert, wenn der Benutzer diesen Auftrag bereits angenommen hat
                  : () {
                      _updateParticipants(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAcceptedThisJob
                    ? Colors.grey // Button wird grau, wenn deaktiviert
                    : const Color.fromARGB(255, 188, 180, 133),
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 12.0),
              ),
              child: const Text(
                'Auftrag übernehmen',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
