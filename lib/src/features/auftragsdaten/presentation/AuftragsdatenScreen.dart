import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/BewertungenScreen/UserRatingProfileScreen.dart';
import 'package:meetkoch/src/features/User%20profil/userProfil.dart';

class AuftragDetailScreen extends StatefulWidget {
  final Map<String, dynamic> auftrag;
  final bool isPastOrder;

  const AuftragDetailScreen({
    super.key,
    required this.auftrag,
    this.isPastOrder = false,
  });

  @override
  _AuftragDetailScreenState createState() => _AuftragDetailScreenState();
}

class _AuftragDetailScreenState extends State<AuftragDetailScreen> {
  bool hasAcceptedThisJob = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasAcceptedThisJob();
  }

  Future<void> _checkIfUserHasAcceptedThisJob() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      final DocumentSnapshot result = await _firestore
          .collection('auftraege')
          .doc(widget.auftrag['id'])
          .get();

      if (result.exists) {
        Map<String, dynamic> data = result.data() as Map<String, dynamic>;
        List<dynamic> assignedUsers = data['assignedUsers'] ?? [];

        if (assignedUsers.any((u) => u['uid'] == user.uid)) {
          setState(() {
            hasAcceptedThisJob = true;
          });
        }
      }
    }
  }

  Future<void> _updateParticipants(BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Du musst eingeloggt sein, um den Auftrag anzunehmen.'),
        ),
      );
      return;
    }

    // Abrufen des Benutzerdokuments aus Firestore
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    String displayName = 'Anonymer Benutzer'; // Standardwert

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      displayName = '${userData['vorname']} ${userData['nachname']}';
    }

    int currentParticipants = widget.auftrag['currentParticipants'] ?? 0;
    int maxParticipants = widget.auftrag['maxParticipants'] ?? 0;

    if (currentParticipants < maxParticipants) {
      currentParticipants++;

      await _firestore
          .collection('auftraege')
          .doc(widget.auftrag['id'])
          .update({
        'currentParticipants': currentParticipants,
        'assignedUser': user.uid, // Beibehaltung der bestehenden Logik
        'assignedUsers': FieldValue.arrayUnion([
          {
            'uid': user.uid,
            'displayName': displayName,
          }
        ]),
      });

      if (currentParticipants == maxParticipants) {
        await _firestore
            .collection('auftraege')
            .doc(widget.auftrag['id'])
            .update({
          'isVisible': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Maximale Teilnehmerzahl erreicht. Auftrag ist jetzt abgeschlossen!'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auftrag wurde angenommen!'),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximale Teilnehmerzahl bereits erreicht!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentParticipants = widget.auftrag['currentParticipants'] ?? 0;
    int maxParticipants = widget.auftrag['maxParticipants'] ?? 0;
    List<dynamic> participants = widget.auftrag['assignedUsers'] ?? [];
    User? currentUser = FirebaseAuth.instance.currentUser;
    bool isEmployer = currentUser?.uid == widget.auftrag['userId'];

    // Formatieren des Datums
    String formatDate(Timestamp? timestamp) {
      if (timestamp == null) return 'Nicht verfügbar';
      DateTime date = timestamp.toDate();
      return '${date.day}.${date.month}.${date.year}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auftragsdaten',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.auftrag['userId'] != null &&
                        widget.auftrag['userId'].isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userId: widget.auftrag[
                                'userId'], // Verwenden der `userId` des Auftraggebers
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Benutzerinformationen nicht verfügbar.'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    widget.auftrag['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if (!isEmployer && widget.isPastOrder)
                  IconButton(
                    icon: const Icon(Icons.rate_review, color: Colors.amber),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserRatingProfileScreen(
                            userId: widget.auftrag['userId'],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Stadt:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.auftrag['city'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Beschreibung:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.auftrag['description'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Startdatum:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatDate(widget.auftrag['startDate']),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enddatum:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatDate(widget.auftrag['endDate']),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Teilnehmer:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$currentParticipants von $maxParticipants Teilnehmern',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ...participants.map((participant) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userId: participant['uid'],
                          ),
                        ),
                      );
                    },
                    child: Text(
                      participant['displayName'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  if (isEmployer && widget.isPastOrder)
                    IconButton(
                      icon: const Icon(Icons.rate_review, color: Colors.amber),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserRatingProfileScreen(
                              userId: participant['uid'],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),
            if (!hasAcceptedThisJob &&
                currentParticipants < maxParticipants &&
                !widget.isPastOrder)
              ElevatedButton(
                onPressed: () {
                  _updateParticipants(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 188, 180, 133),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100.0, vertical: 12.0),
                ),
                child: const Text(
                  'Auftrag übernehmen',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            if (widget.isPastOrder)
              const Text(
                'Dieser Auftrag ist abgeschlossen.',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
