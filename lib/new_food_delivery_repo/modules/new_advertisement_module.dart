import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';

abstract class NewAdvertisementInterface {
  NewAdvertisement fromMap(Map<String, dynamic> map);

  // APIs
  Future<Map<String, dynamic>> getListAdvertisement();
}

class NewAdvertisement implements NewAdvertisementInterface {
  int id;
  String name, imgUrl, desc, path;
  bool isHantarr; // is for hantarr only
  DateTime startDate, endDate;

  NewAdvertisement.initClass() {
    this.id = null;
    this.name = "";
    this.imgUrl = "";
    this.desc = "";
    this.path = "";
    this.isHantarr = false;
    this.startDate = null;
    this.endDate = null;
  }

  NewAdvertisement({
    this.id,
    this.name,
    this.imgUrl,
    this.desc,
    this.path,
    this.isHantarr,
    this.startDate,
    this.endDate,
  });

  @override
  NewAdvertisement fromMap(Map<String, dynamic> map) {
    NewAdvertisement newAdvertisement;
    try {
      newAdvertisement = NewAdvertisement(
        id: map['id'],
        name: map["name"] != null ? map["name"] : "",
        imgUrl: map["img_url"] != null ? map["img_url"] : "",
        desc: map["description"] != null ? map["description"] : "",
        // path: "/menuItems?rest_id=49",
        path: map['path'] != null ? map['path'] : "",
        isHantarr: map['target_platform'] != null
            ? map['target_platform'].toString().toLowerCase() == "hantarr_"
                ? true
                : false
            : false,
        startDate: map["start_date"] != null
            ? DateTime.tryParse(map["start_date"])
            : null,
        endDate:
            map["end_date"] != null ? DateTime.tryParse(map["end_date"]) : null,
      );
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newAdvertisement = null;
    }
    return newAdvertisement;
  }

  @override
  Future<Map<String, dynamic>> getListAdvertisement() async {
    List<NewAdvertisement> advertisements = [];
    DateTime curTime =
        DateTime.tryParse("${DateTime.now().toString().substring(0, 10)}");
    try {
      Dio dio = getDio(
        baseOption: 1,
        queries: {
          "long": hantarrBloc.state.selectedLocation.longitude,
          "lat": hantarrBloc.state.selectedLocation.latitude,
        },
      );
      Response response = await dio.get("/advertisment");
      if (response.data != "") {
        for (Map<String, dynamic> map in response.data) {
          NewAdvertisement newAdvertisement = NewAdvertisement().fromMap(map);
          if (newAdvertisement != null) {
            if (newAdvertisement.isHantarr) {
              if ((curTime.isAfter(newAdvertisement.startDate) ||
                      curTime.isAtSameMomentAs(newAdvertisement.startDate)) &&
                  (curTime.isBefore(newAdvertisement.endDate) ||
                      curTime.isAtSameMomentAs(newAdvertisement.endDate))) {
                advertisements.add(newAdvertisement);
              } else {
                debugPrint("ads expired");
              }
            } else {
              debugPrint("ads is not hantarr");
            }
          }
        }
      }
      hantarrBloc.state.advertisements =
          List<NewAdvertisement>.from(advertisements);
      return {
        "success": true,
        "data": hantarrBloc.state.advertisements,
      };
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason":
            "getListAdvertisement hit error. ${getExceptionLogReq['error_msg']}"
      };
    }
  }
}
