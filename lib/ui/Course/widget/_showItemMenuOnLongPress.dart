import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import 'package:teacher_aide/ui/Course/widget/_showDeleteDialogCourse.dart';
import 'package:teacher_aide/ui/Course/widget/_showEditDialogCourse.dart';


void showItemMenuOnLongPress(BuildContext context, DocumentReference<Object?> reference) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        overlay.localToGlobal(Offset.zero),
        overlay.localToGlobal(overlay.size.bottomRight(Offset.zero)),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
          ),
          onTap: () {
            // Implement delete functionality
             showDeleteDialogCourse(context,reference); 
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
          ),
          onTap: () {
            // Implement edit functionality
            showEditDialogCourse(context, reference);
          },
        ),
      ],
    );
  }