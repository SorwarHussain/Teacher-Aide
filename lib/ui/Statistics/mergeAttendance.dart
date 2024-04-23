import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Statistics/statisticsMerge.dart';

class MergeAttendance extends StatefulWidget {
  @override
  _MergeAttendanceState createState() => _MergeAttendanceState();
}

class _MergeAttendanceState extends State<MergeAttendance> {
  final TextEditingController _courseCodeController = TextEditingController();
  List<String> _selectedCourses = [];
  var currentUser = FirebaseAuth.instance.currentUser;

  Future<void> mergeCourse(BuildContext context) async {
     Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => StatisticsMerge(
        selectedCourses: _selectedCourses,
      )));
    try {
      for (String courseId in _selectedCourses) {
        // Process each selected course
       // String courseTitle = courseSnapshot['title'];
       // print('Merging attendance for course: $courseTitle');
        // Implement the logic to merge attendance for this course
      }

      // Show success message or navigate to the student's dashboard
    } catch (e) {
      // Handle errors
      print('Error merging courses: $e');
      // Show an error message to the user
    }
  }
  bool? isChecked=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merge Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Select Courses to Merge:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .where('instructor', isEqualTo: currentUser?.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final courses = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final courseSnapshot = courses[index];
                      final courseTitle = courseSnapshot['title'];
                      return CheckboxListTile(
  title: Text(courseTitle),
  value: _selectedCourses.contains(courseSnapshot.id),
  onChanged: (bool? newValue) {
    setState(() {
      if (newValue != null) {     
        if (newValue) {
         // Checkbox is checked, add the course ID if not already present
        String courseId = courseSnapshot.id;
        if (!_selectedCourses.contains(courseId)) {
          _selectedCourses.add(courseId);
        }
        }  
      }
      else {
            // Checkbox is unchecked, remove the course ID if present
            String courseId = courseSnapshot.id;
            _selectedCourses.remove(courseId);
      }
    });
  },
  activeColor: Colors.red,
  checkColor: Colors.white,
  tileColor: Colors.black12,
  tristate: true,
);

                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _selectedCourses.isNotEmpty ? () => mergeCourse(context) : null,
                style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 3, 66, 117), // Change the background color here
                ),
                child: Text('Merge Selected Courses', style: TextStyle(fontSize: 18,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}







