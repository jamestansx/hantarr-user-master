import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class OSMInterface {
  factory OSMInterface() => OSM.initClass();
  //  --- Utils ----  //
  OSM fromMap(Map<String, dynamic> map);
  Map<String, dynamic> classOverview();
  OSM fromAPI(Map<String, dynamic> map);

  //  ---   API  ---- //
  Future<Map<String, dynamic>> getListRoute(int fromStopIndex, int toStopIndex,
      double long, double lat, double toLong, double toLat);
}

class OSM implements OSMInterface {
  int fromStopIndex, toStopIndex;
  String code, summary;
  double distance, duration;
  List<OSMCoordinate> coordinates = [];

  OSM({
    this.fromStopIndex,
    this.toStopIndex,
    this.code,
    this.summary,
    this.distance,
    this.duration,
    this.coordinates,
  });

  OSM.initClass() {
    this.fromStopIndex = 0;
    this.toStopIndex = 0;
    this.code = "failed";
    this.summary = "";
    this.distance = 0.0;
    this.duration = 0.0;
    this.coordinates = [];
  }

  @override
  Map<String, dynamic> classOverview() {
    return {
      "from_stop_index": this.fromStopIndex,
      "to_stop_index": this.toStopIndex,
      "code": this.code,
      "summary": this.summary,
      "distance": this.distance,
      "duration": this.duration,
      "coordinates_size": this.coordinates.length,
      "coordinates": this.coordinates.map((e) => e.toJson()).toList(),
    };
  }

  @override
  OSM fromMap(Map<String, dynamic> map) {
    OSM osm;
    try {
      osm = OSM.initClass();
      osm.code = map['code'];
      osm.summary = map['routes'].first['legs'].first['summary'];
      osm.distance =
          num.parse(map['routes'].first['distance'].toString()).toDouble() *
              // 0.95; // - 5%
              1.1; // Thomas asked to update
      osm.duration =
          num.tryParse(map['routes'].first['duration'].toString()).toDouble();
      List<OSMCoordinate> coordinates = [];
      for (Map<String, dynamic> steps
          in map['routes'].first['legs'].first['steps']) {
        for (var coordinate in steps['geometry']['coordinates']) {
          OSMCoordinate osmCoordinate = OSMCoordinate(
            long: num.tryParse(coordinate[0].toString()).toDouble(),
            lat: num.tryParse(coordinate[1].toString()).toDouble(),
          );
          coordinates.add(osmCoordinate);
        }
      }
      osm.coordinates = coordinates;
      return osm;
    } catch (e) {
      String msg = getExceptionMsg(e);
      print("OSM frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      osm = null;
    }
    return osm;
  }

  @override
  Future<Map<String, dynamic>> getListRoute(int fromStopIndex, int toStopIndex,
      double fromLong, double fromLat, double toLong, double toLat) async {
    try {
      Dio dio = getDio(baseOption: 1, queries: {
        "overview": false,
        "steps": true,
        "alternatives": true,
        "geometries": "geojson"
      });
      Response response = await dio
          .get("/geo/route/v1/driving/$fromLong,$fromLat;$toLong,$toLat");
      if (response.data['code'] == "Ok") {
        OSM osm = OSM.initClass().fromMap(response.data);
        osm.fromStopIndex = fromStopIndex;
        osm.toStopIndex = toStopIndex;
        if (osm != null) {
          return {"success": true, "data": osm};
        } else {
          return {"success": false, "reason": "OSM From map hit error"};
        }
      } else {
        return {
          "success": false,
          "reason": "Retrive route error. ${response.data['message']}"
        };
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Retrive route error. $msg"};
    }
  }

  @override
  OSM fromAPI(Map<String, dynamic> map) {
    OSM osm;
    List<OSMCoordinate> coordinates = [];
    try {
      for (Map<String, dynamic> coordinate in map['coordinates']) {
        OSMCoordinate osmCoordinate = OSMCoordinate().fromMap(coordinate);
        if (osmCoordinate != null) {
          coordinates.add(osmCoordinate);
        }
      }
      osm = OSM(
        fromStopIndex: map['from_stop_index'],
        toStopIndex: map['to_stop_index'],
        code: map['code'],
        summary: map['summary'],
        distance: map['distance'],
        duration: map['duration'],
        coordinates: coordinates,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("OSM module frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      osm = null;
    }
    return osm;
  }
}

class OSMCoordinate {
  double long, lat;

  OSMCoordinate({
    this.long,
    this.lat,
  });
  OSMCoordinate.initClass() {
    try {
      this.long = hantarrBloc.state.hUser.longitude;
      this.lat = hantarrBloc.state.hUser.latitude;
    } catch (e) {
      this.long = null;
      this.lat = null;
    }
  }
  Map<String, dynamic> toJson() {
    return {
      "long": this.long,
      "lat": this.lat,
    };
  }

  OSMCoordinate fromMap(Map<String, dynamic> map) {
    OSMCoordinate osmCoordinate;
    try {
      osmCoordinate = OSMCoordinate(
        long: map['long'],
        lat: map['lat'],
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("get osmcoordinates hit erorr. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    return osmCoordinate;
  }
}

abstract class OSMPlaceInterface {
  // -- Utils
  Future<Map<String, dynamic>> searchName(String name);
  OSMPlace fromMap(Map<String, dynamic> map);
}

class OSMPlace implements OSMPlaceInterface {
  String displayName, address;
  OSMCoordinate osmCoordinate;
  OSMPlace({
    this?.displayName,
    this.address,
    this.osmCoordinate,
  });

  OSMPlace.initClass() {
    this?.displayName = "";
    this.address = "";
    this.osmCoordinate = OSMCoordinate.initClass();
  }

  @override
  Future<Map<String, dynamic>> searchName(String name) async {
    try {
      List<OSMPlace> osmPlaces = [];
      Dio dio = getDio(baseOption: 1, queries: {
        "q": "$name",
        "format": "geojson",
        "limit": 50,
        // "state": "selangor"
        // "countrycodes": "MY",
      });
      dio.options.headers = {};
      dio.options.baseUrl = "http://map.resertech.com:7070";
      Response response = await dio.get(
        "/search",
      );
      for (Map<String, dynamic> map in response.data['features']) {
        OSMPlace osmPlace = OSMPlace.initClass().fromMap(map);
        if (osmPlace != null) {
          osmPlaces.add(osmPlace);
        }
      }
      return {"success": true, "data": List<OSMPlace>.from(osmPlaces)};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Search place error. $msg"};
    }
  }

  @override
  OSMPlace fromMap(Map<String, dynamic> map) {
    OSMPlace osmPlace;
    try {
      osmPlace = OSMPlace(
        displayName: map["properties"]["display_name"].split(",").first,
        address: map["properties"]["display_name"],
        osmCoordinate: OSMCoordinate(
          long: num.parse(map["geometry"]["coordinates"][0].toString())
              .toDouble(),
          lat: num.parse(map["geometry"]["coordinates"][1].toString())
              .toDouble(),
        ),
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      print("OSMPlace frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      osmPlace = null;
    }
    return osmPlace;
  }
}
