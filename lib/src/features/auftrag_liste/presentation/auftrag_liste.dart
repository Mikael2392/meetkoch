import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für die Datumsausgabe
import 'package:meetkoch/src/features/auftragsdaten/presentation/AuftragsdatenScreen.dart';
import 'package:meetkoch/src/features/Verlauf/VerlaufScreen.dart';

class AuftraegeListe extends StatelessWidget {
  const AuftraegeListe({super.key});

  // Funktion zum Abrufen des Profilbildes des Benutzers
  Future<Widget> _getUserProfileImage(String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc['imageUrl'] != null) {
        String? userImage = userDoc['imageUrl'];
        return CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(userImage!),
        );
      }
    } catch (e) {
      print("Fehler beim Abrufen des Profilbilds: $e");
    }

    // Fallback: Standardbild, wenn kein Bild vorhanden ist
    return const CircleAvatar(
      radius: 30,
      backgroundImage: AssetImage('assets/icons/default.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user =
        FirebaseAuth.instance.currentUser; // Aktuellen Benutzer abrufen

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meine Aufträge'),
        ),
        body: const Center(
          child: Text('Bitte melde dich an, um deine Aufträge zu sehen.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meine Aufträge',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigiere zum Verlaufscreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerlaufScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('auftraege')
            .where('assignedUser', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('Keine Daten von Firestore erhalten');
            return const Center(child: CircularProgressIndicator());
          }

          var auftraege = snapshot.data!.docs;
          print('Erhaltene Aufträge: ${auftraege.length}');

          // Debug: Anzeigen der erhaltenen Auftragsdetails
          auftraege.forEach((auftrag) {
            print('Auftrag-ID: ${auftrag.id}');
            print('assignedUser: ${auftrag['assignedUser']}');
            print('startDate: ${auftrag['startDate']}');
            print('endDate: ${auftrag['endDate']}');
          });

          // Filter: Nur Aufträge anzeigen, die aktuell aktiv sind (zwischen startDate und endDate)
          var aktuelleAuftraege = auftraege.where((auftrag) {
            DateTime? startDate;
            DateTime? endDate;

            // Überprüfung der Start- und Enddaten
            if (auftrag['startDate'] != null) {
              startDate = (auftrag['startDate'] as Timestamp).toDate();
            } else {
              print('Auftrag ohne gültiges Startdatum: ${auftrag.id}');
            }

            if (auftrag['endDate'] != null) {
              endDate = (auftrag['endDate'] as Timestamp).toDate();
            } else {
              print('Auftrag ohne gültiges Enddatum: ${auftrag.id}');
            }

            // Überprüfen, ob die Daten richtig konvertiert werden
            print('Startdatum: $startDate, Enddatum: $endDate');

            if (startDate != null && endDate != null) {
              // Aktive Aufträge sind jene, die zwischen startDate und endDate liegen
              return DateTime.now().isAfter(startDate) &&
                  DateTime.now().isBefore(endDate.add(const Duration(days: 1)));
            } else if (startDate != null) {
              return DateTime.now()
                  .isAfter(startDate); // Falls nur startDate vorhanden ist
            }
            return false; // Auftrag ohne gültige Daten
          }).toList();

          if (aktuelleAuftraege.isEmpty) {
            return const Center(
              child: Text(
                'Keine Aufträge verfügbar',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.separated(
            itemCount: aktuelleAuftraege.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, index) {
              var auftrag = aktuelleAuftraege[index];

              // Datum des Auftrags, falls vorhanden
              DateTime? startDate;
              if (auftrag['startDate'] != null) {
                startDate = (auftrag['startDate'] as Timestamp).toDate();
              }

              return FutureBuilder<Widget>(
                future: _getUserProfileImage(auftrag['userId']),
                builder: (context, profileImageSnapshot) {
                  if (profileImageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (profileImageSnapshot.hasError) {
                    return const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/icons/default.png'),
                    );
                  }

                  return ListTile(
                    leading: profileImageSnapshot.data!,
                    title: Text(
                      auftrag['name'] ?? 'Kein Name',
                    ),
                    tileColor: const Color.fromARGB(255, 206, 157, 183),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auftrag['city'] ?? 'Unbekannte Stadt',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        // Datum anzeigen, wenn vorhanden
                        if (startDate != null)
                          Text(
                            'Datum: ${DateFormat('dd.MM.yyyy').format(startDate)}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black),
                    isThreeLine: true,
                    onTap: () {
                      // Weiterleitung zur Detailansicht des Auftrags
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuftragDetailScreen(
                            auftrag: auftrag.data() as Map<String, dynamic>,
                            isPastOrder: false, // Auftrag ist aktuell
                          ),
                        ),
                      );
                    },
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
