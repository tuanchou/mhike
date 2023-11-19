// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MySplash extends StatefulWidget {
  const MySplash({super.key});


  @override
  State<MySplash> createState() => _MySplash();
}

class _MySplash extends State<MySplash> with TickerProviderStateMixin{
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // _navigateSplash();
  }
  @override
  void dispose() {
    super.dispose();
  }

/*  _navigateSplash() async {
    await Future.delayed(const Duration(milliseconds: 1500), (){});
    Navigator.pushNamed(context, 'login');
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network("https://lottie.host/11f3f724-ab88-4dba-901f-efc3ee8ae2f2/bjzphIuPrg.json",
              controller: _controller,
              onLoaded: (compos) {
                _controller
                  ..duration = compos.duration
                  ..forward().then((value) {
                    Navigator.pushNamed(context, 'login');
                  });
              }
          ),
        ],
      ),
    );
  }
}
