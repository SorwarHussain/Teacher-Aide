import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseSettingPage extends StatefulWidget {
  final DocumentSnapshot<Object?> course;

  CourseSettingPage({Key? key, required this.course}) : super(key: key);

  @override
  _CourseSettingPageState createState() => _CourseSettingPageState();
}

class _CourseSettingPageState extends State<CourseSettingPage> {
  late bool lateAttendanceOptionOnClass;
  bool showCourseCode = false;

  @override
  void initState() {
    super.initState();
    lateAttendanceOptionOnClass = true;
    loadSettings();
  }

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lateAttendanceOptionOnClass =
          prefs.getBool('${widget.course.id}_lateAttendanceOptionOnClass') ?? true;
    });
  }

  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('${widget.course.id}_lateAttendanceOptionOnClass', lateAttendanceOptionOnClass);
    Navigator.pop(context);
  }

  void copyCourseCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.course['code']));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course code copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showCourseCode = !showCourseCode;
                });
              },
              style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 3, 66, 117), // Change the background color here
               ),
              child: Text(showCourseCode ? 'Hide Course Code' : 'Show Course Code', style: TextStyle(fontSize: 18,color: Colors.white)),
            ),
            if (showCourseCode)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Course Code: ${widget.course.id}", // Display course code
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: copyCourseCodeToClipboard,
                      icon: Icon(Icons.content_copy),
                      tooltip: 'Copy Course Code',
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Late Attendance Option:", style: TextStyle(fontSize: 16)),
                Switch(
                  value: lateAttendanceOptionOnClass,
                  onChanged: (value) {
                    setState(() {
                      lateAttendanceOptionOnClass = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveSettings();
              },
              style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 3, 66, 117), // Change the background color here
              ),
              child: Text('Save Settings', style: TextStyle(fontSize: 18,color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
