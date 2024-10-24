import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Für die Datumsauswahl und Formatierung

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
  String imagePath = "assets/icons/default.png"; // Standardbild
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (widget.auftrag != null) {
      // Falls ein bestehender Auftrag bearbeitet wird, lade die Werte
      nameController.text = widget.auftrag!['name'] ?? '';
      cityController.text = widget.auftrag!['city'] ?? '';
      descriptionController.text = widget.auftrag!['description'] ?? '';
      maxParticipants = widget.auftrag!['maxParticipants'] ?? 0;
      currentParticipants = widget.auftrag!['currentParticipants'] ?? 0;
      imagePath = widget.auftrag!['image'] ?? 'assets/icons/default.png';
      maxParticipantsController.text = maxParticipants.toString();

      // Lade bestehendes Datum, falls vorhanden
      if (widget.auftrag!['startDate'] != null) {
        _startDate = (widget.auftrag!['startDate'] as Timestamp).toDate();
      }
      if (widget.auftrag!['endDate'] != null) {
        _endDate = (widget.auftrag!['endDate'] as Timestamp).toDate();
      }
    }
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        // Setze den Benutzernamen im Textfeld
        setState(() {
          nameController.text = userData['vorname'] ?? '';
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate =
        isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // Methode zum Speichern des Auftrags inklusive Benutzer-ID und Datum
  Future<void> _saveAuftrag() async {
    User? currentUser = _auth.currentUser; // Abrufen des aktuellen Benutzers

    if (currentUser != null) {
      // Auftrag speichern mit der aktuellen Benutzer-ID und Datum
      widget.onSave({
        "name": nameController.text,
        "city": cityController.text,
        "description": descriptionController.text,
        "image": imagePath, // Bildpfad wird übernommen
        "maxParticipants": int.parse(maxParticipantsController.text),
        "currentParticipants": currentParticipants,
        "userId": currentUser.uid, // Benutzer-ID hinzufügen
        "startDate": _startDate != null
            ? Timestamp.fromDate(_startDate!)
            : null, // Startdatum
        "endDate":
            _endDate != null ? Timestamp.fromDate(_endDate!) : null, // Enddatum
      });

      // Zurück zur vorherigen Ansicht nach dem Speichern
      Navigator.pop(context);
    } else {
      // Optional: Fehlerbehandlung, falls kein Benutzer angemeldet ist
      print("Kein Benutzer angemeldet.");
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
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_auth
                      .currentUser!.uid) // Die aktuelle Benutzer-ID abrufen
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Ladesymbol anzeigen
                }
                if (snapshot.hasData) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  String? userImage = userData['imageUrl'];

                  return CircleAvatar(
                    radius: 30,
                    backgroundImage: userImage != null && userImage.isNotEmpty
                        ? NetworkImage(userImage)
                        : const AssetImage('assets/icons/default.png')
                            as ImageProvider, // Standardbild
                  );
                } else {
                  return const CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage('assets/icons/default.png'), // Standardbild
                  );
                }
              },
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(
                        context, true), // Datumsauswahl für Startdatum
                    child: Text(_startDate == null
                        ? 'Startdatum auswählen'
                        : 'Startdatum: ${DateFormat('dd.MM.yyyy').format(_startDate!)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(
                        context, false), // Datumsauswahl für Enddatum
                    child: Text(_endDate == null
                        ? 'Enddatum auswählen'
                        : 'Enddatum: ${DateFormat('dd.MM.yyyy').format(_endDate!)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _saveAuftrag, // Methode zum Speichern mit Benutzer-ID und Datum
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 188, 180, 133),
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 12.0),
              ),
              child: const Text('Speichern',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
