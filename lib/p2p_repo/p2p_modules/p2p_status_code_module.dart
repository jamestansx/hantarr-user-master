import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class P2PStatusCodeInterface {
  factory P2PStatusCodeInterface() => P2PStatusCode.initClass();
  //  --- Utilis   ---//
  P2PStatusCode fromMap(Map<String, dynamic> map);

  //  ---  API   -- //
  Future<Map<String, dynamic>> getListP2PStatus();
}

class P2PStatusCode implements P2PStatusCodeInterface {
  int id;
  String message, code;

  P2PStatusCode({
    this.id,
    this.message,
    this.code,
  });

  P2PStatusCode.initClass() {
    this.id = null;
    this.message = "";
    this.code = "";
  }

  @override
  P2PStatusCode fromMap(Map<String, dynamic> map) {
    P2PStatusCode p2pStatusCode;
    try {
      p2pStatusCode = P2PStatusCode(
        id: map['id'],
        message: map['message'],
        code: map['code'],
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("P2PStatusCode module frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      p2pStatusCode = null;
    }
    return p2pStatusCode;
  }

  @override
  Future<Map<String, dynamic>> getListP2PStatus() async {
    List<P2PStatusCode> statusCodes = [];

    try {
      Dio dio = getDio(
        baseOption: 2,
        queries: {},
      );
      Response response = await dio.get("/list_pp_code");
      for (Map<String, dynamic> map in response.data) {
        P2PStatusCode p2pStatusCode = P2PStatusCode().fromMap(map);
        if (p2pStatusCode != null) {
          statusCodes.add(p2pStatusCode);
        }
      }
      hantarrBloc.state.p2pStatusCodes.clear();
      hantarrBloc.state.p2pStatusCodes = statusCodes;
      hantarrBloc.add(Refresh());
      return {"success": true, "data": List<P2PStatusCode>.from(statusCodes)};
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("Get List P2P status failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get List P2P status failed. $msg"};
    }
  }
}
