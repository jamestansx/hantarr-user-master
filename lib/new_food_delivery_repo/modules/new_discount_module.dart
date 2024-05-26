import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewDiscountInterface {
  factory NewDiscountInterface() => NewDiscount.initClass();

  // utils
  NewDiscount fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
}

class NewDiscount implements NewDiscountInterface {
  int restID; // restaurant's ID
  String name, // discount's title
      subtitle, // discount's subtitle
      description, // discount's description
      banner, // discount's banner
      discountType, // discount's type [ cash, perc ]  cash or percentage
      frequency;
  List<String> targets, // if match any item in the list then check requirement
      requirements; // if match all requirements then got discount

  //  -------------------------  //
  double minSpend, // minimum spend to fullfil requirement
      discountAmount; // discount amount
  //( if discountType is cash then direct deduct by discountAmount else use it as percentage )
  DateTime startDateTime, endDateTime; // valid from date to date

  //  ----    EXAMPLE    -----  //
  // 1) Example 1
  // targets = ["milk tea", "meat"];
  // requirements = ["milk tea", "milk tea"];
  // conclusion ==> need buy 2 milk tea only can get discount

  // 2) Example 2
  // targets = ["milk tea", "meat"];
  // requirements = [];
  // conclusion ==> if match any element inside targets then can get discount

  NewDiscount({
    this.restID,
    this.name,
    this.subtitle,
    this.description,
    this.banner,
    this.discountType,
    this.frequency,
    this.targets,
    this.requirements,
    this.minSpend,
    this.discountAmount,
    this.startDateTime,
    this.endDateTime,
  });

  NewDiscount.initClass() {
    this.restID = null;
    this.name = "";
    this.subtitle = "";
    this.description = "";
    this.banner = "";
    this.discountType = "";
    this.frequency = "";
    this.targets = [];
    this.requirements = [];
    this.minSpend = 50.0;
    this.discountAmount = 0.0;
    this.startDateTime = null;
    this.endDateTime = null;
  }

  @override
  NewDiscount fromMap(Map<String, dynamic> map) {
    NewDiscount newDiscount;
    List<String> requirements = [];
    List<String> targets = [];
    try {
      if (map['requirements'] != null) {
        requirements = map['requirements'].split(",");
      }
      if (map['targets'] != null) {
        targets = map['targets'].split(",");
      }
      if (map['start_date'] == null) {
        return null;
      }
      DateTime sstartDateTime =
          DateTime.tryParse("${map['start_date']} ${map['start_time']}");
      DateTime sendDateTime =
          DateTime.tryParse("${map['end_date']} ${map['end_time']}");
      if (sstartDateTime == null) {
        sstartDateTime = DateTime.now().subtract(Duration(days: 365));
      }
      if (sendDateTime == null) {
        sendDateTime = DateTime.now().subtract(Duration(days: 365));
      }
      newDiscount = NewDiscount(
        restID: map['rest_id'],
        name: map['name'] != null ? map['name'] : NewDiscount.initClass().name,
        subtitle: map['subtitle'] != null ? map['subtitle'] : "",
        description: map['description'] != null ? map['description'] : "",
        banner: map['banner'] != null ? map['banner'] : "",
        discountType: map['disc_type'] != null ? map['disc_type'] : "",
        frequency: map['frequency'] != null
            ? map['frequency']
            : NewDiscount.initClass().frequency,
        targets: targets,
        requirements: requirements,
        minSpend: map['min_spend'],
        discountAmount: map['amount'],
        startDateTime: sstartDateTime,
        endDateTime: sendDateTime,
      );
      if (map['name'].toString().contains("RM 3 off")) {
        debugPrint("check");
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewDiscount frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newDiscount = null;
    }
    return newDiscount;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "requirements": this.requirements.join(","),
      "targets": this.targets.join(","),
      "start_date": this.startDateTime != null
          ? this.startDateTime.toString().substring(0, 10)
          : null,
      "start_time": this.startDateTime != null
          ? this.startDateTime.toString().substring(10, 16)
          : null,
      "end_date": this.endDateTime != null
          ? this.endDateTime.toString().substring(0, 10)
          : null,
      "end_time": this.endDateTime != null
          ? this.endDateTime.toString().substring(10, 16)
          : null,
      "rest_id": this.restID,
      "name": this.name,
      "subtitle": this.subtitle,
      "description": this.description,
      "banner": this.banner,
      "disc_type": this.discountType,
      "frequency": this.frequency,
      "min_spend": this.minSpend,
      "amount": this.discountAmount,
    };
  }
}
