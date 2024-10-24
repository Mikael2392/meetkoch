import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/BewertungenScreen/RatingScreen.dart';

class UserRatingProfileScreen extends StatelessWidget {
  final String userId;

  const UserRatingProfileScreen({super.key, required this.userId});

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

  Future<List<Map<String, dynamic>>> _getUserReviews() async {
    final QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: userId)
        .get();

    return reviewsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Widget _buildStars(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber),
        if (halfStar) const Icon(Icons.star_half, color: Colors.amber),
        for (int i = fullStars + (halfStar ? 1 : 0); i < 5; i++)
          const Icon(Icons.star_border, color: Colors.amber),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benutzerprofil bewerten',
            style: TextStyle(color: Colors.white)),
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
            final String profileImageUrl = userData['imageUrl'] ?? '';
            final String userName =
                '${userData['vorname'] ?? ''} ${userData['nachname'] ?? ''}'
                    .trim();

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Benutzerbild als Circle Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl.isNotEmpty &&
                              profileImageUrl.startsWith('http')
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage('assets/icons/default.png')
                              as ImageProvider, // Placeholder-Bild bei fehlender URL
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 20),
                    // Benutzername
                    Text(
                      userName.isNotEmpty ? userName : 'Unbekannt',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Benutzerbewertung mit Sternen und Text
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
                          return Column(
                            children: [
                              _buildStars(rating),
                              const SizedBox(height: 5),
                              Text(
                                '${rating.toStringAsFixed(1)} Sterne',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RatingScreen(userId: userId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 188, 180, 133),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 12.0),
                      ),
                      child: const Text(
                        'Jetzt bewerten',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Vergangene Bewertungen:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Vergangene Bewertungen anzeigen
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getUserReviews(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Map<String, dynamic>>>
                              reviewsSnapshot) {
                        if (reviewsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (reviewsSnapshot.hasError ||
                            !reviewsSnapshot.hasData ||
                            reviewsSnapshot.data == null ||
                            reviewsSnapshot.data!.isEmpty) {
                          return const Text(
                            'Keine Bewertungen verfügbar.',
                            style: TextStyle(color: Colors.white70),
                          );
                        } else {
                          final reviews = reviewsSnapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              return Card(
                                color: const Color.fromARGB(255, 75, 47, 62),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _buildStars(review['rating'].toDouble()),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${review['rating']} Sterne',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    review['review'] ?? 'Keine Rezension',
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
