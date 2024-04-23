import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Home/home.dart';
import 'package:teacher_aide/ui/Auth/login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user is loged in
            if (snapshot.hasData) {
              return Home();
            }
            //user not loged in
            else {
              return LoginOrRegister();
            }
          }),
    );
  }
}
