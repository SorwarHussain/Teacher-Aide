import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Student/widget/_showDeleteDialog.dart';
import 'package:teacher_aide/ui/Student/widget/_showEditDialog.dart';
import 'package:teacher_aide/widget/_checkIsTeacher.dart';
import 'package:http/http.dart' as http;


class FetchStudents extends StatefulWidget {
  DocumentSnapshot<Object?> course;
  FetchStudents({Key? key, required this.course}) : super(key: key);

  @override
  State<FetchStudents> createState() => _FetchStudentsState();
}

class _FetchStudentsState extends State<FetchStudents> {

  late CollectionReference<Map<String, dynamic>> _studentCourseMappingRef;
   Map<int, bool> _userInfoFetched = {}; // Map to track if user info is fetched for each student
   Map<int, ImageProvider<Object>?> _profileImages = {}; // Map to store profile images for each student
  bool isTeacher=false;  
  Uint8List? _image;
  
  double circleAvatarRadius=34.0;
  String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';
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
  void initState() {
    super.initState();
    _studentCourseMappingRef = FirebaseFirestore.instance.collection("student_course_mapping");
     // Perform the asynchronous operation here
    checkIsTeacher().then((result) {
      // Update the state with the result
      setState(() {
        isTeacher = result;
      });
    });
  }
  
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: StreamBuilder(
        stream: _studentCourseMappingRef
            .where('courseId', isEqualTo: widget.course.id)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Something is wrong"));
          }

          List<DocumentSnapshot>? documents =
              snapshot.data != null ? snapshot.data!.docs : [];

          var length = snapshot.data == null ? 0 : snapshot.data!.docs.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 15),
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromRGBO(25, 103, 210, 1),
                      width: 1.4,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Total Students: $length',
                    style: TextStyle(
                        fontSize: 20, color: Color.fromRGBO(25, 103, 210, 1)),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: length,
                  itemBuilder: (_, index) {
                    DocumentSnapshot _documentSnapshot = documents![index];
                    String studentId =
                        _documentSnapshot['studentId'].toString();
                    int rollNumber = int.parse(studentId);
                    fetchUserInfo(rollNumber);
                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("students")
                          .where('roll', isEqualTo:int.parse(studentId))
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> studentSnapshot) {                
                        if (studentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(" ");
                        }
                        if (studentSnapshot.hasData) {
                          List<QueryDocumentSnapshot> documents =
                              studentSnapshot.data!.docs;                             
                          if (documents.isNotEmpty) {
                            QueryDocumentSnapshot studentDocument =
                                documents.first;
                            Map<String, dynamic> studentData =
                                studentDocument.data() as Map<String, dynamic>;
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 4),
                              decoration: BoxDecoration(),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading:GestureDetector(
                                    onTap: () {
                                      _showImageDialog(context, _profileImages[rollNumber], studentData['name']);
                                    },
                                  child:CircleAvatar(
                                    radius: circleAvatarRadius,
                                    backgroundImage: _profileImages[rollNumber] ?? const NetworkImage('https://static-00.iconduck.com/assets.00/avatar-default-icon-1975x2048-2mpk4u9k.png'),
                                    //backgroundColor: Color.fromARGB(255, 182, 46, 5),
                                  ),
                                ),
                                title: Text(
                                  capitalize(studentData['name'].toString()), // Capitalize the first character of the name
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                subtitle: Text(studentData['roll'].toString()),
                                trailing: isTeacher ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      showEditDialog(
                                          context,studentSnapshot.data!.docs.first,widget.course);
                                    } else if (value == 'delete') {
                                      showDeleteDialog(
                                          context,
                                          studentId,
                                          _studentCourseMappingRef,
                                          widget.course,
                                          studentData['roll']);
                                    }
                                  },
                                  itemBuilder:
                                      (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: ListTile(
                                        title: Text('Edit'),
                                        leading: Icon(Icons.edit),
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: ListTile(
                                        title: Text('Delete'),
                                        leading: Icon(Icons.delete),
                                      ),
                                    ),
                                  ],
                                ):null,
                              ),
                            );
                          } else {
                            // Handle the case where no matching student is found
                            print(
                                'Error: No matching student found for studentId: $studentId');
                            return const SizedBox.shrink(); // Return an empty widget if no matching student is found
                          }
                        } else {
                          // Handle the case where there's an error fetching data
                          print(
                              'Error fetching student data: ${studentSnapshot.error}');
                          return const SizedBox
                              .shrink(); // Return an empty widget if there's an error
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
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
              Text(student, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
