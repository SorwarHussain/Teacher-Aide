import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_aide/ui/Course/widget/Course.dart';

Future<void> addCourse(Course course) async {
  try {
    await FirebaseFirestore.instance.collection('courses').add({
      'title': course.title,
      'code':course.code,
      'department':course.department,
      'session':course.session,
      'instructor': course.instructor,
      // Add more fields as needed
    });
    print('Course added successfully!');
  } catch (e) {
    print('Error adding course: $e');
  }
}
