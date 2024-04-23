import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


//show dialog for delete
void showDeleteDialogCourse(BuildContext context, DocumentReference<Object?> reference) {
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
              deleteCourse(context,reference);
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Delete"),
          ),
        ],
      );
    },
  );
}
//delete 
void deleteCourse(BuildContext context, DocumentReference<Object?> reference) async {
  try {
    // Delete the document using the delete() method
    await reference.delete();

    // Display a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully deleted'),
      ),
    );

    // Optional: If you want to print a message to the console
   // print("Course deleted successfully!");
  } catch (e) {
    // Handle errors, and display an error message if necessary
    print("Error deleting course: $e");
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error deleting course'),
      ),
    );*/
  }
}