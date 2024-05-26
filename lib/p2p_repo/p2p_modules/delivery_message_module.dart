import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class DeliveryMessageInterface {
  DeliveryMessage fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();

  //  --- API  -----  //
  // Future<Map<String,dynamic>> getListDeliveryMessages(int p2pID);
}

class DeliveryMessage implements DeliveryMessageInterface {
  int id, p2pID, stopIndex;
  DateTime datetime;
  String message, code;
  DeliveryMessage(
      {this.id,
      this.p2pID,
      this.stopIndex,
      this.datetime,
      this.message,
      this.code});

  DeliveryMessage.initClass() {
    this.id = null;
    this.p2pID = null;
    this.stopIndex = 0;
    this.datetime = null;
    this.message = "";
    this.code = "";
  }

  @override
  DeliveryMessage fromMap(Map<String, dynamic> map) {
    DeliveryMessage deliveryMessage;
    try {
      deliveryMessage = DeliveryMessage(
        id: map['id'],
        p2pID: map['p2p_id'],
        stopIndex: map['stop_index'] != null
            ? num.tryParse(map['stop_index'].toString()).toInt()
            : 0,
        datetime:
            map['datetime'] != null ? DateTime.tryParse(map['datetime']) : null,
        message: map['message'] != null ? map['message'] : "-",
        code: map['code'] != null ? map['code'] : "",
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("deliveryMessage frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      deliveryMessage = null;
    }
    return deliveryMessage;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
    };
  }
}
