import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikeProvider with ChangeNotifier {
  final Map<String, List<String>> _likes = {};

  Map<String, List<String>> get likes => _likes;

  Future<void> toggleLike(String docId, String currentUserId) async {
    final docRef = FirebaseFirestore.instance.collection('galerie').doc(docId);

    // Likes vom Firestore holen
    final docSnapshot = await docRef.get();
    final data = docSnapshot.data() as Map<String, dynamic>?;
    final List<String> currentLikes = List<String>.from(data?['likes'] ?? []);

    // Like hinzufügen oder entfernen
    if (currentLikes.contains(currentUserId)) {
      currentLikes.remove(currentUserId);
    } else {
      currentLikes.add(currentUserId);
    }

    // Firestore aktualisieren
    await docRef.update({'likes': currentLikes});

    // Lokale Kopie aktualisieren
    _likes[docId] = currentLikes;

    // UI benachrichtigen
    notifyListeners();
  }

  Future<List<String>> fetchLikes(String docId) async {
    if (_likes.containsKey(docId)) {
      return _likes[docId]!;
    }

    final docRef = FirebaseFirestore.instance.collection('galerie').doc(docId);
    final docSnapshot = await docRef.get();
    final data = docSnapshot.data() as Map<String, dynamic>?;
    final List<String> fetchedLikes = List<String>.from(data?['likes'] ?? []);

    _likes[docId] = fetchedLikes;
    notifyListeners();

    return fetchedLikes;
  }
}
