import 'package:hantarr/global.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

Map<String, dynamic> getExceptionLog(dynamic e) {
  String msg = "";
  String log = "";
  try {
    msg = "\n${e.error}" + "\n${e.response.data['reason']}";
    log = "\n${e.error}" + "\n${e.response.data['reason']}";
  } catch (d) {
    try {
      msg = "${e.message}";
      // log = "${e.message}";
      log = e.toString();
    } catch (c) {
      msg = e.toString();
      log = e.toString();
    }
    msg = "Something went wrong"; // show this error msg only
  }

  var path = "";
  var stack = "";
  try {
    path = NavigationHistoryObserver()
        .history
        .map((x) => x.settings.name)
        .toList()
        .toString();
    // .join();
    stack = StackTrace.current.toString();
  } catch (c) {
    print("Exception get path failed " + c.toString());
  }
  Map<String, dynamic> payloadToLog = {
    "path": path,
    "log": "$log",
    "error_msg": msg,
    "stackTrace": stack,
    "datetime": DateTime.now().toString().substring(0, 16),
    "user_id": hantarrBloc.state.hUser.firebaseUser != null
        ? hantarrBloc.state.hUser.firebaseUser.uid
        : "Guest",
    "user_name": hantarrBloc.state.hUser.firebaseUser != null
        ? hantarrBloc.state.hUser.firebaseUser?.displayName
        : "Guest",
  };
  return payloadToLog;
}
