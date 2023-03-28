import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iapp/widgets/alertbox.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/constants.dart';
import '../dto/user.dart';
import 'package:intl/intl.dart';
import '../services/getLoc_Time.dart';
import '../widgets/list_components.dart';
import 'home_screen.dart';
import '../screens/login_screen.dart';

class AttendanceScreen extends StatefulWidget {
  static String routeName = 'AttendanceScreen';
  var date, status;

  @override
  State<StatefulWidget> createState() {
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<AttendanceScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isInkwellEnabled = true;

  Future<List<User>>? _user;
  Map<DateTime, List<dynamic>> _events = {};
  bool isDataAvailable = true;

  Location location = Location();
  DateTime _selectedDate=DateTime.now();
  DateTime? _dates;
  Timer? _debounce;
  var day;
  bool _isVisible = false;
  String? checkInTime, checkOutTime;
  String? empName, workhrs, remarks, mode, wmode, rdate;
  int? present, absent, month, year;
  final dateFormat = DateFormat('yyyy-MM-dd');
  final dayFormat = DateFormat('d E');
  var email, name;
  bool _showAlert = false;


  @override
  void initState() {
    super.initState();
    location.getDate();
    check();
  }

  Future<void> check() async {
    Future.delayed(const Duration(milliseconds: 500), () {


      setState(() {
        year = int.parse(location.year);
        month = int.parse(location.month);
        print('$year,$month');
      });
      _user = fetchDetails(email, month, year);
      checkStatus(email, month, year);
    });
  }

  void showToast() {

    setState(() {
      _isVisible = !_isVisible;
      _showAlert = !_showAlert;

    });
    showAlert();


  }

  @override
  Widget build(BuildContext context) {
    final Map arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    if (arguments != null) {
      email = arguments['email'];
      name = arguments['name'];
      wmode = arguments['mode'];
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.purple.shade50,
      drawer: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: Drawer(
          backgroundColor: Colors.purple.shade50,
          width: MediaQuery.of(context).size.width * 0.7,
          child: ListView(
            padding: EdgeInsets.only(top: 65.0),
            children: <Widget>[
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios),
                  alignment: Alignment.topRight),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 15,
                    width: MediaQuery.of(context).size.width / 8,
                    child: CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/images/user.png',
                      ),
                      radius: 30,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 7,
                    width: MediaQuery.of(context).size.width / 25,
                  ),
                  Text(
                    name,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              ListComponents(
                title: 'Home',
                iconData: Icons.home_filled,
                onPress: () {
                  Navigator.pushNamed(context, HomeScreen.routeName,
                      arguments: {
                        'email': email,
                        'empName': name,
                        'mode': wmode
                      });
                  print(wmode);
                },
              ),
              ListComponents(
                title: 'Attendance',
                iconData: Icons.calendar_today_outlined,
                onPress: () {
                  Navigator.pushNamed(context, AttendanceScreen.routeName,
                      arguments: {'email': email, 'name': name});
                },
              ),
              ListComponents(
                title: 'Logout',
                iconData: Icons.power_settings_new,
                onPress: () {
                  Navigator.pushNamed(context, LoginScreen.routeName);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Logged out Successfully".toString())));
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 9.5,
              ),
              Container(
                margin: EdgeInsets.only(
                    top: kDefaultPadding, right: kDefaultPadding),
                width: MediaQuery.of(context).size.width / 4,
                height: MediaQuery.of(context).size.height / 10,
                child: Image.asset(
                  'assets/images/Ideassion.png',
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              height: MediaQuery.of(context).size.height / 11.5,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(kDefaultPadding * 3),
                  bottomRight: Radius.circular(kDefaultPadding * 3),
                ),
                color: attendance,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 30,
                  ),
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
              )),
          Expanded(
              child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 1.6,
                    width: MediaQuery.of(context).size.width / 0.5,
                    child: Card(
                      margin: const EdgeInsets.all(30.0),
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                        side: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      child: TableCalendar(

                        eventLoader: _getEvents,
                        onPageChanged: (d) {
                          _selectedDate=d;
                          year = d.year;
                          month = d.month;
                          _debounce?.cancel();
                          _debounce =
                              Timer(const Duration(milliseconds: 500), () {
                            // Call the API here
                            Future.delayed(Duration(milliseconds: 500), () {
                              checkStatus(email, month, year).then((value) {
                                // Update the calendar state here
                                setState(() {});
                              });
                            });
                          });
                        },
                        selectedDayPredicate: (day) =>
                            isSameDay(day, _selectedDate),
                        firstDay: DateTime.utc(2018, 10, 16),
                        lastDay: DateTime.utc(2050, 3, 14),
                        calendarFormat: CalendarFormat.month,
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            var status = _events.containsValue("Present")
                                ? "Present"
                                : "Absent";
                            return Container(
                              height: 5,
                              decoration: BoxDecoration(
                                  color: status == "Present" || status == 'Late'
                                      ? Colors.green
                                      : Colors.red,
                                  shape: BoxShape.circle),
                            );
                          },
                          selectedBuilder: (context, date, events) => Container(
                              margin: const EdgeInsets.all(5.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                        focusedDay: _selectedDate!,
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
                          titleTextFormatter: (date, _) =>
                          '${DateFormat.yMMMM().format(date)}', //
                          formatButtonVisible: false
                        ),
                        onDaySelected: (date, events) {
                          setState(() {
                            _selectedDate = date;
                            print(_selectedDate);
                            fetchData(email, _selectedDate);
                          });
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    //behavior: HitTestBehavior.translucent,
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: MediaQuery.of(context).size.width / 1.6,
                      decoration: BoxDecoration(
                          color: Colors.purple.shade200,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(kDefaultPadding),
                            topLeft: Radius.circular(kDefaultPadding),
                            bottomRight: Radius.circular(kDefaultPadding),
                            bottomLeft: Radius.circular(kDefaultPadding),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.info),
                              color: Color(0xFFFFC701)),
                          Text('Tap to view Attendance Details'),
                        ],
                      ),
                    ),
                    onTap: showToast,
                  ),
                  sizedBox,
                  Visibility(
                      visible: _isVisible,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 7.3,
                        width: MediaQuery.of(context).size.width / 1.1,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(width: 10,),
                            Text(rdate != null ? '$rdate' : '---'),
                            VerticalDivider(
                              color: Color(0xFF5C5C5C),
                              thickness: 1,
                            ),
                            Expanded(
                              child: Column(
                                //crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  sizedBox,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    // /alignment: WrapAlignment.center,                                            //mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Mode'),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              12.5),
                                      Text('In &Out'),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                12.5,
                                      ),
                                      Text('Total Hrs'),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              12.5),
                                      Text('Remarks'),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: Color(0xFF5C5C5C),
                                  ),
                                  isDataAvailable? Row(
                                    mainAxisSize: MainAxisSize.max,
                                    // crossAxisAlignment: WrapCrossAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,

                                    //alignment: WrapAlignment.spaceEvenly,
                                    children: [
                                      Text(mode != null ? '$mode' : '------'),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                12.5,
                                      ),
                                      Column(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(checkInTime != null
                                              ? '$checkInTime'
                                              : '------'),
                                          Text(checkOutTime != null
                                              ? '$checkOutTime'
                                              : '------'),
                                        ],
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                12.5,
                                      ),
                                      Text(workhrs != null
                                          ? '$workhrs'
                                          : '------'),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                7.5,
                                      ),
                                      Text(remarks != null
                                          ? '$remarks'
                                          : '-----'),
                                    ],
                                  ):Center(child: Text('No Data Available'),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  //       attendanceDetails(),
                  SizedBox(
                    height: kDefaultPadding * 2,
                  ),
                  Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 14,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 4.5,
                          width: MediaQuery.of(context).size.width / 2.8,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.redAccent,
                                  Colors.redAccent
                                ],
                                stops: [
                                  0.8,
                                  0.2,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.only(
                              bottomLeft:
                                  Radius.circular(kDefaultPadding * 1.2),
                              bottomRight:
                                  Radius.circular(kDefaultPadding * 1.2),
                              topRight: Radius.circular(kDefaultPadding * 1.2),
                              topLeft: Radius.circular(kDefaultPadding * 1.2),
                            ),
                            color: Colors.purple,
                          ),
                          child: Column(
                            children: [
                              sizedBox,
                              Text(
                                'Total Absent',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: kDefaultPadding * 2,
                              ),
                              Text(
                                absent != null ? '$absent' : '0',
                                style: TextStyle(
                                    fontSize: 50, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 8,
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 4.5,
                              width: MediaQuery.of(context).size.width / 2.8,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.blueAccent,
                                      Colors.blueAccent,
                                    ],
                                    stops: [
                                      0.8,
                                      0.2,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter),
                                borderRadius: BorderRadius.only(
                                  bottomLeft:
                                      Radius.circular(kDefaultPadding * 1.2),
                                  bottomRight:
                                      Radius.circular(kDefaultPadding * 1.2),
                                  topRight:
                                      Radius.circular(kDefaultPadding * 1.2),
                                  topLeft:
                                      Radius.circular(kDefaultPadding * 1.2),
                                ),
                                // color: Colors.purple,
                              ),
                              child: Column(
                                children: [
                                  sizedBox,
                                  Text(
                                    'Total Present',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: kDefaultPadding * 2,
                                  ),
                                  Text(
                                    present != null ? '$present' : '0',
                                    style: TextStyle(
                                        fontSize: 50, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ))
        ]),
      ),
    );
  }

  Future<void> showAlert() async {
    if(_showAlert){
      showDialog(context: context, builder: (_) => AlertBox());

    }

  }

  Future<void> checkStatus(String? email, int? month, int? year) async {
    try {
      //15 Wed
      String apiEndpoint =
          'http://ems-ma.ideassionlive.in/api/UserActivity/countStatusByMonth?email=$email&month=$month&year=$year';
      final Uri url = Uri.parse(apiEndpoint);
      print(url);
      var jsonResponse;
      final response = await http.get(url);
      print(response);
      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body.toString());
        // var UserDetails = jsonResponse['userId'];
        absent = jsonResponse['absent'];
        present = jsonResponse['present'];
        User user = User.fromJson(jsonResponse);
        setState(() {
          absent = jsonResponse['Absent'];
          present = jsonResponse['Present'];
          print('present:$present');
          print('absent:$absent');
        });

        print(response.statusCode);
      } else {
        //print(response.statusCode);
        throw response.statusCode;
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  void fetchData(var email, var date) async {
    try {
      String dates = dateFormat.format(date); //15 Wed
      print(date);
      print('fetchDate:$dates');
      String apiEndpoint =
          'http://ems-ma.ideassionlive.in/api/UserActivity/findByEmailAndDate?email=$email&date=$dates';
      final Uri url = Uri.parse(apiEndpoint);

      print(url);
      var jsonResponse;
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          isDataAvailable = true; // set flag to true after successful fetch
          // update other state variables as before
        });
        jsonResponse = jsonDecode(response.body.toString());
        // var UserDetails = jsonResponse['userId'];
        checkInTime = jsonResponse["loginTime"];
        checkOutTime = jsonResponse["logoutTime"];
        mode = jsonResponse["workmode"];
        workhrs = jsonResponse["totalWorkingHours"];
        remarks = jsonResponse["status"];
        rdate = jsonResponse['date'];

        User user = User.fromJson(jsonResponse);
        DateTime dt = DateTime.parse(rdate.toString());
        print('dt:$dt');
        print(response.statusCode);
        setState(() {
          checkInTime = user.loginTime;
          checkOutTime = user.logoutTime;
          mode = user.workmode;
          workhrs = user.totalWorkingHours;
          remarks = user.status;
          rdate = dayFormat.format(dt);
        });
      } else {
        setState(() {
          isDataAvailable = false;
        });
        throw response.statusCode;
      }
    } catch (error) {
      print(error);
      setState(() {
        isDataAvailable = false;
      });
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('No Data Available',style: TextStyle(fontSize: 15),) ,backgroundColor: attendance,));
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

        var listUsers = getUsersData.map((i) => User.fromJson(i)).toList();
        for (var item in getUsersData) {
          //widget.date = DateTime.parse(item['date'].split(' ')[0]);
          var date = DateTime.parse(item['date']);
          var status = item['status'];

          if (_events[date] == null) {
            _events[date] = [status];
          } else {
            _events[date]?.add(status);
          }
          print('s${_events[date]}');
          print('ss${_events[status]}');
          print('date:${date}');
        }

        return listUsers;
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  List<String> _getEvents(DateTime date) {
    String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(date);
    // Retrieve the list of events for the formatted date
    var statuses = _events[formattedDate] ?? [];
    print('statuses:$statuses');

    return statuses.map((status) => status.toString()).toList();
  }
}
