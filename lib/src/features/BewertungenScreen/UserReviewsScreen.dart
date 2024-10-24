import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserReviewsScreen extends StatelessWidget {
  final String userId;

  const UserReviewsScreen({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> _getUserReviews() async {
    final QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> reviews = [];
    for (var doc in reviewsSnapshot.docs) {
      Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;

      // Namen des Rezensenten abrufen
      final reviewerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(reviewData['reviewerId'])
          .get();
      String reviewerName = 'Unbekannter Benutzer';

      if (reviewerDoc.exists) {
        final reviewerData = reviewerDoc.data() as Map<String, dynamic>;
        reviewerName =
            '${reviewerData['vorname']} ${reviewerData['nachname']}'.trim();
      }

      reviews.add({
        'rating': reviewData['rating'],
        'review': reviewData['review'],
        'reviewerName': reviewerName,
      });
    }

    return reviews;
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
        title: const Text('Alle Bewertungen anzeigen',
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
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Fehler beim Laden der Bewertungen.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Keine Bewertungen verfügbar.',
                  style: TextStyle(color: Colors.white)),
            );
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  color: const Color.fromARGB(255, 75, 47, 62),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: _buildStars(review['rating']
                        .toDouble()), // Visuelle Anzeige der Sterne
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Rezension: ${review['review']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rezensiert von: ${review['reviewerName']}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
