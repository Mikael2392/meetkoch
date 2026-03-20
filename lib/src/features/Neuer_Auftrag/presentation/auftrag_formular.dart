import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  String imagePath = 'assets/icons/default.png';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (widget.auftrag != null) {
      nameController.text = widget.auftrag!['name'] ?? '';
      cityController.text = widget.auftrag!['city'] ?? '';
      descriptionController.text = widget.auftrag!['description'] ?? '';
      maxParticipants = widget.auftrag!['maxParticipants'] ?? 0;
      currentParticipants = widget.auftrag!['currentParticipants'] ?? 0;
      imagePath = widget.auftrag!['image'] ?? 'assets/icons/default.png';
      maxParticipantsController.text = maxParticipants.toString();

      if (widget.auftrag!['startDate'] != null) {
        _startDate = (widget.auftrag!['startDate'] as Timestamp).toDate();
      }
      if (widget.auftrag!['endDate'] != null) {
        _endDate = (widget.auftrag!['endDate'] as Timestamp).toDate();
      }
    }
  }

  // Fix #10: dispose() für alle Controller
  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    descriptionController.dispose();
    maxParticipantsController.dispose();
    super.dispose();
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
        setState(() {
          nameController.text = userData['firma'] ?? '';
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

  Future<void> _saveAuftrag() async {
    // Fix #11: Validierung vor dem Speichern
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte einen Namen eingeben.')),
      );
      return;
    }
    if (cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte eine Stadt eingeben.')),
      );
      return;
    }

    // Fix #11: Sichere Zahl-Validierung für maxParticipants
    final int? parsedMax = int.tryParse(maxParticipantsController.text.trim());
    if (parsedMax == null || parsedMax <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bitte eine gültige Teilnehmerzahl eingeben.')),
      );
      return;
    }

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      widget.onSave({
        'name': nameController.text,
        'city': cityController.text,
        'description': descriptionController.text,
        'image': imagePath,
        'maxParticipants': parsedMax,
        'currentParticipants': currentParticipants,
        'userId': currentUser.uid,
        'startDate':
            _startDate != null ? Timestamp.fromDate(_startDate!) : null,
        'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
      });

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kein Benutzer angemeldet. Bitte neu einloggen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auftrag erstellen',
            style: TextStyle(color: Colors.white)),
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
                  .doc(_auth.currentUser!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasData) {
                  var userData =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  String? userImage = userData['imageUrl'];
                  return CircleAvatar(
                    radius: 30,
                    backgroundImage: userImage != null && userImage.isNotEmpty
                        ? NetworkImage(userImage)
                        : const AssetImage('assets/icons/default.png')
                            as ImageProvider,
                  );
                }
                return const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/icons/default.png'),
                );
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
            Text('$currentParticipants von $maxParticipants Teilnehmern',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(_startDate == null
                        ? 'Startdatum auswählen'
                        : 'Start: ${DateFormat('dd.MM.yyyy').format(_startDate!)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(_endDate == null
                        ? 'Enddatum auswählen'
                        : 'Ende: ${DateFormat('dd.MM.yyyy').format(_endDate!)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAuftrag,
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
