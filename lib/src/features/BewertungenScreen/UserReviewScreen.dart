import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserReviewScreen extends StatelessWidget {
  const UserReviewScreen({super.key});

  Future<List<Map<String, dynamic>>> _getUserReviews() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewerId', isEqualTo: currentUser.uid)
        .get();

    return reviewsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<String> _getUserName(String userId) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>?;
      return '${userData?['vorname'] ?? ''} ${userData?['nachname'] ?? ''}'
          .trim();
    }
    return 'Unbekannt';
  }

  Widget _buildStars(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    return Row(
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
        title: const Text('Meine Bewertungen',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUserReviews(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Keine Bewertungen gefunden.',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return FutureBuilder<String>(
                  future: _getUserName(review['reviewedUserId']),
                  builder: (context, nameSnapshot) {
                    if (!nameSnapshot.hasData) {
                      return const ListTile(
                        title: Text('Lädt...',
                            style: TextStyle(color: Colors.white)),
                      );
                    }
                    final userName = nameSnapshot.data!;
                    return Card(
                      color: const Color(0xFF4B2F3E),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          'Bewertet: $userName',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStars(review['rating']),
                            const SizedBox(height: 5),
                            Text(
                              review['review'] ?? 'Keine Rezension',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
