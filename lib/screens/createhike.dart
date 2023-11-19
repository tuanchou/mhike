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
  double _starRating = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _parking = false;
  int _hikeLength = 0;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  String _imageUrl = 'null';
  final CollectionReference _reference =
  FirebaseFirestore.instance.collection('hike');
  String? startLocation;
  // String? endLocation;
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
    if (!_validateFields()) {
      print('Please fill all the required fields');
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
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });

    try {
      final user = _auth.currentUser;
      if (_imageFile != null) {
        Reference storageReference =
        _storage.ref().child('hikesImage/${DateTime.now()}.jpg');
        await storageReference.putFile(File(_imageFile!.path));
        _imageUrl = await storageReference.getDownloadURL();
      }
      await _reference.doc(widget.hikeId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': _imageUrl, // Assuming you want to keep the existing image
        'length': _hikeLength,
        'parking': _parking,
        'start': startLocation,
        // 'end': endLocation,
        'timings': date,
        'level': _starRating,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Update Successfully"),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHome(),
        ),
      );
      // Data updated successfully
    } catch (error) {
      print('Error updating data: $error');
    } finally {
      setState(() {
        _isLoading = false;
        _isSubmitting = false;
      });
    }
  }

  bool _validateFields() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _hikeLength <= 0 ||
        startLocation == null ||
        date == null ||
        _starRating <= 0) {
      return false;
    }
    return true;
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
    try {
      final DocumentSnapshot hikeSnapshot = await _reference.doc(hikeId).get();
      final hikeData = hikeSnapshot.data() as Map<String, dynamic>;

      if (hikeData != null) {
        setState(() {
          _titleController.text = hikeData['title'];
          _descriptionController.text = hikeData['description'];
          startLocation = hikeData['start'];
          date = hikeData['timings'].toDate(); // Assuming it's a DateTime
          _imageUrl = hikeData['imageUrl'];
          _parking = hikeData['parking'] ?? false;
          _hikeLength = hikeData['length'] ?? 0;
          _starRating = hikeData['level'] ?? 0.0;
        });
      }
    } catch (error) {
      print('Error loading hike data: $error');
    }
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
            onPressed: () {
              if (widget.hikeId != null) {
                _showConfirmationDialog('Update');
              } else {
                _showConfirmationDialog('Submit');
              }
            },
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
      : Container(
          alignment: Alignment.topCenter,
        child:  SingleChildScrollView(
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
                  if (_imageFile == null && _imageUrl != 'null')
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
                        child: Image.network(
                          _imageUrl,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
                  SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      // Parking Checkbox
                      Row(
                        children: [
                          Text(
                            'Parking:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Checkbox(
                            value: _parking,
                            onChanged: (value) {
                              setState(() {
                                _parking = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),

                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Hike Length (in kilometers)',
                            border: OutlineInputBorder(),
                          ),
                          // Remove onChanged callback
                          onChanged: (value) {
                            setState(() {
                              _hikeLength = int.tryParse(value) ?? 0;
                            });
                          },
                          // Use the controller to handle changes
                          controller: TextEditingController(text: _hikeLength.toString()),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 8),
                  _buildLocationRow(
                    title: 'Start Location:',
                    value: startLocation ?? 'Not selected',
                    color: Colors.blue,
                    onPressed: () => _selectLocation('start'),
                  ),
                  SizedBox(height: 8),
                  // _buildLocationRow(
                  //   title: 'End Location:',
                  //   value: endLocation ?? 'Not selected',
                  //   color: Colors.green,
                  //   onPressed: () => _selectLocation('end'),
                  // ),
                  // SizedBox(height: 5),
                  _buildDateRow(
                    title: 'Date:',
                    value: date != null
                        ? DateFormat('yyyy-MM-dd | HH:mm').format(date!)
                        : 'Not selected',
                    onPressed: _selectDateAndTime,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Difficulty level:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  StarRatingWidget(
                    onRatingChanged: (rating) {
                      setState(() {
                        _starRating = rating;
                      });
                    },
                    initialRating: _starRating,
                  ),


                ],

              ),
            ),
          ),

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
          child: const Text('Select Date Time'),
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
            // endLocation =
            // "Latitude: ${value['lat']}, Longitude: ${value['lng']}";
          }
        });
      }
    });
  }

  void _selectDateAndTime() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        setState(() {
          date = selectedDateTime;
        });
      }
    }
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
    if (!_validateFields()) {
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
        // 'end': endLocation,
        'timings': date,
        'parking': _parking,
        'length': _hikeLength,
        'level': _starRating,
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
class StarRatingWidget extends StatelessWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;

  const StarRatingWidget({
    Key? key,
    required this.initialRating,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            onRatingChanged(index + 1.0);
          },
          child: Icon(
            index < initialRating ? Icons.star : Icons.star_border,
            color: Colors.yellow,
            size: 40.0,
          ),
        );
      }),
    );
  }
}