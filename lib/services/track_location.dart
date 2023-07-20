import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class TrackLocation {
  static bool value = true;
  Geolocator geolocator = Geolocator();
  bool isReady = false;
  String? officeAddress, nipponAddress;
  Position? position;
  Future<void> markAttendance({double? latitude,double? longitude}) async {
    await placemarkFromCoordinates(latitude!,longitude!)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      officeAddress =
      '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      print(officeAddress);
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }
}