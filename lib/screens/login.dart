import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mhike/widgets/reusable_widgets.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
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
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text)
                        .then((value) {
                      Navigator.pushNamed(context, 'home');
                    })
                        .catchError((error) {
                      if (error.code == 'user-not-found') {
                        // Thông báo cho người dùng rằng email chưa được đăng ký
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Email has not been registered.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (error.code == 'wrong-password') {
                        // Thông báo cho người dùng rằng mật khẩu không đúng
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Incorrect password.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Xử lý các trường hợp lỗi khác
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text(error.message),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
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
