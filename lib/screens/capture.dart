import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Capture extends StatefulWidget {
  const Capture({Key? key}) : super(key: key);

  @override
  State<Capture> createState() => _CaptureState();
}

class _CaptureState extends State<Capture> {
  String imageUrl = 'null';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  GlobalKey<FormState> key = GlobalKey();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  TextEditingController description = TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('hike');

  Future<void> _captureAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = pickedFile.path;
      final storageReference = _storage.ref().child('images/${DateTime.now()}.jpg');
      final uploadTask = storageReference.putFile(File(imageFile));

      await uploadTask.whenComplete(() async {
        final url = await storageReference.getDownloadURL();
        setState(() {
          imageUrl = url;
        });
      });
    }
  }
  Future<void> _submitForm() async {
    final user = _auth.currentUser;
    print(user);
    if (user != null) {
      final userId = user.uid;

      await _firestore.collection('hikes').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'image_url': imageUrl,
        'user_id': userId,
      });

      // Clear form fields
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        imageUrl = "null";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Capture and Upload Image'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title'),
                  TextField(controller: _titleController),
                  SizedBox(height: 16),
                  Text('Description'),
                  TextField(controller: _descriptionController),
                  SizedBox(height: 16),
                  if (imageUrl != "null")
                    Image.network(
                    imageUrl,
                    height: 200, // Set the desired height
                    width: 300,  // Set the desired width
                    fit: BoxFit.cover ),
                  IconButton(
                    icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                  ),
                    onPressed: _captureAndUploadImage,
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit Form'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
