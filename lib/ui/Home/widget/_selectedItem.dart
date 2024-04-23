import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Account/account.dart';
import 'package:teacher_aide/ui/Settings/setting_page.dart';

  //logout function
  void Logout() async {
    await FirebaseAuth.instance.signOut();
  }

void SelectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SettingPage()));
        break;
          case 2:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AccountPage()));
        break;
      case 1:
        Logout();
        break;
    }
  } 