import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'title': 'Auftrag 1',
      'description': 'Beschreibung für Auftrag 1',
    },
    {
      'title': 'Auftrag 2',
      'description': 'Beschreibung für Auftrag 2',
    },
    {
      'title': 'Auftrag 3',
      'description': 'Beschreibung für Auftrag 3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aufträge'),
        backgroundColor: const Color(0xFF4B2F3E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4B2F3E),
              Color(0xFFB16F92),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: const Color(0xFFD2D4C8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B2F3E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4B2F3E),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 188, 180, 133),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Auftrag annehmen'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
