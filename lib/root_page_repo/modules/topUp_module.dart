import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class TopUpInterface {
  factory TopUpInterface() => TopUp.initClass();

  // utils
  Future<Map<String, dynamic>> getTopUpHistory();

  // local
  TopUp fromJson(Map<String, dynamic> map);
}

class TopUp implements TopUpInterface {
  int id;
  String imageURL;
  double amount;
  DateTime datetime;
  bool approve;

  TopUp({
    this.amount,
    this.approve,
    this.datetime,
    this.id,
    this.imageURL,
  });

  TopUp.initClass() {
    this.amount = 0.0;
    this.approve = false;
    this.datetime = null;
    this.id = null;
    this.imageURL = "";
  }

  TopUp fromJson(Map<String, dynamic> map) {
    TopUp topUp;
    try {
      topUp = TopUp(
        id: map["id"],
        imageURL: map["filename"] != null
            ? foodUrl + "images/payments/" + map["filename"]
            : null,
        amount: map["amount"] != null
            ? num.tryParse(map["amount"].toString()).toDouble()
            : 0.0,
        datetime: map["inserted_at"] != null
            ? DateTime.parse(map["inserted_at"]).add(Duration(hours: 8))
            : null,
        approve: map["is_approved"] != null ? map["is_approved"] : false,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("TopUp module frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      topUp = null;
    }
    return topUp;
  }

  @override
  Future<Map<String, dynamic>> getTopUpHistory() async {
    List<TopUp> topUpList = [];
    try {
      Dio dio = getDio(
        baseOption: 1,
        queries: {},
      );
      Response response =
          await dio.get("/topup/${hantarrBloc.state.hUser.firebaseUser.uid}");
      if (response.data != "") {
        for (Map<String, dynamic> map in response.data) {
          TopUp topUp = TopUp.initClass().fromJson(map);
          if (topUp != null) {
            topUpList.add(topUp);
          }
        }
      }
      topUpList.sort((a, b) => b.datetime.compareTo(a.datetime));
      hantarrBloc.state.topUpList = List<TopUp>.from(topUpList);
      hantarrBloc.add(Refresh());
      return {"success": true, "data": List<TopUp>.from(topUpList)};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get Top Up History Failed. $msg"};
    }
  }
}
