import 'package:flutter/cupertino.dart';
import 'package:iapp/admin_screens/attendance_screen.dart';
import 'package:iapp/user_screens/attendance_screen.dart';
import 'package:iapp/user_screens/login_screen.dart';
import '../admin_screens/home_screen.dart';
import '../admin_screens/individual_attendance.dart';
import '../user_screens/splash_screen.dart';
import '../user_screens/home_screen.dart';

Map<String,WidgetBuilder>routes={
  SplashScreen.routeName:(context)=>const SplashScreen(),
  HomeScreen.routeName:(context)=>const HomeScreen(),
  LoginScreen.routeName:(context)=>const LoginScreen(),
  AttendanceScreen.routeName:(context)=>AttendanceScreen(),
  //admin
  AdminHomeScreen.routeName:(context)=>const AdminHomeScreen(),
  AdminAttendanceScreen.routeName:(context)=>const AdminAttendanceScreen(),
  UserAttendanceScreen.routeName:(context)=>const UserAttendanceScreen(),



};