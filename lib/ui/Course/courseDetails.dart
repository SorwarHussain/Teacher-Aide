import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:teacher_aide/ui/Course/widget/_takenClasses.dart';
import 'package:teacher_aide/ui/Course/widget/appBar.dart';
import 'package:teacher_aide/ui/Attendance/new_class.dart';
import 'package:teacher_aide/ui/Statistics/statisticsAnother.dart';
import 'package:teacher_aide/widget/_checkIsTeacher.dart';


import 'package:teacher_aide/ui/Course/widget/FileStorage.dart';
import 'package:teacher_aide/ui/Course/widget/_importExcelFile.dart';
import 'package:teacher_aide/ui/Course/widget/_pickFileCSV.dart';
import 'package:teacher_aide/ui/Settings/courseSettingsPage.dart';
import 'package:teacher_aide/ui/Statistics/Statistics.dart';
import 'package:teacher_aide/ui/Statistics/mergeAttendance.dart';
import 'package:teacher_aide/ui/Student/AddStudentManually.dart';
import 'package:teacher_aide/ui/Student/fetchStudents.dart';

class courseDetails extends StatefulWidget {
  final DocumentSnapshot<Object?> course;
  courseDetails({super.key, required this.course});

  @override
  State<courseDetails> createState() => _courseDetailsState();
}

class _courseDetailsState extends State<courseDetails> {  
  late DocumentReference courseReference; 
  bool isTeacher=false;
  
  @override
  void initState() {
    super.initState();  
       // Perform the asynchronous operation here
    checkIsTeacher().then((result) {
      // Update the state with the result
      setState(() {
        isTeacher = result;
      });
    });
  }  
  Future<void> _refreshData() async {
  // Implement any data refreshing operations here
  // refetch data from Firestore
  takenClasses(course: widget.course, isTeacher: isTeacher,);
  setState(() {
    // Update any necessary state variables
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: buildAppBar(context, widget.course, isTeacher),
      appBar: AppBar(
        //title: const Text('title'),
        title: Text(widget.course['code']),
          actions: [
          Theme(
            data: Theme.of(context).copyWith(
               textTheme: TextTheme().apply(bodyColor: Colors.white), // Set text color to white
                dividerColor: Colors.white, // Set divider color if needed
                // customize other properties like icon color here if needed
              ),
              child: PopupMenuButton<int>(
              //  color: Colors.black, // Set background color to black
              itemBuilder: (context) {
                 List<PopupMenuItem<int>> items = [];
                 items.addAll([
                    PopupMenuItem<int>(
                  value: 9,
                  child: Row(
                    children: [
                      Icon(Icons.refresh_outlined), // Add desired icon here
                      const SizedBox(
                        width: 7,
                      ),
                      Text("Refresh")
                    ],
                  ),
                ),
                 ]);
              if (isTeacher)
                  items.addAll([
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.file_upload), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          Text("Upload Students (CSV)")
                        ],
                      ),
                  ),
                  PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.file_upload), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          Text("Upload Students (Excel)")
                        ],
                      ),
                  ),
                  PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.add), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          Text("Add Students Manually")
                        ],
                      ),
                  ),
                  PopupMenuItem<int>(
                      value: 6,
                      child: Row(
                        children: [
                          Icon(Icons.settings), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          Text("Course Settings")
                        ],
                      ),
                  ),
                  PopupMenuItem<int>(
                      value: 7,
                      child: Row(
                        children: [
                          Icon(Icons.merge_type), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          Text("Merge attendance")
                        ],
                      ),
                  ),                 
                ]);
             
              // const PopupMenuDivider();
              items.addAll([
                PopupMenuItem<int>(
                      value: 3,
                      child: Row(
                        children: [
                          Icon(Icons.people), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          isTeacher ? const Text("Students") : const Text('People'),
                        ],
                      ),
                  ),
                PopupMenuItem<int>(
                      value: 5,
                      child: Row(
                        children: [
                          Icon(Icons.score), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          Text("Statistics")
                        ],
                      ),
                  ),
                PopupMenuItem<int>(
                      value: 4,
                      child: Row(
                        children: [
                          Icon(Icons.file_download), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          Text("Export Statistics")
                        ],
                      ),
                  ),
                PopupMenuItem<int>(
                      value: 8,
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart), // Add desired icon here
                          const SizedBox(
                            width: 7,
                          ),
                          Text("Another Statistics")
                        ],
                      ),
                  ),
              ]);

              return items;
              },
              onSelected: (item) => SelectedItem(context, item, widget.course),
            ),
          ),
        ],
      ),
      //body:takenClasses(course: widget.course,isTeacher: isTeacher),
      body: RefreshIndicator(
      onRefresh: _refreshData,
      child: takenClasses(course: widget.course, isTeacher: isTeacher),
      ),
      floatingActionButton:  isTeacher
        ? FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 3, 66, 117),
        onPressed: () {
          Navigator.push(                    
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakeNewClass(course: widget.course,isTeacher: isTeacher),
                    ),
                  );
        },
        child: Icon(Icons.add,color: Colors.white),
      )
      : null,
    );
  }


  //selected item
void SelectedItem(BuildContext context, item, course) {
    switch (item) {
     case 0:
        //csv file upload
        pickFile(context,course);
        break;
      case 1:
        //excel sheet upload
        importFile(context,course);      
        break;
      case 2:
      //add student manuallay page
      Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddStudentManual(
        course: course,
      )));       
        break;
      case 3:  
          //show students page   
           Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => FetchStudents(
         course: course,
      )));  
        break;
       case 5:
       //show course statistics page
          Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => StatisticsPage(
        course: course,
      )));
        break;
      case 6:  
      //class settings page for late option     
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => CourseSettingPage(
        course: course,
      )));          
        break;
      case 4:
        //export class report     
        //FileStorage.writeCounter(context,course);  
        FileStorage fileStorage = FileStorage(course);
        fileStorage.writeCounter(context, course);    
        break;
      case 7:
       Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MergeAttendance())); 
        break;
          case 8:
       Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => StatisticsAnother(
        course: course,
      ))); 
        break;
      case 9:
        _refreshData(); 
      break;
    }
  }
}