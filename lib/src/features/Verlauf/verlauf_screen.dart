import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetkoch/src/features/auftragsdaten/presentation/auftragsdaten_screen.dart';

class VerlaufScreen extends StatelessWidget {
  const VerlaufScreen({super.key});

  Future<Widget> _getUserProfileImage(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final imageUrl = userDoc['imageUrl'] ?? '';
    return CircleAvatar(
      radius: 30,
      backgroundImage: imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : const AssetImage('assets/icons/default.png') as ImageProvider,
    );
  }

  List<Widget> _buildGamificationIcons(int points) {
    int spoons = points ~/ 10 % 5;
    int pans = (points ~/ 50) % 5;
    int flames = points ~/ 250;

    return [
      ...List.generate(
          flames,
          (_) => const Icon(Icons.local_fire_department,
              color: Colors.amber, size: 20)),
      ...List.generate(pans,
          (_) => const Icon(Icons.kitchen, color: Colors.amber, size: 20)),
      ...List.generate(spoons,
          (_) => const Icon(Icons.soup_kitchen, color: Colors.amber, size: 20)),
    ];
  }

  // Fix #9: Punkte nur einmal schreiben, nicht bei jedem Stream-Update
  Future<void> _updateUserPointsOnce(int totalAuftraege) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final points = totalAuftraege * 10;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'points': points});
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verlauf')),
        body: const Center(
            child: Text('Bitte melde dich an, um deinen Verlauf zu sehen.')),
      );
    }

    final now = DateTime.now();

    final arbeitgeberStream = firestore
        .collection('auftraege')
        .where('userId', isEqualTo: user.uid)
        .snapshots();

    // Fix #8: Beide Felder abfragen (altes assignedUser + neues assignedUsers-Array)
    final freelancerOldStream = firestore
        .collection('auftraege')
        .where('assignedUser', isEqualTo: user.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vergangene Aufträge',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4B2F3E),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: arbeitgeberStream,
              builder: (context, snapshot1) {
                return StreamBuilder<QuerySnapshot>(
                  stream: freelancerOldStream,
                  builder: (context, snapshot2) {
                    if (!snapshot1.hasData || !snapshot2.hasData) {
                      return const SizedBox.shrink();
                    }
                    final total = snapshot1.data!.docs.length +
                        snapshot2.data!.docs.length;
                    final points = total * 10;
                    return Row(
                      children: [
                        Text('$points Punkte',
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: 8.0),
                        ..._buildGamificationIcons(points),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('auftraege').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final uid = user.uid;

          // Fix #8: Alle Aufträge filtern — owner, altes assignedUser-Feld UND neues assignedUsers-Array
          final auftraege = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final endDate = (data['endDate'] as Timestamp?)?.toDate();
            if (endDate == null || !endDate.isBefore(now)) return false;

            final isOwner = data['userId'] == uid;
            final isFreelancerOld = data['assignedUser'] == uid;
            final assignedUsers = data['assignedUsers'] as List<dynamic>?;
            final isFreelancerNew =
                assignedUsers?.any((u) => u['uid'] == uid) ?? false;

            return isOwner || isFreelancerOld || isFreelancerNew;
          }).toList();

          if (auftraege.isEmpty) {
            return const Center(
              child: Text('Keine vergangenen Aufträge',
                  style: TextStyle(color: Colors.white)),
            );
          }

          // Fix #9: Punkte nur einmal nach dem Build aktualisieren
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateUserPointsOnce(auftraege.length);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: auftraege.length,
            itemBuilder: (context, index) {
              final doc = auftraege[index];
              final data = {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              };
              final startDate = (data['startDate'] as Timestamp?)?.toDate();

              return FutureBuilder<Widget>(
                future: _getUserProfileImage(data['userId'] ?? ''),
                builder: (context, imgSnapshot) {
                  final avatar = imgSnapshot.data ??
                      const CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/icons/default.png'));

                  return Card(
                    color: const Color.fromARGB(255, 206, 157, 183),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: avatar,
                      title: Text(data['name'] ?? 'Kein Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['city'] ?? 'Unbekannte Stadt'),
                          if (startDate != null)
                            Text(
                              'Datum: ${DateFormat('dd.MM.yyyy').format(startDate)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuftragDetailScreen(
                              auftrag: data,
                              isPastOrder: true,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color.fromARGB(255, 170, 116, 146),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Legende:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            SizedBox(height: 8),
            Text(
              '• 1 Kochlöffel = 10 Punkte\n'
              '• 1 Pfanne = 5 Kochlöffel (50 Punkte)\n'
              '• 1 Flamme = 5 Pfannen (250 Punkte)',
              style: TextStyle(color: Colors.black87, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
