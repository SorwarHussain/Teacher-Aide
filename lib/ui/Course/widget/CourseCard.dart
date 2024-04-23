import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Attendance/widget/_createAttendanceRef.dart';


import 'package:teacher_aide/ui/Course/courseDetails.dart';
import 'package:teacher_aide/ui/Course/widget/_showItemMenuOnLongPress.dart';
import 'package:teacher_aide/widget/_studentCourseMappingRef.dart';


class CourseCard extends StatefulWidget {
  final DocumentSnapshot document;
  bool isTeacher;
  CourseCard({required this.document,required this.isTeacher});

  @override
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  int totalStudents = 0;
  int totalTakenClasses = 0;

  @override
  void initState() {
    super.initState();
    fetchTakenClasses();
    fetchTotalStudents();
  }
  //taken classes
  Future<void> fetchTakenClasses() async {
    try {
      QuerySnapshot classesSnapshot = await createAttendanceReference()
      .where('courseId', isEqualTo: widget.document.id)
      .get();
      setState(() {
        totalTakenClasses = classesSnapshot.size;
      });
    } catch (e) {
      print("Error fetching total students: $e");
    }
  }
  //total students
  Future<void> fetchTotalStudents() async {
    try {
      QuerySnapshot studentsSnapshot = await createStudentCourseMappingReference()
      .where('courseId', isEqualTo: widget.document.id)
      .get();
      setState(() {
        totalStudents = studentsSnapshot.size;
      });
    } catch (e) {
      print("Error fetching total students: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      clipBehavior: Clip.hardEdge,
      color: Color.fromARGB(255, 72, 82, 78),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => courseDetails(course: widget.document),
            ),
          );
        },
        onDoubleTap: () {
          //implement feature here
        },
        onLongPress: () {
          if(widget.isTeacher){
          // Show menu on long press
          showItemMenuOnLongPress(context,widget.document.reference);
          }
        },
        splashColor: Colors.green,
        highlightColor: Colors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                " ${widget.document['title']}",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20, top: 0),
              child: Text(
                "${widget.document['code']}",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "$totalTakenClasses Classes", //the actual class count
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "$totalStudents", // Display the totalStudents
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

