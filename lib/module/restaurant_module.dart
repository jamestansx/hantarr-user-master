import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart' as dio;
import 'package:hantarr/module/preorderDeliveryFee_module.dart';
import 'package:hantarr/packageUrl.dart';

class Restaurant {
  double distance;
  String name;
  String code;
  String longitude;
  String latitude;
  List<MenuItem> menuItems;
  double rating;
  int prepareTime;
  int individualPrepareTime;
  String area;
  String deliveryEndTime;
  String deliveryStartTime;
  String state;
  String address;
  int id;
  double deliveryMaxKm;
  double deliveryExtraPerKm; //exceed default coverage area
  double deliveryFixFee; //within default coverage area
  double deliveryDefaultKm;
  double preorderExtraPerKm; //exceed default coverage area
  double preorderFixFee; //within default coverage area
  double preorderDefaultKm;
  String bannerImage;
  bool online;
  List<BusinessHour> businessHours;
  bool forceClose;
  List<Restaurant> stalls;
  String menuitemUrl;
  bool allowPreorder;
  List<Discount> discounts;
  bool freeDelivery;
  List categorySortRule;
  List<PreorderDeliveryFee> preorderDeliveryFees;
  double freeDeliveryKm;
  double minOrderValue;

  Restaurant({
    this.distance,
    this.name,
    this.code,
    this.latitude,
    this.longitude,
    this.menuItems,
    this.rating,
    this.prepareTime,
    this.area,
    this.deliveryEndTime,
    this.deliveryStartTime,
    this.address,
    this.state,
    this.id,
    this.deliveryExtraPerKm,
    this.deliveryFixFee,
    this.deliveryMaxKm,
    this.deliveryDefaultKm,
    this.individualPrepareTime,
    this.bannerImage,
    this.online,
    this.businessHours,
    this.forceClose,
    this.stalls,
    this.menuitemUrl,
    this.allowPreorder,
    this.preorderExtraPerKm, //exceed default coverage area
    this.preorderFixFee, //within default coverage area
    this.preorderDefaultKm,
    this.discounts,
    this.freeDelivery,
    this.categorySortRule,
    this.preorderDeliveryFees,
    this.freeDeliveryKm,
    this.minOrderValue = 1.00,
  });

  newClass() {
    return Restaurant(
        distance: this.distance,
        name: this.name,
        code: this.code,
        longitude: this.longitude,
        latitude: this.latitude,
        menuItems: this.menuItems,
        rating: this.rating,
        prepareTime: this.prepareTime,
        individualPrepareTime: this.individualPrepareTime,
        area: this.area,
        deliveryEndTime: this.deliveryEndTime,
        deliveryStartTime: this.deliveryStartTime,
        state: this.state,
        address: this.address,
        id: this.id,
        deliveryMaxKm: this.deliveryMaxKm,
        deliveryExtraPerKm: this.deliveryExtraPerKm,
        deliveryFixFee: this.deliveryFixFee,
        deliveryDefaultKm: this.deliveryDefaultKm,
        preorderExtraPerKm: this.preorderExtraPerKm,
        preorderFixFee: this.preorderFixFee,
        preorderDefaultKm: this.preorderDefaultKm,
        bannerImage: this.bannerImage,
        online: this.online,
        businessHours: this.businessHours,
        forceClose: this.forceClose,
        stalls: this.stalls,
        menuitemUrl: this.menuitemUrl,
        allowPreorder: this.allowPreorder,
        freeDelivery: this.freeDelivery,
        discounts: this.discounts,
        categorySortRule: this.categorySortRule,
        freeDeliveryKm: this.freeDeliveryKm);
  }

  restaurantToClass(Map payload, Map foodCourt) {
    List<PreorderDeliveryFee> preorderDelivery = [];
    if (payload["allow_preorder"]) {
      print("wow");
    }
    if (payload["preorder_cost_map"].isNotEmpty) {
      for (Map pofee in payload["preorder_cost_map"]) {
        preorderDelivery.add(PreorderDeliveryFee.fromJson(pofee));
      }
    }

    // print(payload["preorder_cost_ma"]);
    List<BusinessHour> businessHours = [];
    if (payload["business_hours"].isNotEmpty) {
      for (var bh in payload["business_hours"]) {
        businessHours.add(BusinessHour(
            startTime: bh["day_start"],
            endTime: bh["day_end"],
            numOfDay: bh["day_no"]));
      }
    }
    List<Discount> discountList = [];
    // commented cause this module not use anymore
    // if (payload["discounts"] != null) {
    //   for (Map discountMap in payload["discounts"]) {
    //     if (discountMap["category"] == "snaelauto") {
    //       String startDateTime =
    //           discountMap["start_date"] + " ${discountMap["start_time"]}";
    //       String endDateTime =
    //           discountMap["end_date"] + " ${discountMap["end_time"]}";
    //       if (Jiffy().isSameOrAfter(startDateTime) &&
    //           Jiffy().isSameOrBefore(endDateTime)) {
    //         discountList.add(Discount.fromJson(discountMap));
    //       }
    //     }
    //   }
    // }
    if (payload["rest_id"] == 65) {
      debugPrint("im here");
    }
    Restaurant restaurant = Restaurant(
      id: payload["rest_id"],
      preorderDeliveryFees: preorderDelivery,
      forceClose: payload["online_map"] != null
          ? payload["online_map"]["force_close"]
          : false,
      stalls: [],
      businessHours: businessHours,
      online: false,
      bannerImage: payload["image_url"],
      distance: payload["km"],
      name: payload["name"],
      code: payload["code"],
      latitude: payload["lat"],
      longitude: payload["long"],
      rating: num.tryParse(payload["rate"].toString()).toDouble(),
      individualPrepareTime: num.tryParse(payload["preparation_time"]).toInt(),
      prepareTime: (foodCourt != null
              ? foodCourt["duration"].round()
              : payload["duration"].round()) +
          num.tryParse(payload["preparation_time"]).toInt(),
      area: payload["area"],
      deliveryEndTime: payload["delivery_end_time"],
      deliveryStartTime: payload["delivery_start_time"],
      state: payload["state"],
      address: payload["address"],
      deliveryMaxKm: payload["delivery_max_km"] == null
          ? 0.0
          : (payload["delivery_max_km"] is double
              ? payload["delivery_max_km"]
              : num.tryParse(payload["delivery_max_km"].toString()).toDouble()),
      deliveryExtraPerKm: payload["delivery_extra_per_km_cost"] == null
          ? 0.0
          : (payload["delivery_extra_per_km_cost"] is double
              ? payload["delivery_extra_per_km_cost"]
              : num.tryParse(payload["delivery_extra_per_km_cost"]).toDouble()),
      deliveryFixFee: payload["delivery_cost_price"] == null
          ? 0.0
          : (payload["delivery_cost_price"] is double
              ? payload["delivery_cost_price"]
              : num.tryParse(payload["delivery_cost_price"]).toDouble()),
      deliveryDefaultKm: payload["delivery_default_coverage"] == null
          ? 0.0
          : (payload["delivery_default_coverage"] is double
              ? payload["delivery_default_coverage"]
              : num.tryParse(payload["delivery_default_coverage"]).toDouble()),
      preorderExtraPerKm: payload["preorder_extra_per_km_cost"] == null
          ? 0.0
          : (payload["preorder_extra_per_km_cost"] is double
              ? payload["preorder_extra_per_km_cost"]
              : num.tryParse(payload["preorder_extra_per_km_cost"]).toDouble()),
      preorderFixFee: payload["preorder_cost_price"] == null
          ? 0.0
          : (payload["preorder_cost_price"] is double
              ? payload["preorder_cost_price"]
              : num.tryParse(payload["preorder_cost_price"]).toDouble()),
      preorderDefaultKm: payload["preorder_default_coverage"] == null
          ? 0.0
          : (payload["preorder_default_coverage"] is double
              ? payload["preorder_default_coverage"]
              : num.tryParse(payload["preorder_default_coverage"]).toDouble()),
      menuitemUrl: payload["menu_item_url"],
      allowPreorder: payload["allow_preorder"],
      discounts: discountList,
      freeDelivery: payload["hantarr_free_delivery"] == null
          ? false
          : payload["hantarr_free_delivery"],
      categorySortRule: payload["category_sort_rule"] == null
          ? []
          : payload["category_sort_rule"],
      freeDeliveryKm: payload["free_delivery_km"],
      minOrderValue: payload['min_order_value'] != null
          ? num.tryParse(payload['min_order_value'].toString()).toDouble()
          : 0.0,
    );
    return restaurant;
  }

  getRestaurantList(dynamic filterRestaurant) async {
    try {
      hantarrBloc.state.allRestaurants = [];
      dio.Response<dio.ResponseBody> stream;
      List<String> pendingData = [];
      stream = await dio.Dio().post<dio.ResponseBody>(
        "$foodUrl/marketplace/get_restaurant_v2",
        data: jsonEncode({
          "country": "malaysia",
          "user_long": hantarrBloc.state.user == null
              ? "101.5026"
              : hantarrBloc.state.user.currentContactInfo.longitude,
          "user_lat": hantarrBloc.state.user == null
              ? "2.8121"
              : hantarrBloc.state.user.currentContactInfo.latitude
        }),
        options: dio.Options(
            responseType:
                dio.ResponseType.stream), // set responseType to `stream`
      );
      stream.data.stream.listen((data) {
        String a = utf8.decode(data);
        print(a);

        int prevIdx = pendingData.length - 1;
        if (prevIdx > 0) {
          String checker = pendingData[prevIdx];
          if (checker.endsWith("}") && a.startsWith("{")) {
            pendingData.add(",");
          }
        }

        pendingData.add(a);
        if (a.endsWith("%>")) {
          print("ended with %>");
          if (pendingData.length == 1) {
            var payload = jsonDecode(
                pendingData.join().replaceAll("<%", "").replaceAll("%>", ""));
            print(payload);
            filterRestaurant(payload);
          } else {
            pendingData.removeAt(0);
            pendingData.removeLast();
            pendingData.insert(0, "[");
            int ll = pendingData.length;
            pendingData.insert(ll, "]");
            List<dynamic> zz = jsonDecode(pendingData.join());
            for (var payload in zz) {
              print(payload);
              filterRestaurant(payload);
            }
          }
        }
      });
      return {"success": true};
    } catch (e) {
      BotToast.showText(text: "Retrieve restaurant failed. ${e.toString()}");
      return {"success": false, "reason": e.toString()};
    }
  }

  bool onlineRuleResult(Restaurant res, DateTime currentDT) {
    if ((res.restaurantStatus(res.businessHours, currentDT) &&
            res.online &&
            res.forceClose == false) ||
        res.allowPreorder) {
      return true;
    } else {
      return false;
    }
  }

  // menuItemToClass(Map payload) {
  //   List allMenuItem = payload["menu_items"];
  //   List<MenuItem> menuItems = new List();
  //   for (Map data in allMenuItem) {
  //     if (data["category_name"].contains("_")) {
  //     } else {
  //       List<SchedulePrice> schedulePriceList = [];
  //       if (data["price_history"] != null) {
  //         if (data["price_history"].isNotEmpty) {
  //           for (Map detail in data["price_history"]) {
  //             SchedulePrice schedulePrice = SchedulePrice(
  //                 untilDate: detail["until"],
  //                 fromDate: detail["start"],
  //                 untilTime: detail["time"],
  //                 fromTime: detail["time_start"],
  //                 frequencyDuration: detail["frequency"],
  //                 price: num.tryParse(detail["delivery_price"]).toDouble());
  //             schedulePriceList.add(schedulePrice);
  //           }
  //         }
  //       }
  //       MenuItem mi = MenuItem(
  //           restaurantID: this.id,
  //           name: data["name"],
  //           alt_name: data["alt_name"],
  //           price: (data["delivery_price"] is String)
  //               ? num.tryParse(data["delivery_price"]).toDouble()
  //               : data["delivery_price"],
  //           selfOrderingPrice: (data["price"] is String)
  //               ? num.tryParse(data["price"]).toDouble()
  //               : data["price"],
  //           costPrice: (data["cost_price"] is String)
  //               ? num.tryParse(data["cost_price"]).toDouble()
  //               : data["cost_price"],
  //           selectedCustomizations: [],
  //           confirmedComboItems: [],
  //           isAvailable: data["is_available"],
  //           imageUrl: data["img_url"],
  //           category: data["category_name"],
  //           comboItems: [],
  //           customizations: [],
  //           index: data["index"],
  //           schedulePriceList: schedulePriceList,
  //           merchantCustomization: json.encode(data["merchant_customization"]),
  //           deliveryStartTime: data["delivery_start_time"],
  //           deliveryEndTime: data["delivery_end_time"],
  //           allowSameDayDelivert: data["is_same_day_delivery"],
  //           customizationSortRule: data["category_sort_rule"] == null
  //               ? []
  //               : data["category_sort_rule"]);

  //       if (data["combo_items"].isNotEmpty) {
  //         for (Map combo in data["combo_items"]) {
  //           ComboItem ci = ComboItem(
  //               name: combo["name"],
  //               price: combo["price"] is double
  //                   ? combo["price"]
  //                   : num.tryParse(combo["price"]).toDouble(),
  //               limit: combo["limit"],
  //               category: combo["category"],
  //               alt_name: combo["alt_name"]);
  //           mi.comboItems.add(ci);
  //         }
  //       }
  //       if (data["confirmedComboItems"] != null) {
  //         for (Map combo in data["confirmedComboItems"]) {
  //           ComboItem ci = ComboItem(
  //               name: combo["name"],
  //               price: combo["price"] is double
  //                   ? combo["price"]
  //                   : num.tryParse(combo["price"]).toDouble(),
  //               limit: combo["limit"],
  //               category: combo["category"],
  //               alt_name: combo["alt_name"],
  //               selectedCustomizations: []);
  //           if (combo["customizations"] != null) {
  //             for (Map cus in combo["customizations"]) {
  //               Customization cs = Customization(
  //                   name: cus["name"],
  //                   price: num.tryParse(cus["price"]).toDouble(),
  //                   qty: cus["quantity"] is int ? cus["quantity"] : 0);
  //               ci.selectedCustomizations.add(cs);
  //             }
  //           }

  //           mi.confirmedComboItems.add(ci);
  //         }
  //       }
  //       if (data["customization"] != null) {
  //         for (Map cus in data["customization"]) {
  //           int index = 0;
  //           if (data["category_sort_rule"] != null) {
  //             if (data["category_sort_rule"]
  //                 .any((element) => element["name"] == cus["name"])) {
  //               index = data["category_sort_rule"].firstWhere(
  //                   (element) => element["name"] == cus["name"])["sort"];
  //             }
  //           }
  //           Customization cs = Customization(
  //               name: cus["name"],
  //               price: num.tryParse(cus["price"]).toDouble(),
  //               category: cus["category"] == null ? "empty" : cus["category"],
  //               limit: (cus["limit"] is int || cus["limit"] == null)
  //                   ? cus["limit"]
  //                   : num.tryParse(cus["limit"]).toInt(),
  //               itemLimit:
  //                   (cus["item_limit"] is int || cus["item_limit"] == null)
  //                       ? cus["item_limit"]
  //                       : num.tryParse(cus["item_limit"]).toInt(),
  //               minItemLimit: (cus["min_item_limit"] is int ||
  //                       cus["min_item_limit"] == null)
  //                   ? cus["min_item_limit"]
  //                   : num.tryParse(cus["min_item_limit"]).toInt(),
  //               minLimit: (cus["min_category_limit"] is int ||
  //                       cus["min_category_limit"] == null)
  //                   ? cus["min_category_limit"]
  //                   : num.tryParse(cus["min_category_limit"]).toInt(),
  //               sortIndex: index);
  //           mi.customizations.add(cs);
  //         }
  //         mi.customizations.sort((a,b)=> a.sortIndex.compareTo(b.sortIndex));
  //       }

  //       if (data["confirmedCustomizations"] != null) {
  //         for (Map cus in data["confirmedCustomizations"]) {
  //           Customization cs = Customization(
  //               name: cus["name"],
  //               price: num.tryParse(cus["price"]).toDouble(),
  //               category: cus["category"] == null ? "empty" : cus["category"],
  //               limit: (cus["limit"] is int || cus["limit"] == null)
  //                   ? cus["limit"]
  //                   : num.tryParse(cus["limit"]).toInt(),
  //               qty: cus["quantity"] is int ? cus["quantity"] : 0,
  //               itemLimit:
  //                   (cus["item_limit"] is int || cus["item_limit"] == null)
  //                       ? cus["item_limit"]
  //                       : num.tryParse(cus["item_limit"]).toInt(),
  //               minItemLimit: (cus["min_item_limit"] is int ||
  //                       cus["min_item_limit"] == null)
  //                   ? cus["min_item_limit"]
  //                   : num.tryParse(cus["min_item_limit"]).toInt(),
  //               minLimit: (cus["min_category_limit"] is int ||
  //                       cus["min_category_limit"] == null)
  //                   ? cus["min_category_limit"]
  //                   : num.tryParse(cus["min_category_limit"]).toInt());
  //           mi.selectedCustomizations.add(cs);
  //         }
  //       }
  //       menuItems.add(mi);
  //       // menuItems.add(mi);
  //     }
  //   }

  //   return menuItems;
  // }

  selfOrderMenuItemToClass(String items) {
    List allMenuItem = json.decode(items);
    List<MenuItem> menuItems = new List();
    for (Map data in allMenuItem) {
      MenuItem mi = MenuItem(
          restaurantID: this.id,
          name: data["item_name"],
          alt_name: data["alt_name"],
          price: data["price"] == null ? 0.0 : data["price"],
          selfOrderingPrice: (data["price"] is String)
              ? num.tryParse(data["price"]).toDouble()
              : data["price"],
          selectedCustomizations: [],
          isAvailable: data["is_available"],
          imageUrl: data["img_url"],
          category: data["category_name"],
          comboItems: [],
          customizations: [],
          confirmedComboItems: [],
          confirmedCustomizations: [],
          index: data["index"]);

      if (data["confirmedComboItems"].isNotEmpty) {
        for (Map combo in data["confirmedComboItems"]) {
          ComboItem ci = ComboItem(
              name: combo["name"],
              price: num.tryParse(combo["price"]).toDouble(),
              limit: combo["limit"],
              category: combo["category"],
              alt_name: combo["alt_name"]);
          mi.confirmedComboItems.add(ci);
        }
      }
      if (data["confirmedCustomizations"].isNotEmpty) {
        for (Map cus in data["confirmedCustomizations"]) {
          Customization cs = Customization(
              name: cus["name"],
              price: num.tryParse(cus["price"]).toDouble(),
              category: cus["category"],
              limit: cus["limit"] is int
                  ? cus["limit"]
                  : num.tryParse(cus["limit"]).toInt(),
              itemLimit: (cus["item_limit"] is int || cus["item_limit"] == null)
                  ? cus["item_limit"]
                  : num.tryParse(cus["item_limit"]).toInt(),
              minItemLimit: (cus["min_item_limit"] is int ||
                      cus["min_item_limit"] == null)
                  ? cus["min_item_limit"]
                  : num.tryParse(cus["min_item_limit"]).toInt(),
              minLimit: (cus["min_category_limit"] is int ||
                      cus["min_category_limit"] == null)
                  ? cus["min_category_limit"]
                  : num.tryParse(cus["min_category_limit"]).toInt());
          mi.selectedCustomizations.add(cs);
        }
      }
      menuItems.add(mi);
    }

    return menuItems;
  }

  menuItemToMapList(List<MenuItem> menuItem) {
    List<Map> menuMaps = [];
    for (MenuItem mi in menuItem) {
      var confirmedCustomizations = [];
      if (mi.selectedCustomizations == null) {
        mi.selectedCustomizations = [];
      }
      for (Customization c in mi.selectedCustomizations) {
        Map cm = {
          "name": c.name,
          "price": c.price.toString(),
          "quantity": (c.qty == null || c.qty == 0) ? 1 : c.qty
        };
        confirmedCustomizations.add(cm);
      }

      var comboItems = [];
      if (mi.confirmedComboItems == null) {
        mi.confirmedComboItems = [];
      }
      for (ComboItem c in mi.confirmedComboItems) {
        c.selectedCustomizations == null
            ? c.selectedCustomizations = []
            : c.selectedCustomizations = c.selectedCustomizations;
        List<Map> comboCusMap = [];
        if (c.selectedCustomizations.isNotEmpty) {
          for (Customization cus in c.selectedCustomizations) {
            comboCusMap.add({
              "name": cus.name,
              "price": cus.price.toString(),
              "quantity": (cus.qty == null || cus.qty == 0) ? 1 : cus.qty
            });
          }
        }
        Map cm = {
          "name": c.name,
          "price": c.price,
          "category": c.category,
          "limit": c.limit,
          "alt_name": c.alt_name,
          "customizations": comboCusMap
        };
        comboItems.add(cm);
      }

      Map m = {
        "restaurant_id": mi.restaurantID,
        "name": mi.name,
        "item_name": mi.name,
        "price": mi.price,
        "delivery_price": mi.itemPriceSetter(mi, DateTime.now(), false),
        "category_name": mi.category,
        "customization": confirmedCustomizations,
        "combo_items": comboItems,
        "confirmedCustomizations": confirmedCustomizations,
        "confirmedComboItems": comboItems,
        "index": mi.index,
        "img_url": mi.imageUrl,
        "alt_name": mi.alt_name,
        "is_available": mi.isAvailable,
        "cost_price": mi.costPrice,
        "merchant_customization": mi.merchantCustomization
      };

      menuMaps.add(m);
    }

    return menuMaps;
  }

  menuItemtoSingleMap(MenuItem menuItem) {
    List<Map> confirmedCustomizations = [];
    if (menuItem.selectedCustomizations == null) {
      menuItem.selectedCustomizations = [];
    }
    for (Customization c in menuItem.selectedCustomizations) {
      Map cm = {
        "name": c.name,
        "price": c.price.toString(),
        "quantity": (c.qty == null || c.qty == 0) ? 1 : c.qty
      };
      confirmedCustomizations.add(cm);
    }
    //-----sort-----//
    if (confirmedCustomizations.isNotEmpty) {
      confirmedCustomizations.sort((a, b) {
        return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
      });
    }
    //-----sort-----//

    List<Map> comboItems = [];
    if (menuItem.confirmedComboItems == null) {
      menuItem.confirmedComboItems = [];
    }
    for (ComboItem c in menuItem.confirmedComboItems) {
      c.selectedCustomizations == null
          ? c.selectedCustomizations = []
          : c.selectedCustomizations = c.selectedCustomizations;
      List<Map> comboCusMap = [];
      if (c.selectedCustomizations.isNotEmpty) {
        for (Customization cus in c.selectedCustomizations) {
          comboCusMap.add({
            "name": cus.name,
            "price": cus.price.toString(),
            "quantity": (cus.qty == null || cus.qty == 0) ? 1 : cus.qty
          });
        }
      }

      //-----sort-----//
      if (comboCusMap.isNotEmpty) {
        comboCusMap.sort((a, b) {
          return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
        });
      }
      //-----sort-----//

      Map cm = {
        "name": c.name,
        "price": c.price,
        "category": c.category,
        "limit": c.limit,
        "alt_name": c.alt_name,
        "customizations": comboCusMap
      };
      comboItems.add(cm);
    }
    //-----sort-----//
    if (comboItems.isNotEmpty) {
      comboItems.sort((a, b) {
        return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
      });
    }
    //-----sort-----//

    Map m = {
      "restaurant_id": menuItem.restaurantID,
      "name": menuItem.name,
      "item_name": menuItem.name,
      "price": menuItem.price,
      // "delivery_price":
      //     menuItem.itemPriceSetter(menuItem, DateTime.now(), false),
      "category_name": menuItem.category,
      // "customization": json.encode(confirmedCustomizations),
      // "combo_items": json.encode(comboItems),
      // "confirmedCustomizations": json.encode(confirmedCustomizations),
      // "confirmedComboItems": json.encode(comboItems),
      "customization": confirmedCustomizations,
      "combo_items": comboItems,
      "confirmedCustomizations": confirmedCustomizations,
      "confirmedComboItems": comboItems,
      "img_url": menuItem.imageUrl,
      "alt_name": menuItem.alt_name,
      "is_available": menuItem.isAvailable,
      "cost_price": menuItem.costPrice,
      "merchant_customization": menuItem.merchantCustomization
    };

    return m;
  }

  restaurantStatus(List<BusinessHour> businessHours, DateTime currentDT) {
    DateTime currentDateTime = currentDT;
    DateTime startDT;
    DateTime endDT;
    bool open = false;
    if (currentDateTime == null) {
      currentDateTime = DateTime.now();
    }

    if (businessHours.isEmpty) {
      open = true;
    } else {
      for (BusinessHour bh in businessHours) {
        if (currentDateTime.weekday == bh.numOfDay && open != true) {
          startDT = DateTime(
              currentDateTime.year,
              currentDateTime.month,
              currentDateTime.day,
              num.tryParse(bh.startTime.split(":")[0]).toInt(),
              num.tryParse(bh.startTime.split(":")[1]).toInt());
          endDT = DateTime(
              currentDateTime.year,
              currentDateTime.month,
              currentDateTime.day,
              num.tryParse(bh.endTime.split(":")[0]).toInt(),
              num.tryParse(bh.endTime.split(":")[1]).toInt());
          if (currentDateTime.isAfter(startDT) &&
              currentDateTime.isBefore(endDT)) {
            open = true;
          } else {
            open = false;
          }
        }
      }
    }
    return open;
  }

  sizeAddOnPrice(
      MenuItem currentMenuItem, DateTime currentDT, bool fromSelfOrderingMenu) {
    double addOnPrice;
    if (currentMenuItem.selectedCustomizations
        .any((x) => x.category.toLowerCase() == "size")) {
      addOnPrice = currentMenuItem.selectedCustomizations
              .where((x) => x.category.toLowerCase() == "size")
              .toList()
              .first
              .price +
          currentMenuItem.itemPriceSetter(
              currentMenuItem, currentDT, fromSelfOrderingMenu);
    } else {
      addOnPrice = currentMenuItem.itemPriceSetter(
          currentMenuItem, currentDT, fromSelfOrderingMenu);
    }

    return addOnPrice;
  }

  sizeAddOnPriceFromCustomization(Customization currentCustomization,
      MenuItem currentMenuItem, DateTime currentDT, bool fromSelfOrderingMenu) {
    double addOnPrice;
    if (currentCustomization.category.toLowerCase() == "size") {
      addOnPrice = currentCustomization.price +
          currentMenuItem.itemPriceSetter(
              currentMenuItem, currentDT, fromSelfOrderingMenu);
    } else {
      addOnPrice = currentCustomization.price;
    }
    return addOnPrice;
  }
}
