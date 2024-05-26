import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewPreorderDeliveryFeeInterface {
  factory NewPreorderDeliveryFeeInterface() =>
      NewPreorderDeliveryFee.initClass();

  // utils
  NewPreorderDeliveryFee fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
}

class NewPreorderDeliveryFee implements NewPreorderDeliveryFeeInterface {
  int restaurantID;
  double startKM, endKM, deliveryFee;

  NewPreorderDeliveryFee({
    this.restaurantID,
    this.startKM,
    this.endKM,
    this.deliveryFee,
  });

  NewPreorderDeliveryFee.initClass() {
    this.restaurantID = null;
    this.startKM = 0.0;
    this.endKM = 2.0;
    this.deliveryFee = 5.0;
  }

  @override
  NewPreorderDeliveryFee fromMap(Map<String, dynamic> map) {
    NewPreorderDeliveryFee newPreorderDeliveryFee;
    try {
      newPreorderDeliveryFee = NewPreorderDeliveryFee(
        restaurantID: map['rest_id'],
        startKM: map['start_km'] != null
            ? num.tryParse(map['start_km'].toString()).toDouble()
            : NewPreorderDeliveryFee.initClass().startKM,
        endKM: map['end_km'] != null
            ? num.tryParse(map['end_km'].toString()).toDouble()
            : NewPreorderDeliveryFee.initClass().endKM,
        deliveryFee: map['price'] != null
            ? num.tryParse(map['price'].toString()).toDouble()
            : NewPreorderDeliveryFee.initClass().deliveryFee,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewPreorderDeliveryFee fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    return newPreorderDeliveryFee;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "rest_id": this.restaurantID,
      "start_km": this.startKM,
      "end_km": this.endKM,
      "price": this.deliveryFee,
    };
  }
}
