import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetkoch/src/features/auftragsdaten/presentation/AuftragsdatenScreen.dart';

class VerlaufScreen extends StatelessWidget {
  const VerlaufScreen({super.key});

  // Funktion zum Abrufen des Profilbildes des Benutzers
  Future<Widget> _getUserProfileImage(String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  // Funktion zur Erstellung der Gamification-Icons
  List<Widget> _buildGamificationIcons(int points) {
    int totalSpoons = points ~/ 10;
    int totalPans = totalSpoons ~/ 5;
    int totalFlames = totalPans ~/ 5;

    totalSpoons %= 5;
    totalPans %= 5;

    List<Widget> icons = [];

    for (int i = 0; i < totalFlames; i++) {
      icons.add(const Icon(Icons.local_fire_department,
          color: Colors.amber, size: 20));
    }

    for (int i = 0; i < totalPans; i++) {
      icons.add(const Icon(Icons.kitchen, color: Colors.amber, size: 20));
    }

    for (int i = 0; i < totalSpoons; i++) {
      icons.add(const Icon(Icons.soup_kitchen, color: Colors.amber, size: 20));
    }

    return icons;
  }

  Future<void> _updateUserPoints(int points) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Aktualisiere die Punktzahl des Benutzers in Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'points': points,
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Verlauf'),
        ),
        body: const Center(
          child: Text('Bitte melde dich an, um deinen Verlauf zu sehen.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vergangene Aufträge',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4B2F3E),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FutureBuilder<QuerySnapshot>(
                  future: _firestore
                      .collection('auftraege')
                      .where('assignedUser', isEqualTo: user.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      print('Keine Daten von Firestore erhalten');
                      return const SizedBox.shrink();
                    }

                    var auftraegeFreelancer = snapshot.data!.docs;

                    // Abfrage für Aufträge des Arbeitgebers
                    return FutureBuilder<QuerySnapshot>(
                      future: _firestore
                          .collection('auftraege')
                          .where('userId', isEqualTo: user.uid)
                          .get(),
                      builder: (context, snapshotEmployer) {
                        if (!snapshotEmployer.hasData) {
                          print('Keine Daten von Firestore erhalten');
                          return const SizedBox.shrink();
                        }

                        var auftraegeArbeitgeber = snapshotEmployer.data!.docs;

                        // Gesamtanzahl der Aufträge für die Punkteberechnung
                        int totalAuftraege = auftraegeFreelancer.length +
                            auftraegeArbeitgeber.length;
                        int points = totalAuftraege * 10;

                        // Speichern der Punkte in der Firestore-Datenbank
                        _updateUserPoints(points);

                        return Row(
                          children: [
                            Text('$points Punkte',
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(width: 8.0),
                            Row(children: _buildGamificationIcons(points)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('auftraege')
            .where('userId', isEqualTo: user.uid) // Abfrage für den Arbeitgeber
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('Keine Daten von Firestore erhalten');
            return const Center(child: CircularProgressIndicator());
          }

          var auftraegeVonArbeitsgeber = snapshot.data!.docs;

          // Abfrage für Freelancer-Aufträge
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('auftraege')
                .where('assignedUser',
                    isEqualTo: user.uid) // Abfrage für Freelancer
                .snapshots(),
            builder: (context, snapshotFreelancer) {
              if (!snapshotFreelancer.hasData) {
                print('Keine Daten von Firestore erhalten');
                return const Center(child: CircularProgressIndicator());
              }

              var auftraegeFreelancer = snapshotFreelancer.data!.docs;
              var auftraege = [
                ...auftraegeVonArbeitsgeber,
                ...auftraegeFreelancer,
              ];

              print('Erhaltene Aufträge: ${auftraege.length}');

              if (auftraege.isEmpty) {
                return const Center(
                  child: Text(
                    'Kein Verlauf verfügbar',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.separated(
                itemCount: auftraege.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  var auftrag = auftraege[index];

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
                      }

                      return ListTile(
                        leading: profileImageSnapshot.hasData
                            ? profileImageSnapshot.data!
                            : const CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage('assets/icons/default.png')),
                        title: Text(auftrag['name'] ?? 'Kein Name'),
                        tileColor: const Color.fromARGB(255, 206, 157, 183),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(auftrag['city'] ?? 'Unbekannte Stadt'),
                            if (startDate != null)
                              Text(
                                'Datum: ${DateFormat('dd.MM.yyyy').format(startDate)}',
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
                                auftrag: auftrag.data() as Map<String, dynamic>,
                                isPastOrder: true,
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
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 206, 157, 183),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Legende:',
                style: TextStyle(
                    color: Color.fromARGB(255, 9, 0, 0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Legende:\n'
                '• 1 Kochlöffel = 10 Punkte\n'
                '• 1 Pfanne = 5 Kochlöffel (50 Punkte)\n'
                '• 1 Flamme = 5 Pfannen (250 Punkte)\n',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 16, 16, 16),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
