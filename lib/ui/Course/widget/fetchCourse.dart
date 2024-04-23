import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Course/data/CourseService.dart';
import 'package:teacher_aide/ui/Course/widget/CourseCard.dart';


Widget fetchCourse(bool isTeacher, int rollNumber) {
  CourseService _courseService = CourseService();
   if (isTeacher) {
    // Fetch courses for the teacher
    return StreamBuilder(
      stream: _courseService.fetchTeacherCourses(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Something is wrong"),
        );
      }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (_, index) {
            DocumentSnapshot _documentSnapshot = documents[index];

            return CourseCard(document: _documentSnapshot,isTeacher:isTeacher);
          },
        );
      },
    );
  } else {
     // Fetch courses for the student
  return StreamBuilder<List<DocumentSnapshot>>(
    stream: _courseService
        .fetchStudentEnrolledCourseIds(rollNumber)
        .asyncMap((courseIds) => _courseService.fetchStudentEnrolledCourses(courseIds).first),
    builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Something is wrong"),
        );
      }

      if (!snapshot.hasData) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      List<DocumentSnapshot> documents = snapshot.data!;

      return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (_, index) {
          DocumentSnapshot _documentSnapshot = documents[index];

          return CourseCard(document: _documentSnapshot,isTeacher:isTeacher);
        },
      );
    },
  );
}
}

