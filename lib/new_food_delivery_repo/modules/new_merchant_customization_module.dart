import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewMerchantCustomizationInterface {
  factory NewMerchantCustomizationInterface() =>
      NewMerchantCustomization.initClass();

  // utils
  NewMerchantCustomization fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
}

class NewMerchantCustomization implements NewMerchantCustomizationInterface {
  String name, category;
  double deliveryCostPrice, costPrice;

  NewMerchantCustomization({
    this.name,
    this.category,
    this.deliveryCostPrice,
    this.costPrice,
  });

  NewMerchantCustomization.initClass() {
    this.name = "";
    this.category = "empty";
    this.deliveryCostPrice = 2.0;
    this.costPrice = 2.0;
  }

  @override
  NewMerchantCustomization fromMap(Map<String, dynamic> map) {
    NewMerchantCustomization newMerchantCustomization;
    try {
      newMerchantCustomization = NewMerchantCustomization(
        name: map['name'] != null
            ? map['name']
            : NewMerchantCustomization.initClass().name,
        category: map['category'] != null
            ? map['category']
            : NewMerchantCustomization.initClass().category,
        deliveryCostPrice: map['delivery_cost_price'] != null
            ? num.tryParse(map['delivery_cost_price'].toString()).toDouble()
            : NewMerchantCustomization.initClass().deliveryCostPrice,
        costPrice: map['cost_price'] != null
            ? num.tryParse(map['cost_price'].toString()).toDouble()
            : NewMerchantCustomization.initClass().costPrice,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewMerchantCustomization frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newMerchantCustomization = null;
    }
    return newMerchantCustomization;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "delivery_cost_price": this.deliveryCostPrice.toStringAsFixed(2),
      "cost_price": this.costPrice.toStringAsFixed(2),
      "category": this.category,
    };
  }
}
