import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_cart_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_rider_module.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewFoodDeliveryInterface {
  // local
  void mapToLocal(NewFoodDelivery newFoodDelivery);
  NewFoodDelivery fromMap(Map<String, dynamic> map);
  double getGrandTotal();
  Color chipStatusColors();
  List<NewMenuItem> grouppedMenuItem();
  int countForThisItem(NewMenuItem newMenuItem); // groupped qty in this cart
  List<Map<String, Map<String, dynamic>>> generateTimeLine();
  List<bool> getStatusForTimeline();
  NewFoodDelivery foodCartToDelivery(int orderID, FoodCart foodCart);

  // APIs
  Future<Map<String, dynamic>> getDoneDelivery();
  Future<Map<String, dynamic>> getPendingDelivery();
  Future<Map<String, dynamic>> getRiderLocation();
  Future<Map<String, dynamic>> getSpecificOrder();
}

class NewFoodDelivery implements NewFoodDeliveryInterface {
  int id;
  List<NewMenuItem> menuItems;
  NewRestaurant newRestaurant;
  DateTime orderDateTime, preOrderDateTime;
  NewRider rider;
  bool isPreorder;
  String discountName,
      discountDescription,
      voucherName,
      paymentMethod,
      customerName,
      address,
      phone,
      deliveryMethod,
      status;
  double subtotal,
      deliveryFee,
      discountAmount,
      voucherAmount,
      serviceFeePerOrder,
      smallOrderFee;
  LatLng toLocation;
  bool isPickup, isDropOff, isCancel;
  String pickupTime, dropoffTime, cancelTime;

  NewFoodDelivery({
    this.id,
    this.menuItems,
    this.newRestaurant,
    this.orderDateTime,
    this.preOrderDateTime,
    this.rider,
    this.isPreorder,
    this.discountName,
    this.discountDescription,
    this.voucherName,
    this.paymentMethod,
    this.customerName,
    this.address,
    this.phone,
    this.deliveryMethod,
    this.status,
    this.subtotal,
    this.deliveryFee,
    this.discountAmount,
    this.voucherAmount,
    this.serviceFeePerOrder,
    this.smallOrderFee,
    this.toLocation,
    this.isPickup,
    this.isDropOff,
    this.isCancel,
    this.pickupTime,
    this.dropoffTime,
    this.cancelTime,
  });

  @override
  void mapToLocal(NewFoodDelivery newFoodDelivery) {
    this.id = newFoodDelivery.id != null ? newFoodDelivery.id : this.id;
    this.menuItems = newFoodDelivery.menuItems != null
        ? newFoodDelivery.menuItems
        : this.menuItems;
    this.newRestaurant = newFoodDelivery.newRestaurant != null
        ? newFoodDelivery.newRestaurant
        : this.newRestaurant;
    this.orderDateTime = newFoodDelivery.orderDateTime != null
        ? newFoodDelivery.orderDateTime
        : this.preOrderDateTime;
    this.preOrderDateTime = newFoodDelivery.preOrderDateTime != null
        ? newFoodDelivery.preOrderDateTime
        : this.preOrderDateTime;
    this.rider =
        newFoodDelivery.rider != null ? newFoodDelivery.rider : this.rider;
    this.isPreorder = newFoodDelivery.isPreorder != null
        ? newFoodDelivery.isPreorder
        : this.isPreorder;
    this.discountName = newFoodDelivery.discountName != null
        ? newFoodDelivery.discountName
        : this.discountName;
    this.discountDescription = newFoodDelivery.discountDescription != null
        ? newFoodDelivery.discountDescription
        : this.discountDescription;
    this.voucherName = newFoodDelivery.voucherName != null
        ? newFoodDelivery.voucherName
        : this.voucherName;
    this.paymentMethod = newFoodDelivery.paymentMethod != null
        ? newFoodDelivery.paymentMethod
        : this.paymentMethod;
    this.customerName = newFoodDelivery.customerName != null
        ? newFoodDelivery.customerName
        : this.customerName;
    this.address = newFoodDelivery.address != null
        ? newFoodDelivery.address
        : this.address;
    this.phone =
        newFoodDelivery.phone != null ? newFoodDelivery.phone : this.phone;
    this.deliveryMethod = newFoodDelivery.deliveryMethod != null
        ? newFoodDelivery.deliveryMethod
        : this.deliveryMethod;
    this.status =
        newFoodDelivery.status != null ? newFoodDelivery.status : this.status;
    this.subtotal = newFoodDelivery.subtotal != null
        ? newFoodDelivery.subtotal
        : this.subtotal;
    this.deliveryFee = newFoodDelivery.deliveryFee != null
        ? newFoodDelivery.deliveryFee
        : this.deliveryFee;
    this.discountAmount = newFoodDelivery.discountAmount != null
        ? newFoodDelivery.discountAmount
        : this.discountAmount;
    this.voucherAmount = newFoodDelivery.voucherAmount != null
        ? newFoodDelivery.voucherAmount
        : this.voucherAmount;
    //  serviceFeePerOrder,
    //   smallOrderFee
    this.serviceFeePerOrder = newFoodDelivery.serviceFeePerOrder != null
        ? newFoodDelivery.serviceFeePerOrder
        : this.serviceFeePerOrder;
    this.smallOrderFee = newFoodDelivery.smallOrderFee != null
        ? newFoodDelivery.smallOrderFee
        : this.smallOrderFee;
    this.toLocation = newFoodDelivery.toLocation != null
        ? newFoodDelivery.toLocation
        : this.toLocation;
    this.isPickup = newFoodDelivery.isPickup != null
        ? newFoodDelivery.isPickup
        : this.isPickup;
    this.isDropOff = newFoodDelivery.isDropOff != null
        ? newFoodDelivery.isDropOff
        : this.isDropOff;
    this.isCancel = newFoodDelivery.isCancel != null
        ? newFoodDelivery.isCancel
        : this.isCancel;
    this.pickupTime = newFoodDelivery.pickupTime != null
        ? newFoodDelivery.pickupTime
        : this.pickupTime;
    this.dropoffTime = newFoodDelivery.dropoffTime != null
        ? newFoodDelivery.dropoffTime
        : this.dropoffTime;
    this.cancelTime = newFoodDelivery.cancelTime != null
        ? newFoodDelivery.cancelTime
        : this.cancelTime;
  }

  @override
  NewFoodDelivery fromMap(Map<String, dynamic> map) {
    NewFoodDelivery newFoodDelivery;
    NewRider newRider = NewRider.initClass();
    List<NewMenuItem> menuitems = [];
    NewRestaurant newRestaurant;
    LatLng customerLocation;

    try {
      newRider.id = map['rider_id'] != null ? map['rider_id'] : null;

      if (map['restaurant'] != null) {
        newRestaurant = NewRestaurant().fromMap(map['restaurant']);
      }

      if (map['json_items'] != null) {
        for (Map<String, dynamic> mi in jsonDecode(map['json_items'])) {
          NewMenuItem newMenuItem = NewMenuItem().fromDelivery(mi);
          if (newMenuItem != null) {
            menuitems.add(newMenuItem);
            if (newMenuItem.customizations.isNotEmpty) {
              debugPrint("cjeck");
            }
          }
        }
      }

      if (map['customer_lat'] != null && map['customer_long'] != null) {
        customerLocation = LatLng(
            num.tryParse(map['customer_lat'].toString()).toDouble(),
            num.tryParse(map['customer_long'].toString()).toDouble());
      }

      newFoodDelivery = NewFoodDelivery(
        id: map['delivery_id'],
        menuItems: menuitems,
        newRestaurant: newRestaurant,
        orderDateTime:
            map['datetime'] != null ? DateTime.tryParse(map['datetime']) : null,
        preOrderDateTime: map['preorder_deliver_datetime'] != null
            ? DateTime.tryParse(map['preorder_deliver_datetime'])
            : null,
        rider: newRider,
        isPreorder: map['is_preorder'] != null ? map['is_preorder'] : false,
        discountName: map['discount_name'] != null ? map['discount_name'] : "",
        discountDescription: map['discount_description'] != null
            ? map['discount_description']
            : "",
        voucherName: map['voucher_name'] != null ? map['voucher_name'] : "",
        paymentMethod: map['payment_method'] != null
            ? map['payment_method'].toString().contains("cash")
                ? paymentMethods[0] // "Cash On Delivery"
                : paymentMethods[1] // "Credit"
            : paymentMethods[0],
        customerName: map['customer_name'] != null ? map['customer_name'] : "",
        address: map['to'] != null
            ? map['to'].toString().replaceAll("%address%", " ")
            : "",
        phone: map['customer_phone'] != null ? map['customer_phone'] : "",
        deliveryMethod:
            map['delivery_method'] != null ? map['delivery_method'] : "",
        status: map['status'] != null ? map['status'] : "pending",
        subtotal: map['subtotal'] != null
            ? num.tryParse(map['subtotal'].toString()).toDouble()
            : 0.0,
        deliveryFee: map['delivery_fee'] != null
            ? num.tryParse(map['delivery_fee'].toString()).toDouble()
            : 0.0,
        discountAmount: map['discounted_amount'] != null
            ? num.tryParse(map['discounted_amount'].toString()).toDouble()
            : 0.0,
        voucherAmount: map['voucher_amount'] != null
            ? num.tryParse(map['voucher_amount'].toString()).toDouble()
            : 0.0,
        serviceFeePerOrder: map['service_fee_per_order'] != null
            ? double.tryParse(map['service_fee_per_order'].toString())
            : 0.0,
        smallOrderFee: map['small_order_fee'] != null
            ? double.tryParse(map['small_order_fee'].toString())
            : 0.0,
        toLocation: customerLocation,
        isPickup: map['pickup'] != null ? map['pickup'] : false,
        isDropOff: map['delivered'] != null ? map['delivered'] : false,
        isCancel: map['status'].toString().toLowerCase().contains("cancel"),
        pickupTime: map['pickup_time'] != null ? map['pickup_time'] : null,
        dropoffTime: map['arrive_time'] != null ? map['arrive_time'] : null,
        cancelTime: map['remarks'] != null ? map['remarks'] : null,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewFoodDelivery fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newFoodDelivery = null;
    }
    return newFoodDelivery;
  }

  @override
  Future<Map<String, dynamic>> getDoneDelivery() async {
    List<NewFoodDelivery> deliveries = [];
    if (hantarrBloc.state.hUser.firebaseUser == null) {
      return {"success": true, "data": deliveries};
    }
    try {
      Dio dio = getDio(baseOption: 1, queries: {"status": "Done"});
      Response response = await dio.get(
        "/patron_delivery/${hantarrBloc.state.hUser.firebaseUser.uid}",
      );
      if (response.data != "") {
        for (Map<String, dynamic> map in response.data['delivery']) {
          // debugPrint("${map.toString()}");
          NewFoodDelivery newFoodDelivery = NewFoodDelivery().fromMap(map);
          if (newFoodDelivery != null) {
            deliveries.add(newFoodDelivery);
            hantarrBloc.state.allFoodOrders
                .removeWhere((x) => x.id == newFoodDelivery.id);
            hantarrBloc.state.allFoodOrders.add(newFoodDelivery);
          }
        }
      }
      hantarrBloc.state.allFoodOrders.sort((a, b) => a.id.compareTo(b.id));
      hantarrBloc.state.allFoodOrders.sort((a, b) => b.id.compareTo(a.id));
      // remove cancelled orders
      hantarrBloc.state.pendingFoodOrders =
          List<NewFoodDelivery>.from(deliveries);
      hantarrBloc.add(Refresh());
      return {
        "success": true,
        "data": List<NewFoodDelivery>.from(hantarrBloc.state.pendingFoodOrders)
      };
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("foodDelivery getDoneDelivery hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "foodDelivery get pending order hit error. $msg"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getPendingDelivery() async {
    List<NewFoodDelivery> deliveries = [];
    if (hantarrBloc.state.hUser.firebaseUser == null) {
      return {"success": true, "data": deliveries};
    }
    try {
      Dio dio = getDio(baseOption: 1, queries: {"status": "undone"});
      Response response = await dio.get(
        "/patron_delivery/${hantarrBloc.state.hUser.firebaseUser.uid}",
      );
      if (response.data is! String) {
        for (Map<String, dynamic> map in response.data['delivery']) {
          // debugPrint("${map.toString()}");
          NewFoodDelivery newFoodDelivery = NewFoodDelivery().fromMap(map);
          if (newFoodDelivery != null) {
            deliveries.add(newFoodDelivery);
            hantarrBloc.state.allFoodOrders
                .removeWhere((x) => x.id == newFoodDelivery.id);
            hantarrBloc.state.allFoodOrders.add(newFoodDelivery);
          }
        }
      }
      deliveries.sort((a, b) => a.orderDateTime.compareTo(b.orderDateTime));
      hantarrBloc.state.allFoodOrders.sort((a, b) => b.id.compareTo(a.id));
      // remove cancelled orders
      deliveries.removeWhere((x) => x.status.toLowerCase().contains("cancel"));
      deliveries.removeWhere((x) => x.status.toLowerCase().contains("failed"));
      hantarrBloc.state.pendingFoodOrders =
          List<NewFoodDelivery>.from(deliveries);
      hantarrBloc.add(Refresh());
      return {
        "success": true,
        "data": List<NewFoodDelivery>.from(hantarrBloc.state.pendingFoodOrders)
      };
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("foodDelivery getPendingDelivery hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "foodDelivery get pending order hit error. $msg"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getRiderLocation() async {
    try {
      Dio dio = getDio(
        queries: {},
        baseOption: 1,
      );
      Response response = await dio.get("/delivery_status/${this.id}");
      if (response.data != null) {
        response.data['delivery']['delivery_id'] = this.id;
        NewFoodDelivery newFoodDelivery =
            NewFoodDelivery().fromMap(response.data['delivery']);
        this.mapToLocal(newFoodDelivery);
        if (hantarrBloc.state.allFoodOrders
            .where((x) => x.id == this.id)
            .isEmpty) {
          hantarrBloc.state.allFoodOrders.add(this);
          if (this.status != "Done" &&
              hantarrBloc.state.pendingFoodOrders
                  .where((x) => x.id == this.id)
                  .isEmpty) {
            hantarrBloc.state.pendingFoodOrders.add(this);
          }
        }
        if (!this.status.toLowerCase().contains("done") &&
            !this.status.toLowerCase().contains("cancel")) {
          this.rider.latLng = LatLng(
            num.tryParse(response
                    .data["data"]["map"]["geometry"]["coordinates"].last
                    .toString())
                .toDouble(),
            num.tryParse(response
                    .data['data']['map']["geometry"]["coordinates"].first
                    .toString())
                .toDouble(),
          );
        }

        this.rider.name = response.data["data"]["rider"]["name"];
        hantarrBloc.add(Refresh());
        return {"success": true, "data": this};
      } else {
        return {"success": false, "reason": "Get rider location failed."};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getRiderLocation hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "getRiderLocation hit error. $msg"};
    }
  }

  @override
  double getGrandTotal() {
    double grantTotalAmt = 0.0;
    try {
      grantTotalAmt += this.subtotal;
      grantTotalAmt += this.deliveryFee;
      grantTotalAmt -= this.discountAmount;
      grantTotalAmt -= this.voucherAmount;
      grantTotalAmt += this.serviceFeePerOrder;
      grantTotalAmt += this.smallOrderFee;
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("double getGrandTotal hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    return grantTotalAmt;
  }

  @override
  Color chipStatusColors() {
    Color color = Colors.greenAccent;
    try {
      if (this.status.toLowerCase().contains("cancel")) {
        color = Colors.redAccent;
      } else if (this.status.toLowerCase().contains("pending")) {
        color = Colors.grey;
      } else {
        color = themeBloc.state.primaryColor;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("Color chipStatusColors hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    return color;
  }

  @override
  List<NewMenuItem> grouppedMenuItem() {
    List<NewMenuItem> grouppedList = [];
    int totalLength = this.menuItems.length;
    for (int i = 0; i < totalLength; i++) {
      if (grouppedList
          .where((x) => x.isSameItem(this.menuItems[i]))
          .toList()
          .isEmpty) {
        grouppedList.add(this.menuItems[i]);
      } else {
        continue;
      }
    }
    return grouppedList;
  }

  @override
  int countForThisItem(NewMenuItem newMenuItem) {
    int count = 0;
    try {
      count = this.menuItems.where((x) => x.isSameItem(newMenuItem)).length;
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("countForThisItem hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      count = 0;
    }
    return count;
  }

  @override
  List<bool> getStatusForTimeline() {
    // pickup, drop off
    List<bool> statusTimeline = [];
    return statusTimeline;
  }

  @override
  List<Map<String, Map<String, dynamic>>> generateTimeLine() {
    List<Map<String, Map<String, dynamic>>> timeLineMap = [];

    timeLineMap.add({
      "Order At": {
        "bool": true,
        "datetime": this.orderDateTime,
      },
    });
    timeLineMap.add({
      "Pick Up": {
        "bool": this.isPickup,
        "datetime": this.pickupTime,
      },
    });
    timeLineMap.add({
      "Drop Off": {
        "bool": this.isDropOff,
        "datetime": this.dropoffTime,
      },
    });

    if (this.isCancel) {
      timeLineMap.add({
        "Cancel": {
          "bool": this.isCancel,
          "datetime": this.cancelTime,
        },
      });
    }

    return timeLineMap;
  }

  @override
  Future<Map<String, dynamic>> getSpecificOrder() async {
    try {
      Dio dio = getDio(baseOption: 1, queries: {});
      Response response = await dio.get("/3/delivery/${this.id}/detail");
      NewFoodDelivery newFoodDelivery =
          NewFoodDelivery().fromMap(response.data);
      if (newFoodDelivery != null) {
        return {"success": true, "data": newFoodDelivery};
      } else {
        return {"success": false, "reason": "Get Order Failed. ID: ${this.id}"};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getSpecificOrder hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "Get Order Failed. ID: ${this.id} msg: $msg"
      };
    }
  }

  @override
  NewFoodDelivery foodCartToDelivery(int orderID, FoodCart foodCart) {
    NewFoodDelivery newFoodDelivery = NewFoodDelivery(
      id: orderID,
      menuItems: foodCart.menuItems,
      newRestaurant: foodCart.newRestaurant,
      orderDateTime: foodCart.orderDateTime,
      preOrderDateTime: foodCart.preorderDateTime,
      rider: NewRider.initClass(),
      isPreorder: foodCart.isPreorder,
      discountName:
          foodCart.getDiscount() != null ? foodCart.getDiscount().name : "",
      discountDescription: foodCart.getDiscount() != null
          ? foodCart.getDiscount().description
          : "",
      voucherName: foodCart.voucherName,
      paymentMethod: foodCart.paymentMethod,
      customerName: foodCart.contactPerson,
      address: foodCart.address,
      phone: foodCart.phoneNum,
      deliveryMethod: foodCart.deliveryMethod,
      status: "pending",
      subtotal: foodCart.getSubtotal(),
      deliveryFee: foodCart.getDeliveryFee(),
      discountAmount: foodCart.getDiscountAmount(),
      serviceFeePerOrder: foodCart.getServiceFee(),
      smallOrderFee: foodCart.getSmallOrderFee(),
      voucherAmount: foodCart.voucherAmount,
      toLocation: hantarrBloc.state.selectedLocation,
      isPickup: false,
      isDropOff: false,
      isCancel: false,
      pickupTime: "",
      dropoffTime: "",
      cancelTime: "",
    );
    return newFoodDelivery;
  }
}
