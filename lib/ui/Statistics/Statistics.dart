import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:teacher_aide/ui/Attendance/widget/_createAttendanceRef.dart';
import 'package:teacher_aide/ui/Student/fetchStudents.dart';


class StatisticsPage extends StatelessWidget {
  DocumentSnapshot<Object?> course;
  StatisticsPage({super.key, required this.course});

  final ScrollController _homeController = ScrollController();
  var totalClasse;

  Future<Map<String, dynamic>> fetchStudentAttendance() async {
  try {
    QuerySnapshot querySnapshot = await createAttendanceReference()
      .where('courseId', isEqualTo: course.id)
      .get();
    totalClasse=querySnapshot.docs.length;
    Map<String, dynamic> studentAttendance = {};

    querySnapshot.docs.forEach((document) {
      List<Map<String, dynamic>> attendanceData = List<Map<String, dynamic>>.from(document['attendanceData']);

      attendanceData.forEach((data) {
        int studentRoll = data['roll'];
        String status = data['status'];
        if (studentAttendance.containsKey(studentRoll.toString())) {
          Map<String, dynamic> existingData = studentAttendance[studentRoll.toString()];
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
          Map<String, dynamic> newData = {
            'present': status == 'P' ? 1 : 0,
            'absent': status == 'A' ? 1 : 0,
            'late': status == 'L' ? 1 : 0,
          };
          studentAttendance[studentRoll.toString()] = newData;
        }
      });
    });
    return studentAttendance;
  } catch (e) {
    // Error handling
    print("Error fetching student attendance: $e");
    return {};
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
  List<DataRow> buildDataRows(Map<String, dynamic> studentAttendance) {
    List<DataRow> studentRows = [];

    studentAttendance.forEach((studentRoll, studentData) {
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
        Text('${(studentData['present'] / totalClasse * 100).round()}%'),
        Text('${studentData['present']}/$totalClasse'),
      ],
    )),
    DataCell(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${(studentData['absent'] / totalClasse * 100).round()}%'),
        Text('${studentData['absent']}/$totalClasse'),
      ],
    )),
    DataCell(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${(studentData['late'] / totalClasse * 100).round()}%'),
        Text('${studentData['late']}/$totalClasse'),
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
          List<DataRow> studentRows = buildDataRows(studentAttendance);

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
        title: Text(course['title']),
      ),
      body: ListView(
        children: [
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
          DataTable(
            columns: [
              DataColumn(label: Text('Student')),
              DataColumn(label: Text('Present')),
              DataColumn(label: Text('Absent')),
              DataColumn(label: Text('Late')),
            ],
            rows: studentRows,
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