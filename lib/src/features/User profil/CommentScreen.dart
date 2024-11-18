import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentScreen extends StatelessWidget {
  final String imageId;

  CommentScreen({super.key, required this.imageId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Fehler beim Abrufen der Benutzerdaten: $e");
    }
    return null;
  }

  Future<Widget> _getUserProfileImage(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      String? userImage = userDoc['imageUrl'];

      return CircleAvatar(
        radius: 20,
        backgroundImage: userImage != null && userImage.isNotEmpty
            ? NetworkImage(userImage)
            : const AssetImage('assets/icons/default.png') as ImageProvider,
      );
    } catch (e) {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kommentare'),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('galerie')
                  .doc(imageId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Keine Kommentare vorhanden.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final commentData =
                        comments[index].data() as Map<String, dynamic>;
                    final userId = commentData['userId'] ?? 'Unbekannt';

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getUserData(userId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text('Lädt Benutzerinformationen...',
                                style: TextStyle(color: Colors.white)),
                          );
                        }

                        if (!userSnapshot.hasData ||
                            userSnapshot.data == null) {
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              commentData['comment'] ?? 'Kein Kommentar',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              commentData['timestamp'] != null
                                  ? (commentData['timestamp'] as Timestamp)
                                      .toDate()
                                      .toString()
                                  : '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        final userData = userSnapshot.data!;
                        final userName =
                            '${userData['vorname'] ?? ''} ${userData['nachname'] ?? ''}'
                                .trim();
                        final userImage =
                            userData['imageUrl'] ?? 'assets/icons/default.png';

                        return ListTile(
                          leading: FutureBuilder<Widget>(
                            future: _getUserProfileImage(userId),
                            builder: (context, avatarSnapshot) {
                              if (avatarSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return avatarSnapshot.data ??
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                    child:
                                        Icon(Icons.person, color: Colors.white),
                                  );
                            },
                          ),
                          title: Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                commentData['comment'] ?? 'Kein Kommentar',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                commentData['timestamp'] != null
                                    ? (commentData['timestamp'] as Timestamp)
                                        .toDate()
                                        .toString()
                                    : '',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Kommentar hinzufügen...',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    // Kommentar hinzufügen
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
