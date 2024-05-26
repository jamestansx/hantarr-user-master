import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_comboItem_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_customization_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_merchant_customization_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_schedule_pricing_module.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewMenuItemInterface {
  factory NewMenuItemInterface() => NewMenuItem.initClass();

  // utils
  void mapTopLocal(NewMenuItem newMenuItem);
  NewMenuItem fromMap(Map<String, dynamic> map, int restID);
  NewMenuItem fromDelivery(Map<String, dynamic> map);
  double itemPriceSetter(DateTime selectedDateTime, bool seldOrderMenu);
  double displayPrice(DateTime selectedDateTime, bool seldOrderMenu,
      NewRestaurant newRestaurant);
  double getItemExactPrice(DateTime selectedDateTime,
      bool seldOrderMenu); // price included customization and combos
  void addToConfirmedCustomization(
      NewCustomization newCustomization, BuildContext context);
  void removeFromConfirmedCustomization(NewCustomization newCustomization);
  bool canAddToCat(NewCustomization newCustomization);
  bool canAddMoreItemInThisCat(NewCustomization newCustomization);
  int getConfirmedCustomQTY(
      NewCustomization
          newCustomization); // compare in confirmed customization list
  bool validateAllCustomization(); // validate customizations
  Map<String, dynamic> availability(DateTime dateTime, bool isPreorder);
  bool isSameItem(
      NewMenuItem newMenuItem); // check item code with customizations
  Map<String, dynamic> payloadForCheckout(int index);

  // for history delivery
  double getDeliveryItemExactPrice();
  //  -------------   //

  // APIs
  Future<Map<String, dynamic>> getMenuItems(NewRestaurant newRestaurant);
  Future<Map<String, dynamic>> regenerateMenuItems(NewRestaurant newRestaurant);
}

class NewMenuItem implements NewMenuItemInterface {
  int id, restID, preorderDurationHour;
  String name, // item name
      code, // item code
      categoryName, // under which category
      altName, // alternate name
      imageURL // item's image url
      ;
  double selfOrderingPrice, // self order selling price
      costPrice, // cost price
      itemDeliveryPrice; // item's delivery price ( sometimes depends on delivery datetime, selfOrderMenu (boolean) )
  bool isAvailable, // availability indicator
      isSameDayDelivery, // same day delivery indicator
      isCombo, // combo item indicator
      onlyPreorder, // preoder only
      onlyOndemand // ondemand only
      ;
  TimeOfDay deliveryStartTime, deliveryEndTime; // available from time to time
  List<NewCustomization> customizations, // item's customization
      confirmedCustomizations;
  List<NewComboItem> comboItems, // items's static combo items
      confirmedComboItems; // selected combo items
  List<NewMerchantCustomization>
      merchantCustomizations; // merchant's customization just send no need modify
  List<NewSchedulePrice> schedulePricings;

  NewMenuItem({
    this.id,
    this.restID,
    this.preorderDurationHour,
    this.name,
    this.code,
    this.categoryName,
    this.altName,
    this.imageURL,
    this.selfOrderingPrice,
    this.costPrice,
    this.itemDeliveryPrice,
    this.isAvailable,
    this.isSameDayDelivery,
    this.isCombo,
    this.onlyPreorder,
    this.onlyOndemand,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.customizations,
    this.confirmedCustomizations,
    this.comboItems,
    this.confirmedComboItems,
    this.merchantCustomizations,
    this.schedulePricings,
  });

  NewMenuItem.initClass() {
    this.id = null;
    this.restID = null;
    this.preorderDurationHour = 0;
    this.name = "";
    this.code = "";
    this.categoryName = "";
    this.altName = "";
    this.imageURL = "";
    this.selfOrderingPrice = 0.0;
    this.costPrice = 0.0;
    this.itemDeliveryPrice = 0.0;
    this.isAvailable = false;
    this.isSameDayDelivery = false;
    this.isCombo = false;
    this.onlyPreorder = false;
    this.onlyOndemand = false;
    this.deliveryStartTime = null;
    this.deliveryEndTime = null;
    this.customizations = [];
    this.confirmedCustomizations = [];
    this.comboItems = [];
    this.confirmedComboItems = [];
    this.merchantCustomizations = [];
    this.schedulePricings = [];
  }

  @override
  void mapTopLocal(NewMenuItem newMenuItem) {
    this.id = newMenuItem.id;
    this.restID = newMenuItem.restID;
    this.preorderDurationHour = newMenuItem.preorderDurationHour;
    this.name = newMenuItem.name;
    this.code = newMenuItem.code;
    this.categoryName = newMenuItem.categoryName;
    this.altName = newMenuItem.altName;
    this.imageURL = newMenuItem.imageURL;
    this.selfOrderingPrice = newMenuItem.selfOrderingPrice;
    this.costPrice = newMenuItem.costPrice;
    this.itemDeliveryPrice = newMenuItem.itemDeliveryPrice;
    this.isAvailable = newMenuItem.isAvailable;
    this.isSameDayDelivery = newMenuItem.isSameDayDelivery;
    this.isCombo = newMenuItem.isCombo;
    this.onlyPreorder = newMenuItem.onlyPreorder;
    this.onlyOndemand = newMenuItem.onlyOndemand;
    this.deliveryStartTime = newMenuItem.deliveryStartTime;
    this.deliveryEndTime = newMenuItem.deliveryEndTime;
    this.customizations = newMenuItem.customizations.map(
      (e) {
        NewCustomization thisNewCus = NewCustomization.initClass();
        thisNewCus.mapToLocal(e);
        return thisNewCus;
      },
    ).toList();
    this.confirmedCustomizations = newMenuItem.confirmedCustomizations.map(
      (e) {
        NewCustomization thisNewCus = NewCustomization.initClass();
        thisNewCus.mapToLocal(e);
        return thisNewCus;
      },
    ).toList();
    this.comboItems = newMenuItem.comboItems.map(
      (e) {
        NewComboItem thisNewCon = NewComboItem.initClass();
        thisNewCon.mapToLocal(e);
        return thisNewCon;
      },
    ).toList();
    this.confirmedComboItems = newMenuItem.confirmedComboItems.map(
      (e) {
        NewComboItem thisNewCon = NewComboItem.initClass();
        thisNewCon.mapToLocal(e);
        return thisNewCon;
      },
    ).toList();
    this.merchantCustomizations = newMenuItem.merchantCustomizations;
    this.schedulePricings = newMenuItem.schedulePricings;
  }

  @override
  NewMenuItem fromMap(Map<String, dynamic> map, int restID) {
    NewMenuItem newMenuItem;
    List<NewCustomization> customizations = [], confirmedCustomizations = [];
    List<NewComboItem> comboItems = [], confirmedComboItems = [];
    List<NewMerchantCustomization> merchantCustomizations = [];
    List<NewSchedulePrice> schedulePricings = [];

    try {
      if (map['customization'] != null) {
        for (Map<String, dynamic> customi in map['customization']) {
          NewCustomization newCustomization =
              NewCustomization.initClass().fromMap(customi);
          if (newCustomization != null) {
            customizations.add(newCustomization);
          }
        }
      }

      if (map['confirmedCustomizations'] != null) {
        for (Map<String, dynamic> ccustomi in map['confirmedCustomizations']) {
          NewCustomization newCustomization =
              NewCustomization.initClass().fromMap(ccustomi);
          if (newCustomization != null) {
            confirmedCustomizations.add(newCustomization);
          }
        }
      }

      if (map['combo_items'] != null) {
        for (Map<String, dynamic> ci in map['combo_items']) {
          NewComboItem newComboItem = NewComboItem.initClass().fromMap(ci);
          if (newComboItem != null) {
            comboItems.add(newComboItem);
          }
        }
      }

      if (map['confirmedComboItems'] != null) {
        for (Map<String, dynamic> cci in map['confirmedComboItems']) {
          NewComboItem newComboItem = NewComboItem.initClass().fromMap(cci);
          if (newComboItem != null) {
            confirmedComboItems.add(newComboItem);
          }
        }
      }

      if (map['merchant_customization'] != null) {
        for (Map<String, dynamic> mCus in map['merchant_customization']) {
          NewMerchantCustomization newMerchantCustomization =
              NewMerchantCustomization.initClass().fromMap(mCus);
          if (newMerchantCustomization != null) {
            merchantCustomizations.add(newMerchantCustomization);
          }
        }
      }

      if (map['price_history'] != null) {
        for (Map<String, dynamic> sp in map['price_history']) {
          NewSchedulePrice newSchedulePrice =
              NewSchedulePrice.initClass().fromMap(sp);
          if (newSchedulePrice != null) {
            schedulePricings.add(newSchedulePrice);
          }
        }
      }

      newMenuItem = NewMenuItem(
        id: map['id'],
        restID: restID,
        preorderDurationHour: map['preorder_duration_hours'] != null
            ? num.tryParse(map['preorder_duration_hours'].toString()).toInt()
            : NewMenuItem.initClass().preorderDurationHour,
        name: map['name'] != null ? map['name'] : "",
        code: map['code'] != null ? map['code'] : "",
        categoryName: map['category_name'] != null ? map['category_name'] : "",
        altName: map['alt_name'] != null ? map['alt_name'] : "",
        imageURL: map['img_url'] != null ? map['img_url'] : "",
        selfOrderingPrice: map['price'] != null
            ? num.tryParse(map['price'].toString()).toDouble()
            : 0.0,
        costPrice: map['cost_price'] != null
            ? num.tryParse(map['cost_price'].toString()).toDouble()
            : 0.0,
        itemDeliveryPrice: map['delivery_price'] != null
            ? num.tryParse(map['delivery_price'].toString()).toDouble()
            : 0.0,
        isAvailable: map['is_available'] != null
            ? map['is_available'].toString().toLowerCase() == "yes"
                ? true
                : false
            : false,
        isSameDayDelivery: map['is_same_day_delivery'] != null
            ? map['is_same_day_delivery']
            : false,
        isCombo: map['is_combo'] != null ? map['is_combo'] : false,
        onlyPreorder:
            map['only_preorder'] != null ? map['only_preorder'] : false,
        onlyOndemand:
            map['only_ondemand'] != null ? map['only_ondemand'] : false,
        deliveryStartTime: map['delivery_start_time'] != null
            ? TimeOfDay.fromDateTime(
                DateTime.tryParse(
                    "${DateTime.now().toString().substring(0, 10)} ${map['delivery_start_time']}"),
              )
            : TimeOfDay(hour: 0, minute: 0),
        deliveryEndTime: map['delivery_end_time'] != null
            ? TimeOfDay.fromDateTime(
                DateTime.tryParse(
                    "${DateTime.now().toString().substring(0, 10)} ${map['delivery_end_time']}"),
              )
            : TimeOfDay(hour: 23, minute: 59),
        customizations: customizations,
        confirmedCustomizations: confirmedCustomizations,
        comboItems: comboItems,
        confirmedComboItems: confirmedComboItems,
        merchantCustomizations: merchantCustomizations,
        schedulePricings: schedulePricings,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("newMenuItem fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newMenuItem = null;
    }
    if (newMenuItem.name.toLowerCase().contains("a05")) {
      debugPrint("check here");
    }

    return newMenuItem;
  }

  @override
  Future<Map<String, dynamic>> getMenuItems(NewRestaurant newRestaurant) async {
    List<NewMenuItem> menuItems = [];
    try {
      Dio dio = getDio(baseOption: 1, queries: {});
      Response response = await dio.get(
        "${newRestaurant.menuItemUrl.replaceAll("$foodUrl", "")}",
      );
      // print(response.data);
      if (response.data != "") {
        for (Map<String, dynamic> map in response.data) {
          NewMenuItem newMenuItem =
              NewMenuItem.initClass().fromMap(map, newRestaurant.id);
          if (newMenuItem != null) {
            if (newMenuItem.itemDeliveryPrice > 0) {
              menuItems.add(newMenuItem);
            } else {
              debugPrint("item delivery price <= 0");
            }
          }
        }
        newRestaurant.menuItems = List<NewMenuItem>.from(menuItems);
        try {
          newRestaurant.menuItems.sort((a, b) => a.name.compareTo(b.name));
        } catch (f) {
          debugPrint("sort issue in menuitems");
        }
        hantarrBloc.add(Refresh());
        return {"success": true, "data": List<NewMenuItem>.from(menuItems)};
      } else {
        FirebaseCrashlytics.instance.log(
            "Get menu items failed.\n API: ${newRestaurant.menuItemUrl.replaceAll("$foodUrl", "")}\nData:${response.data}");
        return {
          "success": false,
          "reason": "Something went wrong please try again."
        };
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getMenuItems hit error. $msg");
      debugPrint("request regenerate menu items");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      var regenerateMenuItemReq = await this.regenerateMenuItems(newRestaurant);
      if (regenerateMenuItemReq['success']) {
        newRestaurant.menuItems =
            List<NewMenuItem>.from(regenerateMenuItemReq['data']);
        return regenerateMenuItemReq;
      } else {
        return {"success": false, "reason": "Get Menu Items Failed. $msg"};
      }
    }
  }

  @override
  Future<Map<String, dynamic>> regenerateMenuItems(
      NewRestaurant newRestaurant) async {
    List<NewMenuItem> menuItems = [];
    try {
      Dio dio = getDio(queries: {
        "field": "regen_item_json",
        "rest_id": newRestaurant.id,
      }, baseOption: 1);
      Response response = await dio.get("/sales");
      if (response.data['items'] != null) {
        for (Map<String, dynamic> map in response.data['items']) {
          NewMenuItem newMenuItem =
              NewMenuItem().fromMap(map, newRestaurant.id);
          if (newMenuItem != null) {
            menuItems.add(newMenuItem);
          }
        }
        return {"success": true, 'data': List<NewMenuItem>.from(menuItems)};
      } else {
        return {"success": false, "reason": "${response.data['status']}"};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("regenerateMenuItems hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "Regenerate menu items hit error. $msg"
      };
    }
  }

  @override
  double itemPriceSetter(DateTime selectedDateTime, bool seldOrderMenu) {
    double itemPrice = this.itemDeliveryPrice;
    try {
      if (selectedDateTime == null) {
        selectedDateTime = hantarrBloc.state.serverTime;
      }
      if (this.schedulePricings.isNotEmpty) {
        for (NewSchedulePrice sp in this.schedulePricings) {
          switch (sp.frequencyDuration.toLowerCase()) {
            case "weekly":
              {
                if (selectedDateTime.isAfter(sp.fromDateTime) &&
                    selectedDateTime.isBefore(sp.toDateTime)) {
                  itemPrice = sp.price;
                } else {
                  itemPrice = seldOrderMenu == false
                      ? this.itemDeliveryPrice
                      : this.selfOrderingPrice;
                }
              }
              break;

            case "weekday":
              {
                if (selectedDateTime.weekday >= 1 &&
                    selectedDateTime.weekday <= 5) {
                  if (selectedDateTime.isAfter(sp.fromDateTime) &&
                      selectedDateTime.isBefore(sp.toDateTime)) {
                    itemPrice = sp.price;
                  } else {
                    itemPrice = seldOrderMenu == false
                        ? this.itemDeliveryPrice
                        : this.selfOrderingPrice;
                  }
                } else {
                  itemPrice = seldOrderMenu == false
                      ? this.itemDeliveryPrice
                      : this.selfOrderingPrice;
                }
              }
              break;

            case "weekend":
              {
                if (selectedDateTime.weekday == 6 ||
                    selectedDateTime.weekday == 7) {
                  if (selectedDateTime.isAfter(sp.fromDateTime) &&
                      selectedDateTime.isBefore(sp.toDateTime)) {
                    itemPrice = sp.price;
                  } else {
                    itemPrice = seldOrderMenu == false
                        ? this.itemDeliveryPrice
                        : this.selfOrderingPrice;
                  }
                } else {
                  itemPrice = seldOrderMenu == false
                      ? this.itemDeliveryPrice
                      : this.selfOrderingPrice;
                }
              }
              break;

            case "one time":
              {
                itemPrice = seldOrderMenu == false
                    ? this.itemDeliveryPrice
                    : this.selfOrderingPrice;
              }
              break;

            case "holiday":
              {
                itemPrice = seldOrderMenu == false
                    ? this.itemDeliveryPrice
                    : this.selfOrderingPrice;
              }
              break;

            case "daily":
              {
                if ((selectedDateTime.isAfter(sp.fromDateTime) &&
                        selectedDateTime.isBefore(sp.toDateTime) ||
                    selectedDateTime.isAtSameMomentAs(sp.fromDateTime) ||
                    selectedDateTime.isAtSameMomentAs(sp.toDateTime))) {
                  itemPrice = sp.price;
                } else {
                  itemPrice = seldOrderMenu == false
                      ? this.itemDeliveryPrice
                      : this.selfOrderingPrice;
                }
              }
              break;
          }
        }
      } else {
        itemPrice = seldOrderMenu == false
            ? this.itemDeliveryPrice
            : this.selfOrderingPrice;
      }
    } catch (e) {
      itemPrice = this.itemDeliveryPrice;
    }
    return itemPrice;
  }

  @override
  double getItemExactPrice(DateTime selectedDateTime, bool seldOrderMenu) {
    double totalPrice = 0.0;
    try {
      for (NewCustomization cus in this.confirmedCustomizations) {
        totalPrice += cus.getCustomizationPrice();
      }

      for (NewComboItem cb in this.confirmedComboItems) {
        totalPrice += cb.getComboPrice();
      }
      totalPrice += this.itemPriceSetter(selectedDateTime, seldOrderMenu);
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getItemExactPrice hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      totalPrice = 0.0;
    }
    return totalPrice;
  }

  @override
  bool canAddToCat(NewCustomization newCustomization) {
    bool canAdd = true;
    NewCustomization clonned = NewCustomization.initClass();
    clonned.mapToLocal(newCustomization);
    try {
      int thisCatLimit = clonned.catLimit;
      if (this
              .confirmedCustomizations
              .where((x) => x.category == clonned.category)
              .length <
          thisCatLimit) {
        canAdd = true;
      } else {
        canAdd = false;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("canAddToCat hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      canAdd = false;
    }
    return canAdd;
  }

  @override
  bool canAddMoreItemInThisCat(NewCustomization newCustomization) {
    bool canAdd = true;
    NewCustomization clonned = NewCustomization.initClass();
    clonned.mapToLocal(newCustomization);
    try {
      int thisItemLimit = clonned.itemLimit;
      if (this
          .confirmedCustomizations
          .where((x) => x.name == clonned.name)
          .isNotEmpty) {
        if (this
                .confirmedCustomizations
                .firstWhere((x) => x.name == clonned.name)
                .qty <
            thisItemLimit) {
          canAdd = true;
        } else {
          canAdd = false;
        }
      } else {
        if (newCustomization.itemLimit > 0) {
          canAdd = true;
        } else {
          canAdd = false;
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("canAddMoreItemInThisCat hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      canAdd = false;
    }
    return canAdd;
  }

  @override
  void addToConfirmedCustomization(
      NewCustomization newCustomization, BuildContext context) {
    NewCustomization clonned = NewCustomization.initClass();
    clonned.mapToLocal(newCustomization);
    try {
      int thisItemLimit = clonned.itemLimit;
      int thisCatLimit = clonned.catLimit;
      if (this.canAddMoreItemInThisCat(newCustomization)) {
        if (this
            .confirmedCustomizations
            .where((x) => x.name == clonned.name)
            .toList()
            .isEmpty) {
          if (this.canAddToCat(clonned)) {
            if (clonned.qty >= thisItemLimit) {
              this.confirmedCustomizations.add(clonned);
            } else {
              clonned.qty += 1;
              this.confirmedCustomizations.add(clonned);
            }
          } else {
            if (clonned.catLimit == 1) {
              this
                  .confirmedCustomizations
                  .removeWhere((x) => x.category == clonned.category);
              clonned.qty += 1;
              this.confirmedCustomizations.add(clonned);
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    title: Text("Add Customization Failed"),
                    content: Text(
                        "Cannot Add More Than $thisCatLimit unit in this category ( ${clonned.category} ) ."),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        color: themeBloc.state.primaryColor,
                        child: Text(
                          "OK",
                          style: themeBloc.state.textTheme.button.copyWith(
                            fontSize: ScreenUtil().setSp(35.0),
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          }
        } else {
          if (clonned.qty >= thisItemLimit) {
            this
                .confirmedCustomizations
                .where((x) => x.name == clonned.name)
                .first
                .qty = thisItemLimit;
            BotToast.showText(text: "Only can add up to $thisItemLimit");
          } else {
            this
                .confirmedCustomizations
                .where((x) => x.name == clonned.name)
                .first
                .qty += 1;
          }

          hantarrBloc.add(Refresh());
        }
      } else {
        if (clonned.catLimit == 1) {
          this
              .confirmedCustomizations
              .removeWhere((x) => x.category == clonned.category);
          clonned.qty += 1;
          this.confirmedCustomizations.add(clonned);
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                title: Text("Add Customization Failed"),
                content: Text(
                    "Cannot Add More Than $thisItemLimit amount in this this item ( ${clonned.name} ) ."),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    color: themeBloc.state.primaryColor,
                    child: Text(
                      "OK",
                      style: themeBloc.state.textTheme.button.copyWith(
                        fontSize: ScreenUtil().setSp(35.0),
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }

      // int thisCatLimit = clonned.catLimit;
      // if (this.canAddToCat(clonned)) {
      //   int thisItemLimit = clonned.itemLimit;
      //   if (this
      //       .confirmedCustomizations
      //       .where((x) => x.name == clonned.name)
      //       .isNotEmpty) {
      //     if (this.canAddMoreItemInThisCat(clonned)) {
      //       clonned.qty += 1;
      //       this.confirmedCustomizations.add(clonned);
      //     } else {
      //       showDialog(
      //         context: context,
      //         child: AlertDialog(
      //           title: Text("Add Customization Failed"),
      //           content: Text(
      //               "Cannot Add More Than $thisItemLimit amount in this this item ( ${clonned.name} ) ."),
      //           actions: [
      //             FlatButton(
      //               onPressed: () {
      //                 Navigator.pop(context);
      //               },
      //               color: themeBloc.state.primaryColor,
      //               child: Text(
      //                 "OK",
      //                 style: themeBloc.state.textTheme.button.copyWith(
      //                   fontSize: ScreenUtil().setSp(35.0),
      //                   color: Colors.black,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       );
      //       return;
      //     }
      //   } else {
      //     clonned.qty += 1;
      //     this.confirmedCustomizations.add(clonned);
      //   }
      // } else {
      //   if (this
      //           .confirmedCustomizations
      //           .where((x) => x.category == clonned.category)
      //           .isNotEmpty &&
      //       (newCustomization.itemLimit <= 1)) {
      //     this
      //         .confirmedCustomizations
      //         .removeWhere((x) => x.category == clonned.category);
      //     clonned.qty += 1;
      //     this.confirmedCustomizations.add(clonned);
      //   } else {
      //     // this is not same cat and item limit > 1
      //     // showDialog cannot add more that that
      //     showDialog(
      //       context: context,
      //       child: AlertDialog(
      //         title: Text("Add Customization Failed"),
      //         content: Text(
      //             "Cannot Add More Than $thisCatLimit unit in this category ( ${clonned.category} ) ."),
      //         actions: [
      //           FlatButton(
      //             onPressed: () {
      //               Navigator.pop(context);
      //             },
      //             color: themeBloc.state.primaryColor,
      //             child: Text(
      //               "OK",
      //               style: themeBloc.state.textTheme.button.copyWith(
      //                 fontSize: ScreenUtil().setSp(35.0),
      //                 color: Colors.black,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     );
      //   }

      //   return;
      // }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: Text("Add Customization Failed"),
            content: Text("Message: $msg"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                color: themeBloc.state.primaryColor,
                child: Text(
                  "OK",
                  style: themeBloc.state.textTheme.button.copyWith(
                    fontSize: ScreenUtil().setSp(35.0),
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void removeFromConfirmedCustomization(NewCustomization newCustomization) {
    try {
      if (this
          .confirmedCustomizations
          .where((x) => x.name == newCustomization.name)
          .isNotEmpty) {
        NewCustomization thisCus = this
            .confirmedCustomizations
            .where((x) => x.name == newCustomization.name)
            .first;
        if (thisCus.qty > 0) {
          thisCus.qty -= 1;
        }
        if (thisCus.qty <= 0) {
          this
              .confirmedCustomizations
              .removeWhere((x) => x.name == newCustomization.name);
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("removeFromConfirmedCustomization hit error. $msg");
    }
  }

  @override
  int getConfirmedCustomQTY(NewCustomization newCustomization) {
    int count = 0;
    try {
      if (this
          .confirmedCustomizations
          .where((x) => x.name == newCustomization.name)
          .isNotEmpty) {
        count = this
            .confirmedCustomizations
            .where((x) => x.name == newCustomization.name)
            .first
            .qty;
      } else {
        count = 0;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("getConfirmedCustomQTY hit error. $msg");
    }
    return count;
  }

  @override
  bool validateAllCustomization() {
    bool validated = true;
    try {
      List<String> cusCategories = [];
      this.customizations.map((e) => cusCategories.add(e.category)).toList();
      cusCategories = cusCategories.toSet().toList();
      for (String custCat in cusCategories) {
        List<NewCustomization> thisCategoriesCust =
            this.customizations.where((x) => x.category == custCat).toList();
        for (NewCustomization cus in thisCategoriesCust) {
          int catMinLimit = cus.catMinLimit;
          int maxCatLimit = cus.catLimit;
          int choosenCatlength = this
              .confirmedCustomizations
              .where((x) => x.category == custCat)
              .length;
          if (choosenCatlength >= catMinLimit &&
              choosenCatlength <= maxCatLimit) {
            int itemMinLimit = cus.minItemLimit;
            int itemMaxLimit = cus.itemLimit;
            if (cus.minItemLimit >= itemMinLimit ||
                cus.itemLimit <= itemMaxLimit) {
              continue;
            } else {
              return false;
            }
          } else {
            return false;
          }
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("validateAllCustomization hit error. $msg");
    }
    return validated;
  }

  @override
  Map<String, dynamic> availability(DateTime dateTime, bool isPreorder) {
    if (!this.isAvailable) {
      return {"success": false, "reason": "Item Not Available"};
    }
    if (dateTime == null) {
      hantarrBloc.state.foodCart.orderDateTime = hantarrBloc.state.serverTime;
      dateTime = hantarrBloc.state.serverTime;
    }
    try {
      // throw ("failed");
      // check delivery time
      if (this.onlyPreorder && isPreorder == false) {
        return {"success": false, "reason": "Preoder only"};
      }

      if (this.onlyOndemand && isPreorder == true) {
        return {"success": false, "reason": "On-demand Order only"};
      }

      TimeOfDay converted = TimeOfDay.fromDateTime(dateTime);
      if ((converted.hour * 60 + converted.minute) >=
              (this.deliveryStartTime.hour * 60 +
                  this.deliveryStartTime.minute) &&
          (converted.hour * 60 + converted.minute) <=
              (this.deliveryEndTime.hour * 60 + this.deliveryEndTime.minute)) {
        int minuteToPrepare = this.preorderDurationHour * 60;

        DateTime convertedToDT;
        int hour = (minuteToPrepare ~/ 60).toInt();
        int min = minuteToPrepare - (hour * 60);
        convertedToDT = hantarrBloc.state.serverTime
            .add(Duration(hours: hour, minutes: min));

        if (dateTime.isBefore(convertedToDT) && isPreorder) {
          // is before prepare hour
          return {
            "success": false,
            "reason":
                "Need order on ahead of ${this.preorderDurationHour} hours"
          };
        } else {
          return {"success": true, "data": true};
        }
      } else {
        return {
          "success": false,
          "reason":
              "Available from ${this.deliveryStartTime.hour.toString().padLeft(2, '0')}:${this.deliveryStartTime.minute.toString().padLeft(2, '0')} to ${this.deliveryEndTime.hour.toString().padLeft(2, '0')}:${this.deliveryEndTime.minute.toString().padLeft(2, '0')}"
        };
      }
      // return {"success": true};
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewMenuItem availability hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);

      return {"success": false, "reason": "Hit error. $msg"};
    }
  }

  @override
  bool isSameItem(NewMenuItem newMenuItem) {
    bool isSame = true;
    try {
      if (this.code == newMenuItem.code) {
        List<String> oriCusName =
            this.confirmedCustomizations.map((e) => e.name).toList();
        oriCusName.sort((a, b) => a.compareTo(b));
        List<String> compareCusName =
            newMenuItem.confirmedCustomizations.map((e) => e.name).toList();
        compareCusName.sort((a, b) => a.compareTo(b));
        if (oriCusName.length == compareCusName.length) {
          for (int i = 0; i < oriCusName.length; i++) {
            if (oriCusName[i] == compareCusName[i]) {
              continue;
            } else {
              return false;
            }
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
    return isSame;
  }

  @override
  Map<String, dynamic> payloadForCheckout(int index) {
    return {
      "index": index,
      "restaurant_id": this.restID,
      "name": this.name,
      "item_name": this.name,
      "code": this.code,
      "price": this.itemDeliveryPrice,
      "delivery_price": this.itemPriceSetter(
          hantarrBloc.state.foodCart.isPreorder
              ? hantarrBloc.state.foodCart.preorderDateTime
              : hantarrBloc.state.foodCart.orderDateTime,
          false),
      "category_name": this.categoryName,
      "customization": this
          .confirmedCustomizations
          .map((e) => e.payloadForCheckout())
          .toList(),
      "combo_items":
          this.confirmedComboItems.map((e) => e.payloadForCheckout()).toList(),
      "confirmedCustomizations": this
          .confirmedCustomizations
          .map((e) => e.payloadForCheckout())
          .toList(),
      "confirmedComboItems":
          this.confirmedComboItems.map((e) => e.payloadForCheckout()).toList(),
      // "index": mi.index,
      "img_url": this.imageURL,
      "alt_name": this.altName,
      "is_available": this.isAvailable,
      "cost_price": this.costPrice,
      "merchant_customization": jsonEncode(
          this.merchantCustomizations.map((e) => e.toJson()).toList()),
    };
  }

  @override
  NewMenuItem fromDelivery(Map<String, dynamic> map) {
    NewMenuItem newMenuItem;
    List<NewCustomization> customizations = [], confirmedCustomizations = [];
    List<NewComboItem> comboItems = [], confirmedComboItems = [];
    List<NewMerchantCustomization> merchantCustomizations = [];
    List<NewSchedulePrice> schedulePricings = [];

    try {
      if (map['customization'] != null) {
        for (Map<String, dynamic> customi in map['customization']) {
          NewCustomization newCustomization =
              NewCustomization.initClass().fromMap(customi);
          if (newCustomization != null) {
            customizations.add(newCustomization);
          }
        }
      }

      if (map['confirmedCustomizations'] != null) {
        for (Map<String, dynamic> ccustomi in map['confirmedCustomizations']) {
          NewCustomization newCustomization =
              NewCustomization.initClass().fromMap(ccustomi);
          if (newCustomization != null) {
            confirmedCustomizations.add(newCustomization);
          }
        }
      }

      if (map['combo_items'] != null) {
        for (Map<String, dynamic> ci in map['combo_items']) {
          NewComboItem newComboItem = NewComboItem.initClass().fromMap(ci);
          if (newComboItem != null) {
            comboItems.add(newComboItem);
          }
        }
      }

      if (map['confirmedComboItems'] != null) {
        for (Map<String, dynamic> cci in map['confirmedComboItems']) {
          NewComboItem newComboItem = NewComboItem.initClass().fromMap(cci);
          if (newComboItem != null) {
            confirmedComboItems.add(newComboItem);
          }
        }
      }

      if (map['merchant_customization'] != null) {
        for (Map<String, dynamic> mCus
            in jsonDecode(map['merchant_customization'])) {
          NewMerchantCustomization newMerchantCustomization =
              NewMerchantCustomization.initClass().fromMap(mCus);
          if (newMerchantCustomization != null) {
            merchantCustomizations.add(newMerchantCustomization);
          }
        }
      }

      if (map['price_history'] != null) {
        for (Map<String, dynamic> sp in map['price_history']) {
          NewSchedulePrice newSchedulePrice =
              NewSchedulePrice.initClass().fromMap(sp);
          if (newSchedulePrice != null) {
            schedulePricings.add(newSchedulePrice);
          }
        }
      }

      newMenuItem = NewMenuItem(
        id: map['id'],
        restID: map['restaurant_id'] != null
            ? num.tryParse(map['restaurant_id'].toString()).toInt()
            : null,
        name: map['name'] != null ? map['name'] : "",
        code: map['code'] != null
            ? map['code']
            : map['name'] != null
                ? map['name']
                : "",
        categoryName: map['category_name'] != null ? map['category_name'] : "",
        altName: map['alt_name'] != null ? map['alt_name'] : "",
        imageURL: map['img_url'] != null ? map['img_url'] : "",
        selfOrderingPrice: map['price'] != null
            ? num.tryParse(map['price'].toString()).toDouble()
            : 0.0,
        costPrice: map['cost_price'] != null
            ? num.tryParse(map['cost_price'].toString()).toDouble()
            : 0.0,
        itemDeliveryPrice: map['delivery_price'] != null
            ? num.tryParse(map['delivery_price'].toString()).toDouble()
            : 0.0,
        isAvailable: map['is_available'] != null
            ? map['is_available'].toString().toLowerCase() == "yes"
                ? true
                : false
            : false,
        isSameDayDelivery: map['is_same_day_delivery'] != null
            ? map['is_same_day_delivery']
            : false,
        isCombo: map['is_combo'] != null ? map['is_combo'] : false,
        onlyPreorder:
            map['only_preorder'] != null ? map['only_preorder'] : false,
        deliveryStartTime: map['delivery_start_time'] != null
            ? TimeOfDay.fromDateTime(
                DateTime.tryParse(
                    "${DateTime.now().toString().substring(0, 10)} ${map['delivery_start_time']}"),
              )
            : TimeOfDay(hour: 0, minute: 0),
        deliveryEndTime: map['delivery_end_time'] != null
            ? TimeOfDay.fromDateTime(
                DateTime.tryParse(
                    "${DateTime.now().toString().substring(0, 10)} ${map['delivery_end_time']}"),
              )
            : TimeOfDay(hour: 23, minute: 59),
        customizations: customizations,
        confirmedCustomizations: confirmedCustomizations,
        comboItems: comboItems,
        confirmedComboItems: confirmedComboItems,
        merchantCustomizations: merchantCustomizations,
        schedulePricings: schedulePricings,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewMenuItem fromDelivery hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newMenuItem = null;
    }
    return newMenuItem;
  }

  @override
  double getDeliveryItemExactPrice() {
    double price = 0.0;
    try {
      price += this.itemDeliveryPrice;
      for (NewCustomization cus in this.confirmedCustomizations) {
        price += cus.price * cus.qty;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getDeliveryItemExactPrice hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      price = this.itemDeliveryPrice;
    }
    return price;
  }

  @override
  double displayPrice(DateTime selectedDateTime, bool seldOrderMenu,
      NewRestaurant newRestaurant) {
    double displayPriceAmt =
        this.itemPriceSetter(selectedDateTime, seldOrderMenu);
    try {
      if (newRestaurant.discounts
          .where((x) => x.discountType.toLowerCase().contains("percentage"))
          .isNotEmpty) {
        displayPriceAmt = (1 -
                newRestaurant.discounts
                        .where((x) =>
                            x.discountType.toLowerCase().contains("percentage"))
                        .first
                        .discountAmount /
                    100) *
            displayPriceAmt;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewMenuItem displayPrice hit error. $msg");
      displayPriceAmt = this.itemPriceSetter(selectedDateTime, seldOrderMenu);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    return displayPriceAmt;
  }
}
