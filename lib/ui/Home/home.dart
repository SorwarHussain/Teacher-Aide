import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Course/create_course.dart';
import 'package:teacher_aide/ui/Course/joinCourse.dart';


import 'package:teacher_aide/ui/Course/widget/fetchCourse.dart';
import 'package:teacher_aide/widget/_checkIsTeacher.dart';

import 'package:teacher_aide/ui/Home/widget/_showFloatingActionButtonMenu.dart';
import 'package:teacher_aide/ui/Home/widget/_showNoInternetSnackBar.dart';
import 'package:teacher_aide/ui/Home/widget/homeAppBar.dart';
import 'package:teacher_aide/widget/_fetchUid.dart';
import 'package:teacher_aide/ui/Account/account.dart';

import 'package:teacher_aide/ui/Settings/setting_page.dart';



class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
bool isTeacher=false;

class _HomeState extends State<Home> {
  late Connectivity _connectivity;
  int rollNumber=0;

  
    Future<void> fetchUserInfo() async {
    try {
      CollectionReference _collectionRef =
          FirebaseFirestore.instance.collection("users");
    String uid=await fetchUid();
      DocumentSnapshot<Object?> documentSnapshot =
          await _collectionRef.doc(uid).get();

      if (documentSnapshot.exists) {
        //Object userData = documentSnapshot.data()!;
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
       // print(userData);
        // Set values to controllers
       
       int roll = userData['roll'] ?? 0;
       rollNumber=roll;
      // print(rollNumber);
      }
         } catch (e) {
      print("Error fetching user information: $e");
    }
    }
    

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
     // Perform the asynchronous operation here
    checkIsTeacher().then((result) {
      // Update the state with the result
      setState(() {
        isTeacher = result;
      });
    });
   _connectivity = Connectivity();
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // Show "No internet connection" SnackBar
        showNoInternetSnackBar(context);
      } else {
        // Hide any existing SnackBar when internet connection is restored
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }
   Future<void> _refreshData() async {
    setState(() {
      // Reset the roll number if needed
     // rollNumber = 0;
    });
    // Fetch course data again
    await fetchCourse(isTeacher, rollNumber);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: buildHomeAppBar(context),
      appBar: AppBar(
        title: const Text('Teacher Aide'),
        actions: [
          Theme(
           data: Theme.of(context).copyWith(
               textTheme: TextTheme().apply(bodyColor: Colors.white), // Set text color to white
                dividerColor: Colors.white, // Set divider color if needed
                //customize other properties like icon color here if needed
              ),
            child: PopupMenuButton<int>(
             // color: Colors.black,
              itemBuilder: (context) => [
                if(isTeacher)
                  //settings page option
                  PopupMenuItem<int>(value: 0,
                  child: Row(
                      children: [
                        Icon(Icons.settings), // Add desired icon here
                        const SizedBox(
                          width: 7,
                        ),
                        Text("Settings")
                      ],
                    ),
                  ),
                
               PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.dashboard_rounded), // Add desired icon here
                      const SizedBox(
                        width: 7,
                      ),
                      Text("Account")
                    ],
                  ),
                ),
                  PopupMenuItem<int>(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.refresh_outlined), // Add desired icon here
                      const SizedBox(
                        width: 7,
                      ),
                      Text("Refresh")
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text("Logout")
                      ],
                    )),
              ],
              onSelected: (item) => SelectedItem(context, item),
            ),
          ),
        ],
      ),
       body:  RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder(
        future: _refreshData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return fetchCourse(isTeacher, rollNumber);
          }
        },
      ),
    ),
      //fetch and show all exists course
      //Add Course or join course floating action button 
      floatingActionButton:  FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 3, 66, 117),
        onPressed: () {
          // Show the menu when the floating action button is pressed
         // showFloatingActionButtonMenu(context);
         if(isTeacher){
           Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => CreateCourse()));
         }
          else{
             Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => JoinCoursePage()));
          }
        },
        child: Icon(Icons.add,color: Colors.white),
      ),
     // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }  
  void SelectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SettingPage()));
        break;
          case 2:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AccountPage()));
        break;
        case 3:
           //OpenFile.open('/storage/emulated/0/Download/excel6.xlsx');
           _refreshData();
        break;
      case 1:
        Logout();
        break;
    }
  } 

}

//logout function
  void Logout() async {
    await FirebaseAuth.instance.signOut();
  }

