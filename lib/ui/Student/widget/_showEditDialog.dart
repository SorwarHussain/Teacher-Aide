import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_aide/widget/_studentCourseMappingRef.dart';

void showEditDialog(BuildContext context, DocumentSnapshot documentSnapshot, DocumentSnapshot<Object?> course) {
  TextEditingController nameController = TextEditingController();
  TextEditingController rollController = TextEditingController();

  // Set initial values from the document snapshot
  nameController.text = documentSnapshot['name'];
  rollController.text = documentSnapshot['roll'].toString();
  int rollNumberOld=documentSnapshot['roll'];
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Student'),
        content: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: rollController,
              decoration: InputDecoration(labelText: 'Reg. No'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog without saving changes
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save the changes and update the Firestore document
                     int? roll = int.tryParse(rollController.text);
              if (roll != null) {
                // Save the changes and update the Firestore document
                _updateStudent(documentSnapshot.reference, {
                  'name': nameController.text,
                  'roll': roll,
                },rollNumberOld,course).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student details updated successfully!')),
                  );
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update student details: $error')),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid Roll number. Please enter a valid integer.')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> _updateStudent(DocumentReference documentReference, Map<String, dynamic> data,int rollNumberOld, DocumentSnapshot<Object?> course) async {
   try {
    // Update the Firestore document using the provided data
    if(data['roll']!=rollNumberOld){
       final studentCourseMappingSnapshot = await createStudentCourseMappingReference()
            .where('studentId', isEqualTo: rollNumberOld)
            .where('courseId', isEqualTo: course.id)
            .get();

             // Iterate over each document in the snapshot and update 'studentId' field
      for (var doc in studentCourseMappingSnapshot.docs) {
        await doc.reference.update({'studentId': data['roll']});
      }
    }
    await documentReference.update(data);
    print('Student updated successfully!');
  } catch (error) {
    print('Error updating student: $error');
    // Rethrow the error to be caught by the caller
    throw error;
  }
}
