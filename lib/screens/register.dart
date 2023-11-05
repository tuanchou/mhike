import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mhike/reusable_widgets/reusable_widgets.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmPasswordTextController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFAB815A)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Register",
          style: TextStyle(
            color: Color(0xFFAB815A),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/register.png',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 290, 20, 0),
                child: Column(
                  children: <Widget>[
                    reusableTextField("Enter Your Name", Icons.person_outlined,
                        false, _nameTextController),
                    SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Email", Icons.email_outlined,
                        false, _emailTextController),
                    SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Password", Icons.lock_outlined,
                        true, _passwordTextController),
                    SizedBox(
                      height: 20,
                    ),
                    reusableTextField(
                        "Enter Confirm Password",
                        Icons.lock_outlined,
                        true,
                        _confirmPasswordTextController),
                    SizedBox(
                      height: 20,
                    ),
                    loginRegisterButton(context, false, () {
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((userCredential) {
                        String userID = userCredential.user?.uid ?? '';
                        FirebaseFirestore.instance
                            .collection('user-info')
                            .doc(userID)
                            .set({
                          'UserID': userID,
                          'Name': _nameTextController.text,
                          'Email': _emailTextController.text,
                          'Address': null,
                          'DoB': null,
                          'Gender': null,
                          'Avatar': null,
                        }).then((_) {
                          Navigator.pushNamed(context, 'login');
                        }).catchError((error) {
                          print("Error saving user data: $error");
                        });
                      }).catchError((error) {
                        print("Error creating user: $error");
                      });
                    })
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
