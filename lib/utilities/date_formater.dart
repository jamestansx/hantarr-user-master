import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

import 'get_exception_log.dart';

String dateFormater(DateTime dateTime) {
  String date = "";
  try {
    date =
        "${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  } catch (e) {
    String msg = getExceptionMsg(e);
    debugPrint("dateFormater hit error $msg");
    Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(getExceptionLogReq);
    FirebaseCrashlytics.instance
        .recordError(getExceptionLogReq, StackTrace.current);
    FirebaseCrashlytics.instance.log(jsonString);
  }
  return date;
}
