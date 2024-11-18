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

  // Überprüfen, ob der Benutzer den Auftrag bereits angenommen hat
  Future<void> _checkIfUserHasAcceptedThisJob() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final DocumentSnapshot result = await firestore
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

  // Auftrag übernehmen
  Future<void> _updateParticipants(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Du musst eingeloggt sein, um den Auftrag anzunehmen.'),
        ),
      );
      return;
    }

    final userDoc = await firestore.collection('users').doc(user.uid).get();
    String displayName = 'Anonymer Benutzer';

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      displayName = '${userData['vorname']} ${userData['nachname']}';
    }

    int currentParticipants = widget.auftrag['currentParticipants'] ?? 0;
    int maxParticipants = widget.auftrag['maxParticipants'] ?? 0;

    if (currentParticipants < maxParticipants) {
      currentParticipants++;

      await firestore.collection('auftraege').doc(widget.auftrag['id']).update({
        'currentParticipants': currentParticipants,
        'assignedUsers': FieldValue.arrayUnion([
          {
            'uid': user.uid,
            'displayName': displayName,
          }
        ]),
      });

      setState(() {
        hasAcceptedThisJob = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auftrag wurde erfolgreich angenommen!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximale Teilnehmeranzahl wurde erreicht!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentParticipants = widget.auftrag['currentParticipants'] ?? 0;
    int maxParticipants = widget.auftrag['maxParticipants'] ?? 0;
    List<dynamic> participants = widget.auftrag['assignedUsers'] ?? [];
    String employerId = widget.auftrag['userId'] ?? '';

    User? currentUser = FirebaseAuth.instance.currentUser;
    bool isEmployer = currentUser?.uid == employerId;

    DateTime? startDate = widget.auftrag['startDate'] != null
        ? (widget.auftrag['startDate'] as Timestamp).toDate()
        : null;
    DateTime? endDate = widget.auftrag['endDate'] != null
        ? (widget.auftrag['endDate'] as Timestamp).toDate()
        : null;

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
            // Arbeitgebername in Row
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4B2F3E),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  FutureBuilder<Widget>(
                    future: _getUserProfileImage(employerId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/icons/default.png'),
                        );
                      }
                      return snapshot.data!;
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfileScreen(userId: employerId),
                        ),
                      );
                    },
                    child: Text(
                      widget.auftrag['name'] ?? 'Kein Name',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stadt mit Icon
            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  widget.auftrag['city'] ?? 'Keine Stadt angegeben',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Beschreibung
            const Text(
              'Beschreibung:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4B2F3E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.auftrag['description'] ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Start- und Enddatum
            if (startDate != null)
              Text(
                'Startdatum: ${startDate.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            if (endDate != null)
              Text(
                'Enddatum: ${endDate.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            const SizedBox(height: 20),

            // Teilnehmeranzeige
            Text(
              'Teilnehmer: $currentParticipants von $maxParticipants',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Teilnehmerliste mit Bild und Bewertung
            Wrap(
              spacing: 8.0,
              children: participants.map((participant) {
                return Column(
                  children: [
                    FutureBuilder<Widget>(
                      future: _getUserProfileImage(participant['uid']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage('assets/icons/default.png'),
                          );
                        }
                        return snapshot.data!;
                      },
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileScreen(userId: participant['uid']),
                          ),
                        );
                      },
                      child: Text(
                        participant['displayName'] ?? 'Unbekannt',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    if (widget.isPastOrder && isEmployer)
                      IconButton(
                        icon:
                            const Icon(Icons.rate_review, color: Colors.amber),
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
            ),
            const SizedBox(height: 20),

            // Auftrag übernehmen-Button
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

            // Meldung für abgeschlossene Aufträge
            if (widget.isPastOrder)
              const Text(
                'Dieser Auftrag ist abgeschlossen.',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),

            // Bewertungsbutton für den Arbeitgeber
            if (widget.isPastOrder && !isEmployer)
              IconButton(
                icon: const Icon(Icons.rate_review, color: Colors.amber),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserRatingProfileScreen(
                        userId: employerId,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Funktion zum Abrufen des Profilbildes eines Benutzers
  Future<Widget> _getUserProfileImage(String userId) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String? userImage = userDoc['imageUrl'];

    return CircleAvatar(
      radius: 30,
      backgroundImage: userImage != null && userImage.isNotEmpty
          ? NetworkImage(userImage)
          : const AssetImage('assets/icons/default.png') as ImageProvider,
    );
  }
}
