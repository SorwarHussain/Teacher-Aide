import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:teacher_aide/ui/Course/data/_addData.dart';

  //handle importing csv file 
void pickFile(BuildContext context,course) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    String? filePath;
    List<List<dynamic>> _data = [];

    
    // if no file is picked
    if (result == null) return;
    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
   
      _data = fields;
  
    addData(context, course,_data);
  }