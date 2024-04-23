import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:teacher_aide/ui/Attendance/widget/_createAttendanceRef.dart';



String formatDate(String dateString) {
  final DateFormat inputFormat = DateFormat('E, MMM d, yyyy');
  final DateFormat outputFormat = DateFormat('MMM d, yy');
  try {
    final DateTime date = inputFormat.parse(dateString);
    final String formattedDate = outputFormat.format(date);
    return formattedDate;
  } catch (e) {
    print('Error parsing date: $e');
    return ''; // Handle the error as needed
  }
}

 
//excel sheet work
class FileStorage {
   bool lateAttendanceOption = false;
bool lateAttendanceOptionOnClass = false;
  final DocumentSnapshot<Object?> course;
  //FileStorage(this.course);
   FileStorage(this.course) {
    // Call loadSettings when FileStorage is instantiated
    loadSettings();
  }
    Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance(); 
    lateAttendanceOption = prefs.getBool('lateAttendanceOption') ?? true;
    lateAttendanceOptionOnClass=prefs.getBool('${course.id}_lateAttendanceOptionOnClass') ?? lateAttendanceOption;
    print(lateAttendanceOptionOnClass);
  }

  
 

  static Future<String> getExternalDocumentPath() async {
    // To check whether permission is given for this app or not.
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // If not we will ask for permission first
      await Permission.storage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      // Redirects it to download folder in android
      _directory = Directory("/storage/emulated/0/Download");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
     String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      return selectedDirectory;
    } else {
      // Fallback to the default directory
      final String directory = await getExternalDocumentPath();
      return directory;
    }  
  }

  Future<void> writeCounter(BuildContext context, course) async {
    final path = await _localPath;
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    //Defining a global style with properties.
final Style globalStyle = workbook.styles.add('globalStyle');
globalStyle.backColor = '#0F1035';
globalStyle.fontName = 'Times New Roman';
globalStyle.fontSize = 10;
globalStyle.fontColor = '#FEFBF6';
globalStyle.italic = true;
//globalStyle.bold = true;
//globalStyle.underline = true;
//globalStyle.wrapText = true;
globalStyle.hAlign = HAlignType.center;
globalStyle.vAlign = VAlignType.center;
globalStyle.borders.all.lineStyle = LineStyle.thick;
globalStyle.borders.all.color = '#FEFBF6';

final Style globalStyle1 = workbook.styles.add('globalStyle1');
globalStyle1.fontSize = 14;
globalStyle1.fontColor = '#362191';
globalStyle1.hAlign = HAlignType.center;
globalStyle1.vAlign = VAlignType.center;
globalStyle1.borders.bottom.lineStyle = LineStyle.thin;
globalStyle1.borders.bottom.color = '#829193';
globalStyle1.numberFormat = '0.00';

final Style globalStyle2 = workbook.styles.add('globalStyle2');
globalStyle2.bold= true;
globalStyle2.fontSize = 14;
globalStyle2.backColorRgb = Color.fromARGB(255, 8, 69, 92);
globalStyle2.fontColorRgb = Color.fromARGB(255, 255, 255, 255); 

    // Set the first column header as 'Roll'
    sheet.getRangeByIndex(1, 1).setText('Reg. No');
    
    sheet.getRangeByIndex(1, 1).cellStyle.backColorRgb = Color.fromARGB(255, 8, 69, 92); // Set background color
    sheet.getRangeByIndex(1, 1).cellStyle.bold = true; // Bold text
    sheet.getRangeByIndex(1, 1).cellStyle.fontSize = 14; // Adjust font size
    sheet.getRangeByIndex(1, 1).cellStyle.hAlign = HAlignType.center; // Center align text
    sheet.getRangeByIndex(1, 1).cellStyle.vAlign = VAlignType.center; // Center align text
    sheet.getRangeByIndex(1, 1).cellStyle.fontColorRgb = Color.fromARGB(255, 255, 255, 255); // Set text color
    // Set the width of the 'Roll' column
    sheet.setColumnWidthInPixels(
        1, 120); //adjust the width value (15 in this case)
    // Set the height of the first row
    sheet.setRowHeightInPixels(1, 30); 
    // Fetch data from Firebase
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var currentUser = _auth.currentUser;
    CollectionReference _collectionRef = createAttendanceReference();

    final QuerySnapshot<Object?> attendanceSnapshot =
        await _collectionRef.where('courseId', isEqualTo: course.id).get();
    //print(course.id);
    final List<Map<String, dynamic>> attendanceDataList = [];
    final date = [];
    int i = 0;

    // Create a map to store the total present and absent for each student
    final Map<String, Map<String, int>> studentAttendance = {};
    final Map<String, int> rollNumberMapping = {};

    for (final doc in attendanceSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String originalDate = data['date'];
      final String formattedDate = formatDate(originalDate);

      if (data.containsKey('attendanceData')) {
         //Apply Body Style
        sheet.getRangeByIndex(1,i+2).cellStyle = globalStyle;
        // Update the header with the current date
        sheet.getRangeByIndex(1, i + 2).setText(formattedDate);

        final List<Map<String, dynamic>> attendanceData =
            List<Map<String, dynamic>>.from(data['attendanceData']);

        for (int j = 0; j < attendanceData.length; j++) {
          final Map<String, dynamic> studentEntry = attendanceData[j];
          final String roll = studentEntry['roll'].toString();
          final String status = studentEntry['status'];

          // Set the student roll number in the first column
          sheet.getRangeByIndex(j + 2, 1).setText(roll);

          // Set the attendance status in the corresponding date column
          sheet.getRangeByIndex(j + 2, i + 2).setText(status);

          // Update the total present and absent for each student
          studentAttendance.putIfAbsent(
              roll, () => {'Present': 0, 'Absent': 0,'Late':0});
          if (studentAttendance[roll] != null) {
            if (status == 'P') {
              studentAttendance[roll]!['Present'] =
                  (studentAttendance[roll]!['Present'] ?? 0) + 1;
            } else if(status == 'A') {
              studentAttendance[roll]!['Absent'] =
                  (studentAttendance[roll]!['Absent'] ?? 0) + 1;
            }
            else{
              studentAttendance[roll]!['Late'] =
                  (studentAttendance[roll]!['Late'] ?? 0) + 1;
            }
          }
           // Store the mapping between long roll numbers and unique identifiers
        rollNumberMapping[roll] = j + 2;
        }

        i++;
      }
    }
    //Apply GlobalStyle1
    sheet.getRangeByIndex(1,i+2,i+3,i+4).cellStyle = globalStyle1;
    //s
    // Add the 'Total' header in the last column
    sheet.getRangeByIndex(1, i+2).setText('Total Present');
    sheet.getRangeByIndex(1, i+3).setText('Total Absent');
    if (lateAttendanceOptionOnClass){
      sheet.getRangeByIndex(1, i+4).setText('Total Late');
      sheet.setColumnWidthInPixels(i+4,120); 
    }
    sheet.setColumnWidthInPixels(i+2,120); 
    sheet.setColumnWidthInPixels(i+3,120); 

// Populate the 'Total' column with the total present and absent for each student
    studentAttendance.forEach((roll, totals) {
      final int totalPresent = totals['Present'] ?? 0;
      final int totalAbsent = totals['Absent'] ?? 0;
       final int totalLate = totals['Late'] ?? 0;

      // Check if the roll is already mapped to a unique identifier
      int? rowIndex = rollNumberMapping[roll];
      // If not, create a new mapping
      if (rowIndex == null) {
        rowIndex = rollNumberMapping.length + 2; // Start from the second row
        rollNumberMapping[roll] = rowIndex;
      }

      // Set the text in the corresponding cell
      //sheet.getRangeByIndex(rowIndex, i + 2).setText('P: $totalPresent, A: $totalAbsent');
      sheet.getRangeByIndex(rowIndex,i+2).cellStyle = globalStyle1;
      sheet.getRangeByIndex(rowIndex,i+3).cellStyle = globalStyle1;
      sheet.getRangeByIndex(rowIndex,i+4).cellStyle = globalStyle1;
      sheet.getRangeByIndex(rowIndex, i + 2).setText('$totalPresent');
      sheet.getRangeByIndex(rowIndex, i + 3).setText('$totalAbsent');
      if (lateAttendanceOptionOnClass){
      sheet.getRangeByIndex(rowIndex, i + 4).setText(' $totalLate');
      }
    });

    // Save and dispose the document
    final List<int> bytes = workbook.saveSync();
    workbook.dispose();

    // Create a file for the path of the device and file name with extension
    File file = File('$path/attendance.xlsx');

    await file.writeAsBytes(bytes, flush: true);
    print("Save file");
    print(file);
   ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Successfully Exported Attendance Statistics for this course.')),
    );
    OpenFile.open('$path/attendance.xlsx');
  
  }
}
