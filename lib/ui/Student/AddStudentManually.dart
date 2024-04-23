import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Student/widget/course_manager.dart';

class AddStudentManual extends StatefulWidget {
  DocumentSnapshot<Object?> course;
  AddStudentManual({super.key, required this.course});

  @override
  State<AddStudentManual> createState() => _AddStudentManualState();
}

class _AddStudentManualState extends State<AddStudentManual> {
  late CourseManager _courseManager;

  @override
  void initState() {
    super.initState();
    _courseManager = CourseManager(widget.course.id);
  }
  @override
  void dispose() {
    _courseManager.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Students'),
        ),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(widget.course['title']),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      controller: _courseManager.nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Student Name',
                        hintText: 'Student Name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      controller: _courseManager.rollController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Registration Number',
                        hintText: 'Registration Number',
                      ),
                    ),
                  ),
                     Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      controller: _courseManager.emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Email',
                        hintText: 'Email',
                      ),
                    ),
                  ),
                     Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      controller: _courseManager.phoneController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Phone Number',
                        hintText: 'Phone Number',
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(                      
                        children: [                          
                          ElevatedButton(
                            onPressed: () {
                              _courseManager.addStudent(context,widget.course.id).then((value) {
                              Navigator.pop(context);
                            });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 3, 66, 117), // Change the background color here
                            ),
                            child: Text('Save', style: TextStyle(fontSize: 18,color: Colors.white)),
                         ),
                         SizedBox(width:10 ,),
                          ElevatedButton(
                            onPressed: () {
                              _courseManager.addStudent(context,widget.course.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 3, 66, 117), // Change the background color here
                            ),
                            child: Text('Save and add another', style: TextStyle(fontSize: 18,color: Colors.white)),
                         ),                       
                        ],
                    ),
                  )
                  
                ],
              ),
            )));
  }
}
