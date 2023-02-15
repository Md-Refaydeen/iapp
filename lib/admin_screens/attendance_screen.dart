import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:iapp/admin_screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../constants/constants.dart';
import '../dto/user.dart';
import '../screens/login_screen.dart';
import '../services/getLoc_Time.dart';
import '../widgets/admindrawer_components.dart';
import 'individual_attendance.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({Key? key}) : super(key: key);
  static String routeName = 'AdminAttendanceScreen';

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  GlobalKey<ScaffoldState> key = GlobalKey();

  int? current_mon, year, month;
  static var _searchController = TextEditingController();

  Future<List<User>>? _user;
  Location location = Location();
  String? _searchString, name, empId;
  List<User> _filteredUser = [];
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  final dataTableKey = GlobalKey<_AdminAttendanceScreenState>();

  List months = [
    'January',
    'Febraury',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    // TODO: implement initState
    location.requestPermission();
    location.getDate();
    year = int.parse(location.year);
    month = int.parse(location.month);
    _user = fetchCount(currentMonth, currentYear);

    fetchCount(month, year).then((value) {
      setState(() {
        print(value);
        _filteredUser = value;
      });
    });
  }

  void _filterUsers(value) {
    setState(() {
      _searchString = value;
      print(_searchString);
      if (_searchString!.isEmpty) {
        _filteredUser = _user as List<User>;
      } else {
        _filteredUser = _filteredUser
            .where((data) => data.name!.contains(_searchString!))
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      fetchCount(month, year).then((value) {
        setState(() {
          _filteredUser = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerComponent(
        image: 'assets/images/user.png',
        name: 'Admin',
        onPress1: () {
          Navigator.pushNamed(context, AdminHomeScreen.routeName);
        },
        onPress2: () {
          Navigator.pushNamed(context, AdminAttendanceScreen.routeName);
        },
        onPress3: () {
          Navigator.pushNamed(context, LoginScreen.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Logged out Successfully".toString())));
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(children: [
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xB6B091CF),
                      Color(0xFFAD8DCD),
                    ]),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            icon: Icon(
                              Icons.menu,
                              color: Color(0xFF3F3D56),
                              size: 23,
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AdminHomeScreen.routeName);
                              },
                              icon: Icon(
                                Icons.arrow_circle_left_outlined,
                                color: Color(0xFF3F3D56),
                                size: 28,
                              ))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(65.0),
                        child: Text(
                          'Attendance Details',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: adminHomeBG,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.height / 14.5,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(splashColor: Colors.transparent),
                          child: TextField(
                            controller: _searchController,
                            autofocus: false,
                            onChanged: (value) {
                              _filterUsers(value);
                            },
                            style: TextStyle(
                                fontSize: 15.0, color: Color(0xFFbdc6cf)),
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {},
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _clearSearch();
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Search',
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 12.0, top: 6.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20.7),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20.7),
                              ),
                            ),
                          ),
                        ),
                        decoration: new BoxDecoration(
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(20.0)),
                            color: Colors.white),
                        margin: new EdgeInsets.fromLTRB(20, 40, 20, 0.0),
                        padding: new EdgeInsets.fromLTRB(8, 8, 8, 8),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 17,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: _user,
                              builder: (context, snapshot) {
                                print(snapshot.data);
                                print(snapshot.hasData);
                                if (snapshot.hasData) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width /
                                        1.15,
                                    decoration: BoxDecoration(
                                        //borderRadius: BorderRadius.circular(15.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 15.0,
                                            offset: Offset(0, 2),
                                          )
                                        ]),
                                    child: DataTable(
                                      key: dataTableKey,
                                      columnSpacing: 35,
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => BGcolor),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                          bottomRight: Radius.circular(6),
                                          bottomLeft: Radius.circular(6),
                                        ), // this only make bottom rounded and not top
                                        color: Colors.white,
                                      ),
                                      columns: [
                                        DataColumn(
                                          label: Text(
                                            'S.No',
                                            style: TextStyle(
                                                color: Color(0xff003756)),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Name',
                                            style: TextStyle(
                                                color: Color(0xff003756)),
                                          ),
                                        ),
                                        DataColumn(
                                            label: Text('Present',
                                                style: TextStyle(
                                                    color: Color(0xff003756)))),
                                        DataColumn(
                                            label: Text('Absent',
                                                style: TextStyle(
                                                    color: Color(0xff003756)))),
                                      ],
                                      rows: _filteredUser
                                              ?.asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            var _user = entry.value;

                                            return DataRow(
                                              cells: [
                                                DataCell(Text("${index + 1}")),
                                                DataCell(
                                                    Text(_user.name == null
                                                        ? '----'
                                                        : '${_user.name}'),
                                                    onTap: () {
                                                  setState(() {
                                                    name = _user.name;
                                                  });
                                                  Navigator.pushNamed(
                                                      context,
                                                      UserAttendanceScreen
                                                          .routeName,
                                                      arguments: {
                                                        'name': name
                                                      });
                                                }),
                                                DataCell(Center(
                                                  child: Container(
                                                    height: 22,
                                                    width: 22,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      gradient:
                                                          LinearGradient(colors: [
                                                        Color(0xFF5278FF),
                                                        Color(0xFF6C84D9),
                                                      ]),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        _user.Present == null
                                                            ? '----'
                                                            : '${_user.Present}',
                                                        style: TextStyle(
                                                            color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                                DataCell(

                                                  Center(
                                                    child: Container(
                                                      height: 22,
                                                      width: 22,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5),
                                                        gradient: LinearGradient(
                                                            colors: [
                                                              Color(0xFFCE3636),
                                                              Color(0xFFFF0000),
                                                            ]),
                                                      ),
                                                      child: Center(
                                                        child: Text(_user
                                                                    .Absent ==
                                                                null
                                                            ? '----'
                                                            : '${_user.Absent}',style: TextStyle(color: Colors.white),),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList() ??
                                          [],
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }
                                return CircularProgressIndicator();
                              },
                            ),
                            MaterialButton(
                              onPressed: () async {
                                var attendanceDetailsList =
                                    await attendanceDetails();
                                printAttendanceDetails(attendanceDetailsList);
                                //   attendanceDetails();
                              },
                              child: Container(
                                height: MediaQuery.of(context).size.height / 14,
                                width: MediaQuery.of(context).size.width / 1.14,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                    bottomRight: Radius.circular(25),
                                    bottomLeft: Radius.circular(25),
                                  ),
                                  color: Colors.white,
                                ),
                                child: Center(child: Text('Export')),
                              ),
                            )
                          ],
                        ),
                      )),
                    ],
                  ),
                )
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 3.25,
              left: 44,
              right: 49,
              child: Container(
                height: 40,
                width: 282,
                decoration: BoxDecoration(
                    color: BGcolor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15.0,
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(20.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: Color(0xff3F3D56),
                      iconSize: 25,
                      icon: Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          currentMonth--;
                          if (currentMonth == 0) {
                            currentMonth = 12;
                            currentYear--;
                          }
                          _user = fetchCount(currentMonth, currentYear);
                        });
                      },
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Text(
                      "${months[currentMonth - 1]} - $currentYear",
                      style: TextStyle(fontSize: 17, color: Color(0xFF003756)),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 12,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                      ),
                      iconSize: 25,
                      color: Color(0xff3F3D56),
                      onPressed: () {
                        setState(() {
                          currentMonth++;
                          if (currentMonth == 13) {
                            currentMonth = 1;
                            currentYear++;
                          }
                          _user = fetchCount(currentMonth, currentYear);
                        });
                        WidgetsBinding.instance.performReassemble();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<List<User>> fetchCount(int? month, int? year) async {
    try {
      var response = await http.get(Uri.parse(
          'http://ems-ma.ideassionlive.in/api/UserActivity/countAllStatusByMonth?month=$month&year=$year'));
      print(response);
      if (response.statusCode == 200) {
        var getUsersData = json.decode(response.body) as List;
        print(getUsersData);
        var listUsers = getUsersData.map((i) => User.fromJson(i)).toList();
        return listUsers;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List> attendanceDetails() async {
    try {
      var api =
          'http://ems-ma.ideassionlive.in/api/UserActivity/exportUserAttendenceData';
      List<dynamic> dataList = [];

      print(api);
      var response = await http.get(Uri.parse(api));
      print(response);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(response.body);
        for (String key in map.keys) {
          dataList.add({key: map[key]});
        }
        return dataList;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> printAttendanceDetails(List attendanceDetails) async {
    var excel =
        Excel.createExcel(); // automatically creates 1 empty sheet: Sheet1
    Sheet sheetObject = excel['OverAll Report'];
    sheetObject.setColWidth(0, 22.0);
    sheetObject.setColWidth(1, 22.0);
    sheetObject.setColWidth(2, 20.0);
    sheetObject.setColWidth(3, 40.0);
    sheetObject.setColWidth(4, 20.0);
    sheetObject.setColWidth(5, 40.0);

    sheetObject.appendRow([
      "Employee Name",
      "Attendance Date",
      "Time in",
      'Login Location',
      "Time Out",
      "Logout Location",
      "Total Time",
      "Status"
    ]);

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
              value['logoutTime'],
              value['logoutLocation'],
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
        content: Text('Your Excel file has been saved.'),
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
