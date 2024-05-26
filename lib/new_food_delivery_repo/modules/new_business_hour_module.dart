import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewBusinessHourInterface {
  factory NewBusinessHourInterface() => NewBusinessHour.initClass();

  // utils
  NewBusinessHour fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
}

class NewBusinessHour implements NewBusinessHourInterface {
  int numOfDay, // 1 => Monday, 2=> Tuesday
      restID; // restaurant ID
  String dayString; // Monday, Tuesday
  TimeOfDay startTime, endTime; // Operation Hours

  NewBusinessHour({
    this.numOfDay,
    this.restID,
    this.dayString,
    this.startTime,
    this.endTime,
  });

  NewBusinessHour.initClass() {
    this.numOfDay = 0;
    this.restID = null;
    this.dayString = "";
    this.startTime = TimeOfDay(hour: 00, minute: 00);
    this.endTime = TimeOfDay(hour: 23, minute: 59);
  }

  @override
  NewBusinessHour fromMap(Map<String, dynamic> map) {
    NewBusinessHour newBusinessHour;
    try {
      newBusinessHour = NewBusinessHour(
        numOfDay: map['day_no'],
        restID: map['rest_id'],
        dayString: map['day'] != null
            ? map['day']
            : NewBusinessHour.initClass().dayString,
        startTime: map['day_start'] != null &&
                map['day_start'].toString().length >= 5
            ? TimeOfDay.fromDateTime(DateTime.tryParse(
                "${DateTime.now().toString().substring(0, 10)} ${map['day_start']}"))
            : NewBusinessHour.initClass().startTime,
        endTime: map['day_end'] != null && map['day_end'].toString().length >= 5
            ? TimeOfDay.fromDateTime(DateTime.tryParse(
                "${DateTime.now().toString().substring(0, 10)} ${map['day_end']}"))
            : NewBusinessHour.initClass().endTime,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewBusinessHour fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newBusinessHour = null;
    }
    return newBusinessHour;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "day_no": this.numOfDay,
      "rest_id": this.restID,
      "day": this.dayString,
      "day_start": this.startTime != null
          ? "${this.startTime.hour.toString().padLeft(2, '0')}:${this.startTime.minute.toString().padLeft(2, '0')}"
          : null,
      "day_end": this.endTime != null
          ? "${this.endTime.hour.toString().padLeft(2, '0')}:${this.endTime.minute.toString().padLeft(2, '0')}"
          : null,
    };
  }
}
