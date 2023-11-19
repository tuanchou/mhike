import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mhike/widgets/reusable_widgets.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/login.png',
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).size.height * 0.55, 20, 0),
                  child: Column(
                    children: <Widget>[
                      reusableTextField('Enter Email', Icons.email_outlined, false,
                          _emailTextController),
                      const SizedBox(
                        height: 10,
                      ),
                      reusableTextField('Enter Password', Icons.lock_outline, true,
                          _passwordTextController),
                      const SizedBox(
                        height: 10,
                      ),
                      loginRegisterButton(context, true, () {
                        // Validate email and password before attempting to sign in
                        String email = _emailTextController.text.trim();
                        String password = _passwordTextController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          showErrorMessage('Email and password cannot be empty');
                          return;
                        }

                        if (!_isValidEmail(email)) {
                          showErrorMessage('Invalid email format');
                          return;
                        }

                        // Sign in with Firebase Auth
                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                            email: email, password: password)
                            .then((value) {
                          Navigator.pushNamed(context, 'home');
                        }).catchError((e) {
                          // Handle authentication failure
                          showErrorMessage('Invalid email or password');
                        });
                      }),
                      registerOption(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
  bool _isValidEmail(String email) {
    // Regular expression for email validation
    final emailRegExp = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  void showErrorMessage(String message) {
    // Show toast or snackbar with error message
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Row registerOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have account?",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'register');
          },
          child: const Text(
            " Register",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
