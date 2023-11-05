import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _imageURL = '';
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('user-info');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _dob;
  bool? gender;
  File? _pickedImage;
  final _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Lấy thông tin người dùng đã đăng nhập từ Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Sử dụng UserID từ Authentication để truy vấn Firestore
        final DocumentSnapshot userSnapshot = await _user.doc(user.uid).get();
        final userData = userSnapshot.data() as Map<String, dynamic>;

        if (userData != null) {
          setState(() {
            _nameController.text = userData['Name'] ?? '';
            _addressController.text = userData['Address'] ?? '';
            _emailController.text = userData['Email'] ?? '';
            if (userData['DoB'] != null) {
              _dob = DateTime.parse(userData['DoB']);
            }
            gender = userData['Gender'] ?? false;
            _imageURL = userData['Avatar'];
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String newName = _nameController.text;
      final String newAddress = _addressController.text;
      final String newDoB = _dob?.toIso8601String() ?? '';

      try {
        Reference storageReference =
            _storage.ref().child('UserAvatar/${DateTime.now()}.jpg');
        await storageReference.putFile(File(_imageFile!.path));
        String imageUrl = await storageReference.getDownloadURL();
        await _user.doc(user.uid).update({
          'Name': newName,
          'Address': newAddress,
          'DoB': newDoB,
          'Gender': gender,
          'Avatar': imageUrl
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
  }

  Future<void> _pickImage() async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  _imageFile != null
                      ? Image.file(
                          File(_imageFile!.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : _imageURL.isNotEmpty
                          ? Image.network(
                              _imageURL,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.account_circle,
                              size: 100, color: Colors.grey),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Change Avatar'),
                  ),
                ])),
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
            Row(children: [
              const Text(
                'Date:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _dob != null
                    ? DateFormat('yyyy-MM-dd').format(_dob!)
                    : 'Not selected',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 54, 244, 105),
                ),
              ),
              SizedBox(width: 5),
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
                        _dob = value;
                      });
                    }
                  });
                },
                child: const Text('Select Date'),
              ),
            ]),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const Text(
                  "Gender: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Checkbox(
                  value: gender ?? false,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
                Text("Male"),
                Checkbox(
                  value: gender == false,
                  onChanged: (value) {
                    setState(() {
                      gender = !value!;
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
