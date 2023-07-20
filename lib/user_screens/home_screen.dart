import 'dart:async';
import 'dart:convert';
import 'package:geofence_service/geofence_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iapp/user_screens/attendance_screen.dart';
import 'package:iapp/services/track_location.dart';
import 'package:iapp/services/getLoc_Time.dart';
import 'package:iapp/user_screens/login_screen.dart';
import 'package:intl/intl.dart';
import '../dto/user.dart';
import '../widgets/alert_components.dart';
import '../constants/constants.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/digital_clock_Components.dart';
import '../widgets/googleMap_Widget.dart';
import '../widgets/list_components.dart';
import '../widgets/welcome_widget.dart';
import 'package:iapp/datas/geofences.dart';
class HomeScreen extends StatefulWidget {
  static String routeName = 'HomeScreen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();
  int count = 0;
  bool _isInExitState = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TrackLocation service = TrackLocation();
  final Set<Marker> _markers = {};
  bool _showButton = true;
  Color color = Colors.black87;
  GoogleMapController? controller;
  String? checkInTime, checkOutTime;
  String? empName, Address;
  bool isLoading = false;
  Position? position;
  GetLoc_Time location = GetLoc_Time();
  Timer? _timer;

  User user = User();
  var email;
  bool checkMode = true;
  bool _isCheckedIn = false;

  var name, mode;
  final dateFormat = DateFormat('yyyy-MM-dd');
  final GeofenceService _geofenceService = GeofenceService.instance.setup(
      interval: 10000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 1000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: true,
      geofenceRadiusSortType: GeofenceRadiusSortType.ASC);

  @override
  void dispose() {
    _timer?.cancel();
    _activityStreamController.close();
    _geofenceStreamController.close();

    super.dispose();
  }

  void _hideButton() {
    setState(() {
      _showButton = false;
    });
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showButton = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(geofenceList).catchError(_onError);
    });

    location.getDate();
    checkingDatas();
  }

  Future<void> _saveBreakCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('break_count', count);
  }

  Future<void> checkingDatas() async {
    print('check');

    final prefs = await SharedPreferences.getInstance();
    _isCheckedIn = prefs.getBool('_isCheckedIn') ?? false;
    final previousCount = prefs.getInt('break_count') ?? 0;
    print('previousCount:$previousCount');

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        fetchData(email, location.date);
        count = previousCount;
        print('old Count:$count');
      });
      var greets = location.greeting();
      print(greets);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          greets,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFAD8DCD),
        duration: const Duration(seconds: 5),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    if (arguments != null) {
      email = arguments['email'].toString();
      name = arguments['empName'].toString();
      mode = arguments['mode'].toString();
      setState(() {
        email = arguments['email'];
        mode = arguments['mode'];
      });
    }

    return WillStartForegroundTask(
      onWillStart: () async {
        // You can add a foreground task start condition.
        return _geofenceService.isRunningService;
      },
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'geofence_service_notification_channel',
        channelName: 'Geofence Service Notification',
        channelDescription:
            'This notification appears when the geofence service is running in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        isSticky: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(),
      notificationTitle: 'iapp is running',
      notificationText: 'Tap to return to the app',
      child: Scaffold(
        drawer: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: Drawer(
            backgroundColor: Colors.purple.shade50,
            width: MediaQuery.of(context).size.width * 0.7,
            child: ListView(
              padding: const EdgeInsets.only(top: 65.0),
              children: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                    alignment: Alignment.topRight),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 5,
                      child: const CircleAvatar(
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
                      style: const TextStyle(fontSize: 20),
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
                          'mode': mode
                        });
                  },
                ),
                ListComponents(
                  title: 'Attendance',
                  iconData: Icons.calendar_today_outlined,
                  onPress: () {
                    Navigator.pushNamed(context, AttendanceScreen.routeName,
                        arguments: {
                          'email': email,
                          'name': name,
                          'mode': mode,
                        });
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
                  height: MediaQuery.of(context).size.height / 4.0,
                ),
                Container(
                  margin: const EdgeInsets.only(
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
        key: _scaffoldKey,
        body: Stack(children: <Widget>[
          googleMap_Widget(markers: _markers),
          Positioned(
            top: 39.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: 56,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Welcome_widget(scaffoldKey: _scaffoldKey),
            ),
          ),
          scrollContainer()
        ]),
      ),
    );
  }

  DraggableScrollableSheet scrollContainer() {
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 0.3,
      maxChildSize: 0.4,
      builder: (BuildContext context, ScrollController scrollController) =>
          NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          clipBehavior: Clip.none,
          physics: const ClampingScrollPhysics(),
          controller: scrollController,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 2.5,
                  decoration: BoxDecoration(
                    color: BGcolor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(kDefaultPadding),
                      topRight: Radius.circular(kDefaultPadding),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 20,
                          offset: Offset.zero,
                          color: Colors.grey.withOpacity(0.5))
                    ],
                  ),
                  child: Column(
                    children: [
                      sizedBox,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 15.0,
                          ),
                          const CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/user.png',
                            ),
                            radius: 25.0,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF003756)),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Text('Trainee',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff003756))),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    TextButton(
                                        onPressed: () {},
                                        style: const ButtonStyle(),
                                        child: Text(mode.toString())),
                                  ],
                                ),
                              ]),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 8,
                          ),
                          SvgPicture.asset(
                            height: 57,
                            width: 46,
                            'assets/images/logo.svg',
                            alignment: Alignment.topRight,
                          ),
                        ],
                      ),
                      //sizedBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            location.cdate3.toString(),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF003756),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: kDefaultPadding * 2,
                            width: 20,
                          ),
                          Text(location.day.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003756),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DigitalClockComponent(digitalClockColor: color),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 12,
                          ),
                          _showButton
                              ? Container(
                                  width: 150,
                                  height: 38,
                                  alignment: Alignment.center,
                                  child: MaterialButton(
                                      height: 159,
                                      minWidth: 38,
                                      color: btnColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        _isCheckedIn ? 'Check Out' : 'Check In',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                      onPressed: () async {
                                        if (_isCheckedIn) {
                                          checkOut();
                                        } else {
                                          checkIn();
                                        }
                                        _hideButton();
                                      }),
                                )
                              : const SizedBox()
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: kDefaultPadding * 4,
                            width: 20,
                          ),
                          const Text(
                            'Check In:',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Color(0XFF003756)),
                          ),
                          Text(
                            checkInTime != null ? '$checkInTime' : '--- ---',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Color(0XFF003756)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: kDefaultPadding,
                            width: 20,
                          ),
                          const Text(
                            'Check Out:',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Color(0XFF003756)),
                          ),
                          Text(
                            checkOutTime != null ? '$checkOutTime' : '--- ---',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Color(0XFF003756)),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Breaks:$count',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Color(0XFF003756)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Future<void> checkIn() async {
    if (mode == 'Office' && checkMode == true) {
      if (service.officeAddress != null) {
        setState(() {
          Address = service.officeAddress;
          _isCheckedIn = true;
        });

        await showAccessDialogBox('Office');
        setState(() {
          color = Colors.red;
        });

        await updateLoginLocation(email);
      } else {
        await showDeniedDialogBox('Office');
      }
    } else if (mode == 'Nippon' && checkMode == true) {
      if (service.officeAddress != null) {
        setState(() {
          Address = service.officeAddress;
          _isCheckedIn = true;

        });
        await showAccessDialogBox('Nippon Office');
        setState(()  {
          color = Colors.red;


        });

        updateLoginLocation(email);
      } else {
        showDeniedDialogBox('Nippon Office');
      }
    } else {
      //if the user in home this will work
      await location.getAddress();
      setState(() {
        _isCheckedIn = true;
        Address = location.homeAddress;
      });
      showAccessDialogBox('WFH');
      setState(() {
        color = Colors.red;
      });

      print('wfh:$Address');
      await updateLoginLocation(email);
    }
  }

  Future<void> showAccessDialogBox(String msg) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('_isCheckedIn', _isCheckedIn);

    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (_) => DialogComponent(
              status: 'Access Granted',
              image: 'assets/images/Success.png',
              buttonTitle: 'Go in',
              content: 'Welcome Back,You are in $msg',
              onPress: () {
                Navigator.of(context).pop();
              },
            ));
  }

  Future<void> showDeniedDialogBox(String msg) async {
    showDialog(
        context: context,
        builder: (_) => DialogComponent(
              status: 'Access Denied',
              image: 'assets/images/denied.png',
              buttonTitle: 'Go Back',
              content: 'Sorry ,You are not in $msg',
              onPress: () {
                Navigator.of(context).pop();
              },
            ));
  }

  Future<void> exitSucesssDialogBox() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('_isCheckedIn');
    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (_) => DialogComponent(
              status: 'Exit',
              image: 'assets/images/Success.png',
              buttonTitle: 'Ok',
              content: 'We look forward to see you',
              onPress: () {
                Navigator.of(context).pop();
              },
            ));
  }

  Future<void> checkOut() async {
    if (service.officeAddress != null) {
      setState(() {
        Address = service.officeAddress;
        _isCheckedIn = false;
      });
      await exitSucesssDialogBox();
      setState(() {
        color = Colors.black87;
      });
      updateLogoutLocation(email, Address);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('break_count');

    } else {
      //for user Wfh
      await location.getAddress();
      setState(() {
        _isCheckedIn = false;
        Address = location.homeAddress;
      });
      await exitSucesssDialogBox();
      setState(() {
        color = Colors.black87;
      });
      updateLogoutLocation(email, Address);
    }
  }

  updateLoginLocation(var email) async {
    Map<String, String> data = {
      "email": email.toString(),
      "loginLocation": Address.toString(),
      "workmode": mode.toString(),
    };
    var jsonResponse;
    String apiEndpoint =
        '$appUrl/UserActivity/postUserActivityDetails';
    var body = json.encode(data);
    final Uri url = Uri.parse(apiEndpoint);
    var response = await http.post(
      url,
      body: body,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      fetchData(email, location.date);

      if (jsonResponse != null) {
        User user = User.fromJson(jsonResponse);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchData(var email, var date) async {
    try {
      String apiEndpoint =
          '$appUrl/UserActivity/findByEmailAndDate?email=$email&date=$date';
      final Uri url = Uri.parse(apiEndpoint);
      var jsonResponse;
      final response = await http.get(url);
      print(url);
      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body.toString());
        checkInTime = jsonResponse["loginTime"];
        print(checkInTime);
        checkOutTime = jsonResponse["logoutTime"];
        User user = User.fromJson(jsonResponse);
        setState(() {
          checkInTime = user.loginTime;
          checkOutTime = user.logoutTime;
        });
      } else {
        //print(response.statusCode);
        throw response.statusCode;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateLogoutLocation(var email, String? Address) async {
    var headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };

    var data = {
      "email": email,
      "logoutLocation": Address.toString(),
      "date": location.date.toString(),
      "workModeCheckOut": mode.toString(),
    };
    var response = await http.put(
        Uri.parse('$appUrl/UserActivity/logout'),
        headers: headers,
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      checkOutTime = jsonResponse["logoutTime"];
      setState(() {
        checkOutTime = user.logoutTime;
      });
      fetchData(email, location.date);

      if (jsonResponse != null) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location,
      ) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');

    if (geofenceStatus == GeofenceStatus.ENTER) {
      print('enter state in georadius:${location.longitude},${location.latitude}');
      service.markAttendance(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (_isInExitState) {
        setState(() {
          count = count + 1;
        });
        await _saveBreakCount(count);
        _isInExitState = false; // Reset the flag as the user is back in the "ENTER" state.
      }
    } else if (geofenceStatus == GeofenceStatus.DWELL) {
      print('dwell state');
    } else {
      print('exit state');
      _isInExitState = true; // Set the flag as the user is in the "EXIT" state.
    }

    _geofenceStreamController.sink.add(geofence);
  }

  // This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }
}


