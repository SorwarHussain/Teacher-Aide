import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showEditDialogCourse(BuildContext context, DocumentReference<Object?> reference) {
  TextEditingController titleController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController _sessionController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedSession;
  late List<String> sessions;
   List<String> departments = [
    'ARC', 'CEP', 'CEE', 'CSE', 'EEE', 'FET', 'IPE', 'MEE', 'PME', 'SWE',
    'BMB', 'GEB', 'FES', 'CHE', 'GEE', 'MAT', 'PHY', 'STA', 'OCG', 'BBA',
    'ANP', 'BNG', 'ECO', 'ENG', 'PSS', 'PAD', 'SCW', 'SOC',
  ];
  void _generateSessions() {
    int currentYear = DateTime.now().year - 1;
    sessions = List.generate(5, (index) => (currentYear - index).toString());
  }
 // _generateSessions();
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
  reference.get().then((DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      String existingTitle = snapshot['title'];
      String existingCode = snapshot['code'];
      String existingDept = snapshot['department'];
      //String existingSession = snapshot['session'];
      String existingSession = snapshot['session'];
      titleController.text = existingTitle;
      codeController.text = existingCode;
      _selectedDepartment = existingDept;
      //_selectedSession = existingSession;
      _sessionController.text=existingSession;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Course',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                        controller: titleController,
                        validator: _validateTitle,
                      decoration: InputDecoration(
                        labelText: 'Course Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                   TextFormField(
                    controller: codeController,
                    validator: _validateCode,
                      decoration: InputDecoration(
                        labelText: 'Course Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      onChanged: (newValue) {
                        _selectedDepartment = newValue!;
                      },
                      items: departments.map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                        Padding(
                padding: const EdgeInsets.all(0),
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
                   /* DropdownButtonFormField<String>(
                      value: _selectedSession,
                      onChanged: (newValue) {
                        _selectedSession = newValue!;
                      },
                      items: sessions.map((session) {
                        return DropdownMenuItem(
                          value: session,
                          child: Text(session),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Session',
                        border: OutlineInputBorder(),
                      ),
                    ),*/
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            String? titleError = _validateTitle(titleController.text);
                          String? codeError = _validateCode(codeController.text);
                          if (titleError == null && codeError == null) {
                             _updateCourse(context, reference, {
                              'title': titleController.text,
                              'code': codeController.text,            
                              'department': _selectedDepartment,
                              'session': _sessionController.text,
                            });
                            Navigator.of(context).pop();
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
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course does not exist'),
        ),
      );
    }
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error in Editing course : $error'),
      ),
    );
  });
}

void _updateCourse(BuildContext context, DocumentReference documentReference, Map<String, dynamic> data) {
  documentReference.update(data).then((value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course updated successfully!'),
      ),
    );
  }).catchError((error) {
    print('Error updating course: $error');
  });
}
