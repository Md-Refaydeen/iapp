import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          height: MediaQuery.of(context).size.height / 4.0,
          width: MediaQuery.of(context).size.width / 1.4,
          decoration: const BoxDecoration(),
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
              const Text(
                'Alert!!',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Please click a date to know details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF003756)),
              ),
              const SizedBox(
                height: 15,
              ),
              MaterialButton(
                onPressed:(){
                  Navigator.of(context).pop();

                },
                color: const Color(0xEF5278FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ok',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                minWidth: 120,
                height: 38,
              ),
            ],
          ),
        ));
  }
}
