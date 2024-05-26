import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewSchedulePriceInterface {
  factory NewSchedulePriceInterface() => NewSchedulePrice.initClass();

  // utils
  NewSchedulePrice fromMap(Map<String, dynamic> map);
}

class NewSchedulePrice implements NewSchedulePriceInterface {
  DateTime fromDateTime, toDateTime;
  String frequencyDuration;
  double price;

  NewSchedulePrice({
    this.fromDateTime,
    this.toDateTime,
    this.frequencyDuration,
    this.price,
  });

  NewSchedulePrice.initClass() {
    this.fromDateTime = null;
    this.toDateTime = null;
    this.frequencyDuration = "weekly";
    this.price = 20.0;
  }

  @override
  NewSchedulePrice fromMap(Map<String, dynamic> map) {
    NewSchedulePrice newSchedulePrice;
    try {
      newSchedulePrice = NewSchedulePrice(
        fromDateTime: DateTime.tryParse("${map["start"]} ${map["time_start"]}"),
        toDateTime: DateTime.tryParse("${map["until"]} ${map["time"]}"),
        frequencyDuration: map['frequency'] != null
            ? map['frequency']
            : NewSchedulePrice.initClass().frequencyDuration,
        price: map['delivery_price'] != null
            ? num.tryParse(map['delivery_price'].toString()).toDouble()
            : NewSchedulePrice.initClass().price,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newSchedulePrice = null;
      debugPrint("NewSchedulePrice fromMap hit error. $msg");
    }
    return newSchedulePrice;
  }
}
