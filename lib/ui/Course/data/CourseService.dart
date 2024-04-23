import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teacher_aide/widget/_fetchUserInfo.dart';

class CourseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> fetchTeacherCourses() {
    var currentUser = _auth.currentUser;

    // Fetch courses for the teacher
    return FirebaseFirestore.instance
        .collection("courses")
        .where('instructor', isEqualTo: currentUser?.email)
        .snapshots();
  }
   late String name;
  
  // Step 1: Fetch student's enrolled courses IDs
  Stream<List<String>> fetchStudentEnrolledCourseIds(int rollNumber) {
   return FirebaseFirestore.instance
        .collection("student_course_mapping")
        .where('studentId', isEqualTo: rollNumber)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['courseId'].toString()).toList());
  }
  // Step 2: Fetch course details based on course IDs
  Stream<List<DocumentSnapshot>> fetchStudentEnrolledCourses(List<String> courseIds) {
    return FirebaseFirestore.instance
        .collection("courses")
        .where(FieldPath.documentId, whereIn: courseIds)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.toList());
  }

    // Step 2: Fetch course details based on course IDs
  Stream<List<DocumentSnapshot>> fetchCourseStudents(List<String> studentIds) {
    return FirebaseFirestore.instance
        .collection("students")
        .where('roll', whereIn: studentIds)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.toList());
  }
  
  Future<void> fetchUserData() async {
    await userInfoManager.fetchUserInfo();
    // Access values
    name = userInfoManager.name;
   // rollNumber = userInfoManager.rollNumber;
  }
 

}