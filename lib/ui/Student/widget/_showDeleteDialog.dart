import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_aide/widget/_studentCourseMappingRef.dart';



//show dialog for delete
void showDeleteDialog(BuildContext context, String documentId,CollectionReference studentsCollection, DocumentSnapshot<Object?> course, int rollNumber) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this student?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              deleteStudent(context,studentsCollection, documentId,course,rollNumber);
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Delete"),
          ),
        ],
      );
    },
  );
}
// Delete student and corresponding entries in student course mapping table
void deleteStudent(BuildContext context, CollectionReference studentsCollection, String documentId, DocumentSnapshot<Object?> course, int rollNumber) async {
  try {    

    // Delete corresponding entries in the student course mapping table
    final studentCourseMappingQuerySnapshot = await createStudentCourseMappingReference()
        .where('studentId', isEqualTo: rollNumber)
        .where('courseId', isEqualTo: course.id)
        .get();
 
    // Delete each document in the query snapshot
    for (var doc in studentCourseMappingQuerySnapshot.docs) {
      await doc.reference.delete();
    }    

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student deleted successfully.')),
    );
  } catch (e) {
    // Handle errors
    print('Error deleting student: $e');
   /* ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred while deleting the student.')),
    );*/
  }
}