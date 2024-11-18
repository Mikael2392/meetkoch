import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetkoch/src/features/auftragsdaten/presentation/AuftragsdatenScreen.dart';

class AuftraegeListe extends StatefulWidget {
  const AuftraegeListe({super.key});

  @override
  _AuftraegeListeState createState() => _AuftraegeListeState();
}

class _AuftraegeListeState extends State<AuftraegeListe> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> currentAuftraege = [];

  // Lädt die Aufträge mit Filterlogik
  Future<void> _loadCurrentAuftraege() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final QuerySnapshot snapshot = await _firestore
          .collection('auftraege')
          .where('assignedUser', isEqualTo: currentUser.uid)
          .get();

      setState(() {
        // Filter: Zeige aktive und zukünftige Aufträge
        currentAuftraege = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        }).where((auftrag) {
          DateTime? startDate;
          DateTime? endDate;

          if (auftrag['startDate'] != null) {
            startDate = (auftrag['startDate'] as Timestamp?)?.toDate();
          }
          if (auftrag['endDate'] != null) {
            endDate = (auftrag['endDate'] as Timestamp?)?.toDate();
          }

          // Logik:
          // - Zeige Aufträge, die aktiv sind: now ist zwischen startDate und endDate
          // - Zeige Aufträge, die in der Zukunft starten: startDate > now
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

  // Methode zum Abrufen des Profilbildes des Benutzers
  Future<Widget> _getUserProfileImage(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    String? userImage = userDoc['imageUrl'];

    return CircleAvatar(
      radius: 30,
      backgroundImage: userImage != null && userImage.isNotEmpty
          ? NetworkImage(userImage)
          : const AssetImage('assets/icons/default.png')
              as ImageProvider, // Standardbild
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentAuftraege(); // Lade die Aufträge beim Start
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
          ? const Center(
              child: Text(
                'Keine Aufträge verfügbar',
                style: TextStyle(color: Colors.white),
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
                var auftrag = currentAuftraege[index];
                String? userId = auftrag['userId'];

                DateTime? startDate =
                    (auftrag['startDate'] as Timestamp?)?.toDate();

                return FutureBuilder<Widget>(
                  future: _getUserProfileImage(userId ?? ""),
                  builder: (context, profileImageSnapshot) {
                    if (profileImageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return ListTile(
                      leading: profileImageSnapshot.hasData
                          ? profileImageSnapshot.data!
                          : const CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage('assets/icons/default.png')),
                      title: Text(
                        auftrag['name'] ?? 'Kein Name',
                        style: const TextStyle(color: Colors.black),
                      ),
                      tileColor: const Color.fromARGB(255, 206, 157, 183),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auftrag['city'] ?? 'Unbekannte Stadt',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          if (startDate != null)
                            Text(
                              'Startdatum: ${DateFormat('dd.MM.yyyy').format(startDate)}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuftragDetailScreen(
                              auftrag: auftrag,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
