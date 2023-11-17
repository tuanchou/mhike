import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mhike/widgets/reusable_widgets.dart';

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
  String _passwordError = '';
  String _emailError = '';
  bool isStrongPassword(String password) {
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
    );
    return emailRegex.hasMatch(email);
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: <Widget>[
                      reusableTextField("Enter Your Name",
                          Icons.person_outlined, false, _nameTextController),
                      SizedBox(
                        height: 20,
                      ),
                      reusableTextField("Enter Email", Icons.email_outlined,
                          false, _emailTextController),
                      Text(
                        _emailError,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      reusableTextField(
                        "Enter Password",
                        Icons.lock_outlined,
                        true,
                        _passwordTextController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      reusableTextField(
                          "Enter Confirm Password",
                          Icons.lock_outlined,
                          true,
                          _confirmPasswordTextController),
                      Text(
                        _passwordError,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      loginRegisterButton(context, false, () async {
                        if (isEmailValid(_emailTextController.text)) {
                          if (await isEmailRegistered(
                              _emailTextController.text)) {
                            setState(() {
                              _emailError = "Email address has been previously registered.";
                            });
                          } else {
                            if (_passwordTextController.text ==
                                _confirmPasswordTextController.text) {
                              if (isStrongPassword(
                                  _passwordTextController.text)) {
                                FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: _emailTextController.text,
                                        password: _passwordTextController.text)
                                    .then((userCredential) {
                                  String userID =
                                      userCredential.user?.uid ?? '';
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
                                  }).catchError((_passwordError) {
                                    print("Error saving user data: $_passwordError");
                                  });
                                }).catchError((_passwordError) {
                                  print("Error creating user: $_passwordError");
                                });
                              } else {
                                setState(() {
                                  _passwordError =
                                      "Password is not strong enough.\nPassword must include lowercase letters, uppercase letters, numbers and special characters.";
                                });
                              }
                            } else {
                              setState(() {
                                _passwordError = "Passwords do not match";
                              });
                            }
                          }
                        } else {
                          setState(() {
                            _emailError = "Email address is not valid.";
                          });
                        }
                      })
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Kiểm tra địa chỉ email đã tồn tại trong Firebase Authentication
  Future<bool> isEmailRegistered(String email) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password:
            'random_password', // Chỉ cần một mật khẩu tạm thời để kiểm tra địa chỉ email
      );
      // Nếu không có lỗi xảy ra, địa chỉ email chưa được đăng ký trước đó
      await userCredential.user?.delete(); // Xóa tài khoản tạm thời
      return false;
    } catch (e) {
      // Nếu có lỗi xảy ra, địa chỉ email đã được đăng ký trước đó
      return true;
    }
  }
}
