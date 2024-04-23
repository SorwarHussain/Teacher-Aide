import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teacher_aide/ui/Account/widget/_userRef.dart';
import 'package:teacher_aide/ui/Student/widget/Student.dart';
import 'package:teacher_aide/widget/_studentRef.dart';

final FirebaseStorage _storage=FirebaseStorage.instance;
final FirebaseFirestore _firestore=FirebaseFirestore.instance;

 final FirebaseAuth _auth = FirebaseAuth.instance;
    var currentUser = _auth.currentUser;



class StoreData{

  Future<String> uploadImageToStorage(String childName, Uint8List file) async{
    Reference ref=_storage.ref().child(childName).child(currentUser!.email.toString());
    UploadTask uploadTask=ref.putData(file);
    TaskSnapshot snapshot=await uploadTask;
    String downloadUrl=await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  
  Future<String>saveData({
    required String uid,
    required String name,
    required String roll,
    required Uint8List file,
    String? email, // Make email optional
  String? phone, // Make phone optional
  }) async{
    String resp="Some Error Occurred";
    try{
     String imageUrl=await uploadImageToStorage('profileImage', file);
     await createUserReference()
     .doc(uid)
        .update({
       "name": name,
      "roll": int.tryParse(roll),
      if (email != null) "email": email, // Add email only if provided
      if (phone != null) "phone": phone, // Add phone only if provided
      "imageLink": imageUrl,
    });
      //below code segment save the user data in the student table. further we can fetch as we needed.
     //String studentName = name;
      int studentRoll = int.tryParse(roll) ?? 0;

      if (name.isNotEmpty && studentRoll > 0) {
        Student newStudent = Student(name, studentRoll,email:email,phone:phone);
        await createStudentReference().add(newStudent.toMap());
      }

    return resp="success";
    }
    catch(err){
      resp=err.toString();
    }
    return resp;
  }
}