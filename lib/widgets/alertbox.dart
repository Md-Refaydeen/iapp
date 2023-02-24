import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iapp/constants/constants.dart';

class AlertBox extends StatelessWidget {
  const AlertBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height / 4.5,
          width: MediaQuery.of(context).size.width / 1.4,
          decoration: BoxDecoration(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 40,
                    width: 40,
                  ),
                ],
              ),
              Text(
                'Alert!!',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                'Please click a date to know details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF003756)),
              ),
            ],
          ),
        ));
  }
}