import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        'assignedUser': user.uid,
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

  Widget _buildDetailCard(String title, String value, {Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: onTap != null
                ? const Color.fromARGB(255, 188, 180, 133).withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (onTap != null)
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.black54,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(
      String startLabel, String endLabel, String startDate, String endDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    startDate,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10), // Platz zwischen den beiden Containern
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    endLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    endDate,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(String name, {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color.fromARGB(255, 188, 180, 133).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.black54,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantSection(int currentParticipants, int maxParticipants,
      List<dynamic> participants, bool isEmployer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 10),
        ...participants.map((participant) {
          return Column(
            children: [
              _buildParticipantItem(
                participant['displayName'],
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
              ),
              const SizedBox(height: 10), // Abstand zwischen den Teilnehmern
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, String text, Function(BuildContext) onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 188, 180, 133),
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 12.0),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
    );
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              'Name',
              widget.auftrag['name'] ?? '',
              onTap: () {
                if (widget.auftrag['userId'] != null &&
                    widget.auftrag['userId'].isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        userId: widget.auftrag['userId'],
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Benutzerinformationen nicht verfügbar.'),
                    ),
                  );
                }
              },
            ),
            _buildDetailCard('Stadt', widget.auftrag['city'] ?? ''),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.auftrag['description'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDateRow(
              'Startdatum',
              'Enddatum',
              formatDate(widget.auftrag['startDate']),
              formatDate(widget.auftrag['endDate']),
            ),
            const SizedBox(height: 20),
            _buildParticipantSection(
                currentParticipants, maxParticipants, participants, isEmployer),
            const SizedBox(height: 20),
            if (!hasAcceptedThisJob &&
                currentParticipants < maxParticipants &&
                !widget.isPastOrder)
              _buildActionButton(
                  context, 'Auftrag übernehmen', _updateParticipants),
            if (widget.isPastOrder)
              const Text(
                'Dieser Auftrag ist abgeschlossen.',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                ),
              )
          ],
        ),
      ),
    );
  }
}
