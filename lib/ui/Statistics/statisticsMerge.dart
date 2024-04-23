import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:teacher_aide/ui/Attendance/widget/_createAttendanceRef.dart';

class StatisticsMerge extends StatelessWidget {
  //DocumentSnapshot<Object?> course;
  List<String> selectedCourses;
  StatisticsMerge({super.key, required this.selectedCourses});

  final ScrollController _homeController = ScrollController();
  var totalClasse=0;
  Future<Map<String, dynamic>> fetchStudentAttendance() async {
  try {
    Map<String, dynamic> studentAttendance = {};

    // Loop through each selected course
    for (String courseId in selectedCourses) {
      QuerySnapshot querySnapshot = await createAttendanceReference()
          .where('courseId', isEqualTo: courseId)
          .get();
      totalClasse=querySnapshot.docs.length;
      // Process attendance data for each course
      querySnapshot.docs.forEach((document) {
        List<Map<String, dynamic>> attendanceData =
            List<Map<String, dynamic>>.from(document['attendanceData']);

        attendanceData.forEach((data) {
          int studentRoll = data['roll'];
          String status = data['status'];

          // Update attendance counts for each student
          if (studentAttendance.containsKey(studentRoll.toString())) {
            Map<String, dynamic> existingData =
                studentAttendance[studentRoll.toString()];
            int presentCount = existingData['present'] ?? 0;
            int absentCount = existingData['absent'] ?? 0;
            int lateCount = existingData['late'] ?? 0;

            if (status == 'P') {
              existingData['present'] = presentCount + 1;
            } else if (status == 'A') {
              existingData['absent'] = absentCount + 1;
            } else if (status == 'L') {
              existingData['late'] = lateCount + 1;
            }
          } else {
            // Initialize attendance data for a new student
            studentAttendance[studentRoll.toString()] = {
              'present': status == 'P' ? 1 : 0,
              'absent': status == 'A' ? 1 : 0,
              'late': status == 'L' ? 1 : 0,
            };
          }
        });
      });
    }

    return studentAttendance;
  } catch (e) {
    // Handle errors
    print('Error fetching student attendance: $e');
    return {}; // Return an empty map in case of errors
  }
}
  Future<Map<String, Map<String, int>>> countDaysPerStatus() async {
    Map<String, dynamic> studentAttendance = await fetchStudentAttendance();

    Map<String, Map<String, int>> daysPerStatus = {
      'Present': {},
      'Absent': {},
      'Late': {},
    };
    for (String studentRoll in studentAttendance.keys) {
  String status = studentAttendance[studentRoll]['status'];

  daysPerStatus.forEach((key, value) {
    if (value[studentRoll] != null) {
      value.update(studentRoll, (count) => count + 1);
    } else {
      value[studentRoll] = 1;
    }
  });
}

    return daysPerStatus;
  }
// Method to create data rows for the DataTable
List<DataRow> buildDataRows(Map<String, dynamic> studentAttendance, int totalClasse) {
  List<DataRow> studentRows = [];

  studentAttendance.forEach((studentRoll, studentData) {
    // Calculate the total number of classes attended for each student
    int totalClassesAttended = studentData['present'] + studentData['absent'] + studentData['late'];
    double attendancePercentage = (studentData['present'] / totalClasse * 100);
     // Determine the style based on attendance percentage
    TextStyle rowStyle = TextStyle(color: Colors.black); // Default style
    if (attendancePercentage < 50) {
      rowStyle = TextStyle(color: Colors.red); // Red style for less than 50% attendance
    }

    studentRows.add(DataRow(cells: [
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$studentRoll', style: rowStyle),
        ],
      )),
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${(studentData['present'] / totalClassesAttended * 100).round()}%'),
          Text('${studentData['present']}/$totalClassesAttended'),
        ],
      )),
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${(studentData['absent'] / totalClassesAttended * 100).round()}%'),
          Text('${studentData['absent']}/$totalClassesAttended'),
        ],
      )),
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${(studentData['late'] / totalClassesAttended * 100).round()}%'),
          Text('${studentData['late']}/$totalClassesAttended'),
        ],
      )),
    ]));
  });

  return studentRows;
}



  @override
  Widget build(BuildContext context) {  
     return FutureBuilder<Map<String, dynamic>>(
      future: fetchStudentAttendance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          Map<String, dynamic> studentAttendance = snapshot.data!;
          List<DataRow> studentRows = buildDataRows(studentAttendance, totalClasse);


          //pie data calculate
           // Calculation of total present, absent, and late counts
         int totalPresent = 0;
        int totalAbsent = 0;
          int totalLate = 0;
          int a=0;
          studentAttendance.forEach((_, data) {
            a=data['present'];
            totalPresent += a;
            a=data['absent'];
            totalAbsent += a;
            a=data['late'];
            totalLate += a;
          });

    return Scaffold(
      appBar: AppBar(
        title: Text('Merge Courses Statistics'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0,left: 20,right: 20),
            child: ElevatedButton(
                onPressed: () {
                  // Handle export button press
                },
                   child: Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20),
              child: Text(
                'Export',
                style: TextStyle(fontSize: 18.0,color: Colors.white),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 3, 66, 117),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
              ),
          ),
           Padding(
             padding: const EdgeInsets.only(top: 30),
             child: PieChart(
              dataMap: {
                'Present': totalPresent.toDouble(),
                'Absent': totalAbsent.toDouble(),
                'Late': totalLate.toDouble(),
              },
              chartLegendSpacing: 32.0,
              colorList: [
                Colors.green,
                Colors.red,
                Colors.orange,
              ],
              chartType: ChartType.ring,
              chartRadius: MediaQuery.of(context).size.width / 3.0,
              initialAngleInDegree: 0,
              chartValuesOptions: ChartValuesOptions(
                showChartValues: true,
                showChartValuesOutside: false,
              ),
                     ),
           ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DataTable(
              columns: [
                DataColumn(label: Text('Student')),
                DataColumn(label: Text('Present')),
                DataColumn(label: Text('Absent')),
                DataColumn(label: Text('Late')),
              ],
              rows: studentRows,
            ),
          ),
        ],
      ),
    );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}