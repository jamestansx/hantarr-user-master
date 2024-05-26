import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_business_hour_module.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewDeliveryHourInterface {
  factory NewDeliveryHourInterface() => NewDeliveryHour.initClass();

  // utils
  NewDeliveryHour fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
  void bussinessHourToDeliveryHour(NewBusinessHour businessHour);
}

class NewDeliveryHour implements NewDeliveryHourInterface {
  int numOfDay, // 1 => Monday, 2=> Tuesday
      restID; // restaurant ID
  String dayString; // Monday, Tuesday
  TimeOfDay startTime, endTime; // Operation Hours

  NewDeliveryHour({
    this.numOfDay,
    this.restID,
    this.dayString,
    this.startTime,
    this.endTime,
  });

  NewDeliveryHour.initClass() {
    this.numOfDay = 0;
    this.restID = null;
    this.dayString = "";
    this.startTime = TimeOfDay(hour: 00, minute: 00);
    this.endTime = TimeOfDay(hour: 23, minute: 59);
  }

  @override
  void bussinessHourToDeliveryHour(NewBusinessHour businessHour) {
    this.numOfDay = businessHour.numOfDay;
    this.restID = businessHour.restID;
    this.dayString = businessHour.dayString;
    this.startTime = businessHour.startTime;
    this.endTime = businessHour.endTime;
  }

  @override
  NewDeliveryHour fromMap(Map<String, dynamic> map) {
    NewDeliveryHour newDeliveryHour;
    try {
      newDeliveryHour = NewDeliveryHour(
        numOfDay: map['day_no'],
        restID: map['rest_id'],
        dayString: map['day'] != null
            ? map['day']
            : NewBusinessHour.initClass().dayString,
        startTime: map['time_start'] != null &&
                map['time_start'].toString().length >= 5
            ? TimeOfDay.fromDateTime(DateTime.tryParse(
                "${DateTime.now().toString().substring(0, 10)} ${map['time_start']}"))
            : NewBusinessHour.initClass().startTime,
        endTime: map['time_end'] != null && map['time_end'].toString().length >= 5
            ? TimeOfDay.fromDateTime(DateTime.tryParse(
                "${DateTime.now().toString().substring(0, 10)} ${map['time_end']}"))
            : NewBusinessHour.initClass().endTime,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewDeliveryHour fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newDeliveryHour = null;
    }
    return newDeliveryHour;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "day_no": this.numOfDay,
      "rest_id": this.restID,
      "day": this.dayString,
      "day_start": this.startTime != null
          ? "${this.startTime.hour}:${this.startTime.minute}"
          : null,
      "day_end": this.endTime != null
          ? "${this.endTime.hour}:${this.endTime.minute}"
          : null,
    };
  }
}
