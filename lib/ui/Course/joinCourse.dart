import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_aide/widget/_fetchUserInfo.dart';

class JoinCoursePage extends StatefulWidget {
  @override
  _JoinCoursePageState createState() => _JoinCoursePageState();
}

class _JoinCoursePageState extends State<JoinCoursePage> {
  final TextEditingController _courseCodeController = TextEditingController();
  late String name;
  late int rollNumber;
  
   

  Future<void> joinCourse() async {
    try {
      // Retrieve course information from Firestore
      DocumentSnapshot<Map<String, dynamic>> courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(_courseCodeController.text.trim())
          .get();

      if (courseSnapshot.exists) {
        // Course exists, add student to the course
        String courseId = courseSnapshot.id;
        String courseTitle = courseSnapshot['title'];
        int studentRoll=rollNumber;
        // Check if the student is already enrolled in the course
      QuerySnapshot<Map<String, dynamic>> existingMapping = await FirebaseFirestore.instance
          .collection("student_course_mapping")
          .where('studentId', isEqualTo: studentRoll)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (existingMapping.docs.isNotEmpty) {
        throw Exception("Already enrolled in the course");
      }
       // Create a new mapping entry to represent the student's enrollment
      await FirebaseFirestore.instance.collection("student_course_mapping").add({
        'studentId': studentRoll,
        'courseId': courseId,
      });

        // Show success message or navigate to the student's dashboard
        print('Successfully joined the course: $courseTitle');
      } else {
        // Course not found
        print('Course not found with code: ${_courseCodeController.text}');
        // Show an error message to the user
      }
    } catch (e) {
      // Handle errors
      print('Error joining course: $e');
      // Show an error message to the user
    }
  }
   @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  Future<void> fetchUserData() async {
    await userInfoManager.fetchUserInfo();
    // Access values
    name = userInfoManager.name;
    rollNumber = userInfoManager.rollNumber;
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Join Course'),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.class_,
              size: 80,
              color: Color.fromARGB(255, 3, 66, 117),
            ),
            SizedBox(height: 24.0),
            Text(
              'Enter Course Code',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _courseCodeController,
              decoration: InputDecoration(
                hintText: 'e.g., ABC123',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: joinCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 3, 66, 117),
                padding: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Join Course',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
