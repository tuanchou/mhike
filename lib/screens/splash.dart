// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class MySplash extends StatefulWidget {
  const MySplash({super.key});


  @override
  State<MySplash> createState() => _MySplash();
}

class _MySplash extends State<MySplash> {
  @override
  void initState() {
    super.initState();
    _navigateSplash();
  }

  _navigateSplash() async {
    await Future.delayed(const Duration(milliseconds: 1500), (){});
    Navigator.pushNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: const Text('Splash Screen',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}
