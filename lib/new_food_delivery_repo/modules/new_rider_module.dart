import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewRiderInterface {
  factory NewRiderInterface() => NewRider.initClass();

  // local
  NewRider fromMap(Map<String, dynamic> map);
}

class NewRider implements NewRiderInterface {
  int id;
  String name;
  LatLng latLng;
  double comparedDistance;

  NewRider({
    this.id,
    this.name,
    this.latLng,
    this.comparedDistance,
  });

  NewRider.initClass() {
    this.id = null;
    this.name = "";
    this.latLng = null;
    this.comparedDistance = 0.0;
  }

  @override
  NewRider fromMap(Map<String, dynamic> map) {
    NewRider newRider;
    try {
      newRider = NewRider.initClass();
      newRider.id = map['rider_id'] != null ? map['rider_id'] : this.id;
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewRider fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newRider = null;
    }
    return newRider;
  }
}
