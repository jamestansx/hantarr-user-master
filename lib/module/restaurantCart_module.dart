import 'dart:async';
import 'package:hantarr/module/user_module.dart' as hantarrUser;
import 'package:hantarr/packageUrl.dart';

class RestaurantCart {
  List<MenuItem> menuItems;
  Restaurant restaurant;
  Map summaryMap;
  double subTotal;
  double deliveryFee;
  ZoneDetail currentZoneDetail;
  String preOrderDateTime;

  RestaurantCart(
      {this.menuItems,
      this.restaurant,
      this.summaryMap,
      this.subTotal,
      this.deliveryFee,
      this.currentZoneDetail,
      this.preOrderDateTime});

  Map<String, dynamic> checkItemAvailability(
      BuildContext context, DateTime currentDT, Restaurant restaurant) {
    // String dateTime = hantarrBloc.state.user.restaurantCart.preOrderDateTime;
    bool containDisableItem = false;
    String itemCode = "";
    for (MenuItem menuItem in hantarrBloc.state.user.restaurantCart.menuItems) {
      if (!menuItem.allowAddToCard(restaurant, currentDT)) {
        if (itemCode == "") {
          itemCode += menuItem.name.split(" ").first;
        } else {
          itemCode += ",";
          itemCode += menuItem.name.split(" ").first;
        }
        containDisableItem = true;
      }
    }

    if (containDisableItem) {
      return {
        "success": false,
        "reason": AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
          ),
          title: Container(
            height: 100,
            width: 100,
            child: Image.asset("assets/warning.png"),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Selected delivery time not available for $itemCode please remove them to continue.",
                // presetFontSizes: [12],

                style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                // textAlign: TextAlign.center,
              ),
              SizedBox(
                height: ScreenUtil().setHeight(20),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                    color: themeBloc.state.primaryColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Back",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(33),
                        color: Colors.white,
                      ),
                    )),
              )
            ],
          ),
        )
      };
    } else {
      return {"success": true};
    }
  }

  Future<String> checkout(
      double grandTotal,
      double subtotal,
      double discountAmount,
      double voucherAmount,
      double deliveryFeeAmount,
      String paymentMethod,
      String voucherName,
      Discount discount) async {
    try {
      List<Map> menuMap = this.restaurant.menuItemToMapList(this.menuItems);
      DateTime dateTime = await hantarrUser.User().getCurrentTime();
      Map allMap = {
        "delivery_method": "delivery",
        // "delivery_method": "self pickup",
        "preorder_delivery_datetime": this.preOrderDateTime,
        "is_preorder": this.preOrderDateTime.isEmpty ? false : true,
        "fromFoodCourt": this.restaurant.stalls.isNotEmpty ? true : false,
        "rest_id": this.restaurant.id,
        "res_code": this.restaurant.code,
        "patron": {
          "patron_address_id": hantarrBloc.state.user.currentContactInfo.id,
          "name": hantarrBloc.state.user.currentContactInfo.name,
          "uuid": hantarrBloc.state.user.uuid,
          "phone": hantarrBloc.state.user.currentContactInfo.phone,
          "address": hantarrBloc.state.user.currentContactInfo.address,
          "longitude": hantarrBloc.state.user.currentContactInfo.longitude,
          "latitude": hantarrBloc.state.user.currentContactInfo.latitude
        },
        "menuItem": menuMap,
        "payment": {
          "subtotal": subtotal,
          "delivery_fee": deliveryFeeAmount,
          "method": paymentMethod.contains("Cash")
              ? "cash_on_delivery"
              : paymentMethod,
          "discount_description": discount != null ? discount.desc : null,
          "discount_name": discount != null ? discount.name : null,
          "discounted_amount": discountAmount,
          "voucher_name": voucherName,
          "voucher_amount": voucherAmount
        },
        "date": "${dateTime.year}-${dateTime.month}-${dateTime.day}",
        "datetime": "${dateTime.toString()}",
        // "delivery_max_km": null,
        // "delivery_cost_price": null,
        // "delivery_extra_per_km_cost": null,
        // "delivery_default_coverage": null,
        "duration": this.restaurant.prepareTime,
      };
      this.summaryMap = allMap;
      this.deliveryFee = deliveryFee;
      this.subTotal = subtotal;

      hantarrBloc.state.user.currentDelivery = Delivery(
          // method: "self pickup",
          method: "delivery",
          isPreOrder: this.preOrderDateTime.isEmpty ? false : true,
          preOrderDateTime: this.preOrderDateTime,
          date: "${dateTime.year}-${dateTime.month}-${dateTime.day}",
          datetime: "${dateTime.toString()}",
          deliveryStatus: DeliveryStatus(
              pickUp: false,
              foodPrepared: false,
              riderReceived: false,
              restaurantReceived: false,
              delivered: false),
          menuItem: this.menuItems,
          restaurant: this.restaurant,
          deliveryFee: deliveryFee,
          subTotal: subtotal,
          discountAmount: discountAmount,
          voucherAmount: voucherAmount,
          contactInfo: hantarrBloc.state.user.currentContactInfo,
          eta: this.restaurant.prepareTime.toString());
      double cmpDistance = 0.0;
      for (ZoneDetail zd in hantarrBloc.state.zoneDetailList) {
        var result;

        result = await get(Uri.tryParse(
            "http://map.resertech.com:5000/route/v1/driving/${this.restaurant.longitude},${this.restaurant.latitude};${zd.longitude},${zd.latitude}?overview=false"));

        Map data = json.decode(result.body);
        if (cmpDistance == 0.0) {
          if ((zd.deliveryMaxKM * 1000) > data["routes"].first["distance"]) {
            this.currentZoneDetail = zd;
            try {
              cmpDistance = data["routes"].first["distance"];
            } catch (e) {
              cmpDistance =
                  num.tryParse(data["routes"].first["distance"].toString())
                      .toDouble();
            }
          }
        } else if (data["routes"].first["distance"] < cmpDistance) {
          if ((zd.deliveryMaxKM * 1000) > data["routes"].first["distance"]) {
            this.currentZoneDetail = zd;
            try {
              cmpDistance = data["routes"].first["distance"];
            } catch (e) {
              cmpDistance =
                  num.tryParse(data["routes"].first["distance"].toString())
                      .toDouble();
            }
          }
        }
      }
      this.summaryMap["delivery_max_km"] = this.currentZoneDetail.deliveryMaxKM;
      this.summaryMap["delivery_cost_price"] =
          this.currentZoneDetail.deliveryCostPrice;
      this.summaryMap["delivery_extra_per_km_cost"] =
          this.currentZoneDetail.extraCostPerKM;
      this.summaryMap["delivery_default_coverage"] =
          this.currentZoneDetail.deliveryDefaultKm;
      Map tobeSend = {
        "test": false,
        "state": this.currentZoneDetail.state,
        "area": this.currentZoneDetail.area,
        "user_uuid": hantarrBloc.state.user.uuid,
        "summary": this.summaryMap
      };
      var response = await post(
          Uri.tryParse("$foodUrl/${hantarrBloc.state.user.uuid}/delivery"),
          body: jsonEncode(tobeSend),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
      Map responseMap = jsonDecode(response.body);
      if (responseMap["reason"] == null) {
        hantarrBloc.state.user.credit = responseMap["patron"]["total"];
        if (responseMap["payload"]["summary"]["is_preorder"]) {
          // meed to do preorder ui
          hantarrBloc.state.user.currentDelivery.id =
              responseMap["delivery_id"];
          hantarrBloc.state.user.currentDelivery.paymentMethod = paymentMethod;
          hantarrBloc.state.user.currentDelivery.deliveryStatus
              .restaurantReceived = true;
          if (hantarrBloc.state.user.allDelivery == null) {
            hantarrBloc.state.user.allDelivery = [];
          }
          hantarrBloc.state.user.allDelivery
              .add(hantarrBloc.state.user.currentDelivery.clone());
          Timer(Duration(milliseconds: 500), () {
            hantarrBloc.state.user.restaurantCart =
                RestaurantCart(menuItems: []);
            hantarrBloc.add(Refresh());
          });
          return "preorder success";
        } else {
          hantarrBloc.state.user.currentDelivery.id =
              responseMap["delivery_id"];
          hantarrBloc.state.user.currentDelivery.paymentMethod = paymentMethod;
          hantarrBloc.state.allDeliveries
              .add(hantarrBloc.state.user.currentDelivery.clone());
          Timer(Duration(milliseconds: 500), () {
            hantarrBloc.state.user.restaurantCart =
                RestaurantCart(menuItems: []);
            hantarrBloc.add(Refresh());
          });
          return "success";
        }
      } else {
        return responseMap["reason"];
      }
    } catch (e) {
      // BotToast.showText(text: "Error. ${e.toString()}");
      String message = "";
      try {
        message = e.message;
      } catch (b) {}
      return "Error. $message";
    }
  }
}
