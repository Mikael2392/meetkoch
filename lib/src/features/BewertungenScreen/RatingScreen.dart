import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingScreen extends StatefulWidget {
  final String userId;

  const RatingScreen({super.key, required this.userId});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();

  Future<void> _submitRating() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance.collection('reviews').add({
      'reviewerId': currentUser.uid,
      'reviewedUserId': widget.userId,
      'rating': _rating,
      'review': _reviewController.text,
      'timestamp': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bewertung abgeben',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bewertung:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Sternbewertung hinzufügen
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 0.5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Rezension:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              style: const TextStyle(
                  color: Colors.white), // Textfarbe auf weiß setzen
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Teile deine Erfahrung...',
                hintStyle: const TextStyle(
                    color: Colors.white54), // Hint-Text auch in weißer Farbe
                filled: true,
                fillColor: const Color(
                    0xFF5C3D4F), // Hintergrundeinstellung für Textfeld
              ),
            ),
            const SizedBox(height: 30),
            // Button mittig und visuell ansprechender
            Center(
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 188, 180, 133),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 12.0),
                ),
                child: const Text(
                  'Bewertung absenden',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
