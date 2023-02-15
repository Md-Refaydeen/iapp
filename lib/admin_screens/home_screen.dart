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
                          child: FutureBuilder(
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
                                    child: _selectedButton == 1
                                        ? DataTable(
                                            columnSpacing: 38,
                                            headingRowColor:
                                                MaterialStateColor.resolveWith(
                                                    (states) => BGcolor),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  5), // this only make bottom rounded and not top
                                              color: Colors.white,
                                            ),
                                            columns: [
                                              DataColumn(label: Text('S.No')),
                                              DataColumn(label: Text('Name')),
                                              DataColumn(label: Text('Mode')),
                                              DataColumn(label: Text('Status')),
                                            ],
                                            rows: snapshot.data
                                                    ?.asMap()
                                                    .entries
                                                    .map((entry) {
                                                  int index = entry.key;
                                                  var _user = entry.value;

                                                  return DataRow(
                                                    cells: [
                                                      DataCell(
                                                          Text("${index + 1}")),
                                                      DataCell(Text(_user
                                                                  .name ==
                                                              null
                                                          ? '----'
                                                          : '${_user.name}')),
                                                      DataCell(Text(_user
                                                                  .workmode ==
                                                              null
                                                          ? '----'
                                                          : '${_user.workmode}')),
                                                      DataCell(
                                                        _user.status == null
                                                            ? Text('----')
                                                            : StatusIndicator(
                                                                status: _user
                                                                    .status,
                                                              ),
                                                      )
                                                    ],
                                                  );
                                                }).toList() ??
                                                [],
                                          )
                                        : _selectedButton == 2
                                            ? DataTable(
                                                columnSpacing: 38,
                                                headingRowColor:
                                                    MaterialStateColor
                                                        .resolveWith((states) =>
                                                            BGcolor),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5), // this only make bottom rounded and not top
                                                  color: Colors.white,
                                                ),
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
                                                rows: snapshot.data
                                                        ?.asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int index = entry.key;
                                                      var _user = entry.value;

                                                      return DataRow(
                                                        cells: [
                                                          DataCell(Text(
                                                              "${index + 1}")),
                                                          DataCell(Text(_user
                                                                      .name ==
                                                                  null
                                                              ? '----'
                                                              : '${_user.name}')),
                                                          DataCell(Text(_user
                                                                      .workmode ==
                                                                  null
                                                              ? '----'
                                                              : '${_user.workmode}')),
                                                          DataCell(
                                                            _user.status == null
                                                                ? Text('----')
                                                                : StatusIndicator(
                                                                    status: _user
                                                                        .status,
                                                                  ),
                                                          ),
                                                        ],
                                                      );
                                                    }).toList() ??
                                                    [],
                                              )
                                            : DataTable(
                                                columnSpacing: 38,
                                                headingRowColor:
                                                    MaterialStateColor
                                                        .resolveWith((states) =>
                                                            BGcolor),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5), // this only make bottom rounded and not top
                                                  color: Colors.white,
                                                ),
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
                                                rows: snapshot.data
                                                        ?.asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int index = entry.key;
                                                      var _user = entry.value;

                                                      return DataRow(
                                                        cells: [
                                                          DataCell(Text(
                                                              "${index + 1}")),
                                                          DataCell(Text(_user
                                                                      .name ==
                                                                  null
                                                              ? '----'
                                                              : '${_user.name}')),
                                                          DataCell(Text(_user
                                                                      .workmode ==
                                                                  null
                                                              ? '----'
                                                              : '${_user.workmode}')),
                                                          DataCell(_user
                                                                      .status ==
                                                                  null
                                                              ? Text('----')
                                                              : StatusIndicator(
                                                                  status: _user
                                                                      .status,
                                                                ))
                                                        ],
                                                      );
                                                    }).toList() ??
                                                    [],
                                              ));
                              } else if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              }
                              return CircularProgressIndicator();
                            },
                          ),
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                        ),
                        SvgPicture.asset('assets/images/logo.svg', height: 77),
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
              top: 370,
              left: 70,
              child: Column(
                children: [
                  Container(
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
              left: 140,
              right: 170,
              child: Column(
                children: [
                  Container(
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
              top: 370,
              left: 200.0,
              right: 10,
              child: Column(
                children: [
                  Container(
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
