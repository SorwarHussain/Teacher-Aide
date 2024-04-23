import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_aide/widget/_fetchUid.dart';


class UserInfoManager {
  String _name='';
  int _rollNumber=0;

  String get name => _name;
  int get rollNumber => _rollNumber;

  Future<void> fetchUserInfo() async {
     try {
      CollectionReference _collectionRef =
          FirebaseFirestore.instance.collection("users");
    String uid=await fetchUid();
      DocumentSnapshot<Object?> documentSnapshot =
          await _collectionRef.doc(uid).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
       
        // Set values
        _name = userData['name'] ?? '';
        _rollNumber = userData['roll'] ?? 0;
      }
    } catch (e) {
      print("Error fetching user information: $e");
    }
  }
}

// Singleton instance
UserInfoManager userInfoManager = UserInfoManager();

