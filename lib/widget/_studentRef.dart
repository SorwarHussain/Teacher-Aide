import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference createStudentReference() {
  return FirebaseFirestore.instance.collection('students');
}