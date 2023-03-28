import 'package:flutter/material.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

class DigitalClockComponent extends StatelessWidget {
  const DigitalClockComponent({required this.digitalClockColor});
  final Color digitalClockColor;


  @override
  Widget build(BuildContext context) {
    return DigitalClock(

      areaWidth: 164.0,
      is24HourTimeFormat: true,
      areaDecoration: BoxDecoration(
        color: Colors.transparent,

      ),

      hourMinuteDigitTextStyle: TextStyle(
        color: digitalClockColor,
        fontSize: 30,

      ),
      secondDigitTextStyle: TextStyle(
        color: digitalClockColor,
        fontSize: 30,
      ),
      hourMinuteDigitDecoration: BoxDecoration(
        border: null
      ),
      secondDigitDecoration: BoxDecoration(
        border: null
      ),

    );
  }
}
