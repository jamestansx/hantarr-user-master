import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewCustomizationInterface {
  factory NewCustomizationInterface() => NewCustomization.initClass();

  // utils
  NewCustomization fromMap(Map<String, dynamic> map);
  double getCustomizationPrice();
  void mapToLocal(NewCustomization newCustomization);
  Map<String, dynamic> payloadForCheckout();
}

class NewCustomization implements NewCustomizationInterface {
  String name, // customization name
      category; // customization category
  int catLimit, // max number of options allow in category
      catMinLimit, // min number of options allow in category
      itemLimit, // inside a category, the customization maximum amount choose
      minItemLimit, // inside a category, the customization minimum required amount to choose
      qty // selected qty
      ;
  double price;

  NewCustomization({
    this.name,
    this.category,
    this.catLimit,
    this.catMinLimit,
    this.itemLimit,
    this.minItemLimit,
    this.qty,
    this.price,
  });

  NewCustomization.initClass() {
    this.name = "";
    this.category = "";
    this.catLimit = 0;
    this.catMinLimit = 0;
    this.itemLimit = 0;
    this.minItemLimit = 0;
    this.qty = 0;

    this.price = 10.0;
  }

  @override
  void mapToLocal(NewCustomization newCustomization) {
    this.name = newCustomization.name;
    this.category = newCustomization.category;
    this.catLimit = newCustomization.catLimit;
    this.catMinLimit = newCustomization.catMinLimit;
    this.itemLimit = newCustomization.itemLimit;
    this.minItemLimit = newCustomization.minItemLimit;
    this.qty = newCustomization.qty;

    this.price = newCustomization.price;
  }

  @override
  NewCustomization fromMap(Map<String, dynamic> map) {
    NewCustomization newCustomization;

    try {
      newCustomization = NewCustomization(
        name: map['name'],
        category: map['category'] != null
            ? map['category']
            : NewCustomization.initClass().category,
        catLimit: map['limit'] != null
            ? num.tryParse(map['limit'].toString()).toInt()
            : NewCustomization.initClass().catLimit,
        catMinLimit: map['min_category_limit'] != null
            ? num.tryParse(map['min_category_limit'].toString()).toInt()
            : NewCustomization.initClass().catMinLimit,
        itemLimit: map['item_limit'] != null
            ? num.tryParse(map['item_limit'].toString()).toInt()
            : NewCustomization.initClass().itemLimit,
        minItemLimit: map['min_item_limit'] != null
            ? num.tryParse(map['min_item_limit'].toString()).toInt()
            : NewCustomization.initClass().minItemLimit,
        qty: map['quantity'] != null
            ? num.tryParse(map['quantity'].toString()).toInt()
            : NewCustomization.initClass().qty,
        price: map["price"] != null
            ? num.tryParse(map["price"].toString()).toDouble()
            : NewCustomization.initClass().price,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewCustomization fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newCustomization = null;
    }
    if (newCustomization.catLimit > 1) {
      debugPrint("im herer");
    }
    return newCustomization;
  }

  @override
  double getCustomizationPrice() {
    double total = 0;
    try {
      if (this.qty == 0 || this.qty == null) {
        // make it "1" if qty is 0
        total = this.price * 1;
      } else {
        total = this.price * this.qty;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getCustomizationPrice hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      total = 0;
    }
    return total;
  }

  @override
  Map<String, dynamic> payloadForCheckout() {
    return {
      "name": this.name,
      "price": this.price.toString(),
      "quantity": this.qty,
    };
  }
}
