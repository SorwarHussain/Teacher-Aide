import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Home/widget/_selectedItem.dart';

PreferredSizeWidget buildHomeAppBar(BuildContext context) {
return AppBar(
        title: const Text('Teacher Aide'),
        actions: [
          Theme(
           data: Theme.of(context).copyWith(
               textTheme: TextTheme().apply(bodyColor: Colors.white), // Set text color to white
                dividerColor: Colors.white, // Set divider color if needed
                //customize other properties like icon color here if needed
              ),
            child: PopupMenuButton<int>(
             // color: Colors.black,
              itemBuilder: (context) => [
                //settings page option
                PopupMenuItem<int>(value: 0,
                child: Row(
                    children: [
                      Icon(Icons.settings), // Add desired icon here
                      const SizedBox(
                        width: 7,
                      ),
                      Text("Settings")
                    ],
                  ),
                ),
               PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.dashboard_rounded), // Add desired icon here
                      const SizedBox(
                        width: 7,
                      ),
                      Text("Account")
                    ],
                  ),
                ),
                  PopupMenuItem<int>(
                  value: 3,
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
                PopupMenuDivider(),
                PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text("Logout")
                      ],
                    )),
              ],
              onSelected: (item) => SelectedItem(context, item),
            ),
          ),
        ],
      );
}