import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'get_exception_log.dart';

Future<String> geoDecode(LatLng latLng) async {
  try {
    String address = "";
    Dio dio = Dio(
      BaseOptions(
        baseUrl: "https://maps.googleapis.com",
        headers: {
          "Content-Type": "application/json",
          'Accept': "application/json",
        },
        queryParameters: {
          "latlng": "${latLng.latitude},${latLng.longitude}",
          "key": "AIzaSyCP6DCTU7pUCg-ELswj1bxe1jABsCntkHo",
        },
      ),
    );
    Response response = await dio.get("/maps/api/geocode/json");
    address = response.data['results'].first['formatted_address'];
    return address;
  } catch (e) {
    Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(getExceptionLogReq);
    FirebaseCrashlytics.instance
        .recordError(getExceptionLogReq, StackTrace.current);
    FirebaseCrashlytics.instance.log(jsonString);
    return "";
  }
}
