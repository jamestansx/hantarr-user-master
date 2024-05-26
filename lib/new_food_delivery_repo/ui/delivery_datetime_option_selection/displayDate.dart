import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

String displayDate(DateTime dateTime) {
  String dateDisplay = "";
  try {
    if (dateTime.isAtSameMomentAs(DateTime.tryParse(
        "${hantarrBloc.state.serverTime.toString().substring(0, 10)}"))) {
      return "${(weekday[dateTime.weekday - 1])}, ${(months[dateTime.month - 1])} ${dateTime.day} (Today)";
    } else {
      return "${(weekday[dateTime.weekday - 1])}, ${(months[dateTime.month - 1])} ${dateTime.day}";
    }
  } catch (e) {
    String msg = getExceptionMsg(e);
    debugPrint("displayDate hit error. $msg");
    Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(getExceptionLogReq);
    FirebaseCrashlytics.instance
        .recordError(getExceptionLogReq, StackTrace.current);
    FirebaseCrashlytics.instance.log(jsonString);
  }
  return dateDisplay;
}
