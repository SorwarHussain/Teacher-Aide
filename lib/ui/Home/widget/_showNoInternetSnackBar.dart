import 'package:flutter/material.dart';

void showNoInternetSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.yellow),
            SizedBox(width: 8),
            Text('No internet connection'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(days: 1), // Set a long duration for persistence
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            // Dismiss the SnackBar manually if needed
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }