import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_aide/ui/Attendance/widget/_createAttendanceRef.dart';
import 'package:teacher_aide/ui/Course/widget/TakenClass.dart';

CollectionReference _collectionClassRef=createAttendanceReference(); 

Future<List<TakenClass>> fetchTakenClasses(DocumentSnapshot<Object?> course) async {
  final QuerySnapshot<Object?> querySnapshot = await _collectionClassRef
      .where('courseId', isEqualTo: course.id)
      .get();


    List<TakenClass> takenClasses = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      int presentCount = 0;
      int absentCount = 0;
      int lateCount = 0;

      List<dynamic> attendanceData = data['attendanceData'] ?? [];

      attendanceData.forEach((record) {
        String status = record['status'];
        if (status == 'P') {
          presentCount++;
        } else if (status == 'A') {
          absentCount++;
        } else if (status == 'L') {
          lateCount++;
        }
      });

      return TakenClass(
        docId: doc.id,
        time: data['time'].toString(),
        date: data['date'].toString(),
        attendanceWeight: data['weight'] as int,
        classDuration: data['duration'] as int,
        presentCount: presentCount,
        absentCount: absentCount,
        lateCount: lateCount,
      );
    }).toList();

    return takenClasses;
    
}