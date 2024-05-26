import 'dart:convert';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/p2p_repo/p2p_modules/delivery_message_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/stop_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/vehicle_module.dart';
import 'package:hantarr/root_page_repo/modules/osm_route_module.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';
import 'package:hantarr/utilities/round_currency.dart';

abstract class P2PTransactionInterface {
  factory P2PTransactionInterface() => P2pTransaction.initClass();
  // Utilities
  void mapToLocal(P2pTransaction p2pTransaction);
  Map<String, dynamic> toJson();
  P2pTransaction fromMap(Map<String, dynamic> map);
  double calculateDistance(lat1, lon1, lat2, lon2);
  double getTotalStopsPrice();
  double getDistancePrice();
  double getRiderTipsPrice();
  double getTotalPrice();
  double getRoundedCurrency(double grantTOTAL);
  double getRoundPrice(double grantTOTAL);
  int getTotalValidStopsCount();
  List<Stop> getValidStops();
  bool exceedVehicleKM();
  String firstStopAddress();
  Color chipStatusColor();

  Future<String> choosePaymentMethod(BuildContext context, dynamic setFunction);
  Future<Map<String, dynamic>> ableToPlaceOrder();

  bool canAddMoreStops();
  Map<String, List<P2pTransaction>> grouppedByDate(
      List<P2pTransaction> p2pList);

  // API Calls
  // Future<Map<String, dynamic>> calculateFee();
  Future<Map<String, dynamic>> getTotalDistance();
  Future<Map<String, dynamic>> getListP2P(Map<String, dynamic> queries);
  Future<Map<String, dynamic>> createTransaction();
  Future<Map<String, dynamic>> getSupportAreas();
  Future<Map<String, dynamic>> getPendingP2Ps();
  Future<Map<String, dynamic>> getSpecificP2P();
}

enum PaymentMethod { cash, credit }

String getPaymentMethod(PaymentMethod paymentMethod) {
  String paymenthod = "";
  try {
    if (paymentMethod == PaymentMethod.cash) {
      paymenthod = "Cash on Delivery";
    } else if (paymentMethod == PaymentMethod.credit) {
      paymenthod = "Credit";
    } else {
      throw ("payment method not found");
    }
  } catch (e) {
    paymenthod = "Cash on Delivery";
  }
  return paymenthod;
}

PaymentMethod getPaymentMethodEnum(String paymentMethod) {
  try {
    if (paymentMethod == "Cash on Delivery") {
      return PaymentMethod.cash;
    } else {
      return PaymentMethod.credit;
    }
  } catch (e) {
    return PaymentMethod.cash;
  }
}

class P2pTransaction implements P2PTransactionInterface {
  int id, riderID;
  int patronID;
  String patronUUID;
  String remark;
  String status;
  PaymentMethod paymentType = PaymentMethod.cash;
  Vehicle vehicle;
  List<Stop> stops;
  double grandTotal, totalDistance, riderTips;
  DateTime deliveryDateTime; // user selected pick up time
  DateTime createdAt;
  List<OSM> routes;
  List<DeliveryMessage> deliveryMessages;
  String area;

  P2pTransaction({
    this.id,
    this.riderID,
    this.patronID,
    this.patronUUID,
    this.remark,
    this.status,
    this.paymentType,
    this.vehicle,
    this.stops,
    this.grandTotal,
    this.totalDistance,
    this.riderTips,
    this.deliveryDateTime,
    this.createdAt,
    this.routes,
    this.deliveryMessages,
    this.area,
  });

  P2pTransaction.initClass() {
    this.id = null;
    this.patronID = hantarrBloc.state.hUser.id;
    this.patronUUID = hantarrBloc.state.hUser.firebaseUser != null
        ? hantarrBloc.state.hUser.firebaseUser.uid
        : null;
    this.riderID = null;
    this.remark = "";
    this.paymentType = PaymentMethod.cash;
    this.status = "pending";
    this.vehicle = Vehicle.initClass();
    this.stops = [
      Stop.initClass(),
      Stop.initClass(),
    ];
    this.grandTotal = 0.0;
    this.totalDistance = 0.0;
    this.riderTips = 0.0;
    this.deliveryDateTime = null;
    this.createdAt = null;
    this.routes = [];
    this.deliveryMessages = [];
    this.area = "";
  }

  @override
  void mapToLocal(P2pTransaction p2pTransaction) {
    this.id = p2pTransaction.id;
    this.patronID = p2pTransaction.patronID;
    this.patronUUID = p2pTransaction.patronUUID;
    this.riderID = p2pTransaction.riderID;
    this.remark = p2pTransaction.remark;
    this.paymentType = p2pTransaction.paymentType;
    this.status = p2pTransaction.status;
    this.vehicle = p2pTransaction.vehicle;
    this.stops = p2pTransaction.stops;
    this.grandTotal = p2pTransaction.grandTotal;
    this.totalDistance = p2pTransaction.totalDistance;
    this.deliveryDateTime = p2pTransaction.deliveryDateTime;
    this.createdAt = p2pTransaction.createdAt;
    this.routes = p2pTransaction.routes;
    this.deliveryMessages = p2pTransaction.deliveryMessages;
    this.area = p2pTransaction.area;
  }

  @override
  P2pTransaction fromMap(Map<String, dynamic> map) {
    P2pTransaction p2pTransaction;
    List<OSM> routes = [];
    List<Stop> stops = [];
    List<DeliveryMessage> deliveryMessages = [];

    try {
      if (map['routes'] != null) {
        List routesMap = [];
        if (map['routes'] is List) {
          routesMap = map['routes'];
        } else {
          routesMap = jsonDecode(map['routes']);
        }
        for (Map<String, dynamic> route in routesMap) {
          OSM osm = OSM.initClass().fromAPI(route);
          if (osm != null) {
            routes.add(osm);
          }
        }
        routes.sort((a, b) => a.fromStopIndex.compareTo(b.fromStopIndex));
      }

      if (map['stops'] != null) {
        List stopsMap = [];
        if (map['stops'] is List) {
          stopsMap = map['stops'];
        } else {
          stopsMap = jsonDecode(map['stops']);
        }
        for (Map<String, dynamic> stop in stopsMap) {
          Stop thisStop = Stop.initClass().fromMap(stop);
          if (thisStop != null) {
            stops.add(thisStop);
          }
        }
        stops.sort((a, b) => a.index.compareTo(b.index));
      }

      if (map['status_map'] != null) {
        List statusMaps = [];
        if (map['status_map'] is List) {
          statusMaps = map['status_map'];
        } else {
          statusMaps = jsonDecode(map['status_map']);
        }
        for (Map<String, dynamic> dM in statusMaps) {
          DeliveryMessage deliveryMessage =
              DeliveryMessage.initClass().fromMap(dM);
          if (deliveryMessage != null) {
            deliveryMessages.add(deliveryMessage);
          }
          deliveryMessages.sort((a, b) => a.id.compareTo(b.id));
        }
      }
      Vehicle vehicle;
      if (map['vehicle_info'] != null) {
        Map<String, dynamic> vehicleMap = {};
        if (map['vehicle_info'] is String) {
          vehicleMap = jsonDecode(map['vehicle_info']);
        } else {
          vehicleMap = map['vehicle_info'];
        }

        Vehicle testvehicle = Vehicle.initClass().fromHistoryAPI(vehicleMap);
        if (testvehicle != null) {
          vehicle = testvehicle;
        }
      }

      p2pTransaction = P2pTransaction(
        id: map['id'],
        riderID: map['rider_id'],
        patronID: map['patron_id'],
        patronUUID: map['uuid'],
        status: map['status'],
        remark: map['remarks'] != null ? map['remarks'] : "",
        paymentType: getPaymentMethodEnum(map['payment_type']),
        vehicle: vehicle != null
            ? vehicle
            : throw ("vehicle module in P2PTransaction module decode failed."),
        stops: stops,
        grandTotal: map['grand_total'] != null
            ? num.tryParse(map['grand_total'].toString()).toDouble()
            : 0.0,
        totalDistance: map['totalDistance'] != null
            ? num.tryParse(map['totalDistance'].toString()).toDouble()
            : 0.0,
        riderTips: map['tips_amount'] != null
            ? num.tryParse(map['tips_amount'].toString()).toDouble()
            : 0.0,
        deliveryDateTime: map['delivery_time'] != null
            ? DateTime.tryParse(map['delivery_time'])
            : null,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at']).add(Duration(hours: 8))
            : null,
        routes: routes,
        deliveryMessages: deliveryMessages,
        area: map['area'] != null ? map['area'] : "",
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      print("p2ptransaction module from map hit error. $msg");
      p2pTransaction = null;
    }
    return p2pTransaction;
  }

  @override
  Map<String, dynamic> toJson() {
    try {
      List<Stop> validStops = this.getValidStops();
      List<Map<String, dynamic>> routes =
          this.routes.map((e) => e.classOverview()).toList();
      List<Map<String, dynamic>> deliveryMessages =
          this.deliveryMessages.map((e) => e.toJson()).toList();

      return {
        "id": this.id,
        "rider_id": this.riderID,
        "patron_id": this.patronID != null
            ?
            // "H36uDxWwJuaVRkOCOhsfXzpGky72"
            this.patronID
            : throw ("must login first"),
        "uuid": hantarrBloc.state.hUser.firebaseUser.uid,
        "remarks": this.remark,
        "payment_type": getPaymentMethod(this.paymentType),
        "status": this.status,
        "vehicle": this.vehicle.vehicleName,
        "vehicle_info": this.vehicle.toJson(),
        "stops": validStops.map((e) => e.toJson()).toList(),
        "grand_total": this.getRoundedCurrency(this.getTotalPrice()),
        "delivery_time": this.deliveryDateTime != null
            ? this.deliveryDateTime.toString()
            : null,
        "totalDistance": this.totalDistance,
        "routes": routes,
        "delivery_messages": deliveryMessages,
        "area": this.area,
        "tips_amount": this.riderTips,
      };
    } catch (e) {
      return null;
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<Map<String, dynamic>> getTotalDistance() async {
    try {
      List<OSM> osmList = [];
      double calculateDistance = 0.0;
      List<Stop> validStops = this.getValidStops();
      if (validStops.length > 1) {
        for (int i = 0; i < validStops.length - 1; i++) {
          var getOSMReq = await OSM.initClass().getListRoute(
              validStops[i].index,
              validStops[i + 1].index,
              validStops[i].address.longitude,
              validStops[i].address.latitude,
              validStops[i + 1].address.longitude,
              validStops[i + 1].address.latitude);
          if (getOSMReq['success']) {
            osmList.add(getOSMReq['data']);
          } else {
            throw ("Get total distance failed.");
          }
        }
        double dummyDistance = 0.0;
        for (OSM osm in osmList) {
          calculateDistance += osm.distance;
          for (var i = 0; i < osm.coordinates.length - 1; i++) {
            dummyDistance += this.calculateDistance(
                osm.coordinates[i].lat,
                osm.coordinates[i].long,
                osm.coordinates[i + 1].lat,
                osm.coordinates[i + 1].long);
          }
        }
        debugPrint((dummyDistance).toString());
        // added 10 percent to total distance
        this.totalDistance = calculateDistance * 1.10;
        this.routes = osmList;
        return {"success": true, "data": this};
      } else {
        // No need calculate distance
        // must at least 2 stops to calculate distance
        return {"success": true, "data": this};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get distance failed. $msg"};
    }
  }

  @override
  double getTotalPrice() {
    double total = 0.0;
    double vehicleOptionsPrice = 0.0;
    try {
      vehicleOptionsPrice = this.vehicle.getVehicleOptionPrice();
      debugPrint(
          "Vehicle Options Total Price: RM ${vehicleOptionsPrice.toStringAsFixed(2)}");
      total += vehicleOptionsPrice;
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("get vehicleOptionsPrice price failed. $msg");
    }

    try {
      // print(this.vehicle.toString());
      double totalDistancePrice = this.getDistancePrice();
      total += totalDistancePrice;
      debugPrint(
          "Total Distance Price: ( ${(this.totalDistance / 1000).toStringAsFixed(2)} km ): RM ${totalDistancePrice.toStringAsFixed(2)}");
    } catch (e) {
      // ignore: unused_local_variable
      String msg = getExceptionMsg(e);
      debugPrint("get distance price failed.");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      // throw ("HIT ERROR");
    }

    try {
      double extraStopsPrice = this.getTotalStopsPrice();
      total += extraStopsPrice;
      debugPrint(
          "Extra Stops Price: + RM ${extraStopsPrice.toStringAsFixed(2)}");
    } catch (e) {
      // ignore: unused_local_variable
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("get stops price failed");
    }

    try {
      double totalTips = this.getRiderTipsPrice();
      total += totalTips;
      debugPrint("Total Rider Tips: + RM ${totalTips.toStringAsFixed(2)}");
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("get total tips price failed");
    }

    debugPrint("Total Price: RM ${total.toStringAsFixed(2)}");
    debugPrint(
        "Rounded Amount: RM ${this.getRoundPrice(total).toStringAsFixed(2)}");
    debugPrint(
        "Grand Total Price: RM ${(this.getRoundedCurrency(total)).toStringAsFixed(2)}");
    debugPrint(
        "###############################################################\n\n\n");
    return total;
  }

  @override
  double getTotalStopsPrice() {
    double total = 0.0;
    // Calculate stops that have ID only
    int totalStops = this.getTotalValidStopsCount();
    debugPrint("Total Valid Stops: $totalStops Stops");
    if (totalStops > 2) {
      int stopCounts = totalStops - 2;
      if (this
          .vehicle
          .vehicleOption
          .where((x) => x.keyName == "additional_stop_fare")
          .isNotEmpty) {
        total = this
                .vehicle
                .vehicleOption
                .firstWhere((x) => x.keyName == "additional_stop_fare")
                .fareAmount *
            stopCounts;
      } else {
        throw ("Must have additional stop fare.");
      }
    }
    return total;
  }

  @override
  int getTotalValidStopsCount() {
    int count = 0;
    count = this.getValidStops().length;
    return count;
  }

  @override
  List<Stop> getValidStops() {
    List<Stop> allstops = this
        .stops
        .where((x) => x.address.longitude != null && x.address.latitude != null)
        .toList();
    for (int i = 0; i < allstops.length; i++) {
      allstops[i].index = i;
    }
    return allstops;
  }

  @override
  Future<Map<String, dynamic>> getListP2P(Map<String, dynamic> queries) async {
    List<P2pTransaction> p2pList = [];

    try {
      Dio dio = getDio(baseOption: 2, queries: queries);
      // ?uuid=${hantarrBloc.state.hUser.firebaseUser.uid}
      Response response = await dio.get("/list_pp_transaction");
      for (Map<String, dynamic> map in response.data) {
        P2pTransaction p2p = P2pTransaction.initClass().fromMap(map);
        if (p2p != null) {
          p2pList.add(p2p);
        }
      }
      p2pList.sort((a, b) => b.id.compareTo(a.id));
      hantarrBloc.state.p2pHistoryList = List<P2pTransaction>.from(p2pList);
      hantarrBloc.add(Refresh());
      return {"success": true, "data": List<P2pTransaction>.from(p2pList)};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get list P2P failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> createTransaction() async {
    try {
      Dio dio = getDio(baseOption: 2, queries: {});
      Response response = await dio.post(
        "/create_order",
        data: this.toJson(),
      );
      print(jsonEncode(response.data));
      if (response.data['point_to_point_id'] != null) {
        this.id = response.data['point_to_point_id'];
        this.createdAt = DateTime.tryParse(response.data['datetime']);
        hantarrBloc.state.p2pPendingOrders.insert(0, this);
        UniqueKey key = UniqueKey();
        BotToast.showWidget(
            key: key,
            toastBuilder: (_) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                title: Container(
                    child: Image.asset("assets/orderComplete.png",
                        width: ScreenUtil().setWidth(500),
                        height: ScreenUtil().setWidth(400))),
                content: Text(
                  "Your order has been made successfully !",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      BotToast.remove(key);
                    },
                    child: Text(
                      "GOT IT",
                      style: themeBloc.state.textTheme.button.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(30.0),
                        color: themeBloc.state.primaryColor,
                      ),
                    ),
                  )
                ],
              );
            });
        return {"success": true, "data": this};
      } else {
        return {"success": false, "reason": "Create Transaction Failed.."};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Create Delivery Failed. $msg"};
    }
  }

  @override
  Future<String> choosePaymentMethod(
      BuildContext context, dynamic setFunction) async {
    var confimation = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter state) {
            return AlertDialog(
              title: Text("Please choose a payment method."),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    RadioListTile<PaymentMethod>(
                      title: Text(
                        getPaymentMethod(PaymentMethod.cash),
                      ),
                      value: PaymentMethod.cash,
                      groupValue: this.paymentType,
                      onChanged: (PaymentMethod value) {
                        this.paymentType = value;
                        setFunction();
                        state(() {
                          this.paymentType = value;
                        });
                      },
                    ),
                    RadioListTile<PaymentMethod>(
                      title: Text(
                        getPaymentMethod(PaymentMethod.credit),
                      ),
                      subtitle: Text(
                        "Balance: RM ${hantarrBloc.state.hUser.creditBalance.toStringAsFixed(0)}",
                      ),
                      value: PaymentMethod.credit,
                      groupValue: this.paymentType,
                      onChanged: (PaymentMethod value) {
                        this.paymentType = value;
                        setFunction();
                        state(() {
                          this.paymentType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, "yes");
                  },
                  color: Colors.orange[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                  child: Text(
                    "Proceed",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(30.0),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    return confimation;
  }

  @override
  Future<Map<String, dynamic>> ableToPlaceOrder() async {
    if (this.getTotalValidStopsCount() < 2) {
      return {"success": false, "reason": "Must add atleast 2 stops"};
    }

    try {
      var getDistanceReq = await this.getTotalDistance();
      if (getDistanceReq['success']) {
        if (this.paymentType == PaymentMethod.cash) {
          return {"success": true, "data": this};
        } else {
          if (hantarrBloc.state.hUser.creditBalance >= this.grandTotal) {
            return {"success": true, "data": this};
          } else {
            return {
              "success": false,
              "reason": "Insufficient Credt Balance. Please Top Up"
            };
          }
        }
      } else {
        return {
          "success": false,
          "reason": "Please try again. ${getDistanceReq['reason']}"
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
      return {"success": false, "reason": "Something went wrong. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> getSupportAreas() async {
    List supportedAreas = [];
    try {
      // get first stop's coordinate
      // check if this area is under coverage
      List<Stop> validStops = this.getValidStops();

      LatLng firstCoordinate = LatLng(
        validStops.first.address.latitude,
        validStops.first.address.longitude,
      );
      Dio dio = getDio(
        baseOption: 2,
        queries: {},
      );
      Map<String, dynamic> payload = {
        "long": firstCoordinate.longitude,
        "lat": firstCoordinate.latitude,
        "uuid": hantarrBloc.state.hUser.firebaseUser.uid,
        "stops": validStops.map((e) => e.toJson()).toList(),
        "vehicle": this.vehicle.toJson(),
      };
      Response response = await dio.post(
        "/compare_area",
        data: payload,
      );
      debugPrint(response.data.toString());
      supportedAreas = response.data;
      if (supportedAreas.isNotEmpty) {
        this.area = supportedAreas.first;
        // this.area = "Belakong";
        hantarrBloc.add(Refresh());
        return {"success": true, "data": supportedAreas};
      } else {
        return {
          "success": true,
          "data": supportedAreas,
          "reason": "Sorry. This location is not under coverage yet."
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
      return {
        "success": false,
        "data": supportedAreas,
        "reason": "Get supported areas failed. $msg",
      };
    }
  }

  @override
  bool canAddMoreStops() {
    bool canAdd = true;
    if (this.stops.length <= this.maxStops()) {
      canAdd = true;
    } else {
      canAdd = false;
    }
    return canAdd;
  }

  int maxStops() {
    int maxStops = 10;
    return maxStops;
  }

  @override
  bool exceedVehicleKM() {
    try {
      if (this.totalDistance / 1000 <= this.vehicle.kmLimit) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      // ignore: unused_local_variable
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return false;
    }
  }

  @override
  String firstStopAddress() {
    String add = "";
    try {
      add = this.stops.firstWhere((x) => x.index == 0).address.address;
    } catch (e) {
      add = "";
    }
    return add;
  }

  @override
  Color chipStatusColor() {
    Color color = themeBloc.state.primaryColor;
    if (this.status.toLowerCase() == "pending") {
      color = Colors.black;
    } else if (this.status.toLowerCase() == "done") {
      color = Colors.lightGreen[300];
    } else if (this.status.toLowerCase() == "cancel") {
      color = Colors.redAccent;
    } else {
      color = themeBloc.state.primaryColor;
    }
    return color;
  }

  @override
  Map<String, List<P2pTransaction>> grouppedByDate(
      List<P2pTransaction> p2pList) {
    Map<String, List<P2pTransaction>> map = {};
    p2pList.map(
      (e) {
        if (map["${months[e.deliveryDateTime.month - 1]} ${e.deliveryDateTime.day}"] ==
            null) {
          map["${months[e.deliveryDateTime.month - 1]} ${e.deliveryDateTime.day}"] =
              [e];
        } else {
          map["${months[e.deliveryDateTime.month - 1]} ${e.deliveryDateTime.day}"]
              .add(e);
        }
      },
    ).toList();
    return map;
  }

  @override
  double getRoundedCurrency(double grantTOTAL) {
    // round of grandtotal
    try {
      Map<String, dynamic> roundCurrentReq = roundCurrency(grantTOTAL);
      return roundCurrentReq['final_amount'];
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("get rounded price failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return grantTOTAL;
    }
  }

  @override
  double getRoundPrice(double grantTOTAL) {
    try {
      Map<String, dynamic> roundedCurrentReq = roundCurrency(grantTOTAL);
      return roundedCurrentReq['rounded_amount'];
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("get rounded price failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return 0.0;
    }
  }

  @override
  Future<Map<String, dynamic>> getPendingP2Ps() async {
    List<P2pTransaction> p2pS = [];
    if (hantarrBloc.state.hUser.firebaseUser == null) {
      return {"success": true, "data": p2pS};
    }
    try {
      Dio dio = getDio(
          baseOption: 2,
          queries: {"uuid": hantarrBloc.state.hUser.firebaseUser.uid});
      Response response = await dio.get(
        "/pending_pp_transaction",
      );
      for (Map<String, dynamic> map in response.data) {
        P2pTransaction p2pTransaction = P2pTransaction.initClass().fromMap(map);
        if (p2pTransaction != null) {
          p2pS.add(p2pTransaction);
        }
      }
      p2pS.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      for (P2pTransaction p2p in p2pS) {
        if (hantarrBloc.state.p2pPendingOrders
            .where((x) => x.id == p2p.id)
            .isNotEmpty) {
          hantarrBloc.state.p2pPendingOrders
              .where((x) => x.id == p2p.id)
              .first
              .mapToLocal(p2p);
        } else {
          hantarrBloc.state.p2pPendingOrders.add(p2p);
        }
      }
      hantarrBloc.add(Refresh());
      return {"success": true, "data": List<P2pTransaction>.from(p2pS)};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get Pending P2Ps Failed. $msg"};
    }
  }

  @override
  double getDistancePrice() {
    double getDistancePriceReq =
        this.vehicle.getDistancePrice(this.totalDistance);
    return getDistancePriceReq;
  }

  @override
  double getRiderTipsPrice() {
    double tipsPrice = 0.0;
    try {
      tipsPrice = this.riderTips != null ? this.riderTips : 0.0;
      return tipsPrice;
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return tipsPrice;
    }
  }

  @override
  Future<Map<String, dynamic>> getSpecificP2P() async {
    try {
      Dio dio = getDio(baseOption: 2, queries: {"scope": "p2p", "id": this.id});
      Response response = await dio.get("/webhook");
      P2pTransaction p2pTransaction = P2pTransaction().fromMap(response.data);
      if (p2pTransaction != null) {
        this.mapToLocal(p2pTransaction);
        return {"success": true, "data": this};
      } else {
        return {"success": false, "reason": "Get P2P Detail Failed"};
      }
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "${getExceptionLogReq['msg']}"};
    }
  }
}
