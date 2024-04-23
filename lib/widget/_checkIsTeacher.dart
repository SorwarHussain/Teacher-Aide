import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> checkIsTeacher() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String uid = user.uid;

    // Use await to get the actual value from the Future<bool>
    bool isTeacher = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) => doc['isTeacher'] ?? false);

    return isTeacher;
  }
  return false;
}
