import 'dart:io';

import 'package:dio/dio.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';

import '../global.dart';

Future<Map<String, dynamic>> collectUserData(
    Map<String, dynamic> payload) async {
  try {
    var location = new Location();
    LocationData currentLocation;
    double long, lat;
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      _permissionGranted = await Location().requestPermission();
      currentLocation = await location.getLocation();
    } else {
      currentLocation = await location.getLocation();
    }
    try {
      long = currentLocation.longitude;
      lat = currentLocation.latitude;
    } catch (b) {}
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Dio dio = Dio();
    Map<String, dynamic> sendThis = {
      "email": payload['email'],
      "phone": payload['phone'],
      "platform": Platform.isAndroid ? "android" : "ios",
      "version": packageInfo.version,
      "long": long,
      "lat": lat,
    };
    print(sendThis);
    Response response = await dio.post(
      "$foodUrl/collect_data",
      data: sendThis,
    );
    print("${response.data}");
    return {"success": true};
  } catch (e) {
    return {"success": false, "reason": e.toString()};
  }
}
