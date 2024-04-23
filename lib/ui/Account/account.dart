import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teacher_aide/ui/Account/data/add_data.dart';

import 'package:teacher_aide/ui/Account/widget/utils.dart';
import 'package:http/http.dart' as http;
import 'package:teacher_aide/widget/_fetchUid.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});  

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  int roll=0;

  bool isEditing = false;
  Uint8List? _image;
  ImageProvider<Object>? _profileImage;

  void selecteImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  

  //fetchUserInfo
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
        // Set values to controllers
        nameController.text = userData['name'] ?? '';
        roll = userData['roll'] ?? 0;
        rollNumberController.text=roll.toString();
        // Fetch the image bytes and set _image
        if (userData['imageLink'] != null) {
          final String imageUrl = userData['imageLink'];
          _image = await fetchImageBytes(imageUrl);
        } else {
          _image = null;
        }

        // Determine the appropriate ImageProvider
        ImageProvider<Object>? profileImage;
        if (_image != null) {
          profileImage = MemoryImage(_image!);
        } else if (userData['imageLink'] != null) {
          profileImage = NetworkImage(userData['imageLink']);
        } else {
          profileImage = const NetworkImage(
            'https://static-00.iconduck.com/assets.00/avatar-default-icon-1975x2048-2mpk4u9k.png',
          );
        }

        // Update the UI
        setState(() {
          _profileImage = profileImage;
        });
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
    fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 28),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: _profileImage,
                    ),
                    if (isEditing)
                      Positioned(
                        child: IconButton(
                          onPressed: selecteImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                        bottom: -10,
                        left: 80,
                      ),
                  ],
                ),
                SizedBox(height: 16),

                // User Information
                TextFormField(
                  controller: nameController,
                  enabled: isEditing,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: rollNumberController,
                  enabled: isEditing,
                  decoration: InputDecoration(
                    labelText: 'Reg. No',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  enabled: isEditing,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: phoneNumberController,
                  enabled: isEditing,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),

                // Save button
                if (isEditing)
                  ElevatedButton(
                    onPressed: () {
                      // Save changes and exit edit mode
                      saveChanges();
                    },
                    style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 3, 66, 117), // Change the background color here
                ),
                    child: Text('Save', style: TextStyle(fontSize: 18,color: Colors.white)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to save changes
  Future<void> saveChanges() async {
    //implement logic here to save the changes
    // After saving changes, exit edit mode
    String uid=await fetchUid();
    await StoreData()
        .saveData(
            uid: uid,
            name: nameController.text,
            roll: rollNumberController.text,
            file: _image!,
            email: emailController.text,
            phone: phoneNumberController.text
            )
        .then((value) {
      Navigator.pop(context);
    });
    setState(() {
      isEditing = false;
    });
  }
}
