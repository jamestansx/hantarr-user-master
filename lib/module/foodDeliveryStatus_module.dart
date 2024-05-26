import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class DeliveryStatusInterface {
  String getDisplayStatus();
}

class DeliveryStatus implements DeliveryStatusInterface {
  bool pickUp;
  bool foodPrepared;
  bool delivered;
  bool restaurantReceived;
  bool riderReceived;
  bool canceled;
  bool acceptFailedByRestaurant;
  bool noRider;
  String status;

  DeliveryStatus({
    this.delivered,
    this.foodPrepared,
    this.restaurantReceived,
    this.pickUp,
    this.riderReceived,
    this.canceled,
    this.acceptFailedByRestaurant,
    this.noRider,
    this.status,
  });

  DeliveryStatus newClass() {
    return DeliveryStatus(
      pickUp: this.pickUp,
      foodPrepared: this.foodPrepared,
      delivered: this.delivered,
      restaurantReceived: this.restaurantReceived,
      riderReceived: this.riderReceived,
      canceled: this.canceled,
      acceptFailedByRestaurant: this.acceptFailedByRestaurant,
      noRider: this.noRider,
      status: this.status,
    );
  }

  @override
  String getDisplayStatus() {
    String displayStatus = "";
    try {
      if (this.delivered == true) {
        displayStatus = "Delivered";
      } else if (this.canceled == true) {
        displayStatus = "Cancelled";
      } else if (this.pickUp == false) {
        displayStatus = "Order Ready";
      } else if (this.pickUp == true) {
        displayStatus = "Picked Up";
      } else {
        displayStatus = "Pending";
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("getDisplayStatus hit error $msg");
      displayStatus = "Pending.";
    }
    return displayStatus;
  }
}
