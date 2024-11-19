import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meetkoch/src/features/User%20profil/LikeProvider.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        "currentUserId"; // Ersetze durch aktuelle Benutzer-ID.

    return ChangeNotifierProvider(
      create: (_) => LikeProvider(),
      child: Scaffold(
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
                    Consumer<LikeProvider>(
                      builder: (context, likeProvider, _) {
                        return FutureBuilder<List<String>>(
                          future: likeProvider.fetchLikes(docId),
                          builder: (context, likeSnapshot) {
                            final likes = likeSnapshot.data ?? [];

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['comment'] ??
                                        'Kein Kommentar vorhanden.',
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
                                  onPressed: () => likeProvider.toggleLike(
                                      docId, currentUserId),
                                ),
                                Text(
                                  '${likes.length} Likes',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          },
                        );
                      },
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
        ),
      ),
    );
  }
}
