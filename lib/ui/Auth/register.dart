import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teacher_aide/ui/Auth/login_or_register.dart';

import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../../components/square_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? ontap;
  RegisterPage({super.key, required this.ontap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isTeacher = false;

  SignUserUp() async {
    print("aise");
    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        var authCredential = userCredential.user;
        print(authCredential!.uid);
        // Extract user ID
        String userId = authCredential!.uid;

        // Store user details in Firestore or Realtime Database
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': emailController.text,
          'isTeacher': _isTeacher,
          // Add other user details as needed
        });
        if (authCredential.uid.isNotEmpty) {
          Navigator.push(
              context, CupertinoPageRoute(builder: (_) => LoginOrRegister()));
        } else {
          Fluttertoast.showToast(msg: "Something is wrong");
          showErrorMessage("Something is wrong");
        }
      } else {
        Fluttertoast.showToast(msg: "Password don't match!");
        showErrorMessage("Password don't match!");
      }
    } on FirebaseAuthException catch (e) {
      /*if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        Fluttertoast.showToast(msg: "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Fluttertoast.showToast(
            msg: "The account already exists for that email.");
      }*/
      showErrorMessage(e.code);
    } catch (e) {
      print(e);
    }
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
                  "Let's create an account for you!",
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
                  height: 20,
                ),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obsecureText: true,
                ),
                SizedBox(
                  height: 10,
                ),
                 // User type selection
                ListTile(
                  title: Text('Are you a teacher?'),
                  trailing: Switch(
                    value: _isTeacher,
                    onChanged: (value) {
                      setState(() {
                        _isTeacher = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                MyButton(
                  ontap: SignUserUp,
                  buttonText: "Sign Up",
                ),
                 //if you implement 'google auth' then uncomment below code section.
               /* SizedBox(
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
                      "Already member?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.ontap,
                      child: Text(
                        "Login here",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    /*CupertinoButton(
                      onPressed: widget.ontap,
                      child: Text(
                        "Login here",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),*/
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
