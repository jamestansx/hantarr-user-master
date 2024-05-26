import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class AdditionalFareInterface {
  factory AdditionalFareInterface() => AdditionalFare.initClass();
  // utils
  void mapToLocal(AdditionalFare additionalFare);
  Map<String, dynamic> toJson();
  AdditionalFare fromMap(Map<String, dynamic> map);
}

class AdditionalFare implements AdditionalFareInterface {
  int vehicleTypeID;
  String fareName;
  double kmStart, kmLimit, farePerKM;

  AdditionalFare({
    this.vehicleTypeID,
    this.fareName,
    this.kmStart,
    this.kmLimit,
    this.farePerKM,
  });

  AdditionalFare.initClass() {
    this.vehicleTypeID = null;
    this.fareName = "";
    this.kmStart = 0.0;
    this.kmLimit = 0.0;
    this.farePerKM = 1.0;
  }
  @override
  void mapToLocal(AdditionalFare additionalFare) {
    this.vehicleTypeID = additionalFare.vehicleTypeID;
    this.fareName = additionalFare.fareName;
    this.kmStart = additionalFare.kmStart;
    this.kmLimit = additionalFare.kmLimit;
    this.farePerKM = additionalFare.farePerKM;
  }

  @override
  AdditionalFare fromMap(Map<String, dynamic> map) {
    AdditionalFare additionalFare;
    try {
      additionalFare = AdditionalFare(
        vehicleTypeID: map['vechicle_type_id'] != null
            ? num.tryParse(map['vechicle_type_id'].toString()).toInt()
            : null,
        fareName: map['name'] != null ? map['name'] : "",
        kmStart: map['km_start'] != null
            ? num.tryParse(map['km_start'].toString()).toDouble()
            : 0.0,
        kmLimit: map['km_limit'] != null
            ? num.tryParse(map['km_limit'].toString()).toDouble()
            : 0.0,
        farePerKM: map['additional_fare_per_km'] != null
            ? num.tryParse(map['additional_fare_per_km'].toString()).toDouble()
            : 2.0,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("AdditionalFare frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      additionalFare = null;
    }
    return additionalFare;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "vechicle_type_id": this.vehicleTypeID,
      "name": this.fareName,
      "km_start": this.kmStart,
      "km_limit": this.kmLimit,
      "additional_fare_per_km": this.farePerKM,
    };
  }
}
