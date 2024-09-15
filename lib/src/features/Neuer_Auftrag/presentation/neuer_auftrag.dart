import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:meetkoch/src/features/Neuer_Auftrag/presentation/auftrag_formular.dart';

class ArbeitsgeberAuftragListe extends StatefulWidget {
  const ArbeitsgeberAuftragListe({super.key});

  @override
  State<ArbeitsgeberAuftragListe> createState() => _AuftraegeListeState();
}

class _AuftraegeListeState extends State<ArbeitsgeberAuftragListe> {
  List<Map<String, String>> currentAuftraege = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentAuftraege(); // Lädt nur die Aufträge des aktuellen Arbeitsgebers
  }

  // Methode zum Hinzufügen eines neuen Auftrags und Speichern in SharedPreferences
  void _addAuftrag(Map<String, String> neuerAuftrag) {
    setState(() {
      neuerAuftrag['isFromCurrentUser'] =
          'true'; // Kennzeichnet den Auftrag als vom aktuellen Arbeitgeber
      currentAuftraege.add(neuerAuftrag);
      _saveAllAuftraegeToPreferences(); // Speichert den Auftrag in SharedPreferences
    });
  }

  // Methode zum Löschen eines Auftrags
  void _deleteAuftrag(int index) {
    setState(() {
      currentAuftraege.removeAt(index); // Löscht den Auftrag aus der Liste
      _saveAllAuftraegeToPreferences(); // Speichert die aktualisierte Liste in SharedPreferences
    });
  }

  // Lädt die gespeicherten Aufträge, die vom aktuellen Arbeitgeber erstellt wurden
  Future<void> _loadCurrentAuftraege() async {
    final prefs = await SharedPreferences.getInstance();
    final String? auftraegeString = prefs.getString('auftraege');
    if (auftraegeString != null) {
      List<Map<String, String>> allAuftraege = List<Map<String, String>>.from(
          json
              .decode(auftraegeString)
              .map((item) => Map<String, String>.from(item)));
      setState(() {
        currentAuftraege = allAuftraege
            .where((auftrag) => auftrag['isFromCurrentUser'] == 'true')
            .toList();
      });
    }
  }

  // Speichert alle Aufträge (vom aktuellen Arbeitgeber und anderen) in SharedPreferences
  Future<void> _saveAllAuftraegeToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String updatedAuftraegeString = json.encode(currentAuftraege);
    await prefs.setString('auftraege', updatedAuftraegeString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meine Aufträge',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: currentAuftraege.isEmpty
          ? Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NeuerAuftragScreen(
                        onSave: _addAuftrag,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Neuen Auftrag erstellen',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            )
          : ListView.separated(
              itemCount: currentAuftraege.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[300],
                thickness: 1,
                height: 1,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        AssetImage(currentAuftraege[index]["image"] as String),
                  ),
                  title: Text(currentAuftraege[index]["name"] as String),
                  tileColor: const Color.fromARGB(255, 206, 157, 183),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentAuftraege[index]["city"] as String),
                      Text(
                        currentAuftraege[index]["description"] as String,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  isThreeLine: true,
                  onTap: () {
                    // Öffne den Bearbeitungsbildschirm und übergebe den aktuellen Auftrag
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NeuerAuftragScreen(
                          auftrag:
                              currentAuftraege[index], // Übergabe des Auftrags
                          onSave: (updatedAuftrag) {
                            setState(() {
                              currentAuftraege[index] = updatedAuftrag;
                              _saveAllAuftraegeToPreferences();
                            });
                          },
                          onDelete: () {
                            _deleteAuftrag(index); // Auftragslöschung
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NeuerAuftragScreen(
                onSave: _addAuftrag,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFFBF8AA7),
        child: const Icon(Icons.add),
      ),
    );
  }
}
