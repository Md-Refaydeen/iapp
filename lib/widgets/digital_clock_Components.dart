import 'package:flutter/material.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

class DigitalClockComponent extends StatelessWidget {
  const DigitalClockComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DigitalClock(

      areaWidth: 164.0,
      is24HourTimeFormat: true,
      areaDecoration: BoxDecoration(
        color: Colors.transparent,
      ),

      hourMinuteDigitTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 30,
      ),
      secondDigitTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 30,
      ),

    );
  }
}
