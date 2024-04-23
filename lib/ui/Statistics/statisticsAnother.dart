import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pie_chart/pie_chart.dart' as pieCharts;
import 'package:teacher_aide/ui/Attendance/widget/_createAttendanceRef.dart';
import 'package:charts_flutter/flutter.dart'as charts;

class StatisticsAnother extends StatelessWidget {
  DocumentSnapshot<Object?> course;
  StatisticsAnother({super.key, required this.course});

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
    //print(studentAttendance);
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
  studentRows.add(DataRow(cells: [
    DataCell(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$studentRoll'),
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
List<charts.Series<BarChartData, String>> buildBarChartData(
      Map<String, dynamic> studentAttendance) {
    List<BarChartData> barChartData = [];
    studentAttendance.forEach((studentRoll, data) {
      int presentCount = data['present'];
      int absentCount = data['absent'];
      int lateCount = data['late'];

      barChartData.add(BarChartData(studentRoll, 'Present', presentCount));
      barChartData.add(BarChartData(studentRoll, 'Absent', absentCount));
      barChartData.add(BarChartData(studentRoll, 'Late', lateCount));
    });

    var presentSeries = charts.Series<BarChartData, String>(
      id: 'Present',
      domainFn: (BarChartData data, _) => data.studentRoll,
      measureFn: (BarChartData data, _) => data.count,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.green),
      labelAccessorFn: (BarChartData data, _) => '${data.count}',
      data: barChartData.where((data) => data.type == 'Present').toList(),
    );

    var absentSeries = charts.Series<BarChartData, String>(
      id: 'Absent',
      domainFn: (BarChartData data, _) => data.studentRoll,
      measureFn: (BarChartData data, _) => data.count,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.red),
      labelAccessorFn: (BarChartData data, _) => '${data.count}',
      data: barChartData.where((data) => data.type == 'Absent').toList(),
    );

    var lateSeries = charts.Series<BarChartData, String>(
      id: 'Late',
      domainFn: (BarChartData data, _) => data.studentRoll,
      measureFn: (BarChartData data, _) => data.count,
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.orange),
      labelAccessorFn: (BarChartData data, _) => '${data.count}',
      data: barChartData.where((data) => data.type == 'Late').toList(),
    );

    return [presentSeries, absentSeries, lateSeries];
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
          List<charts.Series<BarChartData, String>> barChartData = buildBarChartData(studentAttendance);


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
            body: Column(
                children: [
                  Expanded(
                    //flex: 4, 
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: charts.BarChart(
                        barChartData,
                        animate: true,
                        vertical: false,
                        barGroupingType: charts.BarGroupingType.grouped,
                        behaviors: [charts.SeriesLegend()],
                      ),
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


class BarChartData {
  final String studentRoll;
  final String type;
  final int count;

  BarChartData(this.studentRoll, this.type, this.count);
}
