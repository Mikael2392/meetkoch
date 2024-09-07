import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NeuerAuftragScreen extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final Function? onDelete;
  final Map<String, String>? auftrag;

  const NeuerAuftragScreen(
      {super.key, required this.onSave, this.onDelete, this.auftrag});

  @override
  State<NeuerAuftragScreen> createState() => _NeuerAuftragScreenState();
}

class _NeuerAuftragScreenState extends State<NeuerAuftragScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String imagePath = "assets/default.png"; // Standardbild

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // Lädt das Profilbild aus den SharedPreferences
    if (widget.auftrag != null) {
      // Falls ein bestehender Auftrag bearbeitet wird, lade die Werte
      nameController.text = widget.auftrag!['name']!;
      cityController.text = widget.auftrag!['city']!;
      descriptionController.text = widget.auftrag!['description']!;
      imagePath = widget.auftrag!['image']!;
    }
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profileImagePath = prefs.getString('profile_image');
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      setState(() {
        imagePath = profileImagePath;
      });
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onSave({
                  "name": nameController.text,
                  "city": cityController.text,
                  "description": descriptionController.text,
                  "image": imagePath, // Bildpfad wird übernommen
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 188, 180, 133),
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 12.0),
              ),
              child: const Text('Speichern',
                  style: TextStyle(color: Colors.black)),
            ),
            if (widget.onDelete != null) const SizedBox(height: 20),
            if (widget.onDelete != null)
              ElevatedButton(
                onPressed: () {
                  widget.onDelete!();
                  Navigator.pop(context); // Zurück nach dem Löschen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100.0, vertical: 12.0),
                ),
                child: const Text('Löschen',
                    style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
