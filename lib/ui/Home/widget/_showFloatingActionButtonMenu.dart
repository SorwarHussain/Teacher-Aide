import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Course/create_course.dart';
import 'package:teacher_aide/ui/Course/joinCourse.dart';

void showFloatingActionButtonMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Join Class'),
              onTap: () {
                // Handle Join Class
                Navigator.pop(context); // Close the bottom sheet
                Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => JoinCoursePage()));
                // Add logic here for handling 'Join Class'
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create Class'),
              onTap: () {
                // Handle Create Class
                // Navigate to the addCourse page
                Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => CreateCourse()));
               
              },
            ),
          ],
        );
      },
    );
  }