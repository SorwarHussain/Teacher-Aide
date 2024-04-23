import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference createUserReference() {
  return FirebaseFirestore.instance.collection('users');
}