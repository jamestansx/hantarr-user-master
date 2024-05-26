import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_advertisement_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_cart_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2p_status_code_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/vehicle_module.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/module/user_module.dart' as hantarrUser;
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/root_page_repo/modules/user_module.dart';

class HantarrState {
  bool loginStatus;
  hantarrUser.User? user;
  List<Restaurant> allRestaurants;
  List<ZoneDetail> zoneDetailList;
  List<Delivery> allDeliveries;
  Translation translation;
  final FlutterSecureStorage storage;
  DateTime serverTime;
  FirebaseMessaging fcm;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  NotificationDetails? notificationDetails;
  String versionName;
  // -----  new   ---- //
  HantarrUser hUser;
  List<Address> addressList;
  List<Vehicle> vehicleList;
  List<P2pTransaction> p2pHistoryList;
  List<P2PStatusCode> p2pStatusCodes;
  List<TopUp> topUpList;
  List<Delivery> pendingOrders;
  List<P2pTransaction> p2pPendingOrders;
  //  -- new food delivery repo - //
  List<NewRestaurant> newRestaurantList;
  LatLng? selectedLocation;
  FoodCart foodCart;
  LatLng? currentLocation;
  List<NewFoodDelivery> pendingFoodOrders;
  FirebaseApp? app;
  List<NewFoodDelivery> allFoodOrders;
  bool p2pVehicleLoaded;
  List<NewRestaurant> allrestList;
  List<NewAdvertisement> advertisements;
  bool showedAds;
  bool foodCheckoutPageLoading;
  String foodCheckoutErrorMsg;
  StreamController<String> streamController;

  HantarrState({
    required this.loginStatus,
    required this.user,
    required this.allRestaurants,
    required this.zoneDetailList,
    required this.allDeliveries,
    required this.translation,
    required this.storage,
    required this.serverTime,
    required this.fcm,
    required this.flutterLocalNotificationsPlugin,
    required this.notificationDetails,
    required this.versionName,
    required this.hUser,
    required this.addressList,
    required this.vehicleList,
    required this.p2pHistoryList,
    required this.p2pStatusCodes,
    required this.topUpList,
    required this.pendingOrders,
    required this.p2pPendingOrders,
    required this.newRestaurantList,
    required this.selectedLocation,
    required this.foodCart,
    required this.currentLocation,
    required this.pendingFoodOrders,
    required this.app,
    required this.allFoodOrders,
    required this.p2pVehicleLoaded,
    required this.allrestList,
    required this.advertisements,
    required this.showedAds,
    required this.foodCheckoutPageLoading,
    required this.foodCheckoutErrorMsg,
    required this.streamController,
  });

  factory HantarrState.initial() {
    return HantarrState(
      loginStatus: false,
      user: null,
      allRestaurants: [],
      zoneDetailList: [],
      allDeliveries: [],
      translation: Translation(),
      serverTime: DateTime.now(),
      storage: new FlutterSecureStorage(),
      fcm: FirebaseMessaging.instance,
      flutterLocalNotificationsPlugin: null,
      notificationDetails: null,
      versionName: "",
      hUser: HantarrUserInterface(),
      addressList: [],
      vehicleList: [],
      p2pHistoryList: [],
      p2pStatusCodes: [],
      topUpList: [],
      pendingOrders: [],
      p2pPendingOrders: [],
      newRestaurantList: [],
      selectedLocation: null,
      foodCart: FoodCart.initClass(),
      currentLocation: null,
      pendingFoodOrders: [],
      app: null,
      allFoodOrders: [],
      p2pVehicleLoaded: false,
      allrestList: [],
      advertisements: [],
      showedAds: false,
      foodCheckoutPageLoading: false,
      foodCheckoutErrorMsg: "",
      streamController: new StreamController.broadcast(),
    );
  }

  factory HantarrState.save(
    bool loginStatus,
    hantarrUser.User user,
    List<Restaurant> allRestaurants,
    List<ZoneDetail> zoneDetailList,
    List<Delivery> allDeliveries,
    Translation translation,
    DateTime serverTime,
    final storage,
    FirebaseMessaging fcm,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    NotificationDetails notificationDetails,
    String versionName,
    HantarrUser hUser,
    List<Address> addressList,
    List<Vehicle> vehicleList,
    List<P2pTransaction> p2pHistoryList,
    List<P2PStatusCode> p2pStatusCodes,
    List<TopUp> topUpList,
    List<Delivery> pendingOrders,
    List<P2pTransaction> p2pPendingOrders,
    List<NewRestaurant> newRestaurantList,
    LatLng selectedLocation,
    FoodCart foodCart,
    LatLng currentLocation,
    List<NewFoodDelivery> pendingFoodOrders,
    FirebaseApp app,
    List<NewFoodDelivery> allFoodOrders,
    bool p2pVehicleLoaded,
    List<NewRestaurant> allrestList,
    List<NewAdvertisement> advertisements,
    bool showedAds,
    bool foodCheckoutPageLoading,
    String foodCheckoutErrorMsg,
    StreamController<String> streamController,
  ) {
    return HantarrState(
      loginStatus: loginStatus,
      user: user,
      allRestaurants: allRestaurants,
      zoneDetailList: zoneDetailList,
      allDeliveries: allDeliveries,
      translation: translation,
      serverTime: serverTime,
      storage: storage,
      fcm: fcm,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      notificationDetails: notificationDetails,
      versionName: versionName,
      hUser: hUser,
      addressList: addressList,
      vehicleList: vehicleList,
      p2pHistoryList: p2pHistoryList,
      p2pStatusCodes: p2pStatusCodes,
      topUpList: topUpList,
      pendingOrders: pendingOrders,
      p2pPendingOrders: p2pPendingOrders,
      newRestaurantList: newRestaurantList,
      selectedLocation: selectedLocation,
      foodCart: foodCart,
      currentLocation: currentLocation,
      pendingFoodOrders: pendingFoodOrders,
      app: app,
      allFoodOrders: allFoodOrders,
      p2pVehicleLoaded: p2pVehicleLoaded,
      allrestList: allrestList,
      advertisements: advertisements,
      showedAds: showedAds,
      foodCheckoutPageLoading: foodCheckoutPageLoading,
      foodCheckoutErrorMsg: foodCheckoutErrorMsg,
      streamController: streamController,
    );
  }
}
