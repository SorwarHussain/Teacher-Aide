import 'package:firebase_auth/firebase_auth.dart';

Future<String> fetchUid() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      print(uid);
      return uid;
    } else {
      return 'User not authenticated';
    }
  }