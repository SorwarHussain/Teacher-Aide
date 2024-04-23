import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Course/widget/FileStorage.dart';
import 'package:teacher_aide/ui/Course/widget/_importExcelFile.dart';
import 'package:teacher_aide/ui/Course/widget/_pickFileCSV.dart';
import 'package:teacher_aide/ui/Course/widget/_takenClasses.dart';
import 'package:teacher_aide/ui/Settings/courseSettingsPage.dart';
import 'package:teacher_aide/ui/Statistics/Statistics.dart';
import 'package:teacher_aide/ui/Statistics/mergeAttendance.dart';
import 'package:teacher_aide/ui/Statistics/statisticsAnother.dart';
import 'package:teacher_aide/ui/Student/AddStudentManually.dart';
import 'package:teacher_aide/ui/Student/fetchStudents.dart';

 Future<void> _refreshData(course, isTeacher) async {
  // Implement any data refreshing operations here
  // refetch data from Firestore
  takenClasses(course: course, isTeacher: isTeacher);
}

//selected item
void SelectedItem(context, item, course, isTeacher) {
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
         /* Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => StudentsPage(
        course: course,
      )));*/
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
        FileStorage fileStorage = FileStorage(course);
        fileStorage.writeCounter(context, course);   
        break;
      case 7:
       Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MergeAttendance())); 
        break;
          case 8:
       /*Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => StatisticsPagea(
        course: course,
      ))); */
        break;
          case 9:
       Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => StatisticsAnother(
        course: course,
      ))); 
        break;
         case 10:
        _refreshData(course, isTeacher); 
      break;
    }
  }
