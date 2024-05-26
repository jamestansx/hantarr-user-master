import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_delivery_hour_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_discount_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/checkout_wizard_pages/page_1_contact_info_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/checkout_wizard_pages/page_2_payment_method_page.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/date_formater.dart';
import 'package:hantarr/utilities/geo_decode.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';
import 'package:location/location.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart'
    as gL;

abstract class FoodCartInterface {
  factory FoodCartInterface() => FoodCart.initClass();

  // local
  void reInitClass();
  Future<Map<String, dynamic>> addToCart(NewRestaurant newRestaurant,
      NewMenuItem newMenuItem, BuildContext context);
  Future<void> removeItem(NewMenuItem newMenuItem, BuildContext context);
  double getSubtotal();
  double getDeliveryFee();
  double getDiscountAmount();
  NewDiscount getDiscount();
  double getVoucherAmount();
  double getServiceFee();
  double getSmallOrderFee();
  double getGrantTotal();
  List<NewMenuItem> grouppedMenuItem();
  int countForThisItem(NewMenuItem newMenuItem); // groupped qty in this cart
  void addACloneItem(
      NewMenuItem newMenuItem); // if item already exist then use this

  Future<void> removeItemFromCart(
      NewMenuItem newMenuItem, BuildContext context);
  Future<void> removeAllThisItemFromCart(
      NewMenuItem newMenuItem, BuildContext context);
  void setDeliveryDateTime(DateTime dateTime, TimeOfDay timeOfDay);
  void initDeliveryDateTime(
      NewRestaurant newRestaurant); // this is called at menu item listing page
  Map<String, dynamic> validateBindedphone();
  Map<String, dynamic> validateAllItem();
  Map<String, dynamic> validateDeliveryTime();
  Map<String, dynamic> validateDeliveryDistance();
  Future<Map<String, dynamic>> validateCreditAmount();
  Map<String, dynamic> validatePhoneNumber();
  Map<String, dynamic> validateReceiverName();
  Map<String, dynamic> validateAddress();
  Map<String, dynamic> validateSubtotalPrice();
  Future<Map<String, dynamic>> validateAll();
  Map<String, dynamic> validateContactInfo();

  Future<void> changeLocation(BuildContext context);
  Future<String> getPlace(LatLng latLng, BuildContext context);

  Future<Map<String, dynamic>> getCurrentTime();

  // payload to create order
  Future<Map<String, dynamic>> payloadToSend();

  Future<Map<String, dynamic>> createNewFoodOrder({@required String remarks});

  // APIs
  Future<void> applyVoucher(String voucher, BuildContext context);

  List<Map<String, dynamic>> wizardPages(
      {@required TextEditingController remarksCon});
  Future<void> getDistance();
}

List<String> paymentMethods = ["Cash On Delivery", "Credit"];

class FoodCart implements FoodCartInterface {
  int addressID;
  NewRestaurant newRestaurant;
  List<NewMenuItem> menuItems;
  DateTime orderDateTime, preorderDateTime;
  double voucherAmount;
  String paymentMethod,
      voucherName,
      address,
      contactPerson,
      phoneNum,
      deliveryMethod;
  bool isPreorder;
  LatLng latLng;

  FoodCart({
    this.addressID,
    this.newRestaurant,
    this.menuItems,
    this.orderDateTime,
    this.preorderDateTime,
    this.voucherAmount,
    this.paymentMethod,
    this.voucherName,
    this.address,
    this.contactPerson,
    this.phoneNum,
    this.deliveryMethod,
    this.isPreorder,
    this.latLng,
  });

  FoodCart.initClass() {
    this.newRestaurant = null;
    this.menuItems = [];
    this.orderDateTime = null;
    this.preorderDateTime = null;
    this.voucherAmount = 0.0;
    this.paymentMethod = "Cash On Delivery";
    this.voucherName = "";
    this.address = "";
    this.contactPerson =
        hantarrBloc != null && hantarrBloc.state.hUser.firebaseUser != null
            ? hantarrBloc.state.hUser.firebaseUser?.displayName
            : "";
    this.phoneNum =
        hantarrBloc != null && hantarrBloc.state.hUser.firebaseUser != null
            ? hantarrBloc.state.hUser.firebaseUser.phoneNumber
            : "";
    this.deliveryMethod = "delivery";
    this.isPreorder = false;
    this.latLng =
        hantarrBloc != null ? hantarrBloc.state.selectedLocation : null;
  }

  @override
  void reInitClass() {
    this.newRestaurant = null;
    this.menuItems = [];
    this.orderDateTime = hantarrBloc.state.serverTime;
    this.preorderDateTime = null;
    this.voucherAmount = 0.0;
    this.paymentMethod = "Cash On Delivery";
    this.voucherName = "";
    this.deliveryMethod = "delivery";
    // this.address = ""; // no need reinit this
    // this.contactPerson = ""; // no need reinit this
    // this.phoneNum = ""; // no need reinit this
    this.isPreorder = false;
    this.latLng =
        hantarrBloc != null ? hantarrBloc.state.selectedLocation : null;
  }

  @override
  Future<Map<String, dynamic>> addToCart(NewRestaurant newRestaurant,
      NewMenuItem newMenuItem, BuildContext context) async {
    if (hantarrBloc.state.hUser.firebaseUser == null) {
      var getLoginReq = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Please login first"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, "no");
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: themeBloc.state.textTheme.button.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, "yes");
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                color: themeBloc.state.primaryColor,
                child: Text(
                  "Login",
                  style: themeBloc.state.textTheme.button.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (getLoginReq == "yes") {
        Navigator.pushNamed(context, loginPage);
      }
      return {"success": false, "reason": "Please login first"};
    }

    if (hantarrBloc.state.hUser.firebaseUser.phoneNumber == null) {
      var getLoginReq = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Please bind to a phone number first"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, "no");
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: themeBloc.state.textTheme.button.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, "yes");
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                color: themeBloc.state.primaryColor,
                child: Text(
                  "Bind Phone Number",
                  style: themeBloc.state.textTheme.button.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (getLoginReq == "yes") {
        Navigator.pushNamed(context, manageMyAccountPage);
      }
      return {
        "success": false,
        "reason": "Please bind to a phone number first"
      };
    }
    if (this.newRestaurant == null) {
      this.newRestaurant = newRestaurant;
    }

    if (newRestaurant.online == false) {
      // await this.newRestaurant.restaurantAvailable();
      // if (this.newRestaurant.online == false) {
      //   BotToast.showText(text: "Restaurant Offline");
      //   return {"success": false, "reason": "Restaurant Closed"};
      // }
      return {"success": false, "reason": "Shop Closed"};
    }
    try {
      // check if orderdatetime is null then set server time (on demand)
      // check if restaurant is null
      // if null set restaurant
      // else check if same restaurant if same then add to cart
      if (this.orderDateTime == null) {
        this.orderDateTime = hantarrBloc.state.serverTime;
      }

      if (this.newRestaurant.id == newRestaurant.id) {
        // check if item got customization / combo
        if (newMenuItem.customizations.isNotEmpty) {
          var getCus = await Navigator.pushNamed(
            context,
            newMenuItemCustomizationPage,
            arguments: newMenuItem,
          );
          if (getCus != null) {
            Map<String, dynamic> arguments = getCus as Map<String, dynamic>;
            // this.menuItems.removeWhere((x) => x.id == arguments['item'].id);
            // await FirebaseAnalytics().logAddToCart(
            //   itemId: newMenuItem.id.toString(),
            //   itemCategory: newMenuItem.categoryName,
            //   itemName: newMenuItem.name,
            //   quantity: arguments['qty'],
            // );
            for (int i = 0; i < arguments['qty']; i++) {
              NewMenuItem clonnedItem = NewMenuItem.initClass();
              clonnedItem.mapTopLocal(arguments['item']);
              this.menuItems.add(clonnedItem);
            }
          }
        } else {
          // await FirebaseAnalytics().logAddToCart(
          //   itemId: newMenuItem.id.toString(),
          //   itemCategory: newMenuItem.categoryName,
          //   itemName: newMenuItem.name,
          //   quantity: 1,
          // );
          this.menuItems.add(newMenuItem);
        }

        hantarrBloc.add(Refresh());
        return {"success": true, "data": this};
      } else {
        // prompt dialog ask to clear cart
        var confirmClearCart = await showDialog(
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () {
                Navigator.pop(context, "No");
                return null;
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                title: Container(
                  width: ScreenUtil().setWidth(500),
                  height: ScreenUtil().setHeight(300),
                  child: SvgPicture.asset(
                    "assets/warning_cart.svg",
                  ),
                ),
                content: Text(
                  "If you proceed to add item your item will be cleared!",
                  style: themeBloc.state.textTheme.bodyText1.copyWith(
                    fontSize: ScreenUtil().setSp(30.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, "No");
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: themeBloc.state.textTheme.button.copyWith(
                        color: themeBloc.state.primaryColor,
                        fontSize: ScreenUtil().setSp(30.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, "Ok");
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      "Proceed",
                      style: themeBloc.state.textTheme.button.copyWith(
                        color: themeBloc.state.primaryColor,
                        fontSize: ScreenUtil().setSp(30.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
        if (confirmClearCart == "Ok") {
          DateTime preorderDateTime = this.preorderDateTime;
          this.reInitClass();
          this.newRestaurant = newRestaurant;
          if (this.newRestaurant.allowPreorder) {
            if (preorderDateTime != null) {
              this.isPreorder = true;
              this.preorderDateTime = preorderDateTime;
            }
          }
          this.menuItems.clear();
          this.addToCart(newRestaurant, newMenuItem, context);
        }
        hantarrBloc.add(Refresh());
        return {"success": true, "data": this};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      hantarrBloc.add(Refresh());
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Add to cart failed. $msg"};
    }
  }

  @override
  Future<void> removeItem(NewMenuItem newMenuItem, BuildContext context) async {
    try {
      int indexOfItem = hantarrBloc.state.foodCart.menuItems
          .lastIndexWhere((x) => x.id == newMenuItem.id);
      var confirmation = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Remove ${newMenuItem.name} from cart?"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, 'no');
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: themeBloc.state.textTheme.button.copyWith(
                    color: themeBloc.state.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, 'yes');
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                color: themeBloc.state.primaryColor,
                child: Text(
                  "Remove",
                  style: themeBloc.state.textTheme.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (confirmation == "yes") {
        hantarrBloc.state.foodCart.menuItems.removeAt(indexOfItem);
        hantarrBloc.add(Refresh());
      }
    } catch (e) {
      BotToast.showText(text: "Something went wrong");
    }
  }

  @override
  double getSubtotal() {
    double subtotal = 0.0;
    try {
      for (NewMenuItem newMenuItem in this.menuItems) {
        subtotal += newMenuItem.getItemExactPrice(this.orderDateTime, false);
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("get grand total failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      subtotal = 150.0;
    }
    return subtotal;
  }

  @override
  double getDeliveryFee() {
    // double dp(double val, int places) {
    //   double mod = pow(10.0, places);
    //   return ((val * mod).round().toDouble() / mod);
    // }

    double deliveryFee = 0.0;
    try {
      if (!this.isPreorder) {
        if (this.newRestaurant.allowFreeDelivery) {
          if (this.newRestaurant.distance <=
              this.newRestaurant.freeDeliveryKM) {
            deliveryFee = 0.0;
          } else {
            if (this.newRestaurant.distance <= this.newRestaurant.defaultKM) {
              deliveryFee = this.newRestaurant.fixFee;
            } else {
              double extraKM =
                  this.newRestaurant.distance - this.newRestaurant.defaultKM;
              extraKM = extraKM.ceilToDouble();
              double extraKMCost = extraKM * this.newRestaurant.extraPerKM;
              deliveryFee = this.newRestaurant.fixFee + extraKMCost;
            }
          }
        } else {
          if (this.newRestaurant.distance <= this.newRestaurant.defaultKM) {
            deliveryFee = this.newRestaurant.fixFee;
          } else {
            double extraKM =
                this.newRestaurant.distance - this.newRestaurant.defaultKM;
            extraKM = extraKM.ceilToDouble();
            double extraKMCost = extraKM * this.newRestaurant.extraPerKM;
            deliveryFee = this.newRestaurant.fixFee + extraKMCost;
          }
        }
      } else {
        if (this.newRestaurant.distance <=
            this.newRestaurant.preorderDefaultKM) {
          deliveryFee = this.newRestaurant.preorderFixFee;
        } else {
          double extraKM = this.newRestaurant.distance -
              this.newRestaurant.preorderDefaultKM;
          extraKM = extraKM.ceilToDouble();
          double extraKMCost = extraKM * this.newRestaurant.preorderExtraPerKM;
          deliveryFee = this.newRestaurant.preorderFixFee + extraKMCost;
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("cart getDeliveryFee failed. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      deliveryFee = 6.0;
    }
    // deliveryFee = dp(deliveryFee, 1);
    deliveryFee = deliveryFee;
    return deliveryFee;
  }

  @override
  double getDiscountAmount() {
    double discountAmount = 0.0;
    NewDiscount newDiscount = this.getDiscount();
    try {
      if (newDiscount != null) {
        if (newDiscount.discountType.toLowerCase() == "percentage") {
          discountAmount =
              (this.getSubtotal() * newDiscount.discountAmount) / 100;
        } else if (newDiscount.discountType.toLowerCase() == "cash") {
          discountAmount = newDiscount.discountAmount;
        } else {
          discountAmount = 0.0;
        }
      } else {
        discountAmount = 0.0;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("food card getDiscountAmount hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      discountAmount = 0.0;
    }
    return discountAmount;
  }

  @override
  NewDiscount getDiscount() {
    NewDiscount thiDiscount;
    try {
      for (NewDiscount newDiscount in this.newRestaurant.discounts) {
        if (this.getSubtotal() >= newDiscount.minSpend) {
          if ((this.orderDateTime.isAfter(newDiscount.startDateTime) &&
                  this.orderDateTime.isBefore(newDiscount.endDateTime)) ||
              (this.orderDateTime.isAtSameMomentAs(newDiscount.startDateTime) ||
                  this
                      .orderDateTime
                      .isAtSameMomentAs(newDiscount.endDateTime))) {
            return newDiscount;
          }
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("Food cart getDiscount hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
    return thiDiscount;
  }

  @override
  double getGrantTotal() {
    double total = 0.0;
    total += this.getSubtotal();
    total += this.getServiceFee();
    total += this.getSmallOrderFee();
    total -= this.getDiscountAmount();
    total += this.getDeliveryFee();
    total -= this.getVoucherAmount();
    return total;
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
  void addACloneItem(NewMenuItem newMenuItem) {
    try {
      NewMenuItem clonned = NewMenuItem.initClass();
      clonned.mapTopLocal(newMenuItem);
      this.menuItems.add(clonned);
      hantarrBloc.add(Refresh());
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("addACloneItem hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }

  @override
  Future<void> removeItemFromCart(
      NewMenuItem newMenuItem, BuildContext context) async {
    try {
      int countForThisItem = this.countForThisItem(newMenuItem);
      if (countForThisItem == 1) {
        var confirmation = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Remove ${newMenuItem.name} from cart?"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, 'no');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: themeBloc.state.textTheme.button.copyWith(
                      fontSize: ScreenUtil().setSp(35.0),
                      color: themeBloc.state.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, 'yes');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  color: themeBloc.state.primaryColor,
                  child: Text(
                    "Remove",
                    style: themeBloc.state.textTheme.button.copyWith(
                      fontSize: ScreenUtil().setSp(35.0),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
        if (confirmation == 'yes') {
          this.voucherName = "";
          this.voucherAmount = 0.0;
          this.menuItems.remove(newMenuItem);
          if (this.menuItems.isEmpty) {
            Navigator.popUntil(context, ModalRoute.withName(newRestaurantPage));
          }
        } else {
          return;
        }
      } else {
        this.voucherName = "";
        this.voucherAmount = 0.0;
        this.menuItems.remove(newMenuItem);
      }
      hantarrBloc.add(Refresh());
      return;
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("removeItemFromCart hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }

  @override
  Future<void> applyVoucher(String voucher, BuildContext context) async {
    try {
      Dio dio = getDio(
        baseOption: 1,
        queries: {
          "field": "check_voucher",
          "uuid": hantarrBloc.state.hUser.firebaseUser.uid,
          "voucher": "${voucher.toUpperCase()}",
          "subtotal": this.getSubtotal(),
          "rest_id": this.newRestaurant.id,
        },
      );
      loadingWidget(context);
      Response response = await dio.get("/sales");
      Navigator.pop(context);
      if (response.data['can_use'] == true) {
        // ask user confirmation
        var confirmation = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              title: Icon(
                Icons.warning,
                color: Colors.yellow,
                size: ScreenUtil().setSp(150, allowFontScalingSelf: true),
              ),
              content: Text(
                "Note:\nCurrent discount will be invalid once promo code is applied!",
                style: themeBloc.state.textTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: ScreenUtil().setSp(40),
                  color: Colors.black,
                ),
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, 'no');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: themeBloc.state.textTheme.button.copyWith(
                      fontSize: ScreenUtil().setSp(35.0),
                      color: themeBloc.state.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, 'yes');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  color: themeBloc.state.primaryColor,
                  child: Text(
                    "Proceed",
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
        if (confirmation == "yes") {
          this.voucherName = response.data['voucher']['name'];
          this.voucherAmount = response.data['voucher']['amount'];
          hantarrBloc.add(Refresh());
          BotToast.showText(
            text: "Voucher Applied Successfully",
          );
          Navigator.pop(context);
        } else {
          return;
        }
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
              title: Text("Apply voucher failed"),
              content: Text("${response.data['status']}"),
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
    } catch (e) {
      Navigator.pop(context);
      String msg = getExceptionMsg(e);
      debugPrint("applyVoucher hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Apply voucher error."};
    }
  }

  @override
  double getVoucherAmount() {
    double voucherAMT = 0.0;
    try {
      voucherAMT = this.voucherAmount != null ? this.voucherAmount : 0.0;
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getVoucherAmount hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      voucherAMT = 0.0;
    }
    return voucherAMT;
  }

  @override
  double getServiceFee() {
    double serviceFee = 0.0;
    try {
      if (this.newRestaurant.serviceFeePerOrder > 0) {
        serviceFee = this.newRestaurant?.serviceFeePerOrder;
      } else {
        serviceFee = 0.0;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getServiceFee hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      serviceFee = 0.0;
    }
    return serviceFee;
  }

  @override
  double getSmallOrderFee() {
    double smallorderFee = 0.0;
    try {
      double subtotal = this.getSubtotal();
      if (subtotal < this.newRestaurant?.smallOrderMinAmount ?? 0.0) {
        smallorderFee = this.newRestaurant.smallOrderFee ?? 0.0;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("getSmallOrderFee hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      smallorderFee = 0.0;
    }
    return smallorderFee;
  }

  @override
  void setDeliveryDateTime(DateTime dateTime, TimeOfDay timeOfDay) {
    try {
      if (timeOfDay != null) {
        if (timeOfDay.hour == 0 && timeOfDay.minute == 1) {
          this.isPreorder = false;
          this.preorderDateTime = null;
          this.orderDateTime = hantarrBloc.state.serverTime;
        } else {
          this.isPreorder = true;
          this.orderDateTime = hantarrBloc.state.serverTime;
          this.preorderDateTime = DateTime.tryParse(
              "${dateTime.toString().substring(0, 10)} ${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}");
        }
        hantarrBloc.add(Refresh());
      } else {
        this.isPreorder = true;
        this.preorderDateTime =
            hantarrBloc.state.serverTime.add(Duration(hours: 8));
        this.orderDateTime = hantarrBloc.state.serverTime;
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("setOrderDateTime hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }

  @override
  void initDeliveryDateTime(NewRestaurant tnewRestaurant) {
    DateTime selectedDate;
    TimeOfDay selectedTime;
    try {
      try {
        if (tnewRestaurant.id == this.newRestaurant.id) {
          if (this.newRestaurant.allowPreorder) {
            if (this.newRestaurant.availableDates().isNotEmpty) {
              selectedDate = this.newRestaurant.availableDates().first;
            }
            if (this.newRestaurant.availableTimes(selectedDate).isNotEmpty) {
              selectedTime =
                  this.newRestaurant.availableTimes(selectedDate).first;
            }
          } else {
            selectedDate = hantarrBloc.state.serverTime;
            selectedTime = TimeOfDay(hour: 00, minute: 01); // set this as ASAP
          }

          if (this.newRestaurant.onlyPreorder) {
            this.isPreorder = true;
            if (this.newRestaurant.availableDates().isNotEmpty) {
              selectedDate = this.newRestaurant.availableDates().first;
            }
            if (this.newRestaurant.availableTimes(selectedDate).isNotEmpty) {
              selectedTime =
                  this.newRestaurant.availableTimes(selectedDate).first;
            }
          }

          if (this.newRestaurant.onlyOndemand) {
            this.isPreorder = false;
            selectedDate = hantarrBloc.state.serverTime;
            selectedTime = TimeOfDay(hour: 00, minute: 01); // set this as ASAP
          }
        } else {
          if (tnewRestaurant.allowPreorder) {
            if (tnewRestaurant.availableDates().isNotEmpty) {
              selectedDate = tnewRestaurant.availableDates().first;
            }
            if (tnewRestaurant.availableTimes(selectedDate).isNotEmpty) {
              selectedTime = tnewRestaurant.availableTimes(selectedDate).first;
            }
          } else {
            selectedDate = hantarrBloc.state.serverTime;
            selectedTime = TimeOfDay(hour: 00, minute: 01); // set this as ASAP
          }
        }
      } catch (g) {
        debugPrint("g");
      }
      this.setDeliveryDateTime(selectedDate, selectedTime);
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("initDeliveryDateTime hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }

  @override
  Map<String, dynamic> validateAllItem() {
    try {
      for (NewMenuItem e in this.menuItems) {
        if (e.availability(
                this.isPreorder ? this.preorderDateTime : this.orderDateTime,
                this.isPreorder)['success'] ==
            false) {
          return {
            "success": false,
            "reason":
                "${e.name} not able to place order at date time selected. ${dateFormater(this.isPreorder ? this.preorderDateTime : this.orderDateTime)}"
          };
        } else {
          continue;
        }
      }
      return {"success": true, "data": this};
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validateAllItem hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      // showDialog(
      //   context: context,
      //   child: AlertDialog(
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(
      //         Radius.circular(10.0),
      //       ),
      //     ),
      //     title: Text("Something went wrong"),
      //     actions: [
      //       FlatButton(
      //         onPressed: () {
      //           Navigator.pop(context);
      //         },
      //         child: Text(
      //           "OK",
      //           style: themeBloc.state.textTheme.button.copyWith(
      //             fontWeight: FontWeight.bold,
      //             color: themeBloc.state.primaryColor,
      //             fontSize: ScreenUtil().setSp(30),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // );
      return {"success": false, "reason": "Validate items hit error. $msg"};
    }
  }

  @override
  Map<String, dynamic> validateDeliveryTime() {
    bool validated = false;
    DateTime deliveryDT;
    if (this.isPreorder) {
      deliveryDT = this.preorderDateTime;
    } else {
      deliveryDT = this.orderDateTime;
    }
    try {
      List<NewDeliveryHour> deliveryHours = this
          .newRestaurant
          .deliveryHours
          .where((x) => x.numOfDay == deliveryDT.weekday)
          .toList();
      if (deliveryHours.isNotEmpty) {
        for (NewDeliveryHour dh in deliveryHours) {
          int startTimeInMins = (dh.startTime.hour * 60) + dh.startTime.minute;
          int endTimeInMins = (dh.endTime.hour * 60) + dh.endTime.minute;
          int orderDTInMins = (deliveryDT.hour * 60) + deliveryDT.minute;
          if (orderDTInMins >= startTimeInMins &&
              orderDTInMins <= endTimeInMins) {
            validated = true;
          } else {
            continue;
          }
        }
      } else {
        return {"success": false, "reason": "Not inside delivery time"};
      }

      if (validated) {
        return {"success": true, "data": this};
      } else {
        return {"success": false, "reason": "Not inside delivery time"};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validateDeliveryTime hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "validateDeliveryTime hit error. $msg"
      };
    }
  }

  @override
  Future<void> changeLocation(BuildContext context) async {
    try {
      loadingWidget(context);
      String curLocation = "";
      LatLng curLatLong;
      try {
        var location = new Location();
        await location.requestPermission();
        LocationData currentLocation;
        PermissionStatus permission = await location.hasPermission();
        if (permission == PermissionStatus.granted) {
          currentLocation = await Location().getLocation();
          if (currentLocation != null) {
            curLatLong =
                LatLng(currentLocation.latitude, currentLocation.longitude);
            curLocation = await this.getPlace(
                LatLng(currentLocation.latitude, currentLocation.longitude),
                context);
            hantarrBloc.state.currentLocation =
                LatLng(currentLocation.latitude, currentLocation.longitude);
          }
        }
      } catch (e) {
        BotToast.showText(text: "Get location failed");
      }
      var getAllAddressReq = await AddressInterface().getListAddress();
      Navigator.pop(context);
      if (getAllAddressReq['success']) {
      } else {
        BotToast.showText(
            text: "Get Address List Failed. ${getAllAddressReq['reason']}");
      }

      showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        context: context,
        builder: (BuildContext context) {
          return BlocBuilder<HantarrBloc, HantarrState>(
              bloc: hantarrBloc,
              builder: (BuildContext context, HantarrState state) {
                List<Widget> widgetlist = [];
                Widget headerWidget = ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  trailing: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                );
                widgetlist.add(headerWidget);
                Widget currentLocation = ListTile(
                  onTap: () async {
                    loadingWidget(context);
                    var getDistance =
                        await this.newRestaurant.getDistance(curLatLong);
                    Navigator.pop(context);
                    if (getDistance['success']) {
                      double thisDistance = getDistance['data'] as double;
                      if (thisDistance <= this.newRestaurant.maxKM) {
                        if (hantarrBloc.state.hUser.firebaseUser?.displayName !=
                                null &&
                            hantarrBloc.state.hUser.firebaseUser?.displayName
                                .isNotEmpty) {
                          hantarrBloc.state.foodCart.contactPerson =
                              hantarrBloc.state.hUser.firebaseUser?.displayName;
                        } else {
                          hantarrBloc.state.foodCart.contactPerson = "";
                        }
                        hantarrBloc.state.foodCart.phoneNum =
                            hantarrBloc.state.hUser.firebaseUser.phoneNumber;
                        hantarrBloc.state.foodCart.address = curLocation;
                        hantarrBloc.state.foodCart.latLng = curLatLong;
                        hantarrBloc.add(Refresh());
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        UniqueKey key = UniqueKey();
                        BotToast.showWidget(
                          key: key,
                          toastBuilder: (_) => AlertDialog(
                            title: Text("Cannot deliver to this location"),
                            content: Text("Please choose another location"),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  BotToast.remove(key);
                                },
                                child: Text(
                                  "OK",
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("${getDistance['reason']}"),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  leading: Icon(
                    Icons.location_on,
                  ),
                  title: Text(
                    "Current Location",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      fontSize: ScreenUtil().setSp(30.0),
                      color: Colors.grey[850],
                    ),
                  ),
                  subtitle: Text(
                    "$curLocation",
                    style: themeBloc.state.textTheme.bodyText1.copyWith(
                      fontSize: ScreenUtil().setSp(30.0),
                      color: Colors.grey[850],
                    ),
                  ),
                );
                widgetlist.add(currentLocation);
                widgetlist.add(Divider());

                Widget editSelectedLocationWidget = ListTile(
                  onTap: () async {
                    await hantarrBloc.state.hUser.setLocalOnSelectedAddress(
                        hantarrBloc.state.selectedLocation,
                        hantarrBloc.state.foodCart.address);
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    Icons.location_on,
                    color: themeBloc.state.primaryColor,
                  ),
                  title: Text(
                    "Selected Address",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      inherit: true,
                    ),
                  ),
                  subtitle: Text(
                    "${hantarrBloc.state.foodCart.address.replaceAll("%address%", "")}",
                    style: themeBloc.state.textTheme.subtitle2.copyWith(),
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      String jAddress = "";
                      String jBloc = "";
                      if (hantarrBloc.state.foodCart.address
                              .split("%address%")
                              .length >
                          1) {
                        jAddress = hantarrBloc.state.foodCart.address
                            .split("%address%")[1];
                        jBloc = hantarrBloc.state.foodCart.address
                            .split("%address%")[0];
                      } else {
                        jBloc = "";
                        jAddress = hantarrBloc.state.foodCart.address;
                      }

                      TextEditingController blockCon =
                          TextEditingController(text: jBloc);
                      TextEditingController addCon =
                          TextEditingController(text: jAddress);

                      var result = await showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter state) {
                              return AlertDialog(
                                title: Text("Edit Address"),
                                content: Container(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: TextFormField(
                                            controller: blockCon,
                                            validator: (val) {
                                              if (val
                                                  .replaceAll(" ", "")
                                                  .isEmpty) {
                                                return "Cannot Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText:
                                                  "Company / Building Name",
                                              fillColor: Colors.white,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: .4,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: .4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        ListTile(
                                          title: TextFormField(
                                            controller: addCon,
                                            maxLines: null,
                                            maxLengthEnforced: false,
                                            validator: (val) {
                                              if (val
                                                  .replaceAll(" ", "")
                                                  .isEmpty) {
                                                return "Cannot Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: "Address",
                                              fillColor: Colors.white,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                  width: .4,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: .4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'no');
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: themeBloc.state.primaryColor,
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'yes');
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    color: themeBloc.state.primaryColor,
                                    child: Text(
                                      "OK",
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                      if (result == "yes") {
                        debugPrint(addCon.text);
                        if (addCon.text.replaceAll(" ", "").isNotEmpty ||
                            blockCon.text.replaceAll(" ", "").isNotEmpty) {
                          String merged =
                              "${blockCon.text}%address%${addCon.text}";
                          hantarrBloc.state.foodCart.address = merged;
                          await hantarrBloc.state.hUser
                              .setLocalOnSelectedAddress(
                                  hantarrBloc.state.selectedLocation, merged);
                          hantarrBloc.add(Refresh());
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: Icon(Icons.edit),
                  ),
                );
                widgetlist.add(editSelectedLocationWidget);
                widgetlist.add(Divider());

                hantarrBloc.state.addressList.map(
                  (e) {
                    Widget addTile = ListTile(
                      onTap: () async {
                        loadingWidget(context);
                        var getDistance = await this
                            .newRestaurant
                            .getDistance(LatLng(e.latitude, e.longitude));
                        Navigator.pop(context);
                        if (getDistance['success']) {
                          double thisDistance = getDistance['data'] as double;
                          if (thisDistance <= this.newRestaurant.maxKM) {
                            hantarrBloc.state.foodCart.phoneNum = e.phone;
                            hantarrBloc.state.foodCart.contactPerson =
                                e.receiverName;
                            hantarrBloc.state.foodCart.address = e.address;
                            Navigator.pop(context);
                          } else {
                            UniqueKey key = UniqueKey();
                            BotToast.showWidget(
                              key: key,
                              toastBuilder: (_) => AlertDialog(
                                title: Text("Cannot deliver to this location"),
                                content: Text("Please choose another location"),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      BotToast.remove(key);
                                    },
                                    child: Text(
                                      "OK",
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("${getDistance['reason']}"),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "OK",
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      leading: Icon(e.title.toLowerCase().contains("home")
                          ? Icons.home
                          : e.title.toLowerCase().contains("work")
                              ? Icons.work
                              : Icons.location_on),
                      title: Text(
                        "${e.title}",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: Colors.grey[850],
                        ),
                      ),
                      subtitle: Text(
                        "${e.address}",
                        style: themeBloc.state.textTheme.bodyText1.copyWith(
                          fontSize: ScreenUtil().setSp(30.0),
                          color: Colors.grey[850],
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          if (!e.isFavourite) {
                            // ignore: await_only_futures
                            await e.setAsFavourite();
                          } else {
                            // ignore: await_only_futures
                            await e.removeFavourite();
                          }
                        },
                        icon: Icon(
                          e.isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    );
                    widgetlist.add(addTile);
                    widgetlist.add(Divider());
                  },
                ).toList();

                Widget addAddressWidget = ListTile(
                  onTap: () async {
                    gL.LocationResult _pickedLocation;
                    gL.LocationResult result = await gL.showLocationPicker(
                      context, "AIzaSyCP6DCTU7pUCg-ELswj1bxe1jABsCntkHo",
                      initialCenter: hantarrBloc.state.selectedLocation,
                      automaticallyAnimateToCurrentLocation: false,
//                      mapStylePath: 'assets/mapStyle.json',
                      myLocationButtonEnabled: true,
                      requiredGPS: false,
                      layersButtonEnabled: true,
                      countries: ["MY"],
                      // countries: ['AE', 'NG']
                      resultCardAlignment: Alignment.bottomCenter,
                      desiredAccuracy: gL.LocationAccuracy.best,
                    );
                    print("result = $result");
                    _pickedLocation = result;
                    if (_pickedLocation != null) {
                      loadingWidget(context);
                      var getDistance = await this
                          .newRestaurant
                          .getDistance(_pickedLocation.latLng);
                      Navigator.pop(context);
                      if (getDistance['success']) {
                        double thisDistance = getDistance['data'] as double;
                        if (thisDistance <= this.newRestaurant.maxKM) {
                          hantarrBloc.state.selectedLocation =
                              _pickedLocation.latLng;
                          hantarrBloc.state.foodCart.address =
                              _pickedLocation.address != null
                                  ? "${_pickedLocation.address}"
                                  : await this.getPlace(
                                      _pickedLocation.latLng, context);
                          if (hantarrBloc
                                      .state.hUser.firebaseUser?.displayName !=
                                  null &&
                              hantarrBloc.state.hUser.firebaseUser?.displayName
                                  .isNotEmpty) {
                            hantarrBloc.state.foodCart.contactPerson =
                                hantarrBloc
                                    .state.hUser.firebaseUser?.displayName;
                          } else {
                            hantarrBloc.state.foodCart.contactPerson = "";
                          }
                          hantarrBloc.state.foodCart.phoneNum =
                              hantarrBloc.state.hUser.firebaseUser.phoneNumber;
                          hantarrBloc.add(Refresh());
                          Navigator.pop(context);
                        } else {
                          UniqueKey key = UniqueKey();
                          BotToast.showWidget(
                            key: key,
                            toastBuilder: (_) => AlertDialog(
                              title: Text("Cannot deliver to this location"),
                              content: Text("Please choose another location"),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    BotToast.remove(key);
                                  },
                                  child: Text(
                                    "OK",
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("${getDistance['reason']}"),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "OK",
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  leading: Icon(
                    Icons.add,
                    color: themeBloc.state.primaryColor,
                  ),
                  title: Text(
                    "Use another address",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      fontSize: ScreenUtil().setSp(30.0),
                      color: themeBloc.state.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: themeBloc.state.primaryColor,
                  ),
                );
                widgetlist.add(addAddressWidget);

                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter state) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: widgetlist,
                      ),
                    );
                  },
                );
              });
        },
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("changeLocation hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }

  Future<String> getPlace(LatLng latLng, BuildContext context) async {
    String thisAddress = "";
    try {
      if (latLng != null) {
        // List<geo.Placemark> newPlace = await geo.placemarkFromCoordinates(
        //   latLng.latitude,
        //   latLng.longitude,
        // );
        // // this is all you need
        // geo.Placemark placeMark = newPlace[0];
        // String name = placeMark.name;
        // String jalanName = placeMark.thoroughfare;
        // String subLocality = placeMark.subLocality;
        // String locality = placeMark.locality;
        // String postalCode = placeMark.postalCode;
        // String administrativeArea = placeMark.administrativeArea;
        // // String postalCode = placeMark.postalCode;
        // // String country = placeMark.country;
        // thisAddress =
        //     "$name, $subLocality, $jalanName, $postalCode $locality, $administrativeArea";
        // // print(hantarrBloc.state.foodCart.address);
        thisAddress =
            await geoDecode(LatLng(latLng.latitude, latLng.longitude));
      } else {
        print("getting location");
        await Navigator.pushNamed(context, getlocationPage);
      }
    } catch (e) {
      print("get locaton failed. ${e.toString()}");
    }
    return thisAddress;
  }

  @override
  Map<String, dynamic> validateDeliveryDistance() {
    try {
      if (this.newRestaurant.distance <= this.newRestaurant.maxKM) {
        return {"success": true, "data": this};
      } else {
        return {
          "success": false,
          "reason":
              "Exceed max km allowed. (Max km: ${this.newRestaurant.maxKM.toStringAsFixed(2)} km)"
        };
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validateDeliveryDistance hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "validateDeliveryDistance hit error. $msg"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> validateCreditAmount() async {
    try {
      if (this.paymentMethod == "Credit" ||
          this.paymentMethod == paymentMethods[1]) {
        double grandTotal = this.getGrantTotal();
        if (hantarrBloc.state.hUser.creditBalance < grandTotal) {
          return {
            "success": false,
            "reason": "Insufficient credit balance. Please top up to proceed."
          };
        } else {
          return {"success": true, "data": this};
        }
      } else {
        return {"success": true, "data": this};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validateCreditAmount hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "Validate Credit Amount hit error. $msg"
      };
    }
  }

  @override
  Map<String, dynamic> validatePhoneNumber() {
    try {
      if (this.phoneNum.length >= 9) {
        return {"success": true, "data": this.phoneNum};
      } else {
        return {
          "success": false,
          "reason": "Please enter a valid phone number. eg. 0123456789"
        };
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validatePhoneNumber hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "Validate Phone Number hit error. $msg"
      };
    }
  }

  @override
  Map<String, dynamic> validateReceiverName() {
    try {
      if (this.contactPerson.length > 0) {
        return {"success": true, "data": this.phoneNum};
      } else {
        return {"success": false, "reason": "Please input a receiver name"};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validatePhoneNumber hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "Validate Receiver Name hit error. $msg"
      };
    }
  }

  @override
  Map<String, dynamic> validateAddress() {
    try {
      if (this.address == null) {
        // this.address = hantarrBloc.state.
        this.address = "";
      }

      if (this.address.isNotEmpty) {
        if (this.address.length < 15) {
          return {
            "success": false,
            "reason": "Please input valid address. At least 15 character"
          };
        } else {
          return {"success": true, "data": this.address};
        }
      } else {
        return {"success": false, "reason": "Please input address"};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validateAddress hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Validate Address hit error. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> payloadToSend() async {
    try {
      if (this.orderDateTime == null) {
        this.orderDateTime = hantarrBloc.state.serverTime;
      }

      int index = 0;
      List<Map<String, dynamic>> menuitemsMap = [];
      for (NewMenuItem menuItem in this.menuItems) {
        menuitemsMap.add(menuItem.payloadForCheckout(index));
        index += 1;
      }

      double cmpDistance = 0.0;
      // ZoneDetail selectedZone;
      // for (ZoneDetail zd in hantarrBloc.state.zoneDetailList) {
      //   Dio dio = getDio(
      //     baseOption: 1,
      //     queries: {},
      //   );
      //   dio.options.baseUrl = "http://map.resertech.com:5000";
      //   Response response = await dio.get(
      //       "/route/v1/driving/${this.newRestaurant.longitude},${this.newRestaurant.latitude};${zd.longitude},${zd.latitude}?overview=false");
      //   Map<String, dynamic> data = response.data;
      //   if (cmpDistance == 0.0) {
      //     if ((zd.deliveryMaxKM * 1000) > data["routes"].first["distance"]) {
      //       selectedZone = zd;
      //       try {
      //         cmpDistance = data["routes"].first["distance"];
      //       } catch (e) {
      //         cmpDistance =
      //             num.tryParse(data["routes"].first["distance"].toString())
      //                 .toDouble();
      //       }
      //       break;
      //     }
      //   } else if (data["routes"].first["distance"] < cmpDistance) {
      //     if ((zd.deliveryMaxKM * 1000) > data["routes"].first["distance"]) {
      //       selectedZone = zd;
      //       try {
      //         cmpDistance = data["routes"].first["distance"];
      //       } catch (e) {
      //         cmpDistance =
      //             num.tryParse(data["routes"].first["distance"].toString())
      //                 .toDouble();
      //       }
      //       break;
      //     }
      //   }
      // }

      print(hantarrBloc.state.addressList.length);

      return {
        "success": true,
        "data": {
          "test": false,
          "state": this.newRestaurant.state,
          "area": this.newRestaurant.area,
          "user_uuid": hantarrBloc.state.hUser.firebaseUser.uid,
          "app_os": Platform.isAndroid ? "Android" : "IOS",
          "app_version": hantarrBloc.state.versionName,
          "summary": {
            "delivery_method": this.deliveryMethod,
            // "delivery_method": "self pickup",
            "preorder_delivery_datetime": this.preorderDateTime != null
                ? this.preorderDateTime.toString()
                : null,
            "is_preorder": this.isPreorder,
            "fromFoodCourt":
                this.newRestaurant.stalls.isNotEmpty ? true : false,
            "rest_id": this.newRestaurant.id,
            "res_code": this.newRestaurant.code,
            "patron": {
              "patron_address_id": this.addressID,
              "name":
                  this.contactPerson != null && this.contactPerson.isNotEmpty
                      ? this.contactPerson
                      : hantarrBloc.state.hUser.firebaseUser?.displayName,
              "uuid": hantarrBloc.state.hUser.firebaseUser.uid,
              "phone": this.phoneNum != null && this.phoneNum.isNotEmpty
                  ? this.phoneNum
                  : hantarrBloc.state.hUser.firebaseUser.phoneNumber,
              "address": this.address,
              "longitude": hantarrBloc.state.selectedLocation.longitude,
              "latitude": hantarrBloc.state.selectedLocation.latitude
            },
            "menuItem": menuitemsMap,
            "payment": {
              "subtotal": this.getSubtotal(),
              "delivery_fee": this.getDeliveryFee(),
              "service_fee_per_order": this.getServiceFee(),
              "small_order_fee": this.getSmallOrderFee(),
              "method": this.paymentMethod == paymentMethods[0]
                  ? "cash_on_delivery"
                  : this.paymentMethod,
              "discount_description": this.getDiscount() != null
                  ? this.getDiscount().description
                  : null,
              "discount_name":
                  this.getDiscount() != null ? this.getDiscount().name : null,
              "discounted_amount": this.getDiscountAmount(),
              "voucher_name": this.voucherName,
              "voucher_amount": this.getVoucherAmount(),
            },
            "date":
                "${this.orderDateTime.year}-${this.orderDateTime.month}-${this.orderDateTime.day}",
            "datetime": "${this.orderDateTime.toString()}",
            // "delivery_max_km": null,
            // "delivery_cost_price": null,
            // "delivery_extra_per_km_cost": null,
            // "delivery_default_coverage": null,
            "duration": this.newRestaurant.prepareTime,
            "delivery_max_km": this.newRestaurant.maxKM,
            "delivery_cost_price": this.newRestaurant.fixFee,
            "delivery_extra_per_km_cost": this.newRestaurant.extraPerKM,
            "delivery_default_coverage": this.newRestaurant.defaultKM,
          }
        }
      };
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
        "reason": "Generate payload to send hit error. $msg"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> validateAll() async {
    try {
      List<Map<String, dynamic>> validations = [
        this.validateAllItem(),
        this.validateDeliveryTime(),
        this.validateDeliveryDistance(),
        await this.validateCreditAmount(),
        this.validatePhoneNumber(),
        this.validateReceiverName(),
        this.validateAddress(),
        this.validateSubtotalPrice(),
      ];
      for (Map<String, dynamic> validatedResult in validations) {
        if (validatedResult['success'] == false) {
          return validatedResult;
        } else {
          continue;
        }
      }
      return {"success": true, "data": this};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Validate checkout failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> createNewFoodOrder(
      {@required String remarks}) async {
    try {
      var getPayload = await this.payloadToSend();
      if (getPayload['success']) {
        Map<String, dynamic> data = getPayload['data'];
        data['order_remark'] = remarks;
        Dio dio = getDio(queries: {}, baseOption: 1);
        Response response = await dio.post(
          "/${hantarrBloc.state.hUser.firebaseUser.uid}/delivery",
          data: data,
        );
        if (response.data['delivery_id'] != null) {
          // await FirebaseAnalytics()
          //     .logEvent(name: "checkout_food_order", parameters: {
          //   "subtotal": this.getSubtotal(),
          //   "grant_total": this.getGrantTotal(),
          //   "discount_amount": this.getDiscountAmount(),
          //   // "discount":
          //   //     this.getDiscount() != null ? this.getDiscount().name : null,
          //   "currency": this.newRestaurant.currencyCode.isNotEmpty
          //       ? this.newRestaurant.currencyCode
          //       : "MYR",
          //   "transactionId": response.data['delivery_id'],
          // });
          // if (this.paymentMethod == paymentMethods[1]) {
          //   hantarrBloc.state.hUser.creditBalance -= this.getGrantTotal();
          // }

          NewFoodDelivery newFoodDelivery = NewFoodDelivery()
              .foodCartToDelivery(response.data['delivery_id'], this);
          if (hantarrBloc.state.pendingFoodOrders
              .where((x) => x.id == newFoodDelivery.id)
              .isEmpty) {
            hantarrBloc.state.pendingFoodOrders.add(newFoodDelivery);
          }
          hantarrBloc.state.hUser.creditBalance =
              num.tryParse(response.data['patron']['total'].toString())
                  .toDouble();
          await Future.delayed(Duration(seconds: 2), () async {
            await NewFoodDelivery().getPendingDelivery();
            await hantarrBloc.state.hUser.getUserData();
          });
          hantarrBloc.add(Refresh());
          return {"success": true, "data": newFoodDelivery};
        } else {
          hantarrBloc.state.foodCheckoutErrorMsg = "${response.data["reason"]}";
          hantarrBloc.state.foodCheckoutPageLoading = false;
          return {"success": false, "reason": "${response.data["reason"]}"};
        }
      } else {
        return getPayload;
      }
    } catch (e) {
      print(e.toString());
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      hantarrBloc.state.foodCheckoutErrorMsg = "$msg";
      hantarrBloc.state.foodCheckoutPageLoading = false;
      hantarrBloc.add(Refresh());
      return {
        "success": false,
        "reason": "Create New Food Order hit error. $msg"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentTime() async {
    var getTimeReq = await hantarrBloc.state.hUser.getCurrentTime();
    if (getTimeReq['success']) {
      this.orderDateTime = getTimeReq['data'];
    }
    return getTimeReq;
  }

  @override
  Map<String, dynamic> validateSubtotalPrice() {
    try {
      if (this.getSubtotal() >= this.newRestaurant.minOrderValue) {
        return {"success": true, "data": this.getSubtotal()};
      } else {
        return {
          "success": false,
          "reason":
              "Minimum order valid is RM ${this.newRestaurant.minOrderValue.toStringAsFixed(2)}"
        };
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validatePhoneNumber hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "Validate Receiver Name hit error. $msg"
      };
    }
  }

  @override
  Future<void> removeAllThisItemFromCart(
      NewMenuItem newMenuItem, BuildContext context) async {
    try {
      var confirmation = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Remove ${newMenuItem.name} from cart?"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, 'no');
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: themeBloc.state.textTheme.button.copyWith(
                    fontSize: ScreenUtil().setSp(35.0),
                    color: themeBloc.state.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, 'yes');
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                color: themeBloc.state.primaryColor,
                child: Text(
                  "Remove",
                  style: themeBloc.state.textTheme.button.copyWith(
                    fontSize: ScreenUtil().setSp(35.0),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (confirmation == 'yes') {
        this.voucherName = "";
        this.voucherAmount = 0.0;
        this.menuItems.removeWhere((x) => x.id == newMenuItem.id);
        if (this.menuItems.isEmpty) {
          Navigator.popUntil(context, ModalRoute.withName(newRestaurantPage));
        }
      } else {
        return;
      }

      hantarrBloc.add(Refresh());
      return;
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("removeItemFromCart hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }

  @override
  Map<String, dynamic> validateBindedphone() {
    try {
      if (hantarrBloc.state.hUser.firebaseUser == null) {
        return {"success": false, "reason": "Please login first"};
      } else {
        if (hantarrBloc.state.hUser.firebaseUser.phoneNumber == null ||
            hantarrBloc.state.hUser.firebaseUser.phoneNumber == "") {
          return {
            "success": false,
            "reason": "Please bind to phone number first."
          };
        } else {
          return {
            "success": true,
            "data": hantarrBloc.state.hUser.firebaseUser.phoneNumber
          };
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("validateBindedphone hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "Please bind to phone number first. $msg"
      };
    }
  }

  @override
  List<Map<String, dynamic>> wizardPages(
      {@required TextEditingController remarksCon}) {
    List<Map<String, dynamic>> pageList = [
      {
        "title": "Contact Info",
        "widget": ContactInfoPage(),
        "onPressed": () {
          try {
            var validaContactInfoReq = this.validateContactInfo();
            if (validaContactInfoReq['success']) {
              return true;
            } else {
              BotToast.showText(
                  text: "${validaContactInfoReq["reason"]}",
                  duration: Duration(seconds: 3));
              return false;
            }
          } catch (e) {
            print(e.toString());
            return false;
          }
        }
      },
      {
        "title": "${this.newRestaurant.name}",
        "widget": PaymentMethodPage(
          remarksCon: remarksCon,
        ),
        "onPressed": (hantarrBloc.state.foodCheckoutPageLoading == false &&
                hantarrBloc.state.foodCheckoutErrorMsg.isEmpty)
            ? () {
                debugPrint("function inside wizard root page");
              }
            : () async {
                await this.getDistance();
              }
      },
    ];
    return pageList;
  }

  @override
  Future<void> getDistance() async {
    hantarrBloc.state.foodCheckoutPageLoading = true;
    hantarrBloc.state.foodCheckoutErrorMsg = "";
    hantarrBloc.add(Refresh());
    var getResDistanceReq = await hantarrBloc.state.foodCart.newRestaurant
        .getDistance(hantarrBloc.state.selectedLocation);
    debugPrint("getting distance price");
    if (getResDistanceReq['success']) {
      hantarrBloc.state.foodCheckoutPageLoading = false;
      hantarrBloc.state.foodCheckoutErrorMsg = "";
      hantarrBloc.add(Refresh());
    } else {
      hantarrBloc.state.foodCheckoutPageLoading = false;
      hantarrBloc.state.foodCheckoutErrorMsg = "${getResDistanceReq['reason']}";
      hantarrBloc.add(Refresh());
    }
  }

  @override
  Map<String, dynamic> validateContactInfo() {
    try {
      List<Map<String, dynamic>> validations = [
        this.validatePhoneNumber(),
        this.validateReceiverName(),
        this.validateAddress(),
      ];
      for (Map<String, dynamic> validatedResult in validations) {
        if (validatedResult['success'] == false) {
          return validatedResult;
        } else {
          continue;
        }
      }
      return {"success": true, "data": this};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Validate checkout failed. $msg"};
    }
  }
}
