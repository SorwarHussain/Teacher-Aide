import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Student/widget/Student.dart';
import 'package:teacher_aide/widget/_studentCourseMappingRef.dart';
import 'package:teacher_aide/widget/_studentRef.dart';

//file upload part
Future addData(BuildContext context,course, List<List> _data) async {
    for (var element
        in _data) {
    final studentName=element[0];
    final studentRoll = element[1];
    int rollNumber=studentRoll is String ? int.tryParse(studentRoll) ?? 0 : studentRoll;
      // Check if the student is already associated with the course
        final studentCourseMappingSnapshot = await createStudentCourseMappingReference()
            .where('studentId', isEqualTo: rollNumber)
            .where('courseId', isEqualTo: course.id)
            .get();

        if (studentCourseMappingSnapshot.docs.isNotEmpty) {
          print('Student with roll number $rollNumber is already associated with the course. Skipping...');
          continue; // Skip adding the student to the course
        }
    // Check if the student with this roll number already exists
    final studentSnapshot = await createStudentReference()
        .where('roll', isEqualTo: rollNumber)
        .get();

    // If the student already exists, skip adding them to students
    if (studentSnapshot.docs.isNotEmpty) {
       await createStudentCourseMappingReference().add({
      'studentId': rollNumber,
      'courseId': course.id,
    });
      print('Student with roll number $rollNumber already exists. Skipping...');
      continue;
    }
   
       // Creating a new student object
    Student newStudent;
    if (element.length > 2) {
      final studentEmail = element[2];
      final studentPhone = element.length > 3 ? element[3] : ''; // Phone is optional
      newStudent = Student(studentName, rollNumber, email: studentEmail, phone: studentPhone);
    } else {
      newStudent = Student(studentName, rollNumber);
    }

    // Adding the new student to Firestore
   await createStudentReference().add(newStudent.toMap());
    await createStudentCourseMappingReference().add({
      'studentId': rollNumber,
      'courseId': course.id,
    });
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
          'Wow! Successfully Added all new students to this course.'),
    ),
  );
  print("Wow! Successfully Added all new students");
    
  }