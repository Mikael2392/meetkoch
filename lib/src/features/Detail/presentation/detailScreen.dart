import 'package:flutter/material.dart';

class AuftragDetailScreen extends StatelessWidget {
  final Map<String, String> auftrag;

  const AuftragDetailScreen({super.key, required this.auftrag});

  @override
  Widget build(BuildContext context) {
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
            ElevatedButton(
              onPressed: () {
                // Hier kannst du die Logik hinzufügen, um den Auftrag anzunehmen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auftrag wurde angenommen!'),
                  ),
                );
                Navigator.pop(
                    context); // Nach Annahme zum vorherigen Screen zurückkehren
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
