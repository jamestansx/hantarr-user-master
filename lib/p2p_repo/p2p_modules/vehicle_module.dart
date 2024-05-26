import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/p2p_repo/p2p_modules/additional_fare_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/vehicle_option_module.dart';
import 'package:hantarr/p2p_repo/pages/homepage/vehicle_options_page.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

UniqueKey getListKey = UniqueKey();

abstract class VehicleInterface {
  // Utilities
  factory VehicleInterface() => Vehicle.initClass();
  Map<String, dynamic> toJson();
  Vehicle fromMap(Map<String, dynamic> map);
  Vehicle fromHistoryAPI(Map<String, dynamic> map);
  IconData getIcon();
  Widget getTabPage(dynamic onchange);
  double getVehicleOptionPrice();
  double getDistancePrice(double meter);

  // API Calls
  Future<Map<String, dynamic>> getAllVehicle();
}

class Vehicle implements VehicleInterface {
  int id;
  bool disable;
  String vehicleName;
  double weightLimit, kmLimit;
  double baseKm;
  List<VehicleOption> vehicleOption;
  List<AdditionalFare> additionalFare;

  Vehicle({
    this.id,
    this.disable,
    this.vehicleName,
    this.weightLimit,
    this.kmLimit,
    this.baseKm,
    this.vehicleOption,
    this.additionalFare,
  }) : assert(
          disable != null &&
              vehicleName != null &&
              weightLimit != null &&
              kmLimit != null &&
              baseKm != null &&
              vehicleOption != null &&
              additionalFare != null,
        );

  Vehicle.initClass() {
    this.id = null;
    this.disable = false;
    this.vehicleName = "Motorcycle";
    this.weightLimit = 10.0;
    this.kmLimit = 100.0;
    this.baseKm = 4.0;
    this.vehicleOption = [];
    this.additionalFare = [];
  }

  @override
  Vehicle fromMap(Map<String, dynamic> map) {
    Vehicle vehicle;
    List<VehicleOption> vehicleOptions = [];
    List<AdditionalFare> additionalFare = [];
    try {
      map.forEach((key, value) {
        if (availableFares.where((x) => x.keyName == key).isNotEmpty) {
          VehicleOption vehicleOption = VehicleOption.initClass();
          vehicleOption
              .mapToLocal(availableFares.firstWhere((x) => x.keyName == key));
          vehicleOption.fareAmount = num.tryParse(value.toString()).toDouble();
          if (vehicleOption.fareAmount == 0) {
            vehicleOption.showInUI = false;
          }
          vehicleOptions.add(vehicleOption);
        } else {
          debugPrint("Vehicle options (this key is missing):  $key");
        }
      });

      if (map['additional_fare'] != null) {
        for (Map<String, dynamic> addFare in map['additional_fare']) {
          AdditionalFare addkmFare =
              AdditionalFare.initClass().fromMap(addFare);
          if (addkmFare != null) {
            additionalFare.add(addkmFare);
          }
        }
      }
      additionalFare.sort((a, b) => a.kmStart.compareTo(b.kmStart));

      vehicle = Vehicle(
        id: map['id'],
        disable: map['disable'] != null ? map['disable'] : false,
        vehicleName: map['name'] != null ? map['name'] : "",
        weightLimit: map['weight_limit'] != null
            ? num.tryParse(map['weight_limit'].toString()).toDouble()
            : 0.0,
        kmLimit: map['km_limit'] != null
            ? num.tryParse(map['km_limit'].toString()).toDouble()
            : 0.0,
        baseKm: map['base_km'] != null
            ? num.tryParse(map['base_km'].toString()).toDouble()
            : 0.0,
        vehicleOption: vehicleOptions,
        additionalFare: additionalFare,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      print("vehicle module frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      vehicle = null;
    }
    return vehicle;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "disable": this.disable,
      "name": this.vehicleName,
      "weight_limit": this.weightLimit,
      "km_limit": this.kmLimit,
      "base_km": this.baseKm,
      "vehicle_options": this
          .vehicleOption
          .map(
            (e) => e..toJson(),
          )
          .toList(),
      "additional_fare": this
          .additionalFare
          .map(
            (e) => e.toJson(),
          )
          .toList(),
    };
  }

  @override
  Future<Map<String, dynamic>> getAllVehicle() async {
    try {
      if (hantarrBloc.state.p2pVehicleLoaded) {
        return {
          "success": true,
          "data": List<Vehicle>.from(hantarrBloc.state.vehicleList)
        };
      }
      Dio dio = getDio(baseOption: 2, queries: {});
      Response response = await dio.get(
        "/vechicle_type_rate",
      );
      hantarrBloc.state.vehicleList = [];
      for (Map<String, dynamic> map in response.data) {
        Vehicle vehicle = VehicleInterface().fromMap(map);
        if (vehicle != null) {
          hantarrBloc.state.vehicleList.add(vehicle);
        }
      }
      hantarrBloc.state.vehicleList
          .sort((a, b) => a.weightLimit.compareTo(b.weightLimit));

      if (hantarrBloc.state.vehicleList.isEmpty) {
        return {"success": false, "reason": "Vehicle list empty"};
      } else {
        hantarrBloc.state.p2pVehicleLoaded = true;
        return {
          "success": true,
          "data": List<Vehicle>.from(hantarrBloc.state.vehicleList)
        };
      }
    } catch (e) {
      hantarrBloc.state.p2pVehicleLoaded = false;
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      BotToast.showWidget(
        key: getListKey,
        toastBuilder: (_) => WillPopScope(
          onWillPop: () {
            return null;
          },
          child: AlertDialog(
            title: Text("Something went wrong"),
            content: Text("Please try again"),
            actions: [
              FlatButton(
                onPressed: () {
                  BotToast.remove(getListKey);
                  this.getAllVehicle();
                },
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
      return {"success": false, "reason": "Get Vehicle List Failed. $msg"};
    }
  }

  @override
  IconData getIcon() {
    if (this.vehicleName.toLowerCase().contains("motor")) {
      return Icons.motorcycle;
    } else if (this.vehicleName.toLowerCase().contains("car")) {
      return Icons.local_taxi;
    } else if (this.vehicleName.toLowerCase().contains("van")) {
      return FontAwesomeIcons.shuttleVan;
    } else if (this.vehicleName.toLowerCase().contains("4x4")) {
      return FontAwesomeIcons.truckPickup;
    } else if (this.vehicleName.toLowerCase().contains("1-ton")) {
      return FontAwesomeIcons.truck;
    } else if (this.vehicleName.toLowerCase().contains("3-ton")) {
      return FontAwesomeIcons.truckMoving;
    } else {
      return Icons.motorcycle;
    }
  }

  @override
  Widget getTabPage(dynamic onchange) {
    return Stack(
      children: [
        VehicleOptionsPage(
          vehicle: this,
          onChange: onchange,
        ),
        this.disable
            ? MaterialButton(
                onPressed: () {},
                color: Colors.black.withOpacity(.7),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "This Vehicle is not availble yet",
                        textAlign: TextAlign.center,
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontSize: ScreenUtil().setSp(55.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(15),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  @override
  double getVehicleOptionPrice() {
    double total = 0.0;
    this.vehicleOption.map((e) {
      if (e.enable) {
        total += e.fareAmount;
        debugPrint(
            "Vehicle Option: (${e.optionTitle}): + RM ${e.fareAmount.toStringAsFixed(2)}");
      }
    }).toList();
    return total;
  }

  @override
  double getDistancePrice(double meter) {
    double total = 0.0;
    double totalKM = meter / 1000;
    // debugPrint("total distance ==> ${totalKM.toStringAsFixed(2)} km ");
    this.additionalFare.sort((a, b) => a.kmStart.compareTo(b.kmStart));
    if (totalKM > this.baseKm) {
      debugPrint(
          "Total KM (${totalKM.toStringAsFixed(2)}) > Base KM (${this.baseKm.toStringAsFixed(2)})");
      totalKM -= this.baseKm;
      debugPrint("Exceeded Distance: ${totalKM.toStringAsFixed(2)} km");
      for (AdditionalFare additionalFare in this.additionalFare) {
        debugPrint(
            "${additionalFare.kmStart}km to ${additionalFare.kmLimit}km, Fare (RM ${additionalFare.farePerKM}/km):");
        if (totalKM >= additionalFare.kmStart &&
            totalKM <= additionalFare.kmLimit) {
          total = (totalKM * additionalFare.farePerKM);
          debugPrint(
              "(${totalKM.toStringAsFixed(2)} km * ${additionalFare.farePerKM.toStringAsFixed(2)}/km = RM ${total.toStringAsFixed(2)}), Balance: 0.0 km");
          totalKM = 0.0;
          break;
        } else {
          double croppedDist = additionalFare.kmLimit - additionalFare.kmStart;
          if (croppedDist < totalKM) {
            totalKM -= croppedDist;
            total += croppedDist * additionalFare.farePerKM;
            debugPrint(
                "(${croppedDist.toStringAsFixed(2)} km * ${additionalFare.farePerKM.toStringAsFixed(2)}/km = RM ${total.toStringAsFixed(2)}), Balance: ${totalKM.toStringAsFixed(2)} km");
          } else {
            total += totalKM * additionalFare.farePerKM;
            totalKM = 0.0;
            debugPrint(
                "(${totalKM.toStringAsFixed(2)} km * ${additionalFare.farePerKM.toStringAsFixed(2)}/km = RM ${total.toStringAsFixed(2)}), Balance: ${totalKM.toStringAsFixed(2)} km");
          }
        }
      }
    } else {
      totalKM = 0;
      total = 0;
      debugPrint(
          "Total KM (${totalKM.toStringAsFixed(2)}) < Base KM (${this.baseKm.toStringAsFixed(2)}km)");
    }
    if (totalKM > 0 && this.additionalFare.isNotEmpty) {
      total += totalKM * this.additionalFare.last.farePerKM;
      debugPrint(
          "Extra ${totalKM.toStringAsFixed(2)} km ==> ${totalKM.toStringAsFixed(2)} * ${this.additionalFare.last.farePerKM}/km = RM ${(totalKM * this.additionalFare.last.farePerKM).toStringAsFixed(2)}");
      totalKM = 0;
    } else if (totalKM > 0 && this.additionalFare.isEmpty && this.id == null) {
      throw ("HIT ERROR");
    } else if (totalKM < 0) {
      throw ("INTERNAL APP HIT ERROR");
    }
    debugPrint("Total Additional fare: + RM ${total.toStringAsFixed(2)}");
    return total;
  }

  @override
  Vehicle fromHistoryAPI(Map<String, dynamic> map) {
    //     int id;
    // bool disable;
    // String vehicleName;
    // double weightLimit, kmLimit;
    // double baseKm;
    // List<VehicleOption> vehicleOption;
    // List<AdditionalFare> additionalFare;
    Vehicle vehicle;
    List<VehicleOption> vehicleOptions = [];
    if (map['vehicle_options'] != null) {
      for (Map<String, dynamic> vo in map['vehicle_options']) {
        VehicleOption vehicleOption = VehicleOption.initClass().fromMap(vo);
        if (vehicleOption != null) {
          vehicleOptions.add(vehicleOption);
        }
      }
    }
    List<AdditionalFare> additionFares = [];
    if (map['additional_fare'] != null) {
      for (Map<String, dynamic> vo in map['additional_fare']) {
        AdditionalFare additionalFare = AdditionalFare.initClass().fromMap(vo);
        if (additionalFare != null) {
          additionFares.add(additionalFare);
        }
      }
    }

    try {
      vehicle = Vehicle(
        id: map['id'],
        disable: map['disable'],
        vehicleName: map['name'],
        weightLimit: map['weight_limit'],
        kmLimit: map['km_limit'],
        baseKm: map['base_km'],
        vehicleOption: vehicleOptions,
        additionalFare: additionFares,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("Vehicle fromHistori API decode failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      vehicle = null;
    }
    return vehicle;
  }
}
