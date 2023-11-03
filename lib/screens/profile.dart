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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: Image.asset("assets/images/register.png", fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: IconButton(
                      onPressed: () {
                        // Add image picker logic here.
                      },
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.indigo,
                      ),
                    ),
                    bottom: -5,
                    left: 80,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.indigo),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Enter your name",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.person),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {},
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.indigo),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Enter your email",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.email),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {},
                ),
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Address",
                labelStyle: TextStyle(color: Colors.indigo),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Enter your address",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {},
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add logic to handle form submission here.
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
            )
          ],
        ),
      ),
    );

  }
}