import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class VehicleOptionInterface {
  factory VehicleOptionInterface() => VehicleOption.initClass();

  // utils
  void mapToLocal(VehicleOption vehicleOption);
  Map<String, dynamic> toJson();
  VehicleOption fromMap(Map<String, dynamic> map);
}

// list of available fee

// base_fare ==> dont show in ui
// holiday_surcharge_fare  ==> dont show in ui
// additional_stop_fare  ==> dont show in ui
// door_to_door_service_fare
// door_to_door_service_1helper
// door_to_door_service_2helper
// buy4u_service_fare
// round_trip_fare

List<VehicleOption> availableFares = [
  new VehicleOption(
    keyName: "base_fare",
    fareAmount: 0.0,
    optionTitle: "Base Fare",
    optionDescription: "",
    enable: true,
    showInUI: false,
  ),
  new VehicleOption(
    keyName: "holiday_surcharge_fare",
    fareAmount: 0.0,
    optionTitle: "Holiday Surcharge Fare",
    optionDescription: "",
    enable: false,
    showInUI: false,
  ),
  new VehicleOption(
    keyName: "additional_stop_fare",
    fareAmount: 0.0,
    optionTitle: "Additional Stop Fare",
    optionDescription: "",
    enable: false,
    showInUI: false,
  ),
  new VehicleOption(
    keyName: "door_to_door_service_fare",
    fareAmount: 0.0,
    optionTitle: "Door to door service fare",
    optionDescription: "",
    enable: false,
    showInUI: true,
  ),
  new VehicleOption(
    keyName: "door_to_door_service_1helper",
    fareAmount: 0.0,
    optionTitle: "Door to door service fare 1 helper",
    optionDescription: "",
    enable: false,
    showInUI: true,
  ),
  new VehicleOption(
    keyName: "door_to_door_service_2helper",
    fareAmount: 0.0,
    optionTitle: "Door to door service fare 2 helper",
    optionDescription: "",
    enable: false,
    showInUI: true,
  ),
  new VehicleOption(
    keyName: "buy4u_service_fare",
    fareAmount: 0.0,
    optionTitle: "Buy for you",
    optionDescription: "",
    enable: false,
    showInUI: true,
  ),
  new VehicleOption(
    keyName: "round_trip_fare",
    fareAmount: 0.0,
    optionTitle: "Round trip fare",
    optionDescription: "",
    enable: false,
    showInUI: true,
  ),
];

class VehicleOption implements VehicleOptionInterface {
  String keyName;
  double fareAmount;
  String optionTitle, optionDescription;
  bool enable, showInUI;

  VehicleOption({
    this.keyName,
    this.fareAmount,
    this.optionTitle,
    this.optionDescription,
    this.enable,
    this.showInUI,
  }) : assert(
          keyName != null &&
              fareAmount != null &&
              optionTitle != null &&
              optionDescription != null &&
              enable != null &&
              showInUI != null,
        );

  VehicleOption.initClass() {
    this.keyName = "";
    this.fareAmount = 0.0;
    this.optionTitle = "";
    this.optionDescription = null;
    this.enable = false;
    this.showInUI = false;
  }

  @override
  void mapToLocal(VehicleOption vehicleOption) {
    this.keyName = vehicleOption.keyName;
    this.fareAmount = vehicleOption.fareAmount;
    this.optionTitle = vehicleOption.optionTitle;
    this.optionDescription = vehicleOption.optionDescription;
    this.enable = vehicleOption.enable;
    this.showInUI = vehicleOption.showInUI;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "key_name": this.keyName,
      "fare_amount": this.fareAmount,
      "option_title": this.optionTitle,
      "option_description": this.optionDescription,
      "enable": this.enable,
      "showInUI": this.showInUI,
    };
  }

  @override
  VehicleOption fromMap(Map<String, dynamic> map) {
    VehicleOption vehicleOption;
    try {
      vehicleOption = VehicleOption(
        keyName: map['key_name'] != null ? map['key_name'] : "",
        fareAmount: map['fare_amount'] != null
            ? num.tryParse(map['fare_amount'].toString()).toDouble()
            : 0.0,
        optionTitle: map['option_title'] != null ? map['option_title'] : "",
        optionDescription:
            map['option_description'] != null ? map['option_description'] : "",
        enable: map['enable'] != null ? map['enable'] : true,
        showInUI: map['showInUI'] != null ? map['showInUI'] : false,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("vehicle option frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      vehicleOption = null;
    }
    return vehicleOption;
  }
}
