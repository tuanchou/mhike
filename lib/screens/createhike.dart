import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mhike/screens/selectlocation.dart';


class CreateHike extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const CreateHike({Key? key});

  @override
  State<CreateHike> createState() => _CreateHikeState();
}

class _CreateHikeState extends State<CreateHike> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  String _imageUrl = 'null';
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('hike');
  String? startLocation;
  String? endLocation;
  DateTime? date;
  final _auth = FirebaseAuth.instance;
  Future<void> _pickImage() async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }
  Future<void> _updateData() async {
    if (startLocation == null || endLocation == null || date == null) {
      print('Please fill all the fields');
      return;
    }

    try {
      final user = _auth.currentUser;
      await _reference.doc('YOUR_DOCUMENT_ID').update({
        'start': startLocation,
        'end': endLocation,
        'timings': date,
      });
      // Data updated successfully
    } catch (error) {
      print('Error updating data: $error');
    }
  }
  Future<void> _deleteData() async {
    try {
      await _reference.doc('YOUR_DOCUMENT_ID').delete();
      // Data deleted successfully
    } catch (error) {
      print('Error deleting data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Hike'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null)
              Image.file(
                File(_imageFile!.path),
                height: 200,
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick an Image'),
            ),
            Text('Title'),
            TextField(controller: _titleController),
            SizedBox(height: 16),
            Text('Description'),
            TextField(controller: _descriptionController),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MySelectLocation(),
                  ),
                ).then((value)  {
                  if (value != null) {
                    setState(() {
                      startLocation = "Latitude: ${value['lat']}, Longitude: ${value['lng']}";
                    });
                  }
                });
              },
              child: const Text('Select Start Location'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MySelectLocation(),
                  ),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      endLocation =  "Latitude: ${value['lat']}, Longitude: ${value['lng']}";
                    });
                  }
                });
              },
              child: const Text('Select End Location'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      date = value;
                    });
                  }
                });
              },
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start Location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              startLocation ?? 'Not selected',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue, // Set start location text color
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'End Location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              endLocation ?? 'Not selected',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green, // Set end location text color
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Date:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              date?.toString() ?? 'Not selected',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red, // Set date text color
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Submit'),
            ),
            ElevatedButton(
              onPressed: _updateData,
              child: const Text('Update'),
            ),
            ElevatedButton(
              onPressed: _deleteData,
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _submitData() async {

    final user = _auth.currentUser;

    if (startLocation == null || endLocation == null || date == null) {
      print('Please fill all the fields');
      return;
    }


    try {
      Reference storageReference = _storage.ref().child('hikesImage/${DateTime.now()}.jpg');
      await storageReference.putFile(File(_imageFile!.path));
      String imageUrl = await storageReference.getDownloadURL();
      print(user?.uid);
      await _reference.add({
        'title':_titleController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl,
        'start': startLocation,
        'end': endLocation,
        'timings': date,
        'userId': user?.uid,
      });
      // Data saved successfully, show success message or navigate to the next screen
    } catch (error) {
      // Handle error, show error message or retry logic
      print('Error saving data: $error');
    }
  }
}
