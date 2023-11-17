import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mhike/screens/selectlocation.dart';
import 'package:intl/intl.dart';

import 'home.dart';

class CreateHike extends StatefulWidget {
  final String? hikeId;

  const CreateHike({this.hikeId});

  @override
  State<CreateHike> createState() => _CreateHikeState();
}

class _CreateHikeState extends State<CreateHike> {
  bool _isLoading = false;
  bool _isSubmitting = false;
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
      await _reference.doc(widget.hikeId).update({
        'start': startLocation,
        'end': endLocation,
        'timings': date,
      });
      // Data updated successfully
    } catch (error) {
      print('Error updating data: $error');
    }
  }



  @override
  void initState() {
    super.initState();
    // Load existing data when the hikeId is provided
    if (widget.hikeId != null) {
      loadHikeData(widget.hikeId);
    }
  }

  Future<void> loadHikeData(String? hikeId) async {
    final DocumentSnapshot userSnapshot = await _reference.doc(hikeId).get();
    final userHike = userSnapshot.data() as Map<String, dynamic>;

    if (userHike != null) {
      setState(() {
        _titleController.text = userHike['title'];
        _descriptionController.text = userHike['description'];
        startLocation = userHike['start'];
        endLocation = userHike['end'];
        date = userHike['timings'].toDate(); // Assuming it's a DateTime
        _imageUrl = userHike['imageUrl'];
      });
    }

    setState(() {
      // Update the state to reflect the loaded data
    });
  }

  Future<void> _showConfirmationDialog(String action) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action this hike?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Perform the action based on the button clicked
                if (action == 'Submit') {
                  _submitData();
                } else if (action == 'Update') {
                  _updateData();
                } else if (action == 'Delete') {
                  _deleteData();
                }
              },
              child: Text('Confirm'),

            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Hike'),
        actions: [
          IconButton(
            onPressed: () => _showConfirmationDialog('Submit'),
            icon: Icon(Icons.check),
          ),
          IconButton(
            onPressed: () => _showConfirmationDialog('Delete'),
            icon: Icon(Icons.delete),
          ),
        ],

      ),
      body: Center(
    child: _isLoading
    ? CircularProgressIndicator()
      : Stack(
          children: [ SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_imageFile != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_imageFile!.path),
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.amber,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text('Pick an Image'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
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
                  _buildLocationRow(
                    title: 'Start Location:',
                    value: startLocation ?? 'Not selected',
                    color: Colors.blue,
                    onPressed: () => _selectLocation('start'),
                  ),
                  SizedBox(height: 16),
                  _buildLocationRow(
                    title: 'End Location:',
                    value: endLocation ?? 'Not selected',
                    color: Colors.green,
                    onPressed: () => _selectLocation('end'),
                  ),
                  SizedBox(height: 16),
                  _buildDateRow(
                    title: 'Date:',
                    value: date != null
                        ? DateFormat('yyyy-MM-dd').format(date!)
                        : 'Not selected',
                    onPressed: _selectDate,
                  ),
                  SizedBox(height: 20),


                ],

              ),
            ),
          ),
          ]
      ),
    ),
    );
  }

  Widget _buildLocationRow({
    required String title,
    required String value,
    required Color color,
    required void Function() onPressed,
  }) {
    final List<String> parts = value.split(', ');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                parts.length > 0 ? '${parts[0]}' : 'Not available',
                style: TextStyle(fontSize: 12, color: color),
              ),
              SizedBox(height: 4),
              Text(
                parts.length > 1 ? '${parts[1]}' : 'Not available',
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: onPressed,
          child: const Text('Select Location'),
        ),
      ],
    );
  }


  Widget _buildDateRow({
    required String title,
    required String value,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            onPrimary: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Select Date'),
        ),
      ],
    );
  }

  void _selectLocation(String locationType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MySelectLocation(),
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          if (locationType == 'start') {
            startLocation =
            "Latitude: ${value['lat']}, Longitude: ${value['lng']}";
          } else {
            endLocation =
            "Latitude: ${value['lat']}, Longitude: ${value['lng']}";
          }
        });
      }
    });
  }

  void _selectDate() {
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
  }
  Future<void> _deleteData() async {
    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });

    try {
      if (widget.hikeId != null) {
        await _reference.doc(widget.hikeId).delete();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Deleted Successfully"),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHome(),
          ),
        );
      } else {
        print('No hikeId provided. Unable to delete data.');
      }
    } catch (error) {
      print('Error deleting data: $error');
    } finally {
      setState(() {
        _isLoading = false;
        _isSubmitting = false;
      });
    }
  }

  Future<void> _submitData() async {
    final user = _auth.currentUser;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });
    if (_imageFile == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        startLocation == null ||
        endLocation == null ||
        date == null) {
      // Show an error message or handle the case where any of the required fields is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill in all the fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isLoading = false;
        _isSubmitting = false;
      });
      return;
    }

    try {
      Reference storageReference =
      _storage.ref().child('hikesImage/${DateTime.now()}.jpg');
      await storageReference.putFile(File(_imageFile!.path));
      String imageUrl = await storageReference.getDownloadURL();
      print(user?.uid);
      await _reference.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl,
        'start': startLocation,
        'end': endLocation,
        'timings': date,
        'userId': user?.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Created Successfully"),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHome(),
        ),
      );
      // Data saved successfully, show success message or navigate to the next screen
    } catch (error) {
      // Handle error, show error message or retry logic
      print('Error saving data: $error');
    } finally {
      setState(() {
        _isLoading = false;
        _isSubmitting = false;
      });
    }
  }
}