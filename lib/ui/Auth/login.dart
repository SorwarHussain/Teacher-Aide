import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teacher_aide/ui/Auth/auth_page.dart';

import '../../components/my_button.dart';
import '../../components/my_textfield.dart';


class LoginPage extends StatefulWidget {
  final Function()? ontap;
  LoginPage({super.key, required this.ontap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void SignUserIn() async {
    /*showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );*/
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      //circular progress indicator terminate
     // Navigator.pop(context);
      var authCredential = userCredential.user;
      print(authCredential!.uid);
     if (authCredential.uid.isNotEmpty && mounted) {
      Navigator.push(context, CupertinoPageRoute(builder: (_) => AuthPage()));
    } else {
        Fluttertoast.showToast(msg: "Something is wrong");
        //showErrorMessage("Something is wrong");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      //showErrorMessage(e.code);
    }
    //Navigator.pop(context);
  }

  //error message
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Icon(Icons.lock, size: 100),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Welcome to our Login Page",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                SizedBox(
                  height: 25,
                ),
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obsecureText: false,
                ),
                SizedBox(
                  height: 20,
                ),
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obsecureText: true,
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forget Password?",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                MyButton(
                  ontap: SignUserIn,
                  buttonText: "Sign In",
                ),
                //if you implement 'google auth' then uncomment below code section.
                /*SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Text(
                      "Or Continue With",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(imagePath: "assets/images/google.png"),
                    SizedBox(
                      width: 25,
                    ),
                    SquareTile(imagePath: "assets/images/facebook.png"),
                  ],
                ),*/
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.ontap,
                      child: Text(
                        "Register now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
