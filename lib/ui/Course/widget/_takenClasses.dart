import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:teacher_aide/ui/Course/widget/TakenClass.dart';
import 'package:teacher_aide/ui/Course/widget/_buildClassCard.dart';
import 'package:teacher_aide/ui/Course/widget/_fetchTakenClasses.dart';

 
Widget takenClasses({required DocumentSnapshot<Object?> course,required bool isTeacher}) {
  return Scaffold(
    /*appBar: AppBar(
      title: Text('My Taken Classes'),
    ),*/
    body: FutureBuilder(
      future: fetchTakenClasses(course),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final List<TakenClass>? takenClasses = snapshot.data;
          if (takenClasses!.isEmpty) {
            return Center(child: Text('No classes taken yet.'));
          } else {
            return ListView.builder(
              itemCount: takenClasses.length,
              itemBuilder: (context, index) {
                return buildClassCard(takenClasses[index],course,isTeacher);
              },
            );
          }
        } else {
          return Center(child: Text('No classes taken yet.'));
        }
      },
    ),
  );
}