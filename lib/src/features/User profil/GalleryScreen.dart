import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'CommentScreen.dart';

class GalleryScreen extends StatefulWidget {
  final String userId;

  const GalleryScreen({super.key, required this.userId});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<Map<String, dynamic>>> _galleryItems;

  @override
  void initState() {
    super.initState();
    _galleryItems = _getUserGallery();
  }

  Future<List<Map<String, dynamic>>> _getUserGallery() async {
    final QuerySnapshot gallerySnapshot = await FirebaseFirestore.instance
        .collection('galerie')
        .where('userId', isEqualTo: widget.userId)
        .get();

    return gallerySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> _likeImage(String docId, String currentUserId) async {
    final docRef = FirebaseFirestore.instance.collection('galerie').doc(docId);

    final docSnapshot = await docRef.get();
    final data = docSnapshot.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likes'] ?? []);

    if (likes.contains(currentUserId)) {
      likes.remove(currentUserId); // Like entfernen
    } else {
      likes.add(currentUserId); // Like hinzufügen
    }

    await docRef.update({'likes': likes});
    setState(() {
      _galleryItems = _getUserGallery(); // Galerie aktualisieren
    });
  }

  Future<int> _getCommentCount(String docId) async {
    final QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collection('galerie')
        .doc(docId)
        .collection('comments')
        .get();

    return commentsSnapshot.size;
  }

  Future<void> _addComment(
      String docId, String comment, String currentUserId) async {
    if (comment.isEmpty) return;

    final commentData = {
      'userId': currentUserId,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('galerie')
        .doc(docId)
        .collection('comments')
        .add(commentData);

    setState(() {
      _galleryItems = _getUserGallery(); // Galerie aktualisieren
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        "currentUserId"; // Ersetze durch aktuelle Benutzer-ID.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      backgroundColor: const Color(0xFF4B2F3E),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _galleryItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Galerie konnte nicht geladen werden.',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final galleryItems = snapshot.data!;
          if (galleryItems.isEmpty) {
            return const Center(
              child: Text('Keine Bilder in der Galerie vorhanden.',
                  style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: galleryItems.length,
            itemBuilder: (context, index) {
              final item = galleryItems[index];
              final docId = item['id'];
              final likes = List<String>.from(item['likes'] ?? []);
              final TextEditingController _commentController =
                  TextEditingController();

              return FutureBuilder<int>(
                future: _getCommentCount(docId),
                builder: (context, commentSnapshot) {
                  final commentCount = commentSnapshot.data ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bild
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          item['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Kommentar und Aktionen
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['comment'] ?? 'Kein Kommentar vorhanden.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              likes.contains(currentUserId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: likes.contains(currentUserId)
                                  ? Colors.red
                                  : Colors.white,
                            ),
                            onPressed: () => _likeImage(docId, currentUserId),
                          ),
                          Text(
                            '${likes.length} Likes',
                            style: const TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.comment, color: Colors.white),
                            onPressed: () {
                              // Navigation zum CommentScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommentScreen(imageId: docId),
                                ),
                              );
                            },
                          ),
                          Text(
                            '$commentCount Kommentare',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Kommentar hinzufügen
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Kommentar hinzufügen...',
                                hintStyle:
                                    const TextStyle(color: Colors.white70),
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
                              _addComment(docId, _commentController.text.trim(),
                                  currentUserId);
                              _commentController.clear();
                            },
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.white54,
                        thickness: 1,
                        height: 30,
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
