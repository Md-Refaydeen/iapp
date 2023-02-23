import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:iapp/screens/login_screen.dart';
import '../widgets/admindrawer_components.dart';
import 'package:iapp/admin_screens/attendance_screen.dart';
import 'package:iapp/constants/constants.dart';
import 'package:iapp/services/getLoc_Time.dart';
import '../dto/user.dart';
import '../widgets/digital_clock_Components.dart';
import '../widgets/status.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);
  static String routeName = 'AdminHomeScreen';

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Location location = Location();
  Future<List<User>>? _user;
  int? checkedIn, notCheckedIn, total;
  int? month, year;
  int _selectedButton = 1;

  var date;

  var presentStatus = "Present", absentStatus = "Absent";
  @override
  void initState() {
    check();
    location.getDate();
    date = location.date;
    print(date);
    usersCount(date);
    _user = fetchUsers(date, presentStatus);
  }

  Future<void> check() async {
    Future.delayed(const Duration(milliseconds: 50), () {
      var greets = location.greeting();
      print(greets);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          greets,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFFAD8DCD),
        duration: Duration(seconds: 5),
      ));
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
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xB6B091CF),
                        Color(0xFFAD8DCD),
                      ]),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: kDefaultPadding * 2,
                                width: kDefaultPadding,
                              ),
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
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.53,
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, LoginScreen.routeName);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Logged out Successfully"
                                                    .toString())));
                                  },
                                  icon: Icon(Icons.power_settings_new,
                                      color: Color(0xFF3F3D56)))
                            ],
                          ),
                          Text(
                            'Hello Admin',
                            style: Theme.of(context).textTheme.headline1,
                          )
                        ],
                      ),
                    )),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: adminHomeBG,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 3.1,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: LayoutBuilder(builder: (context, constraints) {

                            return FutureBuilder(
                              future: _user,
                              builder: (context, snapshot) {
                                print(snapshot.data);
                                print(snapshot.hasData);
                                if (snapshot.hasData) {
                                  var attendanceDetails = AttendanceDetailsDataSource(snapshot.data ?? []);
                                  attendanceDetails.removeEmptyRows();
                                  if (attendanceDetails.rowCount == 0) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: Text('No data available.'),
                                    );
                                  }

                                  return Container(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width /
                                          1.15,
                                      constraints: BoxConstraints(
                                        minHeight:
                                        200, // Set a minim
                                        // um height
                                      ),
                                      decoration: BoxDecoration(
                                        //borderRadius: BorderRadius.circular(15.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 15.0,
                                              offset: Offset(0, 2),
                                            )
                                          ]),
                                      child: _selectedButton == 1
                                          ? PaginatedDataTable(
                                        rowsPerPage: 10,
                                          columnSpacing: 15,

                                          columns: [
                                            DataColumn(
                                                label: Text('S.No')),
                                            DataColumn(
                                                label: Text('Name')),
                                            DataColumn(
                                                label: Text('Mode')),
                                            DataColumn(
                                                label: Text('Status')),
                                          ],
                                          source: attendanceDetails
                                      ): _selectedButton == 2
                                          ? PaginatedDataTable(
                                          columnSpacing: 15,
                                          rowsPerPage: 10,

                                          columns: [
                                            DataColumn(
                                                label: Text('S.No')),
                                            DataColumn(
                                                label: Text('Name')),
                                            DataColumn(
                                                label: Text('Mode')),
                                            DataColumn(
                                                label: Text('Status')),
                                          ],
                                          source: attendanceDetails)

                                          : PaginatedDataTable(
                                          columnSpacing: 15,
                                          rowsPerPage: 10,

                                          columns: [
                                            DataColumn(
                                                label: Text('S.No')),
                                            DataColumn(
                                                label: Text('Name')),
                                            DataColumn(
                                                label: Text('Mode')),
                                            DataColumn(
                                                label: Text('Status')),
                                          ],
                                          source: attendanceDetails)
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }
                                return CircularProgressIndicator();
                              },
                            );
                          })
                          ),
                        ),

                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 150,
              right: 40,
              left: 40,
              child: Container(
                height: MediaQuery.of(context).size.height / 2.3,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(kDefaultPadding * 1.5),
                        bottomRight: Radius.circular(kDefaultPadding * 1.5),
                        topLeft: Radius.circular(kDefaultPadding * 1.5),
                        bottomLeft: Radius.circular(kDefaultPadding * 1.5)),
                    color: Colors.white),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: kDefaultPadding * 4,
                          width: 20,
                        ),
                        Text(
                          '${location.cdate3}',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(location.day.toString(),
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    sizedBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DigitalClockComponent(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 400,
              left: 60,
              child: Column(
                children: [
                  Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      color: Color(0xcf7C4CAC),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() => _selectedButton = 3);
                        _user = fetchUsers(date, presentStatus);
                      },
                      icon: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, top: 0.2),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 25,
                    ),
                  ),
                  Text(
                    'Check In:$checkedIn',
                    style: TextStyle(color: Color(0xff003756)),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 320,
              right: 215,
              child: Column(
                children: [
                  Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      color: Color(0xcf7C4CAC),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() => _selectedButton = 1);
                        _user = fetchUsers(date, 'Total');
                      },
                      icon: Icon(
                        Icons.groups,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  sizedBox,
                  Text('Total:$total',
                      style: TextStyle(color: Color(0xff003756)))
                ],
              ),
            ),
            Positioned(
              top: 400,
              right: 60,
              child: Column(
                children: [
                  Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      color: Color(0xcf7C4CAC),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() => _selectedButton = 2);
                        _user = fetchUsers(date, absentStatus);
                      },
                      icon: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 0.5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(
                        Icons.close_sharp,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  Text('Not Check In:$notCheckedIn',
                      style: TextStyle(color: Color(0xff003756)))
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.17,
              right: MediaQuery.of(context).size.width * 0.1,
              child: SvgPicture.asset('assets/images/logo.svg',
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.05,

              ),
            )
          ]),
        ),
      ),
    );
  }

  Future<List<User>> fetchUsers(var date, var status) async {
    try {
      var api =
          'http://ems-ma.ideassionlive.in/api/UserActivity/adminFindAllByDateAndStatus?date=$date&status=$status';
      print(api);
      var response = await http.get(Uri.parse(api));
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

  void usersCount(var date) async {
    try {
      String apiEndpoint =
          'http://ems-ma.ideassionlive.in/api/UserActivity/adminTotalUserCount?date=$date';
      final Uri url = Uri.parse(apiEndpoint);
      var jsonResponse;
      final response = await http.get(url);
      print(url);
      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body.toString());

        setState(() {
          checkedIn = jsonResponse["chekedIn"];
          notCheckedIn = jsonResponse["notCheckedIn"];
          total = jsonResponse["total"];
        });
      } else {
        //print(response.statusCode);
        throw response.statusCode;
      }
    } catch (error) {
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
        DataCell(
            Text("${index + 1}")),
        DataCell(Text(attendanceDetail.name ==
            null
            ? '----'
            : '${attendanceDetail.name}')),
        DataCell(Text(attendanceDetail
            .workmode ==
            null
            ? '----'
            : '${attendanceDetail.workmode}')),
        DataCell(
          attendanceDetail.status == null
              ? StatusIndicator(status: attendanceDetail.status)
              : StatusIndicator(
            status: attendanceDetail.status,
          ),
        )
      ],
    );
  }

  @override
  int get rowCount {
    int count = 0;
    for (var attendanceDetail in _attendanceDetails) {
      if (attendanceDetail.name != null ||
          attendanceDetail.workmode != null ||
          attendanceDetail.status != null) {
        count++;
      }
    }
    return count;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRowCount;

  void removeEmptyRows() {
    print('empty eow');
    _attendanceDetails.removeWhere((attendanceDetail) =>
    attendanceDetail.name == null &&
        attendanceDetail.workmode == null &&
        attendanceDetail.status == null);
    notifyListeners();
  }
}
