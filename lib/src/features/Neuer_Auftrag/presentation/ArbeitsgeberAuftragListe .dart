import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
    _loadCurrentAuftraege();
  }

  Future<void> _addAuftrag(Map<String, dynamic> neuerAuftrag) async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      neuerAuftrag['isFromCurrentUser'] = true;
      neuerAuftrag['userId'] = currentUser.uid;

      await _firestore.collection('auftraege').add(neuerAuftrag);
      _loadCurrentAuftraege();
    }
  }

  Future<void> _deleteAuftrag(String documentId) async {
    await _firestore.collection('auftraege').doc(documentId).delete();
    _loadCurrentAuftraege();
  }

  Future<void> _loadCurrentAuftraege() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final QuerySnapshot snapshot = await _firestore
          .collection('auftraege')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      setState(() {
        currentAuftraege = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        }).where((auftrag) {
          DateTime? startDate;
          DateTime? endDate;

          if (auftrag['startDate'] != null) {
            startDate = (auftrag['startDate'] as Timestamp).toDate();
          }
          if (auftrag['endDate'] != null) {
            endDate = (auftrag['endDate'] as Timestamp).toDate();
          }

          if (startDate != null && endDate != null) {
            return DateTime.now().isAfter(startDate) &&
                    DateTime.now()
                        .isBefore(endDate.add(const Duration(days: 1))) ||
                DateTime.now().isBefore(startDate);
          } else if (startDate != null) {
            return DateTime.now().isBefore(startDate) ||
                DateTime.now().isAfter(startDate);
          }
          return false;
        }).toList();
      });
    }
  }

  Future<Widget> _getUserProfileImage(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    String? userImage = userDoc['imageUrl'];

    return CircleAvatar(
      radius: 30,
      backgroundImage: userImage != null && userImage.isNotEmpty
          ? NetworkImage(userImage)
          : const AssetImage('assets/icons/default.png') as ImageProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Meine Aufträge', style: TextStyle(color: Colors.white)),
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
                      builder: (context) =>
                          NeuerAuftragScreen(onSave: _addAuftrag),
                    ),
                  );
                },
                child: const Text(
                  'Neuen Auftrag erstellen',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            )
          : ListView.builder(
              itemCount: currentAuftraege.length,
              itemBuilder: (context, index) {
                final auftrag = currentAuftraege[index];
                final currentParticipants = auftrag["currentParticipants"] ?? 0;
                final maxParticipants = auftrag["maxParticipants"] ?? 0;
                DateTime? startDate;
                if (auftrag['startDate'] != null) {
                  startDate = (auftrag['startDate'] as Timestamp).toDate();
                }

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    color: const Color.fromARGB(255, 206, 157, 183),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: FutureBuilder<Widget>(
                        future: _getUserProfileImage(auftrag['userId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasData) {
                            return snapshot.data!;
                          }
                          return const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage('assets/icons/default.png'),
                          );
                        },
                      ),
                      title: Text(
                        auftrag["name"] ?? 'Kein Titel',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auftrag["city"] ?? ''),
                          if (startDate != null)
                            Text(
                                'Datum: ${DateFormat('dd.MM.yyyy').format(startDate)}'),
                          const SizedBox(height: 4),
                          Text(
                            "$currentParticipants von $maxParticipants Teilnehmern",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NeuerAuftragScreen(
                              auftrag: auftrag,
                              onSave: (updatedAuftrag) async {
                                await _firestore
                                    .collection('auftraege')
                                    .doc(auftrag['id'])
                                    .update(updatedAuftrag);
                                _loadCurrentAuftraege();
                              },
                              onDelete: () {
                                _deleteAuftrag(auftrag['id']);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NeuerAuftragScreen(onSave: _addAuftrag),
            ),
          );
        },
        backgroundColor: const Color(0xFFBF8AA7),
        child: const Icon(Icons.add),
      ),
    );
  }
}
