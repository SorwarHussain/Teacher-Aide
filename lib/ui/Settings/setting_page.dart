import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int selectedAttendanceWeight = 1;
  bool lateAttendanceOption = true;
  TimeOfDay selectedClassDuration = TimeOfDay(hour: 1, minute: 0);

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      final int classDurationMinutes = prefs.getInt('classDurationMinutes') ?? 60;
      selectedClassDuration = TimeOfDay(
        hour: classDurationMinutes ~/ 60,
        minute: classDurationMinutes % 60,
      );
      selectedAttendanceWeight = prefs.getInt('attendanceWeight') ?? 1;
      lateAttendanceOption = prefs.getBool('lateAttendanceOption') ?? true;
    });
  }

  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final classDurationMinutes =
        selectedClassDuration.hour * 60 + selectedClassDuration.minute;
    prefs.setInt('classDurationMinutes', classDurationMinutes);
    prefs.setInt('attendanceWeight', selectedAttendanceWeight);
    prefs.setBool('lateAttendanceOption', lateAttendanceOption);

    Navigator.pop(context);
  }

  void _selectClassDuration() {
    showTimePicker(
      context: context,
      initialTime: selectedClassDuration,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    ).then((pickedTime) {
      if (pickedTime != null) {
        setState(() {
          selectedClassDuration = pickedTime;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _selectClassDuration();
              },
              child: Row(
                children: [
                  Text(
                    "Class Duration:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Row(
                   children: [
                      Icon(Icons.access_time, size: 30, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "${selectedClassDuration.hour.toString().padLeft(2, '0')}:${selectedClassDuration.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
              ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Attendance Weight:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                DropdownButton<int>(
                  value: selectedAttendanceWeight,
                  onChanged: (int? value) {
                    setState(() {
                      selectedAttendanceWeight = value!;
                    });
                  },
                  items: [1, 2, 3, 4, 5, 6, 7, 8].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 30,
                    color: Colors.black,
                  ),
                  isExpanded: false,
                  underline: Container(
                    height: 2,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Late Attendance Option:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Switch(
                  value: lateAttendanceOption,
                  onChanged: (value) {
                    setState(() {
                      lateAttendanceOption = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  saveSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 3, 66, 117), // Change the background color here
                ),
                child: Text('Save Settings', style: TextStyle(fontSize: 18,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

