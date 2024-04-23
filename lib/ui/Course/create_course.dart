import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Course/data/addedCourse.dart';
import 'package:teacher_aide/ui/Course/widget/Course.dart';

class CreateCourse extends StatefulWidget {
  const CreateCourse({super.key});

  @override
  State<CreateCourse> createState() => _CreateCourseState();
}

class _CreateCourseState extends State<CreateCourse> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  TextEditingController _sessionController = TextEditingController();
  //TextEditingController _deptContString? _selectedDepartment;
   // Variable to store the selected department
   String? _selectedDepartment;
  String? _selectedSession;
  late List<String> sessions;

  // List of departments for the dropdown menu
  List<String> departments = [
    'ARC', 'CEP', 'CEE', 'CSE', 'EEE', 'FET', 'IPE', 'MEE', 'PME', 'SWE',
    'BMB', 'GEB', 'FES', 'CHE', 'GEE', 'MAT', 'PHY', 'STA', 'OCG', 'BBA',
    'ANP', 'BNG', 'ECO', 'ENG', 'PSS', 'PAD', 'SCW', 'SOC',
  ];
  void addedCourse1(){
   final FirebaseAuth _auth = FirebaseAuth.instance;
    var currentUser = _auth.currentUser;
    Course newCourse = Course(
      _titleController.text,
      _codeController.text,
      _selectedDepartment!, // Use the selected department
      _sessionController.text,
      currentUser!.email.toString(),
    );
    addCourse(newCourse);
    Navigator.pop(context);
  }
   String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your course title.';
    } else if (value.length < 3) {
      return 'Title must be at least 3 characters long.';
    }
    else if (value.length > 100) {
      return 'Title must be at most 100 characters long.';
    }
    return null;
  }

  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your course code.';
    } else if (value.length < 3) {
      return 'Code must be at least 3 characters long.';
    }
    else if (value.length > 10) {
      return 'Title must be at most 10 characters long.';
    }
    return null;
  }
  
  @override
void initState() {
  super.initState();
  _selectedDepartment = departments.isNotEmpty ? departments[0] : null;
  // _generateSessions();
   // _selectedSession = sessions.isNotEmpty ? sessions[0] : null;
}
    void _generateSessions() {
    int currentYear = DateTime.now().year-1;
    sessions = List.generate(5, (index) => (currentYear - index).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create New Course'),
        ),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      controller: _titleController,
                      validator: _validateTitle,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Course Title',
                        hintText: 'Course Title',
                      ),
                    ),
                  ),
                 Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: _codeController,
                  validator: _validateCode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Course Code',
                    hintText: 'Course Code',
                  ),
                ),
              ),
                 // Dropdown for selecting department
            Padding(
              padding: EdgeInsets.all(15),
              child: DropdownButtonFormField<String>(
                value: _selectedDepartment,
                onChanged: (newValue) {
                  setState(() {
                    _selectedDepartment = newValue!;
                  });
                },
                items: departments.map((department) {
                  return DropdownMenuItem(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Department',
                  hintText: 'Select Department',
                ),
              ),
            ),

                         Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: _sessionController,
                  //validator: _validateSession, this field is optional
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Session',
                    hintText: 'e.g., 2017-18',
                  ),
                ),
              ),
                     // Dropdown for selecting session
             /* Padding(
                padding: const EdgeInsets.all(15),
                child: DropdownButtonFormField<String>(
                  value: _selectedSession,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSession = newValue!;
                    });
                  },
                  items: sessions.map((session) {
                    return DropdownMenuItem(
                      value: session,
                      child: Text(session),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Session',
                    hintText: 'Select Session',
                  ),
                ),
              ),*/
                  CupertinoButton.filled(
                      onPressed: () {
                        String? titleError = _validateTitle(_titleController.text);
                        String? codeError = _validateCode(_codeController.text);
                        if (titleError == null && codeError == null) {
                          addedCourse1();
                        } else {
                          String errorMessage = '';
                          if (titleError != null) {
                            errorMessage += titleError + '\n';
                          }
                          if (codeError != null) {
                            errorMessage += codeError + '\n';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                            ),
                          );
                        }
                      },
                        child: Text(
                        "Create",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            )));
  }
}
