import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Auth/auth_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teacher Aide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal, // Set desired background color here
          //color: Colors.white,
        ),
      ),
      //theme: ThemeData(scaffoldBackgroundColor: Colors.green),
      home: const AuthPage(),
    );
  }
}
