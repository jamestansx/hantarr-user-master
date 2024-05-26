import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/module/restaurant_module.dart';
import 'package:hantarr/module/schedulerPrice_module.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

class MenuItem {
  String name;
  double price;
  double selfOrderingPrice;
  double costPrice;
  String isAvailable;
  String imageUrl;
  List<Customization> customizations;
  List<Customization> selectedCustomizations = [];
  List<Customization> confirmedCustomizations = [];
  List<ComboItem> comboItems = [];
  List<ComboItem> confirmedComboItems = [];
  int index;
  // ignore: non_constant_identifier_names
  String alt_name;
  String orderDetailsRemark;
  String category;
  List<SchedulePrice> schedulePriceList = [];
  String merchantCustomization;
  int restaurantID;
  String tobeComparedJson;
  int viewQty;
  String deliveryStartTime;
  String deliveryEndTime;
  bool allowSameDayDelivert;
  List customizationSortRule;

  MenuItem(
      // ignore: non_constant_identifier_names
      {this.alt_name,
      this.name,
      this.isAvailable,
      this.price,
      this.imageUrl,
      this.comboItems,
      this.customizations,
      this.confirmedComboItems,
      this.selectedCustomizations,
      this.confirmedCustomizations,
      this.index,
      this.orderDetailsRemark,
      this.category,
      this.schedulePriceList,
      this.selfOrderingPrice,
      this.costPrice,
      this.merchantCustomization,
      this.restaurantID,
      this.tobeComparedJson,
      this.viewQty,
      this.deliveryEndTime,
      this.deliveryStartTime,
      this.allowSameDayDelivert,
      this.customizationSortRule});

  MenuItem fromJson(Map data, int restID) {
    try {
      List<SchedulePrice> schedulePriceListData = [];
      if (data["price_history"] != null) {
        if (data["price_history"].isNotEmpty) {
          for (Map detail in data["price_history"]) {
            SchedulePrice schedulePrice = SchedulePrice(
                untilDate: detail["until"],
                fromDate: detail["start"],
                untilTime: detail["time"],
                fromTime: detail["time_start"],
                frequencyDuration: detail["frequency"],
                price: num.tryParse(detail["delivery_price"]).toDouble());
            schedulePriceListData.add(schedulePrice);
          }
        }
      }
      MenuItem mi = MenuItem(
          restaurantID: restID,
          name: data["name"],
          alt_name: data["alt_name"],
          price: (data["delivery_price"] is String)
              ? num.tryParse(data["delivery_price"]).toDouble()
              : data["delivery_price"],
          selfOrderingPrice: (data["price"] is String)
              ? num.tryParse(data["price"]).toDouble()
              : data["price"],
          costPrice: (data["cost_price"] is String)
              ? num.tryParse(data["cost_price"]).toDouble()
              : data["cost_price"],
          selectedCustomizations: [],
          confirmedComboItems: [],
          isAvailable: data["is_available"].toString() == "true" ||
                  data["is_available"].toString().toLowerCase() == "yes"
              ? "Yes"
              : "No",
          imageUrl: data["img_url"],
          category: data["category_name"],
          comboItems: [],
          customizations: [],
          index: data["index"],
          schedulePriceList: schedulePriceListData,
          merchantCustomization: jsonEncode(data["merchant_customization"]),
          deliveryStartTime: data["delivery_start_time"],
          deliveryEndTime: data["delivery_end_time"],
          allowSameDayDelivert: data["is_same_day_delivery"],
          customizationSortRule: data["category_sort_rule"] == null
              ? []
              : data["category_sort_rule"]);

      // get item combo //
      if (data["combo_items"].isNotEmpty) {
        for (Map combo in data["combo_items"]) {
          ComboItem ci = ComboItem.fromJson(combo);
          mi.comboItems.add(ci);
        }
      }
      // get confirmed combo item //
      if (data["confirmedComboItems"] != null) {
        for (Map combo in data["confirmedComboItems"]) {
          ComboItem ci = ComboItem.fromJson(combo);
          mi.confirmedComboItems.add(ci);
        }
      }
      // get item customization //
      if (data["customization"] != null) {
        for (Map cus in data["customization"]) {
          Customization cs = Customization.fromJson(cus);
          mi.customizations.add(cs);
        }
        mi.customizations.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      }
      // get confirm customization //
      if (data["confirmedCustomizations"] != null) {
        for (Map cus in data["confirmedCustomizations"]) {
          Customization cs = Customization.fromJson(cus);
          mi.selectedCustomizations.add(cs);
        }
      }
      return mi;
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("NewMenuItem frommap hit error. $msg");
      return null;
    }
  }

  MenuItem clone(MenuItem menuItem) {
    List<Customization> selectedCus = [];
    for (Customization cus in menuItem.selectedCustomizations) {
      selectedCus.add(Customization().clone(cus));
    }
    return MenuItem(
        name: menuItem.name,
        price: menuItem.price,
        selfOrderingPrice: menuItem.price,
        costPrice: menuItem.costPrice,
        isAvailable: menuItem.isAvailable,
        imageUrl: menuItem.imageUrl,
        customizations: menuItem.customizations,
        selectedCustomizations: selectedCus,
        confirmedCustomizations: menuItem.confirmedCustomizations,
        comboItems: menuItem.comboItems,
        confirmedComboItems: menuItem.confirmedComboItems,
        index: menuItem.index,
        alt_name: menuItem.alt_name,
        orderDetailsRemark: menuItem.orderDetailsRemark,
        category: menuItem.category,
        schedulePriceList: menuItem.schedulePriceList,
        merchantCustomization: menuItem.merchantCustomization,
        restaurantID: menuItem.restaurantID,
        tobeComparedJson: menuItem.tobeComparedJson,
        viewQty: menuItem.viewQty,
        deliveryStartTime: menuItem.deliveryStartTime,
        deliveryEndTime: menuItem.deliveryEndTime,
        allowSameDayDelivert: menuItem.allowSameDayDelivert,
        customizationSortRule: menuItem.customizationSortRule);
  }

  double displayPriceInMenuItem(MenuItem menuItem, DateTime currentDT,
      bool selfOrderingMenu, Restaurant restaurant) {
    double price = itemPriceSetter(menuItem, currentDT, selfOrderingMenu);
    if (restaurant.discounts.isNotEmpty) {
      if (restaurant.discounts.first.type.toLowerCase() == "percentage") {
        price = price * (1 - (restaurant.discounts.first.amount / 100));
      }
    }
    if (price == 0) {
      print("${menuItem.name}");
      print("here");
    }
    return price;
  }

  bool isSuggested() {
    bool isfava = false;
    try {
      if (this.alt_name.contains("*")) {
        isfava = true;
      }
    } catch (e) {
      isfava = false;
    }
    return isfava;
  }

  double itemPriceSetter(
      MenuItem menuItem, DateTime currentDT, bool selfOrderingMenu) {
    double price;

    if (menuItem.schedulePriceList.isNotEmpty) {
      print("SchedulePricing exists !");
      for (SchedulePrice sp in menuItem.schedulePriceList) {
        switch (sp.frequencyDuration.toLowerCase()) {
          case "weekly":
            {
              if (currentDT.isAfter(
                      DateTime.parse(sp.fromDate + " " + sp.fromTime)) &&
                  currentDT.isBefore(
                      DateTime.parse(sp.untilDate + " " + sp.untilTime))) {
                price = sp.price;
              } else {
                price = selfOrderingMenu == false
                    ? menuItem.price
                    : menuItem.selfOrderingPrice;
              }
            }
            break;

          case "weekday":
            {
              if (currentDT.weekday >= 1 && currentDT.weekday <= 5) {
                if (currentDT.isAfter(
                        DateTime.parse(sp.fromDate + " " + sp.fromTime)) &&
                    currentDT.isBefore(
                        DateTime.parse(sp.untilDate + " " + sp.untilTime))) {
                  price = sp.price;
                } else {
                  price = selfOrderingMenu == false
                      ? menuItem.price
                      : menuItem.selfOrderingPrice;
                }
              } else {
                price = selfOrderingMenu == false
                    ? menuItem.price
                    : menuItem.selfOrderingPrice;
              }
            }
            break;

          case "weekend":
            {
              if (currentDT.weekday == 6 || currentDT.weekday == 7) {
                if (currentDT.isAfter(
                        DateTime.parse(sp.fromDate + " " + sp.fromTime)) &&
                    currentDT.isBefore(
                        DateTime.parse(sp.untilDate + " " + sp.untilTime))) {
                  price = sp.price;
                } else {
                  price = selfOrderingMenu == false
                      ? menuItem.price
                      : menuItem.selfOrderingPrice;
                }
              } else {
                price = selfOrderingMenu == false
                    ? menuItem.price
                    : menuItem.selfOrderingPrice;
              }
            }
            break;

          case "one time":
            {
              price = selfOrderingMenu == false
                  ? menuItem.price
                  : menuItem.selfOrderingPrice;
            }
            break;

          case "holiday":
            {
              price = selfOrderingMenu == false
                  ? menuItem.price
                  : menuItem.selfOrderingPrice;
            }
            break;

          case "daily":
            {
              if ((currentDT.isAfter(
                          DateTime.parse(sp.fromDate + " " + sp.fromTime)) &&
                      currentDT.isBefore(
                          DateTime.parse(sp.untilDate + " " + sp.untilTime)) ||
                  currentDT.isAtSameMomentAs(
                      DateTime.parse(sp.fromDate + " " + sp.fromTime)) ||
                  currentDT.isAtSameMomentAs(
                      DateTime.parse(sp.untilDate + " " + sp.untilTime)))) {
                price = sp.price;
              } else {
                price = selfOrderingMenu == false
                    ? menuItem.price
                    : menuItem.selfOrderingPrice;
              }
            }
            break;
        }
      }
    } else {
      price = selfOrderingMenu == false
          ? menuItem.price
          : menuItem.selfOrderingPrice;
    }
    return price;
  }

  Future getMenuitem(Restaurant currentRestaurant) async {
    currentRestaurant.menuItems = [];
    // currentRestaurant.menuitemUrl = currentRestaurant.menuitemUrl
    //     .replaceAll("10.239.30.225:4000", "8a7c09cb17cf.sn.mynetname.net:4000");

    try {
      dio.Dio myDio = getDio(
        baseOption: 1,
      );
      myDio.options.baseUrl = currentRestaurant.menuitemUrl.replaceAll(
          "http://10.239.30.225:4000",
          "http://8a7c09cb17cf.sn.mynetname.net:4000");
      dio.Response myResponse = await myDio.get("/");
      for (Map<String, dynamic> map in myResponse.data) {
        MenuItem menuItem = MenuItem().fromJson(map, currentRestaurant.id);
        if (!currentRestaurant.allowPreorder) {
          if (menuItem.price > 0) {
            currentRestaurant.menuItems.add(menuItem);
          }
        } else {
          if (menuItem.schedulePriceList.isNotEmpty) {
            if (menuItem.schedulePriceList.first.price > 0) {
              currentRestaurant.menuItems.add(menuItem);
            }
          }
        }
      }
      // var response = await http.get(currentRestaurant.menuitemUrl);
      // if (response.statusCode == 200) {
      //   List itemList = jsonDecode(utf8.decode(response.bodyBytes));
      //   for (Map map in itemList) {
      //     MenuItem menuItem = MenuItem().fromJson(map, currentRestaurant.id);
      //     if (!currentRestaurant.allowPreorder) {
      //       if (menuItem.price > 0) {
      //         currentRestaurant.menuItems.add(menuItem);
      //       }
      //     } else {
      //       if (menuItem.schedulePriceList.isNotEmpty) {
      //         if (menuItem.schedulePriceList.first.price > 0) {
      //           currentRestaurant.menuItems.add(menuItem);
      //         }
      //       }
      //     }
      //   }
      // }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("getMenuitem hit error. $msg");
    }
    try {
      currentRestaurant.menuItems.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {}
  }

  bool allowAddToCard(Restaurant restaurant, DateTime curDT) {
    bool allow = true;
    if (this.isAvailable != "Yes") {
      return false;
    }
    try {
      if (restaurant.allowPreorder) {
        DateTime dateTime;
        if (hantarrBloc.state.user.restaurantCart.preOrderDateTime == "" &&
            this.allowSameDayDelivert) {
          dateTime = curDT;
        } else {
          dateTime = DateTime.parse(
              hantarrBloc.state.user.restaurantCart.preOrderDateTime);
        }

        int curSelectedDay = dateTime.weekday;
        if (restaurant.businessHours
            .where((x) => x.numOfDay == curSelectedDay)
            .isNotEmpty) {
          DateTime startTime = DateTime.tryParse(
              dateTime.toString().substring(0, 10) +
                  " " +
                  restaurant.businessHours
                      .firstWhere((x) => x.numOfDay == curSelectedDay)
                      .startTime);
          DateTime endTime = DateTime.tryParse(
              dateTime.toString().substring(0, 10) +
                  " " +
                  restaurant.businessHours
                      .firstWhere((x) => x.numOfDay == curSelectedDay)
                      .endTime);
          print("ss");
          if (dateTime.isBefore(startTime) || dateTime.isAfter(endTime)) {
            allow = false;
          } else {
            allow = true;
          }
        } else {
          allow = false;
        }
      } else {
        allow = true;
      }
    } catch (e) {
      print(e);
      allow = false;
    }

    return allow;
    // return true;
  }

  bool isLimitedByDeliveryTime(Restaurant restaurant) {
    bool limited = false;
    try {
      if (this.deliveryStartTime != null && this.deliveryEndTime != null) {
        limited = true;
      } else {
        limited = false;
      }
    } catch (e) {}
    return limited;
  }
}

class Customization {
  String name;
  double price;
  String category;
  int limit;
  int itemLimit;
  int minLimit;
  int minItemLimit;
  int qty;
  int sortIndex;

  Customization(
      {this.name,
      this.price,
      this.category,
      this.limit,
      this.itemLimit,
      this.qty,
      this.minLimit,
      this.minItemLimit,
      this.sortIndex});

  Customization clone(Customization cus) {
    return Customization(
        name: cus.name,
        price: cus.price,
        category: cus.category,
        limit: cus.limit,
        itemLimit: cus.itemLimit,
        qty: cus.qty,
        minLimit: cus.minLimit,
        minItemLimit: cus.minItemLimit,
        sortIndex: cus.sortIndex);
  }

  Customization.fromJson(Map data) {
    int index = 0;
    if (data["category_sort_rule"] != null) {
      if (data["category_sort_rule"]
          .any((element) => element["name"] == data["name"])) {
        index = data["category_sort_rule"]
            .firstWhere((element) => element["name"] == data["name"])["sort"];
      }
    }
    name = data["name"];
    price = num.tryParse(data["price"]).toDouble();
    category = data["category"] == null ? "empty" : data["category"].trim();
    limit = (data["limit"] is int || data["limit"] == null)
        ? data["limit"]
        : num.tryParse(data["limit"]).toInt();
    itemLimit = (data["item_limit"] is int || data["item_limit"] == null)
        ? data["item_limit"]
        : num.tryParse(data["item_limit"]).toInt();
    minItemLimit =
        (data["min_item_limit"] is int || data["min_item_limit"] == null)
            ? data["min_item_limit"]
            : num.tryParse(data["min_item_limit"]).toInt();
    minLimit = (data["min_category_limit"] is int ||
            data["min_category_limit"] == null)
        ? data["min_category_limit"]
        : num.tryParse(data["min_category_limit"]).toInt();
    sortIndex = index;
  }
}

class ComboItem {
  String name;
  int limit;
  double price;
  String category;
  List<Customization> selectedCustomizations = [];
  List<Customization> confirmedCustomizations = [];
  int index;
  // ignore: non_constant_identifier_names
  String alt_name;
  ComboItem(
      {this.name,
      this.limit,
      this.price,
      this.category,
      this.selectedCustomizations,
      this.confirmedCustomizations,
      this.index,
      // ignore: non_constant_identifier_names
      this.alt_name});

  ComboItem.fromJson(Map data) {
    List<Customization> allCus = [];
    if (data["customizations"] != null) {
      for (Map cus in data["customizations"]) {
        Customization cs = Customization(
            name: cus["name"],
            price: num.tryParse(cus["price"]).toDouble(),
            qty: cus["quantity"] is int ? cus["quantity"] : 0);
        allCus.add(cs);
      }
    }
    selectedCustomizations = allCus;
    name = data["name"];
    price = data["price"] is double
        ? data["price"]
        : num.tryParse(data["price"]).toDouble();
    limit = data["limit"];
    category = data["category"];
    alt_name = data["alt_name"];
  }
}
