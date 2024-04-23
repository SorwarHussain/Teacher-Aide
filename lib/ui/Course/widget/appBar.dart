import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Course/widget/_showItemMenuOnMoreVert.dart';

PreferredSizeWidget buildAppBar(context, course, isTeacher) {
  return AppBar(
        //title: const Text('title'),
        title: Text(course['code']),
          actions: [
          Theme(
            data: Theme.of(context).copyWith(
               textTheme: TextTheme().apply(bodyColor: Colors.white), // Set text color to white
                dividerColor: Colors.white, // Set divider color if needed
                //customize other properties like icon color here if needed
              ),
              child: PopupMenuButton<int>(
              //  color: Colors.black, // Set background color to black
              itemBuilder: (context) {
                 List<PopupMenuItem<int>> items = [];
              
                  items.addAll([
                    PopupMenuItem<int>(
                  value: 10,
                  child: Row(
                    children: [
                      Icon(Icons.refresh_outlined), // Add desired icon here
                      const SizedBox(
                        width: 7,
                      ),
                      Text("Refresh")
                    ],
                  ),
                ),
                 ]);
              if (isTeacher)
                items.addAll([
                  PopupMenuItem<int>(value: 0, child: const Text("Upload Students (CSV)")),
                  PopupMenuItem<int>(value: 1, child: const Text("Upload Students (Excel)")),
                  PopupMenuItem<int>(value: 2, child: const Text("Add Manually Students")),
                  PopupMenuItem<int>(value: 6, child: const Text("Classs Settings")), 
                ]);
             

              items.addAll([
               // const PopupMenuDivider(),
                PopupMenuItem<int>(
                  value: 3,
                  child: isTeacher ? const Text("Students") : const Text('People'),
                ),
                PopupMenuItem<int>(value: 5, child: const Text("Statistics")),                
                PopupMenuItem<int>(value: 4, child: const Text("Export Statistics")),
                PopupMenuItem<int>(value: 7, child: const Text("Merge attendance")),
                 PopupMenuItem<int>(value: 8, child: const Text("stat-1")),
                  PopupMenuItem<int>(value: 9, child: const Text("stat-2")),
              ]);

              return items;
              },
              onSelected: (item) => SelectedItem(context, item, course, isTeacher),
            ),
          ),
        ],
      );
}

