import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference createAttendanceReference() {
  return FirebaseFirestore.instance.collection('class');
}