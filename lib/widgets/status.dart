import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final String? status;

  StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == "Present" || status=="Late") {
      return Center(
        child: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 25,
        ),
      );
    } else if(status=='Absent' || status=='null'){
      return Center(
        child: Icon(
          Icons.close_rounded,
          color: Colors.red,
          size: 25,
        ),
      );

    }
    else{
      return Center(
        child: Icon(
          Icons.close_rounded,
          color: Colors.red,
          size: 25,
        ),
      );
    }
  }
}
