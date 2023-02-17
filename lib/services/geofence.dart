import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoFencingService {
  GeofenceStatus geofenceStatus = GeofenceStatus.init;
  StreamSubscription<GeofenceStatus>? geofenceStatusStream;
  static bool value = true;
  Geolocator geolocator = Geolocator();
  bool isReady = false;
  String? officeAddress, nipponAddress;
  Position? position;

  Future<void> startGeofencing(var option) async {
    print(option);
    if (option == 'Office') {
      EasyGeofencing.stopGeofenceService();

      await EasyGeofencing.startGeofenceService(
          pointedLatitude: '13.0567361',
          pointedLongitude: '80.2571406',
          radiusMeter: '25.0',
          eventPeriodInSeconds: 5);
      if (geofenceStatusStream == null) {
        print('Status stream:${geofenceStatusStream}');
        geofenceStatusStream =
            EasyGeofencing.getGeofenceStream()!.listen((status) async {
          geofenceStatus = status;
          print('geofence status:${geofenceStatus}');
          position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          isReady = (position != null) ? true : false;
          if (value && GeofenceStatus.enter == geofenceStatus) {
            markAttendance(position);
          }
        });
      }
    } else if (option == 'Nippon') {
      EasyGeofencing.stopGeofenceService();

      await EasyGeofencing.startGeofenceService(
          pointedLatitude: '13.056290',
          pointedLongitude: '80.255287',
          radiusMeter: '15.0',
          eventPeriodInSeconds: 5);
      if (geofenceStatusStream == null) {
        print('Status stream:${geofenceStatusStream}');
        geofenceStatusStream =
            EasyGeofencing.getGeofenceStream()!.listen((status) async {
          geofenceStatus = status;
          print('geofence status:${geofenceStatus}');
          position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          isReady = (position != null) ? true : false;
          if (value && GeofenceStatus.enter == geofenceStatus) {
            markAttendance(position);
          }
        });
      }
    }
  }

  Future<void> markAttendance(Position? position) async {
    await placemarkFromCoordinates(position!.latitude, position!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      officeAddress =
          '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      print(officeAddress);
    }).catchError((e) {
      debugPrint(e);
    });
  }
}
