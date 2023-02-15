import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iapp/routes_folder/routes.dart';
import 'package:iapp/screens/splash_screen.dart';
import 'package:iapp/user_screens/home_screen.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ResponsiveWrapper.builder(child,
          maxWidth: 1200,
          minWidth: 480,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.autoScale(480, name: MOBILE),
            ResponsiveBreakpoint.autoScale(550, name: MOBILE),
            ResponsiveBreakpoint.autoScale(600, name: MOBILE),
            ResponsiveBreakpoint.autoScale(650, name: MOBILE),
            ResponsiveBreakpoint.autoScale(720, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: MOBILE),
            ResponsiveBreakpoint.autoScale(1000, name: MOBILE),
            ResponsiveBreakpoint.autoScale(1100, name: DESKTOP),
          ]),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context)
            .textTheme
            .apply()
            .copyWith(
                headline1: TextStyle(fontSize: 28, color: Color(0xFF003756)))),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      routes: routes,
      initialRoute: SplashScreen.routeName,
    );
  }
}
