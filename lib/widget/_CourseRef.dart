import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference createCourseReference() {
  return FirebaseFirestore.instance.collection('courses');
}