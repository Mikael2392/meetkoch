import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetkoch/src/features/auftragsdaten/presentation/AuftragsdatenScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        var userData = userDoc.data();
        print("Benutzerinformationen: $userData");
      } else {
        print("Benutzerinformationen nicht gefunden.");
      }
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
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('auftraege')
            .where('endDate', isGreaterThan: Timestamp.now())
            .orderBy('endDate', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Fehler beim Laden der Daten',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Keine Aufträge gefunden',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final auftraege = snapshot.data!.docs.map((doc) {
            return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

          return ListView.builder(
            itemCount: auftraege.length,
            itemBuilder: (context, index) {
              int currentParticipants =
                  auftraege[index]["currentParticipants"] ?? 0;
              int maxParticipants = auftraege[index]["maxParticipants"] ?? 0;

              DateTime? startDate;
              if (auftraege[index]['startDate'] != null) {
                startDate =
                    (auftraege[index]['startDate'] as Timestamp).toDate();
              }

              return FutureBuilder<Widget>(
                future: _getUserProfileImage(auftraege[index]['userId']),
                builder: (context, profileImageSnapshot) {
                  if (profileImageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color.fromARGB(255, 206, 157, 183),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuftragDetailScreen(
                              auftrag: auftraege[index],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            profileImageSnapshot.hasData
                                ? profileImageSnapshot.data!
                                : const CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        AssetImage('assets/icons/default.png'),
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auftraege[index]["name"] ?? 'Kein Name',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    auftraege[index]["city"] ??
                                        'Unbekannte Stadt',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$currentParticipants von $maxParticipants Teilnehmern",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (startDate != null)
                                    Text(
                                      'Datum: ${DateFormat('dd.MM.yyyy').format(startDate)}',
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
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
