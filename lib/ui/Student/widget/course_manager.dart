import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Student/widget/Student.dart';
import 'package:teacher_aide/widget/_studentCourseMappingRef.dart';
import 'package:teacher_aide/widget/_studentRef.dart';


// course_manager.dart
class CourseManager {
  final TextEditingController _nameController= TextEditingController();
  final TextEditingController _rollController= TextEditingController();
  final TextEditingController _emailController= TextEditingController();
  final TextEditingController _phoneController= TextEditingController();

  CourseManager(String id);

  // Getter methods to access controllers
  TextEditingController get nameController => _nameController;
  TextEditingController get rollController => _rollController;
    TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;

  Future<void> addStudent(BuildContext context,String courseId) async {
    try {
      String studentName = _nameController.text;
      int studentRoll = int.tryParse(_rollController.text) ?? 0;
      String studentEmail = _emailController.text;
      String studentPhone = _phoneController.text;
      if (studentName.isNotEmpty && studentRoll > 0) {
        // Check if the student is already associated with the course
        final studentCourseMappingSnapshot = await createStudentCourseMappingReference()
            .where('studentId', isEqualTo: studentRoll)
            .where('courseId', isEqualTo: courseId)
            .get();

        if (studentCourseMappingSnapshot.docs.isNotEmpty) {
          print('Student with roll number $studentRoll is already associated with the course. Skipping...');
          return; // Skip adding the student to the course
        }

        final studentSnapshot = await createStudentReference()
        .where('roll', isEqualTo: studentRoll)
        .get();

        // If the student already exists, skip adding them
        if (studentSnapshot.docs.isNotEmpty) {
          await createStudentCourseMappingReference().add({
          'studentId': studentRoll,
          'courseId': courseId,
          });
          print('Student with roll number $studentRoll already exists. Skipping...');
          return;
        }
        Student newStudent = Student(studentName, studentRoll,email: studentEmail, phone: studentPhone);
        await createStudentReference().add(newStudent.toMap());
        await createStudentCourseMappingReference().add({
          'studentId': studentRoll,
          'courseId': courseId,
        });
        print("Successfully added a new student to the course");
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Wow! Successfully Added all new students to this course.'),
          ),
        );
      } else {
        print("Invalid input for student name or roll");
      }
    } catch (e) {
      print("Error adding student to the course: $e");
    }
     // Clear controllers after adding the student
    _nameController.clear();
    _rollController.clear();
    _emailController.clear();
    _phoneController.clear();
  }

  // Dispose controllers to prevent memory leaks
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

  }
}
