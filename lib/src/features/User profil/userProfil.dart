import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/BewertungenScreen/UserReviewsScreen.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  Future<Map<String, dynamic>?> _getUserData() async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<double> _getUserRating() async {
    final QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: userId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) {
      return 0.0; // Keine Bewertungen verfügbar
    }

    double totalRating = 0.0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += doc['rating'];
    }

    return totalRating /
        reviewsSnapshot.docs.length; // Durchschnittliche Bewertung berechnen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Benutzerprofil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return const Center(
                child: Text(
                    'Benutzerinformationen konnten nicht geladen werden.'));
          } else {
            final userData = snapshot.data!;
            final userImage =
                userData['imageUrl'] ?? 'assets/icons/default.png';
            final userName =
                '${userData['vorname'] ?? ''} ${userData['nachname'] ?? ''}'
                    .trim();

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CircleAvatar für das Benutzerbild
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: userImage.startsWith('http')
                          ? NetworkImage(userImage)
                          : AssetImage(userImage) as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Benutzername
                  Center(
                    child: Text(
                      userName.isNotEmpty ? userName : 'Unbekannt',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bewertung:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<double>(
                    future: _getUserRating(),
                    builder: (context, ratingSnapshot) {
                      if (ratingSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (ratingSnapshot.hasError) {
                        return const Text(
                          'Fehler beim Laden der Bewertung',
                          style: TextStyle(color: Colors.white),
                        );
                      } else {
                        final rating = ratingSnapshot.data ?? 0.0;
                        return Text(
                          '${rating.toStringAsFixed(1)} Sterne',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Punkte:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${userData['points'] ?? '0'} Punkte',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'E-Mail:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData['email'] ?? 'Nicht verfügbar',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rolle:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData['role'] ?? 'Nicht festgelegt',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GalleryScreen(userId: userId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 188, 180, 133),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('zur Galerie',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserReviewsScreen(userId: userId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 188, 180, 133),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Bewertungen',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class GalleryScreen extends StatelessWidget {
  final String userId;

  const GalleryScreen({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> _getUserGallery() async {
    final QuerySnapshot gallerySnapshot = await FirebaseFirestore.instance
        .collection('galerie')
        .where('userId', isEqualTo: userId)
        .get();

    return gallerySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUserGallery(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
                child: Text('Galerie konnte nicht geladen werden.'));
          }

          final galleryItems = snapshot.data!;
          if (galleryItems.isEmpty) {
            return const Center(
              child: Text('Keine Bilder in der Galerie vorhanden.',
                  style: TextStyle(color: Colors.white)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: galleryItems.length,
            itemBuilder: (context, index) {
              final item = galleryItems[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(item['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
