import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
// import 'package:fuzzy/fuzzy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/module/zoneDetail_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_business_hour_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_category_sort_rule.module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_delivery_hour_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_discount_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_preoder_delivery_fee_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_favourite_module.dart';
import 'package:hantarr/root_page_repo/modules/osm_route_module.dart';
import 'package:hantarr/root_page_repo/modules/user_module.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewRestaurantInterface {
  factory NewRestaurantInterface() => NewRestaurant.initClass();

  // utils
  NewRestaurant fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
  void mapToLocal(NewRestaurant newRestaurant);
  bool availableForNow();
  List<NewRestaurant> sortRestaurants();
  List<NewRestaurant> filterByOndemand();
  List<NewRestaurant> filterByPreoder();
  List<NewCategorySortRule> categoriesTabs();

  List<DateTime> availableDates();
  List<TimeOfDay> availableTimes(DateTime thisDate);
  Future<Map<String, dynamic>> getDistance(LatLng selectedLoc);

  List<NewRestaurant> fuzzySearch(String searchString);

  // APIs
  Future<void> getRestListNew({bool isRetail});
  Future<void> getListRestaurant();
  Future<Map<String, dynamic>> normalGetListRestaurant(); // GET Stream
  Future<Map<String, dynamic>> getMenuItems();
  Future<Map<String, dynamic>> restaurantAvailable();
  Future<Map<String, dynamic>> getAllRestList(); // raw list
  Future<Map<String, dynamic>> getSpecificRest();
}

// preorder_max_km
class NewRestaurant implements NewRestaurantInterface {
  int id;
  int prepareTime, // time in minute
      individualPrepareTime, // time in minute
      preOrderDurationHours; // must be place before x hours
  String name, // restaurant's name
      code, // restaurant's code
      city, // restaurant's city
      area, // restaurant's area
      state, // restaurant's state
      address, // restaurant's address
      bannerImgUrl, // image display on restaurant listing ( restaurant widget )
      menuItemUrl, // URL to get menu items
      currencyCode; // currency Code
  double longitude, latitude, distance, rating;
  double defaultKM, // coverage default km
      extraPerKM, // exceed default km then multiply with this
      maxKM, // max coverage
      fixFee, // default fare if under default km
      preorderDefaultKM, // preorder default km
      preorderExtraPerKM, // exceed preorder default km then multiply with this
      preorderMaxKM, // max km for preorder
      preorderFixFee, // default preorder fare if under default preorder km
      freeDeliveryKM, // free if distance fall under this km
      minOrderValue, // must exceed this value only can place order
      duration, // estimate wairing time
      serviceFeePerOrder,
      smallOrderFee,
      smallOrderMinAmount;
  bool online, // restaurant online indicator
      forceClose, // restaurant is forced closed
      allowPreorder, // allowed preoder
      allowFreeDelivery, // allowed free delivery
      onlyPreorder, // indicator for only preoder order
      onlyOndemand, // indicator for only ondemand order
      isFavorite, // indicator for favorite restaurant
      isRetail;
  // TimeOfDay deliveryStartTime, deliveryEndTime;
  List<NewDiscount> discounts;
  List<NewCategorySortRule> categorySortRules;
  List<NewPreorderDeliveryFee> preOrderDeliveryFees;
  List<NewBusinessHour> businessHours;
  List<NewRestaurant> stalls; // for hawker stalls
  List<NewMenuItem> menuItems;
  DateTime lastOnline;
  List<NewDeliveryHour> deliveryHours;
  List<dynamic> deliveryMethods;
  List<dynamic> paymentMethods;

  NewRestaurant({
    this.id,
    this.prepareTime,
    this.individualPrepareTime,
    this.preOrderDurationHours,
    this.name,
    this.code,
    this.city,
    this.area,
    this.state,
    this.address,
    this.bannerImgUrl,
    this.menuItemUrl,
    this.currencyCode,
    this.longitude,
    this.latitude,
    this.distance,
    this.rating,
    this.defaultKM,
    this.extraPerKM,
    this.maxKM,
    this.fixFee,
    this.preorderDefaultKM,
    this.preorderExtraPerKM,
    this.preorderMaxKM,
    this.preorderFixFee,
    this.freeDeliveryKM,
    this.minOrderValue,
    this.duration,
    this.serviceFeePerOrder,
    this.smallOrderFee,
    this.smallOrderMinAmount,
    this.online,
    this.forceClose,
    this.allowPreorder,
    this.allowFreeDelivery,
    this.onlyPreorder,
    this.onlyOndemand,
    this.isFavorite,
    this.isRetail,
    // this.deliveryStartTime,
    // this.deliveryEndTime,
    this.discounts,
    this.categorySortRules,
    this.preOrderDeliveryFees,
    this.businessHours,
    this.stalls,
    this.menuItems,
    this.lastOnline,
    this.deliveryHours,
    this.deliveryMethods,
    this.paymentMethods,
  });

  NewRestaurant.initClass() {
    this.id = null;
    this.prepareTime = 20;
    this.individualPrepareTime = 20;
    this.preOrderDurationHours = 0;
    this.name = "";
    this.code = "";
    this.city = "";
    this.area = "";
    this.state = "";
    this.address = "";
    this.bannerImgUrl = "";
    this.menuItemUrl = "";
    this.currencyCode = "";
    this.longitude = 0.0;
    this.latitude = 0.0;
    this.distance = 0.0;
    this.rating = 0.0;
    this.defaultKM = 0.0;
    this.extraPerKM = 0.0;
    this.maxKM = 0.0;
    this.fixFee = 0.0;
    this.preorderDefaultKM = 0.0;
    this.preorderExtraPerKM = 0.0;
    this.preorderMaxKM = 0.0;
    this.preorderFixFee = 0.0;
    this.freeDeliveryKM = 0.0;
    this.minOrderValue = 0.0;
    this.duration = 30.0;
    this.serviceFeePerOrder = 0.0;
    this.smallOrderFee = 0.0;
    this.smallOrderMinAmount = 0.0;
    this.online = false;
    this.forceClose = false;
    this.allowPreorder = false;
    this.allowFreeDelivery = false;
    this.onlyPreorder = false;
    this.onlyOndemand = false;
    this.isFavorite = false;
    this.isRetail = false;
    // this.deliveryStartTime = null;
    // this.deliveryEndTime = null;
    this.discounts = [];
    this.categorySortRules = [];
    this.preOrderDeliveryFees = [];
    this.businessHours = [];
    this.stalls = [];
    this.menuItems = [];
    this.lastOnline = null;
    this.deliveryHours = [];
    this.deliveryMethods = [];
    this.paymentMethods = [];
  }

  @override
  void mapToLocal(NewRestaurant newRestaurant) {
    this.id = newRestaurant.id;
    this.prepareTime = newRestaurant.prepareTime;
    this.individualPrepareTime = newRestaurant.individualPrepareTime;
    this.preOrderDurationHours = newRestaurant.preOrderDurationHours;
    this.name = newRestaurant.name;
    this.code = newRestaurant.code;
    this.city = newRestaurant.city;
    this.area = newRestaurant.area;
    this.state = newRestaurant.state;
    this.address = newRestaurant.address;
    this.bannerImgUrl = newRestaurant.bannerImgUrl;
    this.menuItemUrl = newRestaurant.menuItemUrl;
    this.currencyCode = newRestaurant.currencyCode;
    this.longitude = newRestaurant.longitude;
    this.latitude = newRestaurant.latitude;
    this.distance = newRestaurant.distance;
    this.rating = newRestaurant.rating;
    this.defaultKM = newRestaurant.defaultKM;
    this.extraPerKM = newRestaurant.extraPerKM;
    this.maxKM = newRestaurant.maxKM;
    this.fixFee = newRestaurant.fixFee;
    this.preorderDefaultKM = newRestaurant.preorderDefaultKM;
    this.preorderExtraPerKM = newRestaurant.preorderExtraPerKM;
    this.preorderMaxKM = newRestaurant.preorderMaxKM;
    this.preorderFixFee = newRestaurant.preorderFixFee;
    this.freeDeliveryKM = newRestaurant.freeDeliveryKM;
    this.minOrderValue = newRestaurant.minOrderValue;
    this.duration = newRestaurant.duration;
    this.serviceFeePerOrder = newRestaurant.serviceFeePerOrder;
    this.smallOrderFee = newRestaurant.smallOrderFee;
    this.smallOrderMinAmount = newRestaurant.smallOrderMinAmount;
    this.online = newRestaurant.online;
    this.forceClose = newRestaurant.forceClose;
    this.allowPreorder = newRestaurant.allowPreorder;
    this.allowFreeDelivery = newRestaurant.allowFreeDelivery;
    this.onlyPreorder = newRestaurant.onlyPreorder;
    this.onlyOndemand = newRestaurant.onlyOndemand;
    this.isFavorite = newRestaurant.isFavorite;
    this.isRetail = newRestaurant.isRetail;
    // this.deliveryStartTime = newRestaurant.deliveryStartTime;
    // this.deliveryEndTime = newRestaurant.deliveryEndTime;
    this.discounts = newRestaurant.discounts;
    this.categorySortRules = newRestaurant.categorySortRules;
    this.preOrderDeliveryFees = newRestaurant.preOrderDeliveryFees;
    this.businessHours = newRestaurant.businessHours;
    this.stalls = newRestaurant.stalls;
    this.menuItems = newRestaurant.menuItems;
    this.lastOnline = newRestaurant.lastOnline;
    this.deliveryHours = newRestaurant.deliveryHours;
    this.deliveryMethods = newRestaurant.deliveryMethods;
    this.paymentMethods = newRestaurant.paymentMethods;
  }

  @override
  NewRestaurant fromMap(Map<String, dynamic> map) {
    NewRestaurant newRestaurant;
    List<NewDiscount> discounts = [];
    List<NewCategorySortRule> categorySortRules = [];
    List<NewPreorderDeliveryFee> preOrderDeliveryFees = [];
    List<NewBusinessHour> businessHours = [];
    List<NewRestaurant> stalls = [];
    List<NewMenuItem> menuItems = [];
    List<NewDeliveryHour> deliveryHourList = [];

    if (map['rest_id'] == 337) {
      debugPrint("hehre");
    }
    try {
      if (map['discounts'] != null) {
        for (Map<String, dynamic> disc in map['discounts']) {
          NewDiscount newDiscount = NewDiscount.initClass().fromMap(disc);
          if (newDiscount != null) {
            if (newDiscount.startDateTime
                        .isBefore(hantarrBloc.state.serverTime) &&
                    newDiscount.endDateTime
                        .isAfter(hantarrBloc.state.serverTime) ||
                (newDiscount.startDateTime
                        .isAtSameMomentAs(hantarrBloc.state.serverTime) ||
                    newDiscount.endDateTime
                        .isAtSameMomentAs(hantarrBloc.state.serverTime))) {
              discounts.add(newDiscount);
            }
          } else {
            debugPrint("newDiscount is null");
          }
        }
      }
      if (map['category_sort_rule'] != null) {
        for (Map<String, dynamic> crule in map['category_sort_rule']) {
          // debugPrint(crule.toString());
          NewCategorySortRule newCategorySortRule =
              NewCategorySortRule.initClass().fromMap(crule);
          if (newCategorySortRule != null) {
            categorySortRules.add(newCategorySortRule);
          } else {
            debugPrint("newCategorySortRule is null");
          }
        }
      }
      categorySortRules.sort((a, b) => a.index.compareTo(b.index));
      if (map['preorder_cost_map'] != null) {
        for (Map<String, dynamic> preCost in map['preorder_cost_map']) {
          NewPreorderDeliveryFee newPreorderDeliveryFee =
              NewPreorderDeliveryFee.initClass().fromMap(preCost);
          if (newPreorderDeliveryFee != null) {
            preOrderDeliveryFees.add(newPreorderDeliveryFee);
          } else {
            debugPrint("newPreorderDeliveryFee is null");
          }
        }
      }

      if (map['business_hours'] != null) {
        for (Map<String, dynamic> bh in map['business_hours']) {
          NewBusinessHour newBusinessHour =
              NewBusinessHour.initClass().fromMap(bh);
          if (newBusinessHour != null) {
            businessHours.add(newBusinessHour);
          } else {
            debugPrint("newBusinessHour is null");
          }
        }
      }

      // hawkers stall haven't implement
      if (map['stalls'] != null) {
        stalls = [];
      }

      // delivery hours
      if (map['delivery_times'] != null) {
        for (Map<String, dynamic> dh in map['delivery_times']) {
          NewDeliveryHour newDeliveryHour =
              NewDeliveryHour.initClass().fromMap(dh);
          if (newDeliveryHour != null) {
            deliveryHourList.add(newDeliveryHour);
          } else {
            debugPrint("newDeliveryHour is null");
          }
        }
      }

      if (map['menu_items'] != null && map['menu_items'] != []) {
        for (Map<String, dynamic> mi in map['menu_items']) {
          NewMenuItem newMenuItem =
              NewMenuItem.initClass().fromMap(mi, map['rest_id']);
          if (newMenuItem != null) {
            menuItems.add(newMenuItem);
          } else {
            debugPrint("newMenuItem is null");
          }
        }
      }

      // if (map['online_map'] != null) {
      //   DateTime dateTime = DateTime.tryParse(map['online_map']['last_update']
      //       .replaceAll('Z', '')
      //       .replaceAll(' ', ''));
      //   if (dateTime != null) {
      //     if (dateTime
      //             .difference(hantarrBloc.state.serverTime)
      //             .inMinutes
      //             .abs() <=
      //         5) {
      //       onlineIndicator = true;
      //     } else {
      //       onlineIndicator = false;
      //     }
      //   } else {
      //     onlineIndicator = true;
      //   }
      // }

      newRestaurant = NewRestaurant(
        id: map['rest_id'],
        prepareTime: map["duration"] != null
            ? num.tryParse(map["duration"].toString()).toInt()
            : NewRestaurant.initClass().prepareTime,
        individualPrepareTime: map["preparation_time"] != null
            ? num.tryParse(map["preparation_time"].toString()).toInt()
            : NewRestaurant.initClass().individualPrepareTime,
        preOrderDurationHours: map["preorder_duration_hours"] != null
            ? num.tryParse(map["preorder_duration_hours"].toString()).toInt()
            : NewRestaurant.initClass().preOrderDurationHours,
        name:
            map['name'] != null ? map['name'] : NewRestaurant.initClass().name,
        code:
            map['code'] != null ? map['code'] : NewRestaurant.initClass().code,
        city:
            map['area'] != null ? map['area'] : NewRestaurant.initClass().city,
        area: map['curr_area'] != null
            ? map['curr_area']
            : NewRestaurant.initClass().area,
        state: map['state'] != null
            ? map['state']
            : NewRestaurant.initClass().state,
        address: map['address'] != null
            ? map['address']
            : NewRestaurant.initClass().address,
        bannerImgUrl: map['image_url'] != null
            ? map['image_url']
            : NewRestaurant.initClass().bannerImgUrl,
        menuItemUrl: map['menu_item_url'] != null
            ? map['menu_item_url']
            : NewRestaurant.initClass().menuItemUrl,
        currencyCode: map['currency'] != null
            ? map['currency']
            : NewRestaurant.initClass().currencyCode,
        longitude: map['long'] != null
            ? num.tryParse(map['long'].toString()).toDouble()
            : NewRestaurant.initClass().longitude,
        latitude: map['lat'] != null
            ? num.tryParse(map['lat'].toString()).toDouble()
            : NewRestaurant.initClass().latitude,
        distance: map['km'] != null
            ? num.tryParse(map['km'].toString()).toDouble()
            : NewRestaurant.initClass().distance,
        rating: map['rate'] != null
            ? num.tryParse(map['rate'].toString()).toDouble()
            : NewRestaurant.initClass().rating,
        defaultKM: map['delivery_default_coverage'] != null
            ? num.tryParse(map['delivery_default_coverage'].toString())
                .toDouble()
            : NewRestaurant.initClass().defaultKM,
        extraPerKM: map['delivery_extra_per_km_cost'] != null
            ? num.tryParse(map['delivery_extra_per_km_cost'].toString())
                .toDouble()
            : NewRestaurant.initClass().extraPerKM,
        maxKM: map['delivery_max_km'] != null
            ? num.tryParse(map['delivery_max_km'].toString()).toDouble()
            : NewRestaurant.initClass().maxKM,
        fixFee: map['delivery_cost_price'] != null
            ? num.tryParse(map['delivery_cost_price'].toString()).toDouble()
            : NewRestaurant.initClass().fixFee,
        preorderDefaultKM: map['preorder_default_coverage'] != null
            ? num.tryParse(map['preorder_default_coverage'].toString())
                .toDouble()
            : NewRestaurant.initClass().preorderDefaultKM,
        preorderExtraPerKM: map['preorder_extra_per_km_cost'] != null
            ? num.tryParse(map['preorder_extra_per_km_cost'].toString())
                .toDouble()
            : NewRestaurant.initClass().preorderExtraPerKM,
        preorderMaxKM: map['preorder_max_km'] != null
            ? num.tryParse(map['preorder_max_km'].toString()).toDouble()
            : NewRestaurant.initClass().preorderMaxKM,
        preorderFixFee: map['preorder_cost_price'] != null
            ? num.tryParse(map['preorder_cost_price'].toString()).toDouble()
            : NewRestaurant.initClass().preorderFixFee,
        freeDeliveryKM: map['free_delivery_km'] != null
            ? num.tryParse(map['free_delivery_km'].toString()).toDouble()
            : NewRestaurant.initClass().freeDeliveryKM,
        minOrderValue: map['min_order_value'] != null
            ? num.tryParse(map['min_order_value'].toString()).toDouble()
            : NewRestaurant.initClass().minOrderValue,
        duration: map['duration'] != null && map["preparation_time"] != null
            ? num.tryParse(map['duration'].toString()).toDouble() +
                num.tryParse(map["preparation_time"].toString()).toDouble()
            : NewRestaurant.initClass().duration,
        serviceFeePerOrder: map['service_fee_per_order'] != null
            ? double.tryParse(map['service_fee_per_order'].toString())
            : 0.0,
        smallOrderFee: map['small_order_fee'] != null
            ? double.tryParse(map['small_order_fee'].toString())
            : 0.0,
        smallOrderMinAmount: map['small_order_min_amount'] != null
            ? double.tryParse(map['small_order_min_amount'].toString())
            : 0.0,
        online: map['online_stats'] != null ? map['online_stats'] : false,
        forceClose: map["online_map"] != null
            ? map["online_map"]["force_close"]
            : false,
        lastOnline: map['online_map'] != null
            ? DateTime.parse(
                map['online_map']['last_update'].toString().replaceAll("Z", ""))
            : null,
        allowPreorder:
            map["allow_preorder"] != null ? map["allow_preorder"] : false,
        allowFreeDelivery: map["hantarr_free_delivery"] != null
            ? map["hantarr_free_delivery"]
            : false,
        onlyPreorder:
            map['only_preorder'] != null ? map['only_preorder'] : false,
        onlyOndemand:
            map['only_ondemand'] != null ? map['only_ondemand'] : false,
        isFavorite: false,
        isRetail: map['is_retail'] != null ? map['is_retail'] : false,
        // deliveryStartTime: map['delivery_start_time'] != null &&
        //         map['delivery_start_time'].toString().length == 5
        //     ? TimeOfDay.fromDateTime(DateTime.tryParse(
        //         "${DateTime.now().toString().substring(0, 10)} ${map['delivery_start_time']}"))
        //     : NewRestaurant.initClass().deliveryStartTime,
        // deliveryEndTime: map['delivery_end_time'] != null &&
        //         map['delivery_end_time'].toString().length == 5
        //     ? TimeOfDay.fromDateTime(DateTime.tryParse(
        //         "${DateTime.now().toString().substring(0, 10)} ${map['delivery_end_time']}"))
        //     : NewRestaurant.initClass().deliveryEndTime,
        discounts: discounts,
        categorySortRules: categorySortRules,
        preOrderDeliveryFees: preOrderDeliveryFees,
        businessHours: businessHours,
        stalls: stalls,
        menuItems: menuItems,
        deliveryHours: deliveryHourList,
        deliveryMethods:
            map['delivery_methods']?.map((e) => e.toString())?.toList() ?? [],
        paymentMethods:
            map['payment_methods']?.map((e) => e.toString())?.toList() ?? [],
      );
      if (newRestaurant.deliveryHours.isEmpty) {
        for (NewBusinessHour bh in newRestaurant.businessHours) {
          NewDeliveryHour deliveryHour = NewDeliveryHour.initClass();
          deliveryHour.bussinessHourToDeliveryHour(bh);
          newRestaurant.deliveryHours.add(deliveryHour);
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("newRestaurant fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newRestaurant = null;
    }

    return newRestaurant;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "menu_items": [],
      "rest_id": this.id,
      "duration": this.duration,
      "preparation_time": this.individualPrepareTime,
      "preorder_duration_hours": this.preOrderDurationHours,
      "name": this.name,
      "code": this.code,
      "area": this.area,
      "state": this.state,
      "address": this.address,
      "image_url": this.bannerImgUrl,
      "menu_item_url": this.menuItemUrl,
      "long": this.longitude,
      "lat": this.latitude,
      "km": this.distance,
      "rate": this.rating,
      "delivery_default_coverage": this.defaultKM,
      "delivery_extra_per_km_cost": this.extraPerKM,
      "delivery_max_km": this.maxKM,
      "delivery_cost_price": this.fixFee,
      "preorder_default_coverage": this.preorderDefaultKM,
      "preorder_extra_per_km_cost": this.preorderExtraPerKM,
      "preorder_max_km": this.preorderMaxKM,
      "preorder_cost_price": this.preorderFixFee,
      "free_delivery_km": this.freeDeliveryKM,
      "min_order_value": this.minOrderValue,
      "allow_preorder": this.allowPreorder,
      "only_preorder": this.onlyPreorder,
      "only_ondemand": this.onlyOndemand,
      // "delivery_start_time": this.deliveryStartTime != null
      //     ? "${this.deliveryStartTime.hour}:${this.deliveryStartTime.minute}"
      //     : "",
      // "delivery_end_time": this.deliveryEndTime != null
      //     ? "${this.deliveryEndTime.hour}:${this.deliveryEndTime.minute}"
      //     : "",
      "discounts": this.discounts.map((e) => e.toJson()).toList(),
      "category_sort_rule":
          this.categorySortRules.map((e) => e.toJson()).toList(),
      "preorder_cost_map":
          this.preOrderDeliveryFees.map((e) => e.toJson()).toList(),
      "business_hours": this.businessHours.map((e) => e.toJson()).toList(),
      "stalls": this.stalls.map((e) => e.toJson()).toList(),
      "delivery_times": this.deliveryHours.map((e) => e.toJson()).toList(),
    };
  }

  @override
  Future<void> getListRestaurant() async {
    List<NewRestaurant> restaurantList = [];
    double distance = 0.0;
    double distanceThreshold = 500;
    // LatLng temLatlng = hantarrBloc.state.selectedLocation;
    try {
      var getDistanceReq = await OSMInterface().getListRoute(
        0,
        1,
        101.5003567352995, // banting location
        2.8107439958462668, // banting location
        hantarrBloc.state.selectedLocation.longitude,
        hantarrBloc.state.selectedLocation.latitude,
      );
      if (getDistanceReq['success']) {
        debugPrint("success distance retrieve");
        OSM osm = getDistanceReq['data'] as OSM;
        distance = osm.distance / 1000;
      } else {
        debugPrint("failed distance retrieve");
        distance = distanceThreshold;
      }
    } catch (b) {
      distance = distanceThreshold;
      String msg = getExceptionMsg(b);
      debugPrint("get country failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(b);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    try {
      Dio dio = getDio(
        baseOption: 1,
        queries: {},
      );

      Response<ResponseBody> response = await dio.post<ResponseBody>(
        "/marketplace/get_restaurant_v2",
        data: {
          "country": "malaysia",
          "user_long": hantarrBloc.state.selectedLocation == null ||
                  distance >= distanceThreshold
              ? num.tryParse("101.5003567352995").toStringAsFixed(5)
              : hantarrBloc.state.selectedLocation.longitude.toStringAsFixed(5),
          "user_lat": hantarrBloc.state.selectedLocation == null ||
                  distance >= distanceThreshold
              ? num.tryParse("2.8107439958462668").toStringAsFixed(5)
              : hantarrBloc.state.selectedLocation.latitude.toStringAsFixed(5),
        },
        options: Options(responseType: ResponseType.stream),
      );

      List<String> pendingData = [];
      Stream<Uint8List> streamListener = response.data.stream;
      // ignore: await_only_futures
      await streamListener.listen(
        (data) async {
          String a = utf8.decode(data);
          int prevIdx = pendingData.length - 1;
          if (prevIdx > 0) {
            String checker = pendingData[prevIdx];
            if (checker.endsWith("}") && a.startsWith("{")) {
              pendingData.add(",");
            }
          }
          pendingData.add(a);
          if (a.endsWith("%>")) {
            // print("ended with %>");
            if (pendingData.length == 1) {
              Map<String, dynamic> payload = jsonDecode(
                  pendingData.join().replaceAll("<%", "").replaceAll("%>", ""));
              // debugPrint(payload['page']);
              hantarrBloc.state.zoneDetailList = [];
              for (Map<String, dynamic> zone in payload['state']) {
                ZoneDetail zd = ZoneDetail.fromJson(zone);
                hantarrBloc.state.zoneDetailList.add(zd);
              }
              for (Map<String, dynamic> data in payload['restaurant']) {
                NewRestaurant newRestaurant =
                    NewRestaurant.initClass().fromMap(data);
                if (newRestaurant != null) {
                  if (distance >= distanceThreshold) {
                    newRestaurant.distance = distance;
                  }
                  restaurantList.add(newRestaurant);
                }
              }
            } else {
              pendingData.removeAt(0);
              pendingData.removeLast();
              pendingData.insert(0, "[");
              int ll = pendingData.length;
              pendingData.insert(ll, "]");
              List<dynamic> zz = jsonDecode(pendingData.join());
              for (var payload in zz) {
                // debugPrint(payload['page']);
                hantarrBloc.state.zoneDetailList = [];
                for (Map<String, dynamic> zone in payload['state']) {
                  ZoneDetail zd = ZoneDetail.fromJson(zone);
                  hantarrBloc.state.zoneDetailList.add(zd);
                }
                for (Map<String, dynamic> data in payload['restaurant']) {
                  NewRestaurant newRestaurant =
                      NewRestaurant.initClass().fromMap(data);
                  if (newRestaurant != null) {
                    if (distance >= distanceThreshold) {
                      newRestaurant.distance = distance;
                    }
                    restaurantList.add(newRestaurant);
                  }
                }
              }
            }
            hantarrBloc.state.newRestaurantList = restaurantList;
            await RestaurantFavo().getListFavoRest();
            hantarrBloc.state.newRestaurantList = this.sortRestaurants();
            hantarrBloc.add(Refresh());

            // for (NewRestaurant res in restaurantList) {
            //   if (hantarrBloc.state.newRestaurantList
            //       .where((x) => x.id == res.id)
            //       .isEmpty) {
            //     hantarrBloc.state.newRestaurantList.add(res);
            //   } else {
            //     hantarrBloc.state.newRestaurantList
            //         .firstWhere((x) => x.id == res.id)
            //         .mapToLocal(res);
            //   }
            // }
            hantarrBloc.add(Refresh());
          }
        },
        onDone: () {
          debugPrint("done done done getting rest list");
          hantarrBloc.state.streamController.add(jsonEncode({
            "success": true,
          }));
          return {
            "success": true,
            "sss": "asdasd",
            "data": List<NewRestaurant>.from(restaurantList)
          };
        },
        onError: (c) {
          String msg = getExceptionMsg(c);
          Map<String, dynamic> getExceptionLogReq = getExceptionLog(c);
          JsonEncoder encoder = new JsonEncoder.withIndent('  ');
          String jsonString = encoder.convert(getExceptionLogReq);
          FirebaseCrashlytics.instance
              .recordError(getExceptionLogReq, StackTrace.current);
          FirebaseCrashlytics.instance.log(jsonString);
          hantarrBloc.state.streamController.add(jsonEncode({
            "success": false,
            "reason": "Get List Restaurant hit error. $msg"
          }));
          return {
            "success": false,
            "reason": "Get List Restaurant hit error. $msg"
          };
        },
        cancelOnError: false,
      ).onError((e) {
        print("error");
      });
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getListRestaurant hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      // return {
      //   "success": false,
      //   "reason": "Get List Restaurant hit error. $msg"
      // };
      hantarrBloc.state.streamController.add(jsonEncode(
          {"success": false, "reason": "Get List Restaurant hit error. $msg"}));
    }
  }

  @override
  bool availableForNow() {
    try {
      if (this.forceClose == true) {
        return false;
      }
      if (this.businessHours.isNotEmpty) {
        for (NewBusinessHour bh in this
            .businessHours
            .where((x) => x.numOfDay == hantarrBloc.state.serverTime.weekday)
            .toList()) {
          DateTime serverDT = hantarrBloc.state.serverTime;
          DateTime fromDT = DateTime.tryParse(
              "${serverDT.toString().substring(0, 10)} ${bh.startTime.hour.toString().padLeft(2, '0')}:${bh.startTime.minute.toString().padLeft(2, '0')}");
          DateTime toDT = DateTime.tryParse(
              "${serverDT.toString().substring(0, 10)} ${bh.endTime.hour.toString().padLeft(2, '0')}:${bh.endTime.minute.toString().padLeft(2, '0')}");
          if (serverDT.isAfter(fromDT) && serverDT.isBefore(toDT)) {
            return true;
          } else {
            continue;
          }
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewRestaurant availableForNow hit error. $msg");
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
  List<NewRestaurant> sortRestaurants() {
    List<NewRestaurant> restaurants = hantarrBloc.state.newRestaurantList;
    List<NewRestaurant> sortedResList = [];
    List<NewRestaurant> allowPreorderRes = [];
    try {
      allowPreorderRes = restaurants.where((x) => x.allowPreorder).toList();
      allowPreorderRes.shuffle();
      restaurants.removeWhere((x) => x.allowPreorder);
      sortedResList.addAll(
          restaurants.where((x) => x.availableForNow() && x.online).toList());
      sortedResList.shuffle();
      sortedResList.addAll(
          restaurants.where((x) => x.availableForNow() && !x.online).toList());
      sortedResList.addAll(allowPreorderRes);
      sortedResList.sort(
          (a, b) => b.isFavorite.toString().compareTo(a.isFavorite.toString()));
      sortedResList.addAll(
          restaurants.where((x) => !x.availableForNow() && !x.online).toList());
      sortedResList.addAll(
          restaurants.where((x) => !x.availableForNow() && x.online).toList());
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("Sort Restaurant list failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    return sortedResList;
  }

  @override
  List<NewRestaurant> filterByOndemand() {
    return hantarrBloc.state.newRestaurantList
        .where((x) => !x.onlyPreorder)
        .toList();
  }

  @override
  List<NewRestaurant> filterByPreoder() {
    return hantarrBloc.state.newRestaurantList
        .where((x) => x.allowPreorder || x.onlyPreorder)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getMenuItems() async {
    var getMenuItemsReq = await NewMenuItem.initClass().getMenuItems(this);
    if (getMenuItemsReq['success']) {
      this.menuItems = List<NewMenuItem>.from(menuItems);
      hantarrBloc.add(Refresh());
    }
    return getMenuItemsReq;
  }

  @override
  List<NewCategorySortRule> categoriesTabs() {
    List<NewCategorySortRule> cats =
        this.categorySortRules.where((x) => !x.name.contains("_")).toList();
    return cats;
  }

  @override
  Future<Map<String, dynamic>> restaurantAvailable() async {
    try {
      var getServerDateTime = await HantarrUser.initClass().getCurrentTime();
      if (getServerDateTime['success']) {
        DateTime serverDateTime = getServerDateTime['data'] as DateTime;
        Dio dio = getDio(baseOption: 1, queries: {"rest_id": this.id});
        Response response = await dio.get("/restaurants_online_status");
        this.forceClose = response.data['force_close'] != null
            ? response.data['force_close']
            : true;
        DateTime restaurantLastOnline = DateTime.parse(
            response.data['last_update'].toString().replaceAll("Z", ""));
        if (this.forceClose) {
          this.online = false;
          return {"success": true, "data": false};
        } else {
          if (serverDateTime.difference(restaurantLastOnline).inMinutes.abs() >=
              5) {
            this.online = false;
            return {"success": true, "data": false};
          } else {
            if (!this.allowPreorder) {
              if (this.availableForNow()) {
                this.online = true;
                return {"success": true, "data": true};
              } else {
                this.online = false;
                this.online = false;
                return {
                  "success": true,
                  "data": false,
                  "reason": "Not in business hour.",
                  "business_hours": this.businessHours.toList()
                };
              }
            } else {
              this.online = true;
              return {"success": true, "data": true};
            }
          }
        }
      } else {
        return {
          "success": false,
          "data": false,
          "reason": "${getServerDateTime['reason']}"
        };
      }
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
            "Check restaurant available failed. ${getExceptionLogReq["log"]}"
      };
    }
  }

  @override
  List<DateTime> availableDates() {
    List<DateTime> dateTimes = [];
    DateTime currentDateTime = DateTime.tryParse(
        "${hantarrBloc.state.serverTime.toString().substring(0, 10)}");
    try {
      if (this.allowPreorder) {
        DateTime afterAdvandceHour = currentDateTime.add(Duration(
          hours: this.preOrderDurationHours,
        ));
        DateTime trimToDate = DateTime.tryParse(
            afterAdvandceHour.toString().substring(0, 10)); // use this

        int count = 0;
        int maxDay = 10;
        int tempCount = 200;
        for (int i = 0; i < tempCount; i++) {
          if (i == 0) {
            if (currentDateTime
                .isAtSameMomentAs(currentDateTime.add(Duration(days: i)))) {
              List<TimeOfDay> testTimes = this.availableTimes(trimToDate);
              if (testTimes.isNotEmpty) {
                dateTimes.add(trimToDate);
              }
            }
          } else {
            DateTime thisDT = trimToDate.add(Duration(days: i));
            if (this
                .deliveryHours
                .where((x) => x.numOfDay == thisDT.weekday)
                .isNotEmpty) {
              List<TimeOfDay> testTimes = this.availableTimes(thisDT);
              if (testTimes.isNotEmpty) {
                dateTimes.add(thisDT);
              }
              count += 1;
            }

            if (count == maxDay) {
              break;
            }
          }
        }
      } else {
        dateTimes.add(currentDateTime);
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewRestaurant availableDates hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    return dateTimes;
  }

  @override
  List<TimeOfDay> availableTimes(DateTime thisDate) {
    List<TimeOfDay> timeofdays = [];

    try {
      // if (thisDate.isAtSameMomentAs(DateTime.tryParse(
      //     "${hantarrBloc.state.serverTime.toString().substring(0, 10)}"))) {
      //   // this is today
      //   if (!this.onlyPreorder) {
      //     timeofdays.add(TimeOfDay(hour: 0, minute: 1));
      //   }
      // }
      // if (this.onlyOndemand) {
      //   if (timeofdays.isEmpty) {
      //     timeofdays.add(TimeOfDay(hour: 0, minute: 1));
      //   }
      // } else if (this.allowPreorder) {
      //   if (this.deliveryStartTime == null) {
      //     this.deliveryStartTime = TimeOfDay(hour: 0, minute: 0);
      //   }
      //   if (this.deliveryEndTime == null) {
      //     this.deliveryEndTime = TimeOfDay(hour: 23, minute: 59);
      //   }
      //   DateTime currentDateTime = hantarrBloc.state.serverTime;
      //   TimeOfDay currentTime = TimeOfDay(
      //     hour: currentDateTime.hour,
      //     minute: currentDateTime.minute,
      //   );
      //   // int startMin =
      //   //     (this.deliveryStartTime.hour * 60 + this.deliveryStartTime.minute);
      //   TimeOfDay starthere = this
      //       .deliveryHours
      //       .where((x) => x.numOfDay == thisDate.weekday)
      //       .first
      //       .startTime;
      //   int startMin = (starthere.hour * 60) + starthere.minute;

      //   if (thisDate.isAtSameMomentAs(DateTime.tryParse(
      //       "${hantarrBloc.state.serverTime.toString().substring(0, 10)}"))) {
      //     // this is today
      //     if ((currentTime.hour > this.deliveryStartTime.hour)) {
      //       int hourInAdvance = this.preOrderDurationHours;
      //       startMin = (currentTime.hour + hourInAdvance) * 60;
      //     }
      //   }
      //   // int endMin =
      //   //     (this.deliveryEndTime.hour * 60 + this.deliveryEndTime.minute);
      //   TimeOfDay endHere = this
      //       .deliveryHours
      //       .where((x) => x.numOfDay == thisDate.weekday)
      //       .first
      //       .endTime;
      //   int endMin = (endHere.hour * 60) + endHere.minute;

      //   for (int i = startMin; i < endMin; i++) {
      //     try {
      //       int hour = (i ~/ 60).toInt();
      //       int min = i - (i ~/ 60).toInt() * 60;

      //       int temp = (min ~/ 10).toInt() * 10;
      //       int temp2 = min - temp;
      //       if (temp2 < 30) {
      //         min = temp;
      //       } else if (temp2 == 30) {
      //         min = 30;
      //       } else {
      //         hour += 1;
      //         min = 00;
      //       }

      //       TimeOfDay thisTime = TimeOfDay(
      //         hour: hour,
      //         minute: min,
      //       );
      //       timeofdays.add(thisTime);
      //       i += 30;
      //     } catch (g) {
      //       // error in parse to timeofday
      //       String msg = getExceptionMsg(g);
      //       debugPrint("availableTimes parse to time hit error. $msg");
      //       Map<String, dynamic> getExceptionLogReq = getExceptionLog(g);
      //       JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      //       String jsonString = encoder.convert(getExceptionLogReq);
      //       FirebaseCrashlytics.instance
      //           .recordError(getExceptionLogReq, StackTrace.current);
      //       FirebaseCrashlytics.instance.log(jsonString);
      //     }
      //   }
      // }
      DateTime curDateTime = hantarrBloc.state.serverTime;
      if (curDateTime.hour == 00 && curDateTime.minute == 1) {
        curDateTime.add(Duration(minutes: 3));
      }

      bool isToday = false;
      if (thisDate.isAtSameMomentAs(
          DateTime.tryParse(curDateTime.toString().substring(0, 10)))) {
        thisDate = curDateTime;
        isToday = true;
      }

      if (this.allowPreorder || this.onlyPreorder) {
        if (this.onlyPreorder == false &&
            isToday &&
            this.preOrderDurationHours == 0) {
          timeofdays.add(TimeOfDay(
            hour: 00,
            minute: 01,
          )); // add ASAP
        } else if (this.onlyPreorder &&
            isToday &&
            this.preOrderDurationHours >= 0) {
          timeofdays.add(
            TimeOfDay.fromDateTime(thisDate.add(
              Duration(hours: this.preOrderDurationHours),
            )),
          );
        }
        if (this
            .deliveryHours
            .where((x) => x.numOfDay == thisDate.weekday)
            .isNotEmpty) {
          for (NewDeliveryHour dh in this
              .deliveryHours
              .where((x) => x.numOfDay == thisDate.weekday)
              .toList()) {
            int startMin = (dh.startTime.hour * 60) + dh.startTime.minute;
            int endMin = (dh.endTime.hour * 60) + dh.endTime.minute;

            if (isToday) {
              // current time
              TimeOfDay curTime = TimeOfDay.fromDateTime(thisDate);
              int curMin =
                  (curTime.hour * 60) + curTime.minute; // set it to start time
              startMin = curMin;
            }

            for (int i = startMin; i < endMin; i++) {
              try {
                int hour = (i ~/ 60).toInt();
                int min = i - (i ~/ 60).toInt() * 60;

                int temp = (min ~/ 10).toInt() * 10;
                int temp2 = min - temp;
                if (temp2 < 30) {
                  min = temp;
                } else if (temp2 == 30) {
                  min = 30;
                } else {
                  hour += 1;
                  min = 00;
                }

                TimeOfDay thisTime = TimeOfDay(
                  hour: hour,
                  minute: min,
                );
                timeofdays.add(thisTime);
                i += 30;
              } catch (g) {
                // error in parse to timeofday
                String msg = getExceptionMsg(g);
                debugPrint("availableTimes parse to time hit error. $msg");
                Map<String, dynamic> getExceptionLogReq = getExceptionLog(g);
                JsonEncoder encoder = new JsonEncoder.withIndent('  ');
                String jsonString = encoder.convert(getExceptionLogReq);
                FirebaseCrashlytics.instance
                    .recordError(getExceptionLogReq, StackTrace.current);
                FirebaseCrashlytics.instance.log(jsonString);
              }
            }
          }
        } else {
          timeofdays = [];
        }
      } else {
        if (this
                .deliveryHours
                .where((x) => x.numOfDay == thisDate.weekday)
                .isNotEmpty &&
            this.onlyPreorder == false) {
          NewDeliveryHour dh = this
              .deliveryHours
              .where((x) => x.numOfDay == thisDate.weekday)
              .first;
          int startMin = (dh.startTime.hour * 60) + dh.startTime.minute;
          int endMin = (dh.endTime.hour * 60) + dh.endTime.minute;

          TimeOfDay curTime = TimeOfDay.fromDateTime(thisDate);
          int curMin =
              (curTime.hour * 60) + curTime.minute; // set it to start time
          // startMin = curMin;
          if (curMin >= startMin && curMin <= endMin) {
            timeofdays.add(TimeOfDay(
              hour: 00,
              minute: 01,
            ));
          }
        }
      }

      // thisDate
      // if(this.deliveryHours.where((x) => x)){

      // }

    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewRestaurant availableTimes hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    //   if(timeofdays.isEmpty){
    // timeofdays.add(TimeOfDay(hour: 0, minute: 1));
    //   }
    return timeofdays;
  }

  @override
  Future<Map<String, dynamic>> getDistance(LatLng selectedLoc) async {
    try {
      LatLng restLoc = LatLng(hantarrBloc.state.foodCart.newRestaurant.latitude,
          hantarrBloc.state.foodCart.newRestaurant.longitude);
      var getDistanceReq = await OSMInterface().getListRoute(
        0,
        1,
        restLoc.longitude,
        restLoc.latitude,
        selectedLoc.longitude,
        selectedLoc.latitude,
      );

      if (getDistanceReq['success']) {
        OSM osm = getDistanceReq['data'] as OSM;
        double getdistance = osm.distance / 1000;
        if (!hantarrBloc.state.foodCart.isPreorder) {
          if (getdistance <= this.maxKM) {
            hantarrBloc.state.selectedLocation = selectedLoc;
            this.distance = getdistance;
            hantarrBloc.add(Refresh());
            return {"success": true, "data": getdistance};
          } else {
            return {
              "success": false,
              "reason":
                  "Cannot deliver to selected location. Please try other location. \nDistance: ${getdistance.toStringAsFixed(2)} km\nMax km: ${this.maxKM.toStringAsFixed(2)}, (ondemand)"
            };
          }
        } else {
          if (getdistance <= this.preorderMaxKM) {
            hantarrBloc.state.selectedLocation = selectedLoc;
            this.distance = getdistance;
            hantarrBloc.add(Refresh());
            return {"success": true, "data": getdistance};
          } else {
            return {
              "success": false,
              "reason":
                  "Cannot deliver to selected location. Please try other location. \nDistance: ${getdistance.toStringAsFixed(2)} km\nMax km: ${this.preorderMaxKM.toStringAsFixed(2)} (preorder)"
            };
          }
        }
      } else {
        return getDistanceReq;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get Distance Failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> getAllRestList() async {
    try {
      List<NewRestaurant> allList = [];
      Dio dio = Dio(BaseOptions(
        baseUrl: "https://pos.str8.my",
        queryParameters: {},
        connectTimeout: 20000,
        receiveTimeout: 15000,
        headers: {},
      ));
      Response response = await dio.get("/images/uploads/rest.json");
      for (Map<String, dynamic> map in response.data) {
        NewRestaurant newRestaurant = NewRestaurant().fromMap(map);
        if (newRestaurant != null) {
          allList.add(newRestaurant);
        }
      }
      hantarrBloc.state.allrestList = List<NewRestaurant>.from(allList);
      hantarrBloc.add(Refresh());
      return {"success": true, "data": List<NewRestaurant>.from(allList)};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "getAllRestList Failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> getSpecificRest() async {
    try {
      Dio dio = getDio(
          baseOption: 1, queries: {"field": "restaurant", "id": this.id});
      Response response = await dio.get("/sales");

      if (response.data['success'] == true) {
        NewRestaurant newRestaurant =
            NewRestaurant().fromMap(response.data['result']);

        if (newRestaurant != null) {
          if (hantarrBloc.state.newRestaurantList
              .where((x) => x.id == this.id)
              .isEmpty) {
            hantarrBloc.state.newRestaurantList.add(newRestaurant);
          } else {
            hantarrBloc.state.newRestaurantList
                .where((x) => x.id == this.id)
                .first
                .mapToLocal(newRestaurant);
          }
          await hantarrBloc.state.newRestaurantList
              .where((x) => x.id == this.id)
              .first
              .restaurantAvailable();
          return {
            "success": true,
            "data": hantarrBloc.state.newRestaurantList
                .where((x) => x.id == this.id)
                .first
          };
        } else {
          return {
            "success": false,
            "reason": "Get restaurant failed. ID: ${this.id}"
          };
        }
      } else {
        return {
          "success": false,
          "reason": "Restaurant not found. Result: ${response.data['result']}"
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
      return {"success": false, "reason": "getSpecificRest Failed. $msg"};
    }
  }

  @override
  List<NewRestaurant> fuzzySearch(String searchString) {
    List<NewRestaurant> restList = [];
    try {
      // final fuse = Fuzzy(
      //   hantarrBloc.state.newRestaurantList
      //       .map((e) => jsonEncode(e.toJson()))
      //       .toList(),
      //   options: FuzzyOptions(
      //     isCaseSensitive: false,
      //     findAllMatches: true,
      //     tokenize: true,
      //     verbose: true,
      //     threshold: 0.5,
      //     shouldSort: true,
      //     shouldNormalize: true,
      //   ),
      // );
      // final result = fuse.search(searchString);
      // result.sort((a, b) => b.score.compareTo(a.score));
      // result.removeWhere((x) => x.score >= 1.0);
      // result.map(
      //   (r) {
      //     Map<String, dynamic> data = jsonDecode(r.item);
      //     if (restList.where((x) => x.code == data['code']).isEmpty) {
      //       restList.add(hantarrBloc.state.newRestaurantList.firstWhere((x) => x
      //           .code
      //           .toLowerCase()
      //           .contains(data['code'].toString().toLowerCase())));
      //     }
      //   },
      // ).toList();
      restList = hantarrBloc.state.newRestaurantList
          .where(
            (e) => e.toJson().toString().toLowerCase().contains(
                  searchString.toString().toLowerCase(),
                ),
          )
          .toList();
      return restList;
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return hantarrBloc.state.newRestaurantList;
    }
  }

  @override
  Future<void> getRestListNew({bool isRetail}) async {
    try {
      // Dio dio = Dio(BaseOptions(
      //   baseUrl: foodUrl,
      //   queryParameters: {
      //     "country": "malaysia",
      //     "user_long": hantarrBloc.state.selectedLocation == null
      //         ? num.tryParse("101.5003567352995").toStringAsFixed(5)
      //         : hantarrBloc.state.selectedLocation.longitude.toStringAsFixed(5),
      //     "user_lat": hantarrBloc.state.selectedLocation == null
      //         ? num.tryParse("2.8107439958462668").toStringAsFixed(5)
      //         : hantarrBloc.state.selectedLocation.latitude.toStringAsFixed(5),
      //   },
      //   connectTimeout: 40000,
      //   receiveTimeout: 40000,
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Accept": "*/*",
      //     "Connection": "keep-alive",
      //     "Accept-Encoding": "gzip, deflate, br",
      //   },
      //   // responseType: ResponseType.stream,
      // ));
      Dio dio = getDio(
        baseOption: 1,
        queries: {
          "country": "malaysia",
          "user_long": hantarrBloc.state.selectedLocation == null
              ? num.tryParse("101.5003567352995").toStringAsFixed(5)
              : hantarrBloc.state.selectedLocation.longitude.toStringAsFixed(5),
          "user_lat": hantarrBloc.state.selectedLocation == null
              ? num.tryParse("2.8107439958462668").toStringAsFixed(5)
              : hantarrBloc.state.selectedLocation.latitude.toStringAsFixed(5),
        },
      );
      Response response = await dio.post(
        "/marketplace/get_restaurant_v2",
      );
      // print(response.data);
      List<NewRestaurant> restList = [];
      for (var map in response.data) {
        NewRestaurant newRestaurant = NewRestaurant.initClass().fromMap(map);
        if (newRestaurant != null) {
          restList.add(newRestaurant);
        } else {
          print("this rest got problem. id: ${map['rest_id']}");
        }
      }
      if (isRetail == true) {
        // show only retail shop
        restList.removeWhere((x) => x.isRetail != true);
      } else {
        // show only restaurant
        restList.removeWhere((x) => x.isRetail == true);
      }
      hantarrBloc.state.newRestaurantList = restList;
      await RestaurantFavo().getListFavoRest();
      hantarrBloc.state.newRestaurantList = this.sortRestaurants();
      hantarrBloc.add(Refresh());
      hantarrBloc.state.streamController.add(jsonEncode({
        "success": true,
      }));
      // return
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> normalGetListRestaurant() async {
    List<NewRestaurant> restaurantList = [];
    double distance = 0.0;
    double distanceThreshold = 500;
    // LatLng temLatlng = hantarrBloc.state.selectedLocation;
    try {
      var getDistanceReq = await OSMInterface().getListRoute(
        0,
        1,
        101.5003567352995, // banting location
        2.8107439958462668, // banting location
        hantarrBloc.state.selectedLocation.longitude,
        hantarrBloc.state.selectedLocation.latitude,
      );
      if (getDistanceReq['success']) {
        debugPrint("success distance retrieve");
        OSM osm = getDistanceReq['data'] as OSM;
        distance = osm.distance / 1000;
      } else {
        debugPrint("failed distance retrieve");
        distance = distanceThreshold;
      }
    } catch (b) {
      distance = distanceThreshold;
      String msg = getExceptionMsg(b);
      debugPrint("get country failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(b);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    try {
      // Dio dio = Dio(BaseOptions(
      //   baseUrl: foodUrl,
      //   queryParameters: {
      //     "country": "malaysia",
      //     "user_long": hantarrBloc.state.selectedLocation == null ||
      //             distance >= distanceThreshold
      //         ? num.tryParse("101.5003567352995").toStringAsFixed(5)
      //         : hantarrBloc.state.selectedLocation.longitude.toStringAsFixed(5),
      //     "user_lat": hantarrBloc.state.selectedLocation == null ||
      //             distance >= distanceThreshold
      //         ? num.tryParse("2.8107439958462668").toStringAsFixed(5)
      //         : hantarrBloc.state.selectedLocation.latitude.toStringAsFixed(5),
      //   },
      //   connectTimeout: 40000,
      //   receiveTimeout: 40000,
      //   headers: {
      //     "Content-Type": "application/json",
      //     "Accept": "*/*",
      //     "Connection": "keep-alive",
      //     "Accept-Encoding": "gzip, deflate, br",
      //   },
      //   // responseType: ResponseType.stream,
      // ));
      Dio dio = getDio(
        baseOption: 1,
        queries: {
          "country": "malaysia",
          "user_long": hantarrBloc.state.selectedLocation == null ||
                  distance >= distanceThreshold
              ? num.tryParse("101.5003567352995").toStringAsFixed(5)
              : hantarrBloc.state.selectedLocation.longitude.toStringAsFixed(5),
          "user_lat": hantarrBloc.state.selectedLocation == null ||
                  distance >= distanceThreshold
              ? num.tryParse("2.8107439958462668").toStringAsFixed(5)
              : hantarrBloc.state.selectedLocation.latitude.toStringAsFixed(5),
        },
      );
      Response response = await dio
          .post(
        "/marketplace/get_restaurant_v2",
      )
          .then((value) {
        return value;
      });

      Map<String, dynamic> payload = jsonDecode(
          response.data.toString().replaceAll("<%", "").replaceAll("%>", ""));
      // debugPrint(payload['page']);
      hantarrBloc.state.zoneDetailList = [];
      for (Map<String, dynamic> zone in payload['state']) {
        ZoneDetail zd = ZoneDetail.fromJson(zone);
        hantarrBloc.state.zoneDetailList.add(zd);
      }
      for (Map<String, dynamic> data in payload['restaurant']) {
        NewRestaurant newRestaurant = NewRestaurant.initClass().fromMap(data);
        if (newRestaurant != null) {
          if (distance >= distanceThreshold) {
            newRestaurant.distance = distance;
          }
          restaurantList.add(newRestaurant);
        }
      }
      return {"success": true, "data": restaurantList};
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("normalGetListRestaurant hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "Get Restaurant List hit error. $msg"
      };
    }
  }
}
