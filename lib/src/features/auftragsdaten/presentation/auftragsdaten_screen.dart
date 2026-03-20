import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/BewertungenScreen/user_rating_profile_screen.dart';
import 'package:meetkoch/src/features/User%20profil/user_profil.dart';

class AuftragDetailScreen extends StatefulWidget {
  final Map<String, dynamic> auftrag;
  final bool isPastOrder;

  const AuftragDetailScreen({
    super.key,
    required this.auftrag,
    this.isPastOrder = false,
  });

  @override
  State<AuftragDetailScreen> createState() => AuftragDetailScreenState();
}

class AuftragDetailScreenState extends State<AuftragDetailScreen> {
  bool hasAcceptedThisJob = false;
  bool isAccepting = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasAcceptedThisJob();
  }

  Future<void> _checkIfUserHasAcceptedThisJob() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? auftragId = widget.auftrag['id'];
    if (user == null || auftragId == null) return;

    final DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('auftraege')
        .doc(auftragId)
        .get();

    if (!mounted) return;

    if (result.exists) {
      final data = result.data() as Map<String, dynamic>;
      final List<dynamic> assignedUsers = data['assignedUsers'] ?? [];
      if (assignedUsers.any((u) => u['uid'] == user.uid)) {
        setState(() => hasAcceptedThisJob = true);
      }
    }
  }

  // Fix: KEIN BuildContext-Parameter — verwendet this.context aus dem State
  Future<void> _updateParticipants() async {
    if (isAccepting) return;
    setState(() => isAccepting = true);

    final String? auftragId = widget.auftrag['id'];
    if (auftragId == null) {
      setState(() => isAccepting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auftrag-ID fehlt. Bitte neu laden.')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isAccepting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Du musst eingeloggt sein, um den Auftrag anzunehmen.')),
      );
      return;
    }

    final latestDoc =
        await firestore.collection('auftraege').doc(auftragId).get();
    if (!mounted) return;

    if (latestDoc.exists) {
      final latestData = latestDoc.data() as Map<String, dynamic>;
      final List<dynamic> latestAssigned = latestData['assignedUsers'] ?? [];
      if (latestAssigned.any((u) => u['uid'] == user.uid)) {
        setState(() {
          hasAcceptedThisJob = true;
          isAccepting = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Du hast diesen Auftrag bereits angenommen.')),
        );
        return;
      }
    }

    final userDoc = await firestore.collection('users').doc(user.uid).get();
    if (!mounted) return;

    String displayName = 'Anonymer Benutzer';
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      displayName = '${userData['vorname']} ${userData['nachname']}';
    }

    final int currentParticipants = widget.auftrag['currentParticipants'] ?? 0;
    final int maxParticipants = widget.auftrag['maxParticipants'] ?? 0;

    if (currentParticipants < maxParticipants) {
      await firestore.collection('auftraege').doc(auftragId).update({
        'currentParticipants': currentParticipants + 1,
        'assignedUsers': FieldValue.arrayUnion([
          {'uid': user.uid, 'displayName': displayName}
        ]),
      });

      if (!mounted) return;
      setState(() {
        hasAcceptedThisJob = true;
        isAccepting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auftrag wurde erfolgreich angenommen!')),
      );
    } else {
      setState(() => isAccepting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Maximale Teilnehmeranzahl wurde erreicht!')),
      );
    }
  }

  Future<Widget> _getUserProfileImage(String userId) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final String? userImage = userDoc['imageUrl'];
    return CircleAvatar(
      radius: 30,
      backgroundImage: userImage != null && userImage.isNotEmpty
          ? NetworkImage(userImage)
          : const AssetImage('assets/icons/default.png') as ImageProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentParticipants = widget.auftrag['currentParticipants'] ?? 0;
    final int maxParticipants = widget.auftrag['maxParticipants'] ?? 0;
    final List<dynamic> participants = widget.auftrag['assignedUsers'] ?? [];
    final String employerId = widget.auftrag['userId'] ?? '';

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isEmployer = currentUser?.uid == employerId;

    final DateTime? startDate = widget.auftrag['startDate'] != null
        ? (widget.auftrag['startDate'] as Timestamp).toDate()
        : null;
    final DateTime? endDate = widget.auftrag['endDate'] != null
        ? (widget.auftrag['endDate'] as Timestamp).toDate()
        : null;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Auftragsdaten', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Text('Beschreibung:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
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
            Text(
              'Teilnehmer: $currentParticipants von $maxParticipants',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
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
                                  userId: participant['uid']),
                            ),
                          );
                        },
                      ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (!hasAcceptedThisJob &&
                currentParticipants < maxParticipants &&
                !widget.isPastOrder)
              ElevatedButton(
                // Fix: kein () => _updateParticipants(context) mehr
                onPressed: isAccepting ? null : _updateParticipants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 188, 180, 133),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100.0, vertical: 12.0),
                ),
                child: isAccepting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Auftrag übernehmen',
                        style: TextStyle(color: Colors.black)),
              ),
            if (widget.isPastOrder)
              const Text('Dieser Auftrag ist abgeschlossen.',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16)),
            if (widget.isPastOrder && !isEmployer)
              IconButton(
                icon: const Icon(Icons.rate_review, color: Colors.amber),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UserRatingProfileScreen(userId: employerId),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
