import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_customization_module.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewComboItemInterface {
  factory NewComboItemInterface() => NewComboItem.initClass();

  // utils
  NewComboItem fromMap(Map<String, dynamic> map);
  double getComboPrice();
  void mapToLocal(NewComboItem newComboItem);
  Map<String, dynamic> payloadForCheckout();
}

class NewComboItem implements NewComboItemInterface {
  int limit;
  String name, // combo name
      altName, // alt name
      category; // combo's category
  List<NewCustomization> customizations, // list of static customization
      selectedCustomizations; // list of selected customization
  double price; // combo's price

  NewComboItem({
    this.limit,
    this.name,
    this.altName,
    this.category,
    this.customizations,
    this.selectedCustomizations,
    this.price,
  });

  NewComboItem.initClass() {
    this.limit = 0;
    this.name = "";
    this.altName = "";
    this.category = "";
    this.customizations = [];
    this.selectedCustomizations = [];
    this.price = 50.0;
  }

  @override
  void mapToLocal(NewComboItem newComboItem) {
    this.limit = newComboItem.limit;
    this.name = newComboItem.name;
    this.altName = newComboItem.altName;
    this.category = newComboItem.category;
    this.customizations = newComboItem.customizations.map(
      (e) {
        NewCustomization thisNew = NewCustomization.initClass();
        thisNew.mapToLocal(e);
        return thisNew;
      },
    ).toList();
    this.selectedCustomizations = newComboItem.selectedCustomizations.map(
      (e) {
        NewCustomization thisNew = NewCustomization.initClass();
        thisNew.mapToLocal(e);
        return thisNew;
      },
    ).toList();
    this.price = newComboItem.price;
  }

  @override
  NewComboItem fromMap(Map<String, dynamic> map) {
    NewComboItem newComboItem;
    List<NewCustomization> staticCustomizations = [];
    List<NewCustomization> selectedCustomizations = [];
    try {
      newComboItem = NewComboItem(
        limit: map['limit'] != null
            ? num.tryParse(map['limit'].toString()).toInt()
            : 1,
        name: map['name'] != null ? map['name'] : "",
        altName: map['alt_name'] != null ? map['alt_name'] : "",
        category: map['category'] != null ? map['category'] : "",
        customizations: staticCustomizations,
        selectedCustomizations: selectedCustomizations,
        price: map['price'] != null
            ? num.tryParse(map['price'].toString()).toDouble()
            : 10.0,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("newComboItem frommap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newComboItem = null;
    }
    return newComboItem;
  }

  @override
  double getComboPrice() {
    double totalComboPrice = 0.0;
    try {
      for (NewCustomization cus in this.selectedCustomizations) {
        totalComboPrice += cus.getCustomizationPrice();
      }
      totalComboPrice += this.price;
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("getComboPrice hit error. $msg");
    }
    return totalComboPrice;
  }

  @override
  Map<String, dynamic> payloadForCheckout() {
    return {
      "name": this.name,
      "price": this.price,
      "category": this.category,
      "limit": this.limit,
      "alt_name": this.altName,
      "customizations":
          this.customizations.map((e) => e.payloadForCheckout()).toList(),
    };
  }
}
