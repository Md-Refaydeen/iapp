import 'package:flutter/cupertino.dart';
import 'package:iapp/admin_screens/attendance_screen.dart';
import 'package:iapp/user_screens/attendance_screen.dart';
import 'package:iapp/screens/login_screen.dart';
import '../admin_screens/home_screen.dart';
import '../admin_screens/individual_attendance.dart';
import '../screens/splash_screen.dart';
import '../user_screens/home_screen.dart';

Map<String,WidgetBuilder>routes={
  SplashScreen.routeName:(context)=>SplashScreen(),
  HomeScreen.routeName:(context)=>HomeScreen(),
  LoginScreen.routeName:(context)=>LoginScreen(),
  AttendanceScreen.routeName:(context)=>AttendanceScreen(),
  //admin
  AdminHomeScreen.routeName:(context)=>AdminHomeScreen(),
  AdminAttendanceScreen.routeName:(context)=>AdminAttendanceScreen(),
  UserAttendanceScreen.routeName:(context)=>UserAttendanceScreen(),



};