import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:teacher_aide/ui/Attendance/new_class.dart';
import 'package:teacher_aide/ui/Course/widget/TakenClass.dart';

final ScrollController _homeController = ScrollController();

late TimeOfDay selectedClassDuration;

Widget buildClassCard(TakenClass takenClass, DocumentSnapshot<Object?> course, bool isTeacher) {
  selectedClassDuration = TimeOfDay(
        hour: takenClass.classDuration ~/ 60,
        minute: takenClass.classDuration % 60,
  );
  bool hr=selectedClassDuration.hour>0;
 

  return Card(
              elevation: 5,
              clipBehavior: Clip.hardEdge,      
               child: Builder(
      builder: (BuildContext context) {
              return InkWell(
                onTap: () {                 
                   Navigator.push(                    
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakeNewClass(course:course,docId: takenClass.docId,isTeacher: isTeacher),
                    ),                   
                  );          
                },
                onDoubleTap: () {
                  print("double tap");
                },
                onLongPress: () {
                  print("long tap");                  
                },
                splashColor: Colors.green,
                highlightColor: Colors.blue,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          //course title and 3 dot icon
                          ListTile(                            
                            leading: Icon(Icons.calendar_month),  
                            title: Text(
                              "${takenClass.date}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10, left: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('${takenClass.time}, '),
                                    if(hr)
                                    Text('${selectedClassDuration.hour}h '),
                                    Text('${selectedClassDuration.minute}m'),
                                    ],
                                ),
                                Row(
                                  children: [
                                    
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                      // Pie chart on the right
        Container(
         // width: 150, // Adjust size according to design
          height: 100, // Adjust size according to design
          child: PieChart(
            dataMap:  {
                'Present': takenClass.presentCount.toDouble(),
                'Absent': takenClass.absentCount.toDouble(),
                'Late': takenClass.lateCount.toDouble(),
              },
            colorList: [
              Colors.green, // Color for 'Present'
              Colors.red, // Color for 'Absent'
              Colors.orange, // Color for 'Late'
            ],
            //chartType: ChartType.ring,
            chartRadius: 70, // Adjust size according to design
            chartLegendSpacing: 32,
            legendOptions: LegendOptions(           
            showLegends: false,
            ),
            initialAngleInDegree: 0,
            chartValuesOptions: ChartValuesOptions(
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 0,
              showChartValueBackground: false,
              //chartValueStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
                  ],
                ),
              );
                },
               ),
            );
}


