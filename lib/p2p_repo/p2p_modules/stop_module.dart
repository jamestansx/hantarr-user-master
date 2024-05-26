import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class StopInterface {
  factory StopInterface() => Stop.initClass();

  // utils
  Map<String, dynamic> toJson();
  Stop fromMap(Map<String, dynamic> map);
}

class Stop implements StopInterface {
  int index;
  Address address;

  Stop({
    this.index,
    this.address,
  });

  Stop.initClass() {
    this.index = 0;
    this.address = Address.initClass();
    this.address.longitude = null;
    this.address.latitude = null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "index": this.index,
      "address": address.toJson(),
    };
  }

  @override
  Stop fromMap(Map<String, dynamic> map) {
    Stop stop;
    try {
      stop = Stop(
        index: map['index'] != null
            ? num.tryParse(map['index'].toString()).toInt()
            : 0,
        address: Address.initClass().fromMap(map['address']),
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      print("stop module fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      stop = null;
    }
    return stop;
  }
}
