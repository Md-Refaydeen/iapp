import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iapp/user_screens/attendance_screen.dart';
import 'package:iapp/services/geofence.dart';
import 'package:iapp/services/getLoc_Time.dart';
import 'package:iapp/screens/login_screen.dart';
import 'package:intl/intl.dart';
import '../dto/user.dart';
import '../widgets/alert_components.dart';
import '../constants/constants.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/digital_clock_Components.dart';
import '../widgets/list_components.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = 'HomeScreen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  GeoFencingService service = GeoFencingService();
  final Set<Marker> _markers = {};
  GoogleMapController? controller;
  String? checkInTime, checkOutTime;
  String? empName, Address;
  bool isLoading = false;
  Position? position;
  Location location = Location();
  Timer? _timer;

  User user = User();
  var email;
  bool checkMode = true;
  bool _isCheckedIn = false;

  var name, mode;
  final dateFormat = DateFormat('yyyy-MM-dd');
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    location.getDate();
    check();
    // // _timer = Timer.periodic(Duration(seconds: 60), (timer) {
    //   if (DateTime.now().hour >= 11.22) {
    //     checkOut();
    //   }

  }

  Future<void> check() async {
    print('check');

    final prefs = await SharedPreferences.getInstance();
    _isCheckedIn = prefs.getBool('_isCheckedIn') ?? false;
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() async {
        fetchData(email, location.date);
        await service.startGeofencing(mode);
        print('1');

      });
      var greets = location.greeting();
      print(greets);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(greets,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),backgroundColor: Color(0xFFAD8DCD),duration: Duration(seconds: 5),));

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

    return Scaffold(
      drawer: Drawer(
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width /5,
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
                    arguments: {'email': email, 'empName': name, 'mode': mode});
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
            SizedBox(height: MediaQuery.of(context).size.height/4.0,),

            Container(
              margin:
                  EdgeInsets.only(top: kDefaultPadding, right: kDefaultPadding),
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 10,
              child: Image.asset(
                'assets/images/Ideassion.png',
              ),
            ),
          ],
        ),
      ),
      key: _scaffoldKey,
      body: Stack(children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(13.0567141, 80.2571275),
              zoom: 20.0,
              tilt: 0,
              bearing: 0,
            ),
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            compassEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              controller = controller;
            },
            markers: _markers,
            circles: Set.of([
              Circle(
                circleId: CircleId('Attendance Boundary'),
                center: LatLng(13.0567141, 80.2571275),
                radius: 30.0,
                strokeColor: Colors.red.shade100.withOpacity(0.50),
                fillColor: Colors.red.withOpacity(0.30),
              )
            ]),
          ),
        ),
        Positioned(
          top: 39.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            //color: Colors.redAccent,
            height: 56,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.0),
                  border: Border.all(color: boxColor, width: 1.0),
                  color: BGcolor),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: iconColor,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                  )),
                  IconButton(
                    icon: Icon(
                      Icons.account_circle_rounded,
                      color: iconColor,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.routeName);
                      //print("your menu action here");
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        bottom()
      ]),
    );
  }

  DraggableScrollableSheet bottom() {
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
          physics: ClampingScrollPhysics(),
          controller: scrollController,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 2.5,
                  decoration: BoxDecoration(
                      color: BGcolor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(kDefaultPadding),
                        topRight: Radius.circular(kDefaultPadding),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            blurRadius: 20,
                            offset: Offset.zero,
                            color: Colors.grey.withOpacity(0.5))
                      ]),
                  child: Column(
                    children: [
                      sizedBox,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 15.0,
                          ),
                          CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/user.png',
                            ),
                            radius: 25.0,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600,color: Color(0xFF003756)),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Trainee',
                                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Color(0xff003756))
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    TextButton(
                                        onPressed: () {},
                                        style: ButtonStyle(

                                        ),
                                        child: Text(mode.toString())),
                                  ],
                                )
                              ]),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 15,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 13,
                            width: MediaQuery.of(context).size.width / 11,
                            child: SvgPicture.asset(
                              'assets/images/logo.svg',
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ],
                      ),
                      //sizedBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            location.cdate3.toString(),
                            style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600,color: Color(0xFF003756),
                          ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: kDefaultPadding * 2,
                            width: 20,
                          ),
                          Text(location.day.toString(),
                            style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,color: Color(0xFF003756),))
                             ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DigitalClockComponent(),
                          SizedBox(
                            width:MediaQuery.of(context).size.width/12,
                          ),

                          Container(
                            width: 150,
                            height: 38,
                            alignment: Alignment.center,
                            child: MaterialButton(
                              height: 159,
                              minWidth: 38,
                              color: btnColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _isCheckedIn ? 'Check Out' : 'Check In',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                              onPressed: () async {
                                if (_isCheckedIn) {
                                  checkOut();
                                } else {
                                  checkIn();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: kDefaultPadding * 4,
                            width: 20,
                          ),
                          Text(
                            'Check In:',
                            style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400,color: Color(0XFF003756)),

                          ),
                          Column(
                            children: [
                              Text(
                                checkInTime != null
                                    ? '$checkInTime'
                                    : '--- ---',
                                style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400,color: Color(0XFF003756)),
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: kDefaultPadding,
                            width: 20,
                          ),
                          Text(
                            'Check Out:',
                            style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400,color: Color(0XFF003756)),

                          ),
                          Column(
                            children: [
                              Text(
                                checkOutTime != null
                                    ? '$checkOutTime'
                                    : '--- ---',
                                style: TextStyle(fontSize: 17,fontWeight: FontWeight.w400,color: Color(0XFF003756)),

                              )
                            ],
                          ),
                        ],
                      ),
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
        final prefs = await SharedPreferences.getInstance();

        setState(() {
          Address = service.officeAddress;
          _isCheckedIn = true;
          prefs.setBool('_isCheckedIn', _isCheckedIn);
        });

        showDialog(
            context: context,
            builder: (_) => DialogComponent(
                  status: 'Access Granted',
                  image: 'assets/images/Success.png',
                  buttonTitle: 'Go in',
                  content: 'Welcome Back,You are in Office',
                  onPress: () {
                    Navigator.of(context).pop();
                  },
                ));

        updateLoginLocation(email);
      } else {
        showDialog(
            context: context,
            builder: (_) => DialogComponent(
                  status: 'Access Denied',
                  image: 'assets/images/denied.png',
                  buttonTitle: 'Go Back',
                  content: 'Sorry ,You are not in Office',
                  onPress: () {
                    Navigator.of(context).pop();
                  },
                ));
      }
    } else if(mode=='Nippon' && checkMode == true){
      if (service.officeAddress != null) {
        final prefs = await SharedPreferences.getInstance();

        setState(() {
          Address = service.officeAddress;
          _isCheckedIn = true;
          prefs.setBool('_isCheckedIn', _isCheckedIn);
        });

        showDialog(
            context: context,
            builder: (_) => DialogComponent(
              status: 'Access Granted',
              image: 'assets/images/Success.png',
              buttonTitle: 'Go in',
              content: 'Welcome Back,You are in Nippon Office',
              onPress: () {
                Navigator.of(context).pop();
              },
            ));

        updateLoginLocation(email);
      } else {
        showDialog(
            context: context,
            builder: (_) => DialogComponent(
              status: 'Access Denied',
              image: 'assets/images/denied.png',
              buttonTitle: 'Go Back',
              content: 'Sorry ,You are not in Nippon Office',
              onPress: () {
                Navigator.of(context).pop();
              },
            ));
      }

    }
    else {
      //if the user in home this will work
      await location.getAddress();
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _isCheckedIn = true;
        prefs.setBool('_isCheckedIn', _isCheckedIn);
        Address = location.homeAddress;
      });
      showDialog(
          context: context,
          builder: (_) => DialogComponent(
                status: 'Access Granted',
                image: 'assets/images/remote.png',
                buttonTitle: 'Go in',
                content: 'Welcome,You are in  WFH',
                onPress: () {
                  Navigator.of(context).pop();
                },
              ));
      print('wfh:$Address');
      updateLoginLocation(email);
    }
  }

  Future<void> checkOut() async {
    if (service.officeAddress != null) {
      setState(() {
        Address = service.officeAddress;
        _isCheckedIn = false;
      });

      updateLogoutLocation(email, Address);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('_isCheckedIn');
    } else {
      //for user Wfh
      await location.getAddress();
      setState(() {
        _isCheckedIn = false;
        Address = location.homeAddress;
      });
      updateLogoutLocation(email, Address);
      showDialog(
          context: context,
          builder: (_) => DialogComponent(
                status: 'Exit',
                image: 'assets/images/Success.png',
                buttonTitle: 'ok',
                content: 'We look Forward to see you',
                onPress: () {
                  Navigator.of(context).pop();
                },
              ));
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('_isCheckedIn');
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
        'http://ems-ma.ideassionlive.in/api/UserActivity/postUserActivityDetails';
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
          'http://ems-ma.ideassionlive.in/api/UserActivity/findByEmailAndDate?email=$email&date=$date';
      final Uri url = Uri.parse(apiEndpoint);
      var jsonResponse;
      final response = await http.get(url);
      print(url);
      if (response.statusCode == 200) {
        jsonResponse = jsonDecode(response.body.toString());
        checkInTime = jsonResponse["loginTime"];
        print(checkInTime);
        checkOutTime = jsonResponse["logoutTime"];
        // var UserDetails = jsonResponse['userId'];
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
      "date": location.date.toString()
    };
    var response = await http.put(
        Uri.parse('http://ems-ma.ideassionlive.in/api/UserActivity/logout'),
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
}
