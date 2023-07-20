import 'dart:async';
import 'dart:convert';
import 'package:iapp/services/adminApiClass.dart';
import 'package:iapp/services/exportExcel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/constants.dart';
import '../dto/user.dart';
import '../user_screens/login_screen.dart';
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
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  String? checkInTime, checkOutTime;
  String? empName, workhrs, remarks, mode, rdate;
  DateTime? _selectedDate=DateTime.now(), _dates;
  int? month, year;
  List<User> _attendanceDetailsList = []; // initial empty list

  GetLoc_Time location = GetLoc_Time();
  var name;
  var empId, emailId;
  String? formattedStartDate, formattedEndDate;
  Future<List<User>>? _user;
  DateTime? _rangeStart, _rangeEnd;
  Timer? _clearSelectionTimer;
  AttendanceDetailsDataSource dataSource = AttendanceDetailsDataSource([]);

  @override
  void initState() {
    // TODO: implement initState
    location.getDate();
    setState(() {
      month = int.parse(location.month);
      print('initmonth:$month');
      year = int.parse(location.year);
    });
    check();
  }

  void check() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      await fetchData(name);
      print('email$emailId');
      _user = fetchDetails(emailId, month, year);
      fetchDetails(emailId, month, year).then((value) {
        print('value');
        _attendanceDetailsList = value;
      });
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
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Color(0xB6B091CF),
                          Color(0xFFAD8DCD),
                        ]),
                      ),
                      child: Row(children: [
                        const SizedBox(
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
                              icon: const Icon(
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
                                icon: const Icon(
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
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25),
                              ),
                              side: BorderSide(color: Colors.white, width: 2.0),
                            ),
                            child: TableCalendar(
                              selectedDayPredicate: (day) =>
                                  isSameDay(day, _selectedDate),
                              firstDay: DateTime.utc(2018, 10, 16),
                              lastDay: DateTime.utc(2050, 3, 14),
                              calendarFormat: CalendarFormat.month,
                              calendarBuilders: CalendarBuilders(
                                selectedBuilder: (context, date, events) {
                                  // Check if the date is within the selected range
                                  if (_rangeSelectionMode ==
                                      RangeSelectionMode.toggledOn) {
                                    if (_rangeStart != null &&
                                        _rangeEnd != null) {
                                      if (isSameDay(date, _rangeStart)) {
                                        // Show dark purple color for start date
                                        return Container(
                                          margin: const EdgeInsets.all(5.0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade200,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            date.day.toString(),
                                            style:
                                                const TextStyle(color: Colors.white),
                                          ),
                                        );
                                      } else if (isSameDay(date, _rangeEnd)) {
                                        // Show dark purple color for end date
                                        return Container(
                                          margin: const EdgeInsets.all(5.0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade700,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            date.day.toString(),
                                            style:
                                                const TextStyle(color: Colors.white),
                                          ),
                                        );
                                      } else if (date.isAfter(_rangeStart!) &&
                                          date.isBefore(_rangeEnd!)) {
                                        // Show light purple color for dates between start and end
                                        return Container(
                                          margin: const EdgeInsets.all(5.0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade300,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            date.day.toString(),
                                            style:
                                                const TextStyle(color: Colors.white),
                                          ),
                                        );
                                      } else {
                                        // Show default selected style for non-range dates
                                        return Container(
                                          margin: const EdgeInsets.all(5.0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade200,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            date.day.toString(),
                                            style:
                                                const TextStyle(color: Colors.white),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    // Show default selected style for non-range dates
                                    return Container(
                                      margin: const EdgeInsets.all(5.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Text(
                                        date.day.toString(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                },
                              ),
                              focusedDay: _selectedDate!,
                              onPageChanged: (date) async {
                                _selectedDate=date;
                                print(date);
                                month=int.tryParse(DateFormat('MM').format(date));
                                year=int.tryParse(DateFormat('yyyy').format(date));
                                print('month:$month,year:$year');
                                List<User>users=await fetchDetails(emailId, month, year);
                                _attendanceDetailsList=users;
                                setState(() {
                                  dataSource = AttendanceDetailsDataSource(
                                      _attendanceDetailsList);
                                });
                              },

                              calendarStyle: CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                todayDecoration: const BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Color(0xFF7C4CAC),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                weekendTextStyle: const TextStyle(color: Colors.blue),
                              ),
                              headerStyle: HeaderStyle(
                                  formatButtonShowsNext: false,
                                  titleCentered: true,
                                  titleTextFormatter: (date, _) =>
                                  '${DateFormat.yMMMM().format(date)}', //
                                  formatButtonVisible: false
                              ),
                              rangeSelectionMode: _rangeSelectionMode,
                              rangeStartDay: _rangeStart,
                              rangeEndDay: _rangeEnd,
                              onRangeSelected: (start, end, focused) async {
                                _rangeStart = start;
                                _rangeEnd = end;

                                setState(() {
                                  _rangeSelectionMode =
                                      RangeSelectionMode.toggledOn;
                                  focused = _rangeStart!;
                                  // _clearSelectionTimer = Timer(Duration(seconds: 10), () {
                                  //   setState(() {
                                  //     _rangeStart = null;
                                  //     _rangeEnd = null;
                                  //     _rangeSelectionMode = RangeSelectionMode.toggledOff;
                                  //   });
                                  // });
                                });
                                print('StartDate:$_rangeStart');
                                print('endDate:$_rangeEnd');
                                print('focusedDay:$focused');
                                formattedStartDate = DateFormat('yyyy-MM-dd')
                                    .format(_rangeStart!);
                                formattedEndDate = _rangeEnd != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(_rangeEnd!)
                                    : '';

                                List<User> users = await ApiService()
                                    .individualRangeDate(emailId,
                                        formattedStartDate, formattedEndDate);
                                print('user:$users');
                                setState(() {
                                  _attendanceDetailsList = users;
                                  dataSource = AttendanceDetailsDataSource(
                                      _attendanceDetailsList);
                                });
                              },
                              onDaySelected: (date, events) {
                                setState(() {
                                  _selectedDate = date;
                                  print(_selectedDate);
                                  _rangeSelectionMode =
                                      RangeSelectionMode.toggledOff;
                                });
                              },
                            ),
                          ),
                          sizedBox,
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  LayoutBuilder(
                                      builder: (context, constraints) {
                                    return FutureBuilder(
                                      future: _user,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          dataSource =
                                              AttendanceDetailsDataSource(
                                                  snapshot.data ?? []);
                                          if (dataSource.rowCount == 0) {
                                            return Container(
                                              alignment: Alignment.center,
                                              child: const Text('No data available.'),
                                            );
                                          }
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.1,
                                            constraints: const BoxConstraints(
                                              minHeight: 200, // Set a mi
                                            ),
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(18),
                                                  topRight: Radius.circular(18),
                                                  bottomRight:
                                                      Radius.circular(6),
                                                  bottomLeft:
                                                      Radius.circular(6),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 15.0,
                                                    offset: Offset(0, 2),
                                                  )
                                                ]),
                                            child: PaginatedDataTable(
                                              dataRowHeight: 55,
                                              columnSpacing: 15,
                                              header: const Text('Individual Report'),
                                              columns: [
                                                const DataColumn(label: Text('Date')),
                                                const DataColumn(label: Text('Mode')),
                                                const DataColumn(
                                                    label: Text('In & Out')),
                                                const DataColumn(
                                                    label: Text('Totalhrs')),
                                                const DataColumn(
                                                    label: Text('Remarks')),
                                              ],
                                              actions: [
                                                IconButton(
                                                  icon: const Icon(Icons.refresh),
                                                  onPressed: () async {
                                                    print('onPress called');
                                                    List<User> users=await fetchDetails(emailId, month, year);
                                                    setState(() {
                                                      formattedStartDate = null;
                                                      formattedEndDate = null;

                                                      _attendanceDetailsList = users;
                                                      dataSource = AttendanceDetailsDataSource(
                                                          _attendanceDetailsList);
                                                      _rangeSelectionMode = RangeSelectionMode.toggledOn;


                                                    });
                                                  },
                                                )
                                              ],

                                              source:
                                                  AttendanceDetailsDataSource(
                                                      _attendanceDetailsList),
                                              rowsPerPage:
                                                  5, // Change the number of rows per page as needed
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              snapshot.error.toString());
                                        }
                                        return const CircularProgressIndicator();
                                      },
                                    );
                                  }),
                                  MaterialButton(
                                    onPressed: () async {
                                      print('formatstart:$formattedStartDate');
                                      print('formatEnd:$formattedEndDate');

                                      List<User> attendanceDetails;
                                      if (formattedStartDate != null &&
                                          formattedEndDate != null) {
                                        print('range dates');
                                        attendanceDetails = await ApiService()
                                                .individualRangeDate(
                                                    emailId,
                                                    formattedStartDate,
                                                    formattedEndDate);
                                        ExportExcel().exportIndividualData(
                                            context, attendanceDetails);
                                      } else {
                                        //month wise data
                                        print('month dates');

                                        attendanceDetails = await fetchDetails(
                                            emailId, month, year);
                                        ExportExcel().exportIndividualData(
                                            context, attendanceDetails);
                                      }
                                    },
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              17,
                                      width: MediaQuery.of(context).size.width /
                                          1.12,
                                      margin: const EdgeInsets.only(
                                          top: 0.1,
                                          bottom:
                                              8), // add margin to adjust spacing

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                          bottomRight: Radius.circular(25),
                                          bottomLeft: Radius.circular(25),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: const Center(
                                          child: Text(
                                        'Export',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(
                                              0xFF5278FF,
                                            ),
                                            decoration:
                                                TextDecoration.underline),
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
                        boxShadow: const[
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
                          style: const TextStyle(fontSize: 24),
                        ),
                        sizedBox,
                        Text('$empId' == null ? '----' : '$empId'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
      ),
    );
  }

  Future<void> fetchData(var name) async {
    try {
      String apiEndpoint =
          '$appUrl/User/getEmailByName?name=$name';

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
          '$appUrl/UserActivity/findByEmailAndMonth?email=$email&month=$month&year=$year';
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
          style: const TextStyle(color: Color(0xFF003756)),
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
                  style: const TextStyle(color: Color(0xFF003756)),
                ),
                Text(
                  attendanceDetail.workModeCheckOut == null
                      ? '------'
                      : '${attendanceDetail.workModeCheckOut}',
                  style: const TextStyle(color: Color(0xFF003756)),
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
                  '${attendanceDetail.loginTime}' == 'null'
                      ? '----'
                      : '${attendanceDetail.loginTime}',
                  style: const TextStyle(color: Color(0xFF003756)),
                ),
                Text(
                  '${attendanceDetail.logoutTime}' == 'null'
                      ? '----'
                      : '${attendanceDetail.logoutTime}',
                  style: const TextStyle(color: Color(0xFF003756)),
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
            style: const TextStyle(color: Color(0xFF003756)),
          ),
        ),
        DataCell(
          Text(
            attendanceDetail.status == null
                ? '----'
                : '${attendanceDetail.status}',
            style: const TextStyle(color: Color(0xFF003756)),
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
