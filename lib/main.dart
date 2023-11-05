import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mhike/screens/createhike.dart';
import 'package:mhike/screens/home.dart';
import 'package:mhike/screens/login.dart';
import 'package:mhike/screens/register.dart';
import 'package:mhike/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SafeArea(
      child: MaterialApp(
    initialRoute: 'home',
    debugShowCheckedModeBanner: false,
    routes: {
      'splash': (context) => const MySplash(),
      'login': (context) => const MyLogin(),
      'register': (context) => const MyRegister(),
      'home': (context) => const MyHome(),
    },
  )));
}
