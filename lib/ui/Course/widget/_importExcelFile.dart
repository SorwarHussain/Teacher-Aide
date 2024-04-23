import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:teacher_aide/ui/Course/data/_addData.dart';

Excel parseExcelFile(List<int> _bytes) {
  return Excel.decodeBytes(_bytes);
}
//import excel file
void importFile(BuildContext context,course) async {
    File? file;
    List<List<dynamic>> _data = [];
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
      if (result != null) file = File(result.files.single.path!);      
    } catch (e) {}

    if (file != null) {
      List<int> _bytes = await file.readAsBytes();
      Excel excel = await compute(parseExcelFile, _bytes);
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {      
            String name = row[0]!.value.toString();
            dynamic rollValue = row[1]!.value;
            if (rollValue is double) {
                int roll = rollValue.toInt(); // Convert to int if it's a double
                List<dynamic> rowData = [name, roll];
                _data.add(rowData);
            } 
        }       
      }
    }
    addData(context,course,_data);
  }