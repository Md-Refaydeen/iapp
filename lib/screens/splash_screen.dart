import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iapp/screens/login_screen.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../constants/constants.dart';


class SplashScreen extends StatelessWidget {
  static String routeName='SplashScreen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5),(){
      //for not returning to splash screen
      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
    });
    return Scaffold(
      backgroundColor: BGcolor,
      body:
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/logo.svg',),
            JumpingText('Loading...',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,color: Colors.purple.shade900,fontFamily: 'Poppins-Medium.ttf'),),],


        ),

      ),
    );
  }
}