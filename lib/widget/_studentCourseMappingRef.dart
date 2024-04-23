import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference createStudentCourseMappingReference() {
  return FirebaseFirestore.instance.collection('student_course_mapping');
}