import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('user-info');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _dob;
  bool? _isMale;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final DocumentSnapshot userSnapshot =
          await _user.doc('vrgInyw3y5KtLJQdDaFq').get();
      final userData = userSnapshot.data() as Map<String, dynamic>;

      if (userData != null) {
        setState(() {
          _nameController.text = userData['Name'] ?? '';
          _addressController.text = userData['Address'] ?? '';
          _emailController.text = userData['Email'] ?? '';
          if (userData['DoB'] != null) {
            _dob = DateTime.parse(userData['DoB']);
          }
          _isMale = userData['isMale'] ?? false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateUserData() async {
    final String newName = _nameController.text;
    final String newAddress = _addressController.text;
    final String newDoB = _dob?.toIso8601String() ?? '';

    try {
      await _user.doc('vrgInyw3y5KtLJQdDaFq').update({
        'Name': newName,
        'Address': newAddress,
        'DoB': newDoB,
        'Gender': _isMale,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User data updated successfully',
          ),
        ),
      );
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 3.0),
                    // ... rest of your code for avatar
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  // Customize the label color
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.indigo), // Customize border color
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.indigo), // Customize focused border color
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  prefixIcon:
                      Icon(Icons.account_circle), // Add an icon as a prefix
                  suffixIcon: IconButton(
                    icon: Icon(
                        Icons.clear), // Add a clear button as a suffix icon
                    onPressed: () {
                      _nameController.clear();
                    },
                  ),
                )),
            SizedBox(
              height: 5,
            ),
            TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  // Customize the label color
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.indigo), // Customize border color
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.indigo), // Customize focused border color
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  prefixIcon:
                      Icon(Icons.location_on), // Add an icon as a prefix
                  suffixIcon: IconButton(
                    icon: Icon(
                        Icons.clear), // Add a clear button as a suffix icon
                    onPressed: () {
                      _addressController.clear();
                    },
                  ),
                )),
            SizedBox(height: 5),
            TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  // Customize the label color
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.indigo), // Customize border color
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.indigo), // Customize focused border color
                    borderRadius:
                        BorderRadius.circular(10.0), // Add border radius
                  ),
                  prefixIcon: Icon(Icons.email), // Add an icon as a prefix
                  suffixIcon: IconButton(
                    icon: Icon(
                        Icons.clear), // Add a clear button as a suffix icon
                    onPressed: () {
                      _emailController.clear();
                    },
                  ),
                )),
            SizedBox(height: 5),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                  text: _dob != null ? _dob.toString() : ''),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: _dob ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                ).then((pickedDate) {
                  if (pickedDate != null && pickedDate != _dob) {
                    setState(() {
                      _dob = pickedDate;
                    });
                  }
                });
              },
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text("Gender: "),
                Checkbox(
                  value: _isMale ?? false,
                  onChanged: (value) {
                    setState(() {
                      _isMale = value;
                    });
                  },
                ),
                Text("Male"),
                Checkbox(
                  value: _isMale == false,
                  onChanged: (value) {
                    setState(() {
                      _isMale = !value!;
                    });
                  },
                ),
                Text("Female"),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _updateUserData();
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Update",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
