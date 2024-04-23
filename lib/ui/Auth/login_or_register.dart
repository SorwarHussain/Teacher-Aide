import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Auth/login.dart';
import 'package:teacher_aide/ui/Auth/register.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(ontap: togglePages);
    } else {
      return RegisterPage(ontap: togglePages);
    }
  }
}
