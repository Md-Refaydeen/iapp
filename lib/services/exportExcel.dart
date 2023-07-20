import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iapp/dto/user.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExportExcel {
  Future<void> exportOverMonth(BuildContext context, List attendanceDetails,
      Future<List<User>> attendanceCount) async {
    var excel =
        Excel.createExcel(); // automatically creates 1 empty sheet: Sheet1
    List<User> users = await attendanceCount;
    Sheet sheet = excel['Sheet1'];
    sheet.setColWidth(0, 30); // sets the width of column A to 20
    sheet.setColWidth(1, 10); // sets the width of column B to 30
    sheet.setColWidth(2, 10); //
    excel.appendRow('Sheet1', ["Name", "Present", "Absent"]);

    excel.appendRow('Sheet1', []);
    for (int i = 0; i < users.length; i++) {
      User user = users[i];
      print(user.name);
      excel.appendRow('Sheet1', [user.name, user.Present, user.Absent]);
    }

    Sheet sheetObject = excel['OverAll Report'];
    sheetObject.setColWidth(0, 22.0);
    sheetObject.setColWidth(1, 22.0);
    sheetObject.setColWidth(2, 20.0);
    sheetObject.setColWidth(3, 40.0);
    sheetObject.setColWidth(4, 20.0);
    sheetObject.setColWidth(5, 20.0);
    sheetObject.setColWidth(6, 40.0);
    sheetObject.setColWidth(7, 25.0);
    sheetObject.setColWidth(8, 20.0);
    sheetObject.setColWidth(9, 20.0);

    sheetObject.appendRow([
      "Employee Name",
      "Attendance Date",
      "Time in",
      'Login Location',
      "WorkMode",
      "Time Out",
      "Logout Location",
      "WorkModeCheckOut",
      "Total Time",
      "Status"
    ]);

    for (var attendance in attendanceDetails) {
      for (String key in attendance.keys) {
        sheetObject.appendRow([key]);

        if (attendance[key] is List) {
          for (var value in attendance[key]) {
            sheetObject.appendRow([
              value[''],
              value['date'],
              value['loginTime'],
              value['loginLocation'],
              value['workmode'],
              value['logoutTime'],
              value['logoutLocation'],
              value['workModeCheckOut'],
              value['totalWorkingHours'],
              value['status']
            ]);
          }
        } else {
          sheetObject.appendRow(['${attendance[key]}']);
        }
      }
    }

    String outputFile;
    final Directory? dir = await getExternalStorageDirectory();
    outputFile = '${dir?.path}/EmployeeReport.xlsx';
    print(outputFile);

    try {
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(path.join(outputFile))
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }
    } on FileSystemException catch (e) {
      print('Error while writing to the file: $e');
    } catch (e) {
      print('Unknown error: $e');
    }

    // Show a notification to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your Excel file has been saved.'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            print(outputFile);
            final message = OpenFile.open(outputFile);
          },
        ),
      ),
    );
  }

  Future<void> exportOverRange(BuildContext context, List attendanceDetails,
      List attendanceCount) async {
    var excel =
        Excel.createExcel(); // automatically creates 1 empty sheet: Sheet1

    Sheet sheet = excel['Sheet1'];
    sheet.setColWidth(0, 30); // sets the width of column A to 20
    sheet.setColWidth(1, 10); // sets the width of column B to 30
    sheet.setColWidth(2, 10); //
    CellStyle style = CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center);
    excel.appendRow(
      'Sheet1',
      ["Name", "Present", "Absent"],
    );

    excel.appendRow('Sheet1', []);
    for (var count in attendanceCount) {
      excel.appendRow(
        'Sheet1',
        [count['name'], count['Present'], count['Absent']],
      );
    }

    Sheet sheetObject = excel['OverAll Report'];
    sheetObject.setColWidth(0, 22.0);
    sheetObject.setColWidth(1, 22.0);
    sheetObject.setColWidth(2, 20.0);
    sheetObject.setColWidth(3, 40.0);
    sheetObject.setColWidth(4, 20.0);
    sheetObject.setColWidth(5, 20.0);
    sheetObject.setColWidth(6, 40.0);
    sheetObject.setColWidth(7, 25.0);
    sheetObject.setColWidth(8, 20.0);
    sheetObject.setColWidth(9, 20.0);

    sheetObject.appendRow(
      [
        "Employee Name",
        "Attendance Date",
        "Time in",
        'Login Location',
        "WorkMode",
        "Time Out",
        "Logout Location",
        "WorkModeCheckOut",
        "Total Time",
        "Status"
      ],
    );

    for (var attendance in attendanceDetails) {
      for (String key in attendance.keys) {
        sheetObject.appendRow(['$key']);

        if (attendance[key] is List) {
          for (var value in attendance[key]) {
            sheetObject.appendRow([
              value[''],
              value['date'],
              value['loginTime'],
              value['loginLocation'],
              value['workmode'],
              value['logoutTime'],
              value['logoutLocation'],
              value['workModeCheckOut'],
              value['totalWorkingHours'],
              value['status']
            ]);
          }
        } else {
          sheetObject.appendRow(['${attendance[key]}']);
        }
      }
    }

    String outputFile;
    final Directory? dir = await getExternalStorageDirectory();
    outputFile = '${dir?.path}/EmployeeReport.xlsx';
    print(outputFile);

    try {
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(path.join(outputFile))
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }
    } on FileSystemException catch (e) {
      print('Error while writing to the file: $e');
    } catch (e) {
      print('Unknown error: $e');
    }

    // Show a notification to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your Excel file has been saved.'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            print(outputFile);
            final message = OpenFile.open(outputFile);
          },
        ),
      ),
    );
  }

  Future<void> exportIndividualData(
      BuildContext context, List<User> data) async {
    List<User> users = data;

    var excel =
        Excel.createExcel(); // automatically creates 1 empty sheet: Sheet1
    Sheet sheetObject = excel['Sheet1'];
    CellStyle headerStyle = CellStyle(
        backgroundColorHex: "#0000FF",
        fontSize: 30,
        bold: true,
        fontFamily: getFontFamily(FontFamily.Abadi_MT_Condensed_Extra_Bold));
    var cell = sheetObject.cell(CellIndex.indexByString("A2"));
    cell.cellStyle = headerStyle;

    sheetObject.appendRow(
      ["Attendance Report"],
    );

    CellStyle cellStyle = CellStyle(
        backgroundColorHex: "#1AFF1A",
        fontFamily: getFontFamily(FontFamily.Calibri));
    cell.cellStyle = cellStyle;
    sheetObject.setColWidth(0, 22.0);
    sheetObject.setColWidth(1, 22.0);
    sheetObject.setColWidth(2, 20.0);
    sheetObject.setColWidth(3, 40.0);
    sheetObject.setColWidth(4, 20.0);
    sheetObject.setColWidth(5, 20.0);
    sheetObject.setColWidth(6, 40.0);

    sheetObject.appendRow([
      "Employee Name",
      "Attendance Date",
      "Time in",
      'Login Location',
      'Work Mode',
      "Time Out",
      "Logout Location",
      "Total Time",
      "WorkModeCheckOut",
      "Status"
    ]);

    for (var i = 0; i < users.length; i++) {
      User user = users[i];
      print(user.name);
      sheetObject.appendRow([
        user.name,
        user.date,
        user.loginTime,
        user.loginLocation,
        user.workmode,
        user.logoutTime,
        user.logoutLocation,
        user.totalWorkingHours,
        user.workModeCheckOut,
        user.status
      ]);
    }
    String outputFile;
    final Directory? dir = await getExternalStorageDirectory();
    outputFile = '${dir?.path}/file.xlsx';
    print(outputFile);

    try {
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(path.join(outputFile))
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }
    } on FileSystemException catch (e) {
      print('Error while writing to the file: $e');
    } catch (e) {
      print('Unknown error: $e');
    }
    // / Show a notification to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your Excel file has been saved.'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            print(outputFile);
            final message = OpenFile.open(outputFile);
          },
        ),
      ),
    );
  }
}
