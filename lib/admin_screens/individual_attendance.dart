import 'dart:convert';
import 'package:iapp/services/exportExcel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/constants.dart';
import '../dto/user.dart';
import '../screens/login_screen.dart';
import '../services/getLoc_Time.dart';
import '../widgets/admindrawer_components.dart';
import 'attendance_screen.dart';
import 'home_screen.dart';

class UserAttendanceScreen extends StatefulWidget {
  const UserAttendanceScreen({Key? key}) : super(key: key);
  static String routeName = 'UserAttendanceScreen';

  @override
  State<UserAttendanceScreen> createState() => _UserAttendanceScreenState();
}

class _UserAttendanceScreenState extends State<UserAttendanceScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String? checkInTime, checkOutTime;
  String? empName, workhrs, remarks, mode, rdate;
  DateTime? _selectedDate, _dates;
  int? month, year;
  Location location = Location();
  var name;
  var empId, emailId;
  Future<List<User>>? _user;

  @override
  void initState() {
    // TODO: implement initState
    location.getDate();
    setState(() {
      month = int.parse(location.month);
      year = int.parse(location.year);
    });
    check();
  }

  void check() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      await fetchData(name);
      print('email$emailId');
      _user = fetchDetails(emailId, month, year);
      await location.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    if (arguments != null) {
      setState(() {
        name = arguments['name'];
      });
    }

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
          child: Stack(
            children: [
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
                    child: Row(children: [
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          sizedBox,
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
                          sizedBox,
                          sizedBox,
                          IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AdminAttendanceScreen.routeName);
                              },
                              icon: Icon(
                                Icons.arrow_circle_left_outlined,
                                color: Color(0xFF3F3D56),
                                size: 28,
                              )),
                        ],
                      ),
                    ]),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: adminHomeBG,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 10,
                        ),
                        Card(
                          margin: const EdgeInsets.all(30.0),
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25),
                            ),
                            side: BorderSide(color: Colors.white, width: 2.0),
                          ),
                          child: TableCalendar(
                            onPageChanged: (d) {
                              year = d.year;
                              month = d.month;

                              // checkStatus(email, month, year);
                            },
                            selectedDayPredicate: (day) =>
                                isSameDay(day, _selectedDate),
                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2050, 3, 14),
                            calendarFormat: CalendarFormat.month,
                            calendarBuilders: CalendarBuilders(
                              selectedBuilder: (context, date, events) =>
                                  Container(
                                      margin: const EdgeInsets.all(5.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: Text(
                                        date.day.toString(),
                                        style: TextStyle(color: Colors.white),
                                      )),
                            ),
                            focusedDay: DateTime.now(),
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              todayDecoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                              weekendTextStyle: TextStyle(color: Colors.blue),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonShowsNext: false,
                              titleCentered: true,
                            ),
                            onDaySelected: (date, events) {
                              setState(() {
                                _selectedDate = date;
                                print(_selectedDate);
                                // fetchData(email, _selectedDate);
                              });
                            },
                          ),
                        ),
                        sizedBox,
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                LayoutBuilder(builder: (context, constraints) {
                                  return FutureBuilder(
                                    future: _user,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        var dataSource = AttendanceDetailsDataSource(snapshot.data ?? []);
                                        if (dataSource.rowCount == 0) {
                                          return Container(
                                            alignment: Alignment.center,
                                            child: Text('No data available.'),
                                          );
                                        }
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.1,
                                          constraints: BoxConstraints(
                                            minHeight:
                                                200, // Set a mi
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(18),
                                                topRight: Radius.circular(18),
                                                bottomRight: Radius.circular(6),
                                                bottomLeft: Radius.circular(6),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 15.0,
                                                  offset: Offset(0, 2),
                                                )
                                              ]),
                                          child:  PaginatedDataTable(
                                                  dataRowHeight: 55,
                                                  columnSpacing: 15,

                                                  columns: [
                                                    DataColumn(
                                                        label: Text('Date')),
                                                    DataColumn(
                                                        label: Text('Mode')),
                                                    DataColumn(
                                                        label:
                                                            Text('In & Out')),
                                                    DataColumn(
                                                        label:
                                                            Text('Totalhrs')),
                                                    DataColumn(
                                                        label: Text('Remarks')),
                                                  ],
                                                  source:
                                                      AttendanceDetailsDataSource(
                                                          snapshot.data ?? []),
                                                  rowsPerPage:5, // Change the number of rows per page as needed
                                                ),

                                        );
                                      } else if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      }
                                      return CircularProgressIndicator();
                                    },
                                  );
                                }),
                                MaterialButton(
                                  onPressed: () async {
                                    ExportExcel().exportIndividualData(context, _user!);
                                  },
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 17,
                                    width: MediaQuery.of(context).size.width /
                                        1.12,
                                    margin: EdgeInsets.only(
                                        top: 0.1,
                                        bottom:
                                            8), // add margin to adjust spacing

                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                        bottomRight: Radius.circular(25),
                                        bottomLeft: Radius.circular(25),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                        child: Text(
                                      'Export',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(
                                            0xFF5278FF,
                                          ),
                                          decoration: TextDecoration.underline),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                top: 160,
                left: 50,
                right: 40,
                child: Container(
                  height: MediaQuery.of(context).size.height / 4.4,
                  width: MediaQuery.of(context).size.width / 1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15.0,
                          offset: Offset(2, 4),
                        )
                      ]),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 20,
                      ),
                      Text(
                        '$name' == null ? '---' : name,
                        style: TextStyle(fontSize: 24),
                      ),
                      sizedBox,
                      Text('$empId' == null ? '----' : '$empId'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Digital Transformation Trainee',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xff003756)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.32,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 64,
                      width: 42,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchData(var name) async {
    try {
      String apiEndpoint =
          'http://ems-ma.ideassionlive.in/api/User/getEmailByName?name=$name';

      final Uri url = Uri.parse(apiEndpoint);
      var jsonResponse;
      final response = await http.get(url);
      print(url);
      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body.toString());
        print(jsonResponse);
        setState(() {
          empId = jsonResponse["empUniqueId"];
          emailId = jsonResponse["empEmailId"];
          print(emailId);
        });
      } else {
        //print(response.statusCode);
        throw response.statusCode;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<User>> fetchDetails(var email, int? month, int? year) async {
    try {
      var api =
          'http://ems-ma.ideassionlive.in/api/UserActivity/findByEmailAndMonth?email=$email&month=$month&year=$year';
      print(api);
      var response = await http.get(Uri.parse(api));
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
}

class AttendanceDetailsDataSource extends DataTableSource {
  final List<User> _attendanceDetails;
  int _selectedRowCount = 0;

  AttendanceDetailsDataSource(this._attendanceDetails);

  @override
  DataRow getRow(int index) {
    final attendanceDetail = _attendanceDetails[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(
          attendanceDetail.date == null
              ? '----'
              : attendanceDetail.date == null
                  ? '----'
                  : DateFormat('dd MMM')
                      .format(DateTime.parse(attendanceDetail.date.toString())),
          style: TextStyle(color: Color(0xFF003756)),
        )),
        DataCell(
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  attendanceDetail.workmode == null
                      ? '------'
                      : '${attendanceDetail.workmode}',
                  style: TextStyle(color: Color(0xFF003756)),
                ),
                Text(
                  attendanceDetail.workModeCheckOut == null
                      ? '------'
                      : '${attendanceDetail.workModeCheckOut}',
                  style: TextStyle(color: Color(0xFF003756)),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${attendanceDetail.loginTime}'=='null'
                      ? '----'
                      : '${attendanceDetail.loginTime}',
                  style: TextStyle(color: Color(0xFF003756)),
                ),
                Text(
                  '${attendanceDetail.logoutTime}' == 'null'
                      ? '----'
                      : '${attendanceDetail.logoutTime}',
                  style: TextStyle(color: Color(0xFF003756)),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Text(
            attendanceDetail.totalWorkingHours == null
                ? '----'
                : '${attendanceDetail.totalWorkingHours}',
            style: TextStyle(color: Color(0xFF003756)),
          ),
        ),
        DataCell(
          Text(
            attendanceDetail.status == null
                ? '----'
                : '${attendanceDetail.status}',
            style: TextStyle(color: Color(0xFF003756)),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => _attendanceDetails.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRowCount;
}
