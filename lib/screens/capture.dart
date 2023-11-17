import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  String? hike_id;
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
      final storageReference =
      _storage.ref().child('images/${DateTime.now()}.jpg');
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
        'description': _descriptionController.text,
        'image_url': imageUrl,
        'user_id': userId,
        'hike_id': hike_id
      });

      // Clear form fields
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (imageUrl != "null")
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16),

              Text(
                'Choose Hike',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<QuerySnapshot>(
                future: _reference.get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue, // Set the color of the CircularProgressIndicator
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red), // Set the text color for error messages
                      ),
                    );
                  }
                  List<String> hikeTitles =
                  snapshot.data!.docs.map((doc) => doc['title'].toString()).toList();
                  List<String> hikeIds = snapshot.data!.docs.map((doc) => doc.id).toList();

                  // Convert the list to a set to ensure uniqueness
                  Set<String> uniqueTitles = Set.from(hikeTitles);
                  Set<String> uniqueIds = Set.from(hikeIds);

                  String valueSelected = uniqueIds.isNotEmpty ? uniqueIds.first : "";
                  return DropdownButton<String>(
                    value: valueSelected,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    items: uniqueTitles.toList().asMap().entries.map((entry) {
                      int index = entry.key;
                      String title = entry.value;
                      String id = uniqueIds.elementAt(index);
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      print(uniqueTitles.elementAt(uniqueIds.toList().indexOf(newValue!)));
                      setState(() {
                        valueSelected = newValue;
                         hike_id = newValue;
                         print(hike_id);
                      });

                    },
                  );
                },
              ),

              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _captureAndUploadImage,
                icon: Icon(Icons.camera_alt),
                label: Text(
                  'Capture or Upload Image',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Change the text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Add rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  'Submit Form',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green, // Change the text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Add rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
