import 'dart:io';

import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
class GetLoc_Time {
  String? cdate3;
  String? day;
  String? homeAddress;
  Position? currentPosition;
  var date,month,year;

  void getDate() {
    cdate3 = DateFormat("d MMMM, yyyy").format(DateTime.now()).toString();
    day = DateFormat('EEEE').format(DateTime.now()).toString();
    print(cdate3);
    date = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd,]);
    year = formatDate(DateTime.now(), [yyyy]);
    month=formatDate(DateTime.now(), [mm]);
  }
  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      var status = Permission.storage.request();
      print(status);
      if (status != PermissionStatus.granted) {
        print('Storage permission not granted');
      }
    }
  }

  Future<void> getAddress() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;
    print('current position:$currentPosition');

    await placemarkFromCoordinates(
        currentPosition!.latitude, currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      homeAddress =
      '${place.street} ${place.subLocality},${place
          .subAdministrativeArea},${place.postalCode}';
      print('home:$homeAddress');
    }).catchError((e) {
      debugPrint(e.toString());
    });
    //calling date and time functions
    // print('Current Address:$currentAddress,time:$finalTime,date:$date');

  }

  String greeting() {
    var hour = DateTime
        .now()
        .hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  void getPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

}