import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NeuerAuftragScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Function? onDelete;
  final Map<String, dynamic>? auftrag;

  const NeuerAuftragScreen({
    super.key,
    required this.onSave,
    this.onDelete,
    this.auftrag,
  });

  @override
  State<NeuerAuftragScreen> createState() => _NeuerAuftragScreenState();
}

class _NeuerAuftragScreenState extends State<NeuerAuftragScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxParticipantsController =
      TextEditingController();
  int currentParticipants = 0;
  int maxParticipants = 0;
  String imagePath = "assets/default.png"; // Standardbild
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (widget.auftrag != null) {
      // Falls ein bestehender Auftrag bearbeitet wird, lade die Werte
      nameController.text = widget.auftrag!['name'] ?? '';
      cityController.text = widget.auftrag!['city'] ?? '';
      descriptionController.text = widget.auftrag!['description'] ?? '';
      maxParticipants = widget.auftrag!['maxParticipants'] ?? 0;
      currentParticipants = widget.auftrag!['currentParticipants'] ?? 0;
      imagePath = widget.auftrag!['image'] ?? 'assets/default.png';
      maxParticipantsController.text = maxParticipants.toString();
    }
  }

  // Methode zum Speichern des Auftrags inklusive Benutzer-ID (uid)
  Future<void> _saveAuftrag() async {
    User? currentUser = _auth.currentUser; // Abrufen des aktuellen Benutzers

    if (currentUser != null) {
      // Auftrag speichern mit der aktuellen Benutzer-ID
      widget.onSave({
        "name": nameController.text,
        "city": cityController.text,
        "description": descriptionController.text,
        "image": imagePath, // Bildpfad wird übernommen
        "maxParticipants": int.parse(maxParticipantsController.text),
        "currentParticipants": currentParticipants,
        "userId": currentUser.uid, // Benutzer-ID hinzufügen
      });

      // Zurück zur vorherigen Ansicht nach dem Speichern
      Navigator.pop(context);
    } else {
      // Optional: Fehlerbehandlung, falls kein Benutzer angemeldet ist
      print("Kein Benutzer angemeldet.");
    }
  }

  void _incrementParticipants() {
    if (currentParticipants < maxParticipants) {
      setState(() {
        currentParticipants++;
      });

      if (currentParticipants == maxParticipants) {
        // Auftrag automatisch löschen, wenn die maximale Teilnehmerzahl erreicht ist
        widget.onDelete!();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auftrag erstellen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: const Color(0xFFD2D4C8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'Stadt',
                filled: true,
                fillColor: const Color(0xFFD2D4C8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Beschreibung',
                filled: true,
                fillColor: const Color(0xFFD2D4C8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxParticipantsController,
              decoration: InputDecoration(
                labelText: 'Maximale Teilnehmerzahl',
                filled: true,
                fillColor: const Color(0xFFD2D4C8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Text(
              '$currentParticipants von $maxParticipants Teilnehmern',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAuftrag, // Methode zum Speichern mit Benutzer-ID
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 188, 180, 133),
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 12.0),
              ),
              child: const Text('Speichern',
                  style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementParticipants,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 188, 180, 133),
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 12.0),
              ),
              child: const Text('Teilnehmer hinzufügen',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
