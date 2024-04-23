import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_aide/ui/Attendance/widget/_createAttendanceRef.dart';
import 'package:http/http.dart' as http;

class TakeNewClass extends StatefulWidget {
  final DocumentSnapshot<Object?> course;
  final String? docId;
  final bool isTeacher;
 const TakeNewClass({super.key,required this.course,this.docId,required this.isTeacher});
  @override
  State<TakeNewClass> createState() => _TakeNewClassState();
}
 final FirebaseAuth _auth = FirebaseAuth.instance;

class _TakeNewClassState extends State<TakeNewClass> {
  final ScrollController _homeController = ScrollController();
  
  Map<int, String> _attendanceStatus = {};
   Map<String, dynamic> _fetchedData = {};
  var stud=[];
  
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  int selectedAttendanceWeight=1;
  TimeOfDay selectedClassDuration= TimeOfDay(hour: 1, minute: 0);
  late int classDurationMinutesGlobal;
  bool lateAttendanceOption = false;
  bool lateAttendanceOptionOnClass = false;
  var currentUser = _auth.currentUser;   
  String dateAsId = DateFormat('E, MMM d, yyyy').format(DateTime.now());
  var time12=DateFormat.jm().format(DateTime.now());
  var time24=DateFormat.Hm().format(DateTime.now());
  CollectionReference _collectionClassRef=createAttendanceReference(); 
  
   @override
  void initState() {
    super.initState();
  
    loadSettings();
    // Fetch data based on widget.docId
    if(widget.docId!=null)
      fetchData();
  }
  Future<void> loadSettings() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    final int classDurationMinutes = prefs.getInt('classDurationMinutes') ?? 60;
    classDurationMinutesGlobal=classDurationMinutes;
      selectedClassDuration = TimeOfDay(
        hour: classDurationMinutes ~/ 60,
        minute: classDurationMinutes % 60,
      );
    selectedAttendanceWeight = prefs.getInt('attendanceWeight') ?? 1;
    lateAttendanceOption = prefs.getBool('lateAttendanceOption') ?? true;
    lateAttendanceOptionOnClass=prefs.getBool('${widget.course.id}_lateAttendanceOptionOnClass') ?? lateAttendanceOption;
  });
}
  // Function to fetch data
 Future<void> fetchData() async {
  // Use FirebaseFirestore.instance.collection() to get the reference to the collection
  try {
    // Use the .get() method to retrieve the document snapshot
    DocumentSnapshot<Object?> documentSnapshot = await _collectionClassRef.doc(widget.docId).get();
   // Check if the document exists
    if (documentSnapshot.exists) {
      // Retrieve the data from the document
      _fetchedData = documentSnapshot.data() as Map<String, dynamic>;

      for (var entry in _fetchedData['attendanceData']) {
        int roll = entry['roll'];
        String status = entry['status'];
        _attendanceStatus[roll] = status;
      }  
      setState(() {
    final int classDurationMinutes = _fetchedData['duration'] ?? 60;
    classDurationMinutesGlobal=classDurationMinutes;
      selectedClassDuration = TimeOfDay(
        hour: classDurationMinutes ~/ 60,
        minute: classDurationMinutes % 60,
      );
      //date
      dateAsId=_fetchedData['date'];
      //time
      time12=_fetchedData['time'];
      selectedAttendanceWeight = _fetchedData['weight'];
  });
    } else {
      // Handle the case where the document doesn't exist
      setState(() {
        _fetchedData ={};
      });
    }
  } catch (e) {
    // Handle errors
    setState(() {
      _fetchedData = {};
    });
  }
}
    // Function to update data
void updateData() {  
  List<Map<String, dynamic>> dataList = [];
  for (var e = 0; e < _attendanceStatus.length; e++) {
   Map<String, dynamic> studentData = {
      'roll': stud[e],
      'status': _attendanceStatus[stud[e]],
    };
    dataList.add(studentData);
  }

  // Update other fields as needed
  _collectionClassRef.doc(widget.docId).update({
    'attendanceData': dataList,
    'weight': selectedAttendanceWeight,
    'date': dateAsId,
    'time': time12,
    'duration': classDurationMinutesGlobal,
  }).then((value) {
    // Placeholder for update success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data Updated Successfully!'),
      ),
    );
    
    // Navigate back to the previous screen
    Navigator.pop(context);
  }).catchError((error) {
    // Handle errors
    print("Error updating data: $error");
  });
}

   Future finishAttendance() async {
  List<Map<String, dynamic>> dataList = [];
  for (var e = 0; e < _attendanceStatus.length; e++) {
    Map<String, dynamic> studentData = {
      'roll': stud[e],
      'status': _attendanceStatus[stud[e]],
    };
    dataList.add(studentData);
  }
  await _collectionClassRef.doc().set({
    "date": dateAsId,
      "time": time12,
      "weight": selectedAttendanceWeight,
      "duration": classDurationMinutesGlobal,
    'attendanceData': dataList,
    'courseId': widget.course.id,
  }); 
   print("Wow! Successfully taken new class");
    Navigator.pop(context);
  }
  
void fillWithDefault() {    
    for(var i in stud){
       if(!_attendanceStatus.containsKey(i)){
          _attendanceStatus[i] = "P";
        }
    }  
    finishAttendance();
  }
  //date picker
   Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateAsId=DateFormat('E, MMM d, yyyy').format(selectedDate);
      });
    }
  }
  //select time
    Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        time12=selectedTime.format(context);
      });
    }
  }
  //class durtion set this page
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
        classDurationMinutesGlobal =
        selectedClassDuration.hour * 60 + selectedClassDuration.minute;
      });
    }
  });
}
  Map<int, bool> _userInfoFetched = {}; // Map to track if user info is fetched for each student
   Map<int, ImageProvider<Object>?> _profileImages = {}; // Map to store profile images for each student 
  Uint8List? _image;
  // Define a map to store the image URLs corresponding to each student roll number
  String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';

  double circleAvatarRadius=34.0;

  Future<void> fetchUserInfo(int rollNumber) async {
    try {
      if (_userInfoFetched.containsKey(rollNumber) && _userInfoFetched[rollNumber] == true) {
        // User info already fetched for this student
        return;
      }
      CollectionReference _collectionRef = FirebaseFirestore.instance.collection("users");
      QuerySnapshot<Object?> documentSnapshot = await _collectionRef.where('roll', isEqualTo: rollNumber).get();

      if (!documentSnapshot.docs.isEmpty) {
        Map<String, dynamic> userData = documentSnapshot.docs.first.data() as Map<String, dynamic>;
        String imageUrl = userData['imageLink'] ?? '';
        if (imageUrl.isNotEmpty) {
          Uint8List? imageBytes = await fetchImageBytes(imageUrl);
          if (imageBytes != null) {
            setState(() {
              _profileImages[rollNumber] = MemoryImage(imageBytes);
            });
          }
        } else {
          // Use default image if no image is available
          setState(() {
            _profileImages[rollNumber] = const NetworkImage('https://static-00.iconduck.com/assets.00/avatar-default-icon-1975x2048-2mpk4u9k.png');
          });
        }
          // Update the map to indicate user info fetched for this student
        _userInfoFetched[rollNumber] = true;
      }
    } catch (e) {
      print("Error fetching user information: $e");
    }
  }


  Future<Uint8List?> fetchImageBytes(String imageUrl) async {
    try {
      // Fetch the image bytes
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print("Failed to fetch image bytes: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching image bytes: $e");
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(  
        title: Text("Take New Class"),  
      ),  
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(  
         mainAxisAlignment: MainAxisAlignment.spaceBetween,  
            children:<Widget>[  
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                 children: [
                   GestureDetector(
                    onTap: () {
                        if (widget.isTeacher)
                           _selectClassDuration();                           
                    },
                   child: Row(
                      children: [
                        Text("Class Duration:"),
                        SizedBox(width: 8),
                        Text(
                          "${selectedClassDuration.hour.toString().padLeft(2, '0')}:${selectedClassDuration.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          color:Colors.blue,
                          ),
                              ),
                            ],
                      ),
                    ),                    
                 ],
               ),
              Row(
                children: [
                  Text('Date & Time:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                     
                    ),), 
                  SizedBox(width: 8),
                   GestureDetector(
              onTap: () {
                if (widget.isTeacher)
                  _selectDate(context);
              },
              child:  Text(
                    "${dateAsId}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                       color: Colors.blue,
                    ),
                  ),
            ),
                 
                  SizedBox(width: 16),
                      GestureDetector(
              onTap: () {
                if (widget.isTeacher)
                  _selectTime(context);
              },
              child:
                  Text(
                    "${time12}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                   ),
                ],
              ),
               //attendance weight
               Row(
                   children: [
                    Text(
                      "Attendance Weight:",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    DropdownButton<int>(
                      value: selectedAttendanceWeight,
                     onChanged: widget.isTeacher ? (int? value) {
                  setState(() {
                    selectedAttendanceWeight = value!;
                  });
                } : null,
                      items: [1, 2, 3, 4, 5, 6, 7, 8].map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      style: TextStyle(fontSize: 16, color: Colors.black),
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

              Center(
                child: Container(                    
                  padding: EdgeInsets.all(12.0),                    
                  decoration:BoxDecoration(  
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),   // Adjust the radius as needed
                        topRight: Radius.circular(20.0),  // Adjust the radius as needed
                      ),  
                      color:Color.fromARGB(255, 4, 39, 77)
                  ),  
                  child: Center(
                    child: Text( "Attendance",  
                                style: TextStyle(  
                    fontSize: 25,  
                    color: Colors.white,  
                    fontWeight: FontWeight.w700,  
                    fontStyle: FontStyle.italic,                     
                    wordSpacing: 20,                   
                    ),),
                  ),  
                ),
              ),

                        StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("student_course_mapping") // Use the "student_course_mapping" collection
                      .where('courseId', isEqualTo: widget.course.id) // Filter by the current course
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading..."); // Show loading indicator while fetching data
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final List<DocumentSnapshot> studentMappings = snapshot.data!.docs;
                    // Extract student IDs from the mappings
                    List<String> studentIds = studentMappings.map((mapping) => mapping['studentId'].toString()).toList();
                  // Convert studentIds to List<int>
                      List<int> studentIdsList = studentIds.map((id) => int.tryParse(id) ?? 0).toList();
                      
                   return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                    stream: FirebaseFirestore.instance
                        .collection("students")
                        .where('roll', whereIn: studentIdsList)
                              .snapshots()
                          .map((querySnapshot) => querySnapshot.docs.toList()),
                    builder: (BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>> studentSnapshot) {
                      if (studentSnapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading..."); // Show loading indicator while fetching data
                      }
                      if (studentSnapshot.hasError) {
                        return Text('Error: ${studentSnapshot.error}');
                      }

                      final List<DocumentSnapshot<Map<String, dynamic>>> students = studentSnapshot.data!;
                        return ListView.separated(
                          controller: _homeController,
                          itemBuilder: (BuildContext context, int index) {
                            if (index >= 0 && index < students.length) {
                              final student = students[index];
                              int studentRoll = student['roll'];
                               fetchUserInfo(studentRoll);
                              if(!stud.contains(studentRoll)){
                                  stud.add(studentRoll);   
                              }                                
                              String? attendanceStatus=
                            _attendanceStatus.containsKey(studentRoll) ? _attendanceStatus[studentRoll] : "P";

                             return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 1.0), 
                                leading: GestureDetector(
                                  onTap: () {
                                    _showImageDialog(context, _profileImages[studentRoll], student['name']);
                                  },
                                  child: CircleAvatar(
                                    radius: 24.0,
                                    backgroundImage: _profileImages[studentRoll] ?? const NetworkImage('https://static-00.iconduck.com/assets.00/avatar-default-icon-1975x2048-2mpk4u9k.png'),
                                  ),
                                ),
                              title: Text(
                                  '${student['roll']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(capitalize(student['name'].toString())), // Capitalize the first character of the name
                                trailing: Row(
                              mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min  
                              children:<Widget>[  
                                if (!widget.isTeacher)
                                  Container(                                      
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),  
                                    decoration:BoxDecoration( 
                                        color: attendanceStatus == "P" ? Colors.green : (attendanceStatus=="A"?Colors.red:Colors.orange),                                        
                                    ),  
                                    child: Text(attendanceStatus == "P" ? "P":(attendanceStatus=="A"?"A":"L"),style: TextStyle(color:Colors.white,fontSize:30,fontWeight: FontWeight.bold),),  
                                  ),
                              if (widget.isTeacher) ...[
                               //p   
                               CupertinoButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    setState(() {                                     
                                      _attendanceStatus[studentRoll] = "P";
                                      attendanceStatus = "P";
                                    });                                  
                                  }, 
                                child: Container(                                      
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),  
                                    decoration:BoxDecoration( 
                                        color: attendanceStatus == "P" ? Colors.green : Color.fromARGB(255, 138, 139, 138),                                        
                                    ),  
                                    child: Text("P",style: TextStyle(color:Colors.white,fontSize:30,fontWeight: FontWeight.bold),),  
                                  ),
                              ), 
                              //A
                                 CupertinoButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                     setState(() {                                  
                                      _attendanceStatus[student['roll']] = "A";
                                      attendanceStatus = "A";  
                                    });                                   
                                  },  
                                   child: Container(  
                                    margin: EdgeInsets.symmetric(horizontal: 6.0,),  
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),  
                                    decoration:BoxDecoration(                                         
                                        color: attendanceStatus == "A"
                                        ? Colors.red
                                        :  Color.fromARGB(255, 138, 139, 138),   
                                    ),  
                                    child: Text("A",style: TextStyle(color:Colors.white,fontSize:30,fontWeight: FontWeight.bold),),  
                                                                 ),
                                 ),
                                 //L
                                if (lateAttendanceOptionOnClass)
                                CupertinoButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                     setState(() {
                                       attendanceStatus = "L";
                                       _attendanceStatus[student['roll']] = "L";
                                       });                              
                                  }, 
                                   child: Container(  
                                     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),  
                                    decoration:BoxDecoration(  
                                       color: attendanceStatus == "L"
                                        ? Colors.orange
                                        :  Color.fromARGB(255, 138, 139, 138),   
                                    ),  
                                    child: Text("L",style: TextStyle(color:Colors.white,fontSize:30,fontWeight: FontWeight.bold),),  
                                                                 ),
                                 ),
                              ],
                              ],
                            )
                                
                              );
                            } else {
                              return Container(); // Return an empty container for out-of-range indices
                            }
                          },
                          separatorBuilder: (BuildContext context, int index) => const Divider(
                            thickness: 1,
                          ),
                          itemCount: students.length,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),

             if (widget.isTeacher)
                //finish button
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    constraints: BoxConstraints(
                      minWidth: 0,
                      maxWidth: 250, // Set the maximum width as needed
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.docId==null) {
                            fillWithDefault();
                        }
                        else{
                          updateData();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric( vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.teal, // Change the button's background color
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.docId == null ? "Finish Attendance" : "Update Data",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                //color: const Color.fromARGB(255, 255, 255, 255), // Change the text color
                              ),
                            ),
                            SizedBox(width: 8,),
                            Icon(
                              Icons.done_outline_sharp,
                              size: 28, // Adjust icon size
                              color: Colors.black, // Change the icon color
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),       
        ],
      ),
    ),
  );
}
 // Define a method to show the image in a dialog
  void _showImageDialog(BuildContext context, ImageProvider<Object>? profileImage, student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              profileImage != null
                ? Image(image: profileImage)
                : Image.network('https://static-00.iconduck.com/assets.00/avatar-default-icon-1975x2048-2mpk4u9k.png'),
            SizedBox(height: 8.0),
              Text(capitalize(student), style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
            