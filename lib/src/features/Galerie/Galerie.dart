import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalerieScreen extends StatefulWidget {
  const GalerieScreen({super.key, required String userId});

  @override
  _GalerieScreenState createState() => _GalerieScreenState();
}

class _GalerieScreenState extends State<GalerieScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Bild auswählen und direkt hochladen
  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      try {
        String fileName =
            'gallery/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask =
            _storage.ref().child(fileName).putFile(_selectedImage!);

        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Speichern der Bild-URL in Firestore
        await _firestore.collection('galerie').add({
          'userId': user.uid,
          'imageUrl': imageUrl,
          'uploadedAt': Timestamp.now(),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Bild ausgewählt')),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Button zum Bild auswählen und direkt hochladen
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text(' Bild hochladen'),
            ),

            const SizedBox(height: 16),

            // Anzeige hochgeladener Bilder und Beschreibungen
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              galleryItem['imageUrl'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
