import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key, required this.userId});
  final String userId;

  @override
  _GalerieScreenState createState() => _GalerieScreenState();
}

class _GalerieScreenState extends State<GalerieScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImageAndShowCommentDialog() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      _showCommentDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Bild ausgewählt')),
      );
    }
  }

  void _showCommentDialog() {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kommentar hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Gib einen Kommentar ein...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _uploadImageWithComment(commentController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Hochladen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImageWithComment(String comment) async {
    if (_selectedImage == null) return;
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      String fileName =
          'gallery/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask =
          _storage.ref().child(fileName).putFile(_selectedImage!);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('galerie').add({
        'userId': user.uid,
        'imageUrl': imageUrl,
        'comment': comment,
        'uploadedAt': Timestamp.now(),
      });

      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bild erfolgreich hochgeladen!')),
      );
    } catch (e) {
      print('Fehler beim Hochladen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Hochladen des Bildes')),
      );
    }
  }

  Future<void> _deleteImage(String docId, String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      await _firestore.collection('galerie').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bild erfolgreich gelöscht!')),
      );
    } catch (e) {
      print('Fehler beim Löschen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Löschen des Bildes')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Galerie',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2F3E),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4B2F3E),
              Color(0xFFB16F92),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickImageAndShowCommentDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text('Bild hochladen'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('galerie')
                      .where('userId',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var galleryItems = snapshot.data!.docs;

                    if (galleryItems.isEmpty) {
                      return const Center(
                        child: Text('Keine Bilder hochgeladen'),
                      );
                    }

                    return ListView.builder(
                      itemCount: galleryItems.length,
                      itemBuilder: (context, index) {
                        var galleryItem =
                            galleryItems[index].data() as Map<String, dynamic>;
                        String docId = galleryItems[index].id;
                        String imageUrl = galleryItem['imageUrl'];
                        String? comment = galleryItem['comment'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onLongPress: () => _deleteImage(docId, imageUrl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (comment != null && comment.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      comment,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
