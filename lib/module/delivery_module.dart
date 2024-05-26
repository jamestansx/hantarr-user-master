import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

class Delivery {
  DeliveryStatus deliveryStatus;
  int id;
  List<MenuItem> menuItem;
  Restaurant restaurant;
  String date;
  String datetime;
  double subTotal;
  double deliveryFee;
  Rider rider;
  ContactInfo contactInfo;
  String eta;
  String pickupDateTime;
  String deliveredDateTime;
  String preOrderDateTime;
  bool isPreOrder;
  String method;
  String paymentMethod;
  String discountName;
  String discountDesc;
  double discountAmount;
  String voucherName;
  double voucherAmount;

  Delivery(
      {this.deliveryStatus,
      this.id,
      this.menuItem,
      this.restaurant,
      this.date,
      this.datetime,
      this.subTotal,
      this.deliveryFee,
      this.rider,
      this.contactInfo,
      this.eta,
      this.pickupDateTime,
      this.deliveredDateTime,
      this.isPreOrder,
      this.preOrderDateTime,
      this.method,
      this.paymentMethod,
      this.discountAmount,
      this.discountDesc,
      this.discountName,
      this.voucherAmount,
      this.voucherName});

  Delivery clone() {
    return Delivery(
        deliveryStatus: this.deliveryStatus.newClass(),
        id: this.id,
        menuItem: this.menuItem,
        restaurant: this.restaurant,
        date: this.date,
        datetime: this.datetime,
        subTotal: this.subTotal,
        deliveryFee: this.deliveryFee,
        rider: this.rider,
        contactInfo: this.contactInfo,
        eta: this.eta,
        pickupDateTime: this.pickupDateTime,
        deliveredDateTime: this.deliveredDateTime,
        preOrderDateTime: this.preOrderDateTime,
        isPreOrder: this.isPreOrder,
        method: this.method,
        paymentMethod: this.paymentMethod,
        discountAmount: this.discountAmount,
        discountDesc: this.discountDesc,
        discountName: this.discountName,
        voucherAmount: this.voucherAmount,
        voucherName: this.voucherName);
  }

  Delivery fromJson(Map data) {
    if (hantarrBloc.state.allDeliveries
        .any((x) => x.id == data["delivery_id"])) {
      hantarrBloc.state.allDeliveries
          .removeWhere((x) => x.id == data["delivery_id"]);
    }
    Restaurant res = new Restaurant(
        id: data["restaurant"]["id"],
        name: data["restaurant"]["name"],
        code: data["restaurant"]["code"],
        latitude: data["restaurant"]["lat"],
        longitude: data["restaurant"]["long"],
        rating: num.tryParse(data["restaurant"]["rate"].toString()).toDouble(),
        area: data["restaurant"]["area"],
        state: data["restaurant"]["state"],
        address: data["restaurant"]["address"],
        individualPrepareTime:
            num.tryParse(data["restaurant"]["preparation_time"]).toInt(),
        bannerImage: data["restaurant"]["image_url"]);
    Map menuitems = {"menu_items": json.decode(data["json_items"])};

    List<MenuItem> menuItemList = [];
    for (Map miData in menuitems["menu_items"]) {
      MenuItem ttItem = MenuItem().fromJson(miData, data["restaurant"]["id"]);
      if (ttItem != null) {
        menuItemList.add(ttItem);
      } else {
        print("exception menuitem");
      }
    }
    ContactInfo contactInfo = ContactInfo(
        id: data["id"],
        name: data["customer_name"],
        address: data["to"],
        phone: data["customer_phone"],
        latitude: data["customer_lat"] == null
            ? null
            : data["customer_lat"].toString(),
        longitude: data["customer_long"] == null
            ? null
            : data["customer_long"].toString());
    Delivery delivery = Delivery(
        method: data["delivery_method"],
        isPreOrder: data["is_preorder"],
        preOrderDateTime: data["preorder_deliver_datetime"],
        id: data["delivery_id"],
        pickupDateTime: data["pickup_time"],
        deliveredDateTime: data["arrive_time"],
        eta: data["duration"],
        restaurant: res,
        menuItem: menuItemList,
        date: data["date"],
        datetime: data["datetime"],
        discountName:
            data["discount_name"] == null ? "" : data["discount_name"],
        voucherName: data["voucher_name"] == null ? "" : data["voucher_name"],
        discountAmount: data["discounted_amount"] == null
            ? 0.00
            : num.tryParse(data["discounted_amount"]).toDouble(),
        voucherAmount: data["voucher_amount"] == null
            ? 0.00
            : num.tryParse(data["voucher_amount"]).toDouble(),
        subTotal: num.tryParse(data["subtotal"]).toDouble(),
        deliveryFee: num.tryParse(data["delivery_fee"]).toDouble(),
        deliveryStatus: DeliveryStatus(
          delivered: data["status"] == "Done" ? true : false,
          pickUp: data["pickup"],
          restaurantReceived: data["rest_rec"],
          riderReceived: data["rider_rec"],
          canceled: data["status"].toLowerCase() == "cancel" ? true : false,
          acceptFailedByRestaurant:
              data["status"].toLowerCase() == "failed" ? true : false,
          noRider: data["status"].toLowerCase() == "no rider" ? true : false,
          status: data['status'] != null ? data['status'] : "",
        ),
        rider: Rider(id: data["rider_id"].toString()),
        contactInfo: contactInfo,
        paymentMethod: data["payment_method"].toLowerCase().contains("cash")
            ? "Cash On Delivery"
            : "Credit");
    return delivery;
  }

  Future getPendingOrder() async {
    try {
      print("getting pending orders");
      var response = await get(Uri.tryParse(
          "$foodUrl/patron_delivery/${hantarrBloc.state.hUser.firebaseUser.uid}?status=undone"));
      if (response.body != "") {
        Map payload = jsonDecode(response.body);
        if (payload["user_uuid"] == hantarrBloc.state.user.uuid) {
          for (Map data in payload["delivery"]) {
            if (data["delivery_fee"] != null) {
              try {
                Delivery delivery = fromJson(data);
                if (!hantarrBloc.state.allDeliveries
                    .any((element) => element.id == delivery.id)) {
                  hantarrBloc.state.allDeliveries.add(delivery);
                }
                if (hantarrBloc.state.user.currentDelivery != null) {
                  if (hantarrBloc.state.user.currentDelivery.id ==
                      delivery.id) {
                    hantarrBloc.state.user.currentDelivery = delivery;
                  }
                }
              } catch (q) {
                print(q.toString());
              }
            }
          }
          hantarrBloc.add(Refresh());
        }
        hantarrBloc.state.pendingOrders = List<Delivery>.from(hantarrBloc
            .state.allDeliveries
            .where((x) =>
                x.deliveryStatus.delivered == false &&
                x.deliveryStatus.canceled == false)
            .toList());
        hantarrBloc.add(Refresh());
      }
      return {
        "success": true,
        "data": List<Delivery>.from(hantarrBloc.state.allDeliveries)
      };
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      BotToast.showText(text: "Error on getting pending orders. $msg");
      return {"success": false, "reason": "Get pending orders failed. $msg"};
    }
  }

  Future getDoneOrder() async {
    try {
      var response = await get(Uri.tryParse(
          "$foodUrl/patron_delivery/${hantarrBloc.state.user.uuid}?status=Done"));
      if (response.body != "") {
        Map payload = jsonDecode(response.body);
        if (payload["user_uuid"] == hantarrBloc.state.user.uuid) {
          for (Map data in payload["delivery"]) {
            if (data["delivery_fee"] != null) {
              Delivery delivery = fromJson(data);
              if (!hantarrBloc.state.allDeliveries
                  .any((element) => element.id == delivery.id)) {
                hantarrBloc.state.allDeliveries.add(delivery);
              }
            }
          }
          hantarrBloc.add(Refresh());
        }
      }
    } catch (e) {
      BotToast.showText(
          text: "Error on getting history orders. ${e.toString()}");
    }
  }

  Future<bool> getDeliveryStatus() async {
    var response = await get(Uri.tryParse(
        "$foodUrl/delivery_status/${hantarrBloc.state.user.currentDelivery.id}"));
    if (response.statusCode == 200) {
      Map map = jsonDecode(response.body);
      print(map);
      hantarrBloc.state.user.currentDelivery.rider.longitude =
          map["data"]["map"]["geometry"]["coordinates"].first.toString();
      hantarrBloc.state.user.currentDelivery.rider.latitude =
          map["data"]["map"]["geometry"]["coordinates"].last.toString();
      hantarrBloc.state.user.currentDelivery.rider.name =
          map["data"]["rider"]["name"];
      hantarrBloc.add(Refresh());
      return true;
    } else {
      return false;
    }
  }
}
