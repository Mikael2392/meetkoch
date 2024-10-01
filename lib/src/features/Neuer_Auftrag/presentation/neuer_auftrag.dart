import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetkoch/src/features/Neuer_Auftrag/presentation/auftrag_formular.dart';

class ArbeitsgeberAuftragListe extends StatefulWidget {
  const ArbeitsgeberAuftragListe({super.key});

  @override
  State<ArbeitsgeberAuftragListe> createState() => _AuftraegeListeState();
}

class _AuftraegeListeState extends State<ArbeitsgeberAuftragListe> {
  List<Map<String, dynamic>> currentAuftraege = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentAuftraege(); // Lädt nur die Aufträge des aktuellen Arbeitsgebers
  }

  // Methode zum Hinzufügen eines neuen Auftrags und Speichern in Firestore
  Future<void> _addAuftrag(Map<String, dynamic> neuerAuftrag) async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      neuerAuftrag['isFromCurrentUser'] =
          true; // Markiere Auftrag als vom aktuellen User
      neuerAuftrag['userId'] =
          currentUser.uid; // Speichere die Benutzer-ID (Arbeitsgeber)

      await _firestore
          .collection('auftraege')
          .add(neuerAuftrag); // Speichern in Firestore

      _loadCurrentAuftraege(); // Nach dem Speichern die Aufträge erneut laden
    }
  }

  // Methode zum Löschen eines Auftrags aus Firestore
  Future<void> _deleteAuftrag(String documentId) async {
    await _firestore.collection('auftraege').doc(documentId).delete();
    _loadCurrentAuftraege(); // Nach dem Löschen die Aufträge erneut laden
  }

  // Lädt die gespeicherten Aufträge, die vom aktuellen Arbeitgeber (Benutzer) erstellt wurden, aus Firestore
  Future<void> _loadCurrentAuftraege() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final QuerySnapshot snapshot = await _firestore
          .collection('auftraege')
          .where('userId',
              isEqualTo:
                  currentUser.uid) // Nur Aufträge des aktuellen Benutzers laden
          .get();

      setState(() {
        currentAuftraege = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    }
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
                int currentParticipants =
                    currentAuftraege[index]["currentParticipants"] ?? 0;
                int maxParticipants =
                    currentAuftraege[index]["maxParticipants"] ?? 0;

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
                      Text(
                        "$currentParticipants von $maxParticipants Teilnehmern",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NeuerAuftragScreen(
                          auftrag: currentAuftraege[index],
                          onSave: (updatedAuftrag) async {
                            await _firestore
                                .collection('auftraege')
                                .doc(currentAuftraege[index]['id'])
                                .update(updatedAuftrag);
                            _loadCurrentAuftraege(); // Aktualisierte Aufträge laden
                          },
                          onDelete: () {
                            _deleteAuftrag(currentAuftraege[index]['id']);
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
