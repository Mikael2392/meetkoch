import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetkoch/src/features/auftragsdaten/presentation/AuftragsdatenScreen.dart';

class AuftraegeListe extends StatelessWidget {
  const AuftraegeListe({super.key});

  Future<Widget> _getUserProfileImage(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final imageUrl = userDoc['imageUrl'] ?? '';
      return CircleAvatar(
        radius: 25,
        backgroundImage: imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : const AssetImage('assets/icons/default.png') as ImageProvider,
      );
    } catch (e) {
      return const CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage('assets/icons/default.png'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meine Aufträge',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF4B2F3E),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
        body: const Center(
          child: Text(
            'Bitte melde dich an, um deine Aufträge zu sehen.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final DateTime now = DateTime.now().toUtc();
    final DateTime todayMidnightUtc =
        DateTime.utc(now.year, now.month, now.day);
    final auftraegeStream = firestore.collection('auftraege').snapshots();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Meine Aufträge', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: StreamBuilder<QuerySnapshot>(
        stream: auftraegeStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alle = snapshot.data!.docs;

          final filtered = alle
              .where((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  final endDate =
                      (data['endDate'] as Timestamp?)?.toDate().toUtc();
                  if (endDate == null || endDate.isBefore(todayMidnightUtc))
                    return false;

                  final uid = user.uid;

                  final isOwner = data['userId'] == uid;
                  final assignedUser = data['assignedUser'];
                  final assignedUsers = data['assignedUsers'] as List<dynamic>?;

                  final isFreelancerOld = assignedUser == uid;
                  final isFreelancerNew =
                      assignedUsers?.any((u) => u['uid'] == uid) ?? false;

                  return isOwner || isFreelancerOld || isFreelancerNew;
                } catch (_) {
                  return false;
                }
              })
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          if (filtered.isEmpty) {
            return const Center(
              child: Text(
                'Keine Aufträge verfügbar',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final data = filtered[index];
              final startDate = (data['startDate'] as Timestamp?)?.toDate();

              return FutureBuilder<Widget>(
                future: _getUserProfileImage(data['userId'] ?? ''),
                builder: (context, snapshot) {
                  final avatar = snapshot.data ??
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/icons/default.png'),
                      );

                  return Card(
                    color: const Color(0xFFE8B9D4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: avatar,
                      title: Text(
                        data['name'] ?? 'Kein Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['city'] ?? 'Unbekannte Stadt',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          if (startDate != null)
                            Text(
                              'Startdatum: ${DateFormat('dd.MM.yyyy').format(startDate)}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.black),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AuftragDetailScreen(auftrag: data),
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
    );
  }
}
