import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

String displayTime(TimeOfDay timeOfDay) {
  String time = "";
  try {
    if (timeOfDay.hour == 0 && timeOfDay.minute == 1) {
      time = "ASAP";
    } else {
      time =
          "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}";
    }
  } catch (e) {
    String msg = getExceptionMsg(e);
    debugPrint("displayTime hit error. $msg");
    Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(getExceptionLogReq);
    FirebaseCrashlytics.instance
        .recordError(getExceptionLogReq, StackTrace.current);
    FirebaseCrashlytics.instance.log(jsonString);
  }
  return time;
}
