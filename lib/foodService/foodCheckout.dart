import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:hantarr/foodService/chooseAddress.dart';
import 'package:hantarr/module/preorderDeliveryFee_module.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/module/user_module.dart' as hantarrUser;
import 'discountTileWidgets/discountTile.dart';

// ignore: must_be_immutable
class FoodCheckout extends StatefulWidget {
  Restaurant restaurant;
  FoodCheckout({Key key, @required this.restaurant}) : super(key: key);

  @override
  _FoodCheckoutState createState() => _FoodCheckoutState();
}

class _FoodCheckoutState extends State<FoodCheckout> {
  RestaurantCart restaurantCart;
  double subtotal = 0.00,
      discountAmount = 0.00,
      voucherAmount = 0.00,
      deliveryFee = 0.00,
      grandTotal = 0.00;
  String voucherName = "";
  Discount discount;
  Map vouchermap;
  String paymentMethod;

  @override
  void initState() {
    restaurantCart = hantarrBloc.state.user.restaurantCart;
    discount = widget.restaurant.discounts.isNotEmpty
        ? widget.restaurant.discounts.first
        : null;
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      if (widget.restaurant.minOrderValue > subtotal) {
        showToast(
            hantarrBloc.state.translation.text("Minimum order value is ") +
                " MYR ${widget.restaurant.minOrderValue.toStringAsFixed(2)}",
            duration: Duration(
              seconds: 10,
            ),
            context: context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> showPaymentMethodDialog() async {
    List<String> methodList = ["Cash On Delivery", "Credit"];
    int index;
    if (paymentMethod != null) {
      index = methodList.indexOf(paymentMethod);
    }
    if (hantarrBloc.state.user.credit == null) {
      hantarrBloc.state.user.credit = 0.00;
    }
    paymentMethod = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Payment Method",
            style: TextStyle(fontSize: ScreenUtil().setSp(50)),
          ),
          content: Container(child: StatefulBuilder(
            builder: (BuildContext context, StateSetter state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile(
                    activeColor: Colors.yellow[800],
                    groupValue: index,
                    title: Text(methodList[0],
                        style: TextStyle(fontSize: ScreenUtil().setSp(40))),
                    onChanged: (int value) {
                      state(() {
                        index = value;
                      });
                      Navigator.of(context).pop(methodList[value]);
                    },
                    value: 0,
                  ),
                  Divider(),
                  RadioListTile(
                    activeColor: Colors.yellow[800],
                    groupValue: index,
                    title: Text(
                        "E-Wallet" +
                            " (MYR ${hantarrBloc.state.user.credit.toStringAsFixed(2)})",
                        style: TextStyle(fontSize: ScreenUtil().setSp(40))),
                    onChanged: (int value) {
                      double totalValue = num.tryParse(
                              (deliveryFee + subtotal).toStringAsFixed(2))
                          .toDouble();
                      double snaelCredit = num.tryParse(
                              hantarrBloc.state.user.credit.toStringAsFixed(2))
                          .toDouble();
                      if (snaelCredit >= totalValue) {
                        state(() {
                          index = value;
                        });

                        Navigator.of(context).pop(methodList[value]);
                      } else {
                        showToast("Insufficient Credit !", context: context);
                      }
                    },
                    value: 1,
                  ),
                ],
              );
            },
          )),
        );
      },
    );
    return paymentMethod;
  }

  checkDiscount() {
    if (discount != null) {
      if (subtotal >= discount.minSpend) {
        switch (discount.type) {
          case "percentage":
            discountAmount = (subtotal * discount.amount) / 100;
            break;
          case "cash":
            discountAmount = discount.amount;
            break;
          default:
            discountAmount = 0.00;
        }
      } else {
        discountAmount = 0.00;
      }
    }
  }

  checkVoucher() {
    if (voucherName.isNotEmpty) {
      switch (vouchermap["type"]) {
        case "cash":
          voucherAmount = vouchermap["amount"];
          break;
        case "percentage":
          voucherAmount = (vouchermap["amount"] * grandTotal) / 100;
          break;
        default:
      }
    }
  }

  checkDeliveryFee() {
    double extraFee;
    bool hasDeliveryFee = false;
    if (hantarrBloc.state.user.restaurantCart.restaurant.freeDelivery) {
      // check free delivery fee //
      if (hantarrBloc.state.user.restaurantCart.restaurant.freeDeliveryKm !=
          null) {
        if (hantarrBloc.state.user.restaurantCart.restaurant.distance <=
            hantarrBloc.state.user.restaurantCart.restaurant.freeDeliveryKm) {
          deliveryFee = 0.00;
        } else {
          hasDeliveryFee = true;
        }
      }
    } else {
      hasDeliveryFee = true;
    }
    if (hasDeliveryFee) {
      if (hantarrBloc.state.user.restaurantCart.preOrderDateTime == null) {
        hantarrBloc.state.user.restaurantCart.preOrderDateTime = "";
      }
      if (hantarrBloc.state.user.restaurantCart.preOrderDateTime.isEmpty) {
        // -- for normal delivery calculation -- //
        if (hantarrBloc.state.user.restaurantCart.restaurant.distance <
            hantarrBloc
                .state.user.restaurantCart.restaurant.deliveryDefaultKm) {
          deliveryFee =
              hantarrBloc.state.user.restaurantCart.restaurant.deliveryFixFee;
        } else {
          extraFee = hantarrBloc
                  .state.user.restaurantCart.restaurant.deliveryExtraPerKm *
              (hantarrBloc.state.user.restaurantCart.restaurant.distance -
                  hantarrBloc
                      .state.user.restaurantCart.restaurant.deliveryDefaultKm);

          if (extraFee == extraFee.truncate().toDouble()) {
            extraFee = extraFee.truncate().toDouble();
          } else {
            extraFee = extraFee.truncate().toDouble() + 1;
          }

          deliveryFee =
              hantarrBloc.state.user.restaurantCart.restaurant.deliveryFixFee +
                  extraFee;
        }
      } else {
        // preorder calculation //
        double currentDistance =
            hantarrBloc.state.user.restaurantCart.restaurant.distance;
        for (PreorderDeliveryFee pofee in hantarrBloc
            .state.user.restaurantCart.restaurant.preorderDeliveryFees) {
          if (currentDistance <= pofee.endKM &&
              currentDistance >= pofee.startKM) {
            deliveryFee = pofee.fee;
          }
        }
      }
    }
  }

  List<Widget> menuItemWidgets() {
    List<Widget> widgetList = [];
    List<MenuItem> filteredMenuItem = [];
    restaurantCart.menuItems.forEach((element) {
      element.viewQty = 1;
    });
    for (MenuItem menuItem in restaurantCart.menuItems) {
      if (filteredMenuItem.any((element) => element.name == menuItem.name)) {
        String oriMICus = "", filteredMICus = "";
        bool sameItem = false;
        for (Customization customization in menuItem.selectedCustomizations) {
          oriMICus += customization.name;
        }
        for (MenuItem mi in filteredMenuItem
            .where((element) => element.name == menuItem.name)
            .toList()) {
          for (Customization customization in mi.selectedCustomizations) {
            filteredMICus += customization.name;
          }
          if (oriMICus == filteredMICus) {
            sameItem = true;
          } else {
            sameItem = false;
          }
        }
        if (!sameItem) {
          filteredMenuItem.add(menuItem);
        } else {
          // menuItem.viewQty ++;
          filteredMenuItem
              .where((element) => element.name == menuItem.name)
              .toList()
              .first
              .viewQty++;
        }
      } else {
        filteredMenuItem.add(menuItem);
      }
    }
    subtotal = 0.00;
    for (MenuItem menuItem in filteredMenuItem) {
      double price = menuItem.itemPriceSetter(menuItem, DateTime.now(), false);
      List<Widget> nameDetails = [];
      nameDetails.add(Container(
        alignment: Alignment.centerLeft,
        width: ScreenUtil().setWidth(550),
        child: Text(
          menuItem.name,
          style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: ScreenUtil().setSp(30))),
          overflow: TextOverflow.ellipsis,
        ),
      ));
      for (Customization cus in menuItem.selectedCustomizations) {
        if (cus.price != null) {
          price = price + cus.price;
        }
        nameDetails.add(Container(
          alignment: Alignment.centerLeft,
          width: ScreenUtil().setWidth(550),
          child: Text(
            " - " +
                cus.name +
                (cus.price != null
                    ? " (RM ${cus.price.toStringAsFixed(2)})"
                    : ""),
            style: GoogleFonts.lato(
                textStyle: TextStyle(fontSize: ScreenUtil().setSp(30))),
            overflow: TextOverflow.ellipsis,
          ),
        ));
      }
      price = price * menuItem.viewQty;
      subtotal = subtotal + price;

      widgetList.add(Container(
        padding: EdgeInsets.only(
            top: ScreenUtil().setSp(20),
            bottom: ScreenUtil().setSp(20),
            left: ScreenUtil().setSp(40),
            right: ScreenUtil().setSp(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      setState(() {
                        menuItem.viewQty--;

                        restaurantCart.menuItems.removeAt(
                            restaurantCart.menuItems.indexOf(menuItem));
                      });
                      if (restaurantCart.menuItems.isEmpty) {
                        Navigator.of(context).pop();
                      }
                      hantarrBloc.add(Refresh());
                    },
                    child: Container(
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              new BorderRadius.all(Radius.circular(50.0)),
                          border:
                              Border.all(color: themeBloc.state.primaryColor)),
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.remove,
                        color: themeBloc.state.primaryColor,
                        size: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Text(
                      menuItem.viewQty.toString(),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        menuItem.viewQty++;
                        restaurantCart.menuItems.add(menuItem);
                        hantarrBloc.add(Refresh());
                      });
                    },
                    child: Container(
                      decoration: new BoxDecoration(
                          color: themeBloc.state.primaryColor,
                          borderRadius:
                              new BorderRadius.all(Radius.circular(50.0))),
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: nameDetails,
            ),
            Container(
                child: Text(
              'RM ${price.toStringAsFixed(2)}',
              style: GoogleFonts.lato(
                  textStyle: TextStyle(fontSize: ScreenUtil().setSp(30))),
              overflow: TextOverflow.ellipsis,
            ))
          ],
        ),
      ));
    }
    checkDiscount();
    checkVoucher();
    checkDeliveryFee();
    grandTotal = subtotal - discountAmount - voucherAmount + deliveryFee;
    Future.delayed(Duration(milliseconds: 100), () {
      //////
      if (hantarrBloc.state.user.credit == null) {
        hantarrBloc.state.user.credit = 0.0;
      }
      if (grandTotal > hantarrBloc.state.user.credit) {
        if (paymentMethod == "Credit") {
          paymentMethod = null;
          showToast("Insufficient Credit !", context: context);
          setState(() {});
        }
      }
    });

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.restaurant.name),
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                widget.restaurant.discounts.isNotEmpty
                    ? Container(
                        // margin: EdgeInsets.only(top: 15),
                        child: dicountTile(widget.restaurant, context),
                      )
                    : Container(),
                Card(
                  child: Container(
                    child: Column(
                      children: menuItemWidgets(),
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 15, left: 25, right: 25, bottom: 15),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Subtotal",
                              style: TextStyle(
                                  color: Colors.grey,
                                  height: 2,
                                  fontSize: ScreenUtil().setSp(35)),
                            ),
                            Text(
                              "RM " + subtotal.toStringAsFixed(2),
                              style: TextStyle(
                                  color: Colors.grey,
                                  height: 2,
                                  fontSize: ScreenUtil().setSp(35)),
                            )
                          ],
                        ),
                        discountAmount != 0.00
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Discount(${discount.name})",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        height: 2,
                                        fontSize: ScreenUtil().setSp(35)),
                                  ),
                                  Text(
                                    "- RM " + discountAmount.toStringAsFixed(2),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        height: 2,
                                        fontSize: ScreenUtil().setSp(35)),
                                  )
                                ],
                              )
                            : Container(),
                        voucherAmount != 0.00
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Voucher($voucherName)",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        height: 2,
                                        fontSize: ScreenUtil().setSp(35)),
                                  ),
                                  Text(
                                    "- RM " + voucherAmount.toStringAsFixed(2),
                                    style: TextStyle(
                                        color: Colors.grey,
                                        height: 2,
                                        fontSize: ScreenUtil().setSp(35)),
                                  )
                                ],
                              )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Delivery Fee",
                              style: TextStyle(
                                  color: Colors.grey,
                                  height: 2,
                                  fontSize: ScreenUtil().setSp(35)),
                            ),
                            Text(
                              "RM " + deliveryFee.toStringAsFixed(2),
                              style: TextStyle(
                                  color: Colors.grey,
                                  height: 2,
                                  fontSize: ScreenUtil().setSp(35)),
                            ),
                          ],
                        ),
                        Container(
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Total",
                              style: TextStyle(
                                  color: Colors.yellow[900],
                                  fontSize: ScreenUtil().setSp(35),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "RM " + grandTotal.toStringAsFixed(2),
                              style: TextStyle(
                                  color: Colors.yellow[900],
                                  fontSize: ScreenUtil().setSp(35),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            TextEditingController voucherController =
                                TextEditingController();
                            FocusNode focusNode = FocusNode();
                            vouchermap = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return WillPopScope(
                                  onWillPop: () {
                                    Navigator.of(context).pop();
                                    return null;
                                  },
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    title: new Center(
                                      child: Text("Apply Promo Code"),
                                    ),
                                    content: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: TextField(
                                        controller: voucherController,
                                        focusNode: focusNode,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.yellow[600],
                                                  width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.0),
                                            ),
                                            hintText: "Promo Code"),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      // usually buttons at the bottom of the dialog
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: ScreenUtil().setSp(40,
                                                allowFontScalingSelf: true),
                                            right: ScreenUtil().setSp(40,
                                                allowFontScalingSelf: true),
                                            bottom: ScreenUtil().setSp(40,
                                                allowFontScalingSelf: true)),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: new RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: BorderSide(
                                                  color: Colors.black,
                                                  width: 2)),
                                          color: themeBloc.state.primaryColor,
                                          child: new Text(
                                            "Apply",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    ScreenUtil().setSp(40)),
                                          ),
                                          onPressed: () async {
                                            focusNode.unfocus();
                                            // globals.loadingDialog(context);
                                            var response = await get(
                                                Uri.tryParse(foodUrl +
                                                    "/sales?field=check_voucher&uuid=${hantarrBloc.state.user.uuid}&voucher=${voucherController.text}&subtotal=$subtotal&rest_id=${widget.restaurant.id}"));
                                            try {
                                              Map result =
                                                  jsonDecode(response.body);
                                              // Navigator.of(context).pop();
                                              if (result["can_use"]) {
                                                bool proceed = true;
                                                if (discount != null) {
                                                  proceed = await showDialog(
                                                      context: context,
                                                      builder: (
                                                        BuildContext context,
                                                      ) {
                                                        return AlertDialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .circular(
                                                                    15.0),
                                                          ),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons.warning,
                                                                color: Colors
                                                                    .yellow,
                                                                size: ScreenUtil()
                                                                    .setSp(150,
                                                                        allowFontScalingSelf:
                                                                            true),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    ScreenUtil()
                                                                        .setHeight(
                                                                            50),
                                                              ),
                                                              Text(
                                                                "Note:\nCurrent discount will be invalid once promo code is applied!",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            40)),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: <Widget>[
                                                            FlatButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                              },
                                                              child: Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(35))),
                                                            ),
                                                            RaisedButton(
                                                              color:
                                                                  Colors.black,
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              },
                                                              child: Text(
                                                                "Proceed",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .yellow[
                                                                        600],
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            35)),
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      });

                                                  print(proceed);
                                                  if (proceed) {
                                                    Navigator.of(context)
                                                        .pop(result["voucher"]);

                                                    showToast(
                                                      "Applied successfully",
                                                      context: context,
                                                      backgroundColor: Colors
                                                          .green
                                                          .withOpacity(0.5),
                                                    );
                                                  } else {
                                                    Navigator.of(context).pop();
                                                  }
                                                } else {
                                                  if (proceed) {
                                                    Navigator.of(context)
                                                        .pop(result["voucher"]);
                                                    showToast(
                                                      "Applied successfully",
                                                      context: context,
                                                      backgroundColor: Colors
                                                          .green
                                                          .withOpacity(0.5),
                                                    );
                                                  } else {
                                                    Navigator.of(context).pop();
                                                  }
                                                }
                                              } else {
                                                // String message = result["status"].replaceAll(" ", "_");
                                                String message =
                                                    result["status"];
                                                showToast(
                                                  message,
                                                  context: context,
                                                  backgroundColor: Colors.green
                                                      .withOpacity(0.5),
                                                );
                                              }
                                            } catch (e) {
                                              BotToast.showText(
                                                  text:
                                                      "Something when wrong.");
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            setState(() {
                              if (vouchermap != null) {
                                voucherName = vouchermap["name"];
                                voucherAmount = num.tryParse(
                                        vouchermap["amount"].toString())
                                    .toDouble();
                                discountAmount = 0.00;
                                discount = null;
                              }
                            });
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              "Do you have promo code?",
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(35),
                                      color: themeBloc.state.primaryColor)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 15, left: 25, right: 25, bottom: 15),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Contact Info",
                            style: TextStyle(
                                color: Colors.yellow[900],
                                fontSize: ScreenUtil().setSp(35)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Contact Person",
                              style: TextStyle(
                                  color: Colors.grey,
                                  height: 2,
                                  fontSize: ScreenUtil().setSp(35)),
                            ),
                            Text(
                              hantarrBloc.state.user.currentContactInfo != null
                                  ? hantarrBloc.state.user.currentContactInfo
                                              .name !=
                                          null
                                      ? hantarrBloc
                                          .state.user.currentContactInfo.name
                                          .toString()
                                      : ""
                                  : hantarrBloc.state.user.name,
                              style: TextStyle(
                                  color: Colors.grey,
                                  height: 2,
                                  fontSize: ScreenUtil().setSp(35)),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Deliver to",
                              style: TextStyle(
                                  color: Colors.grey,
                                  height: 2,
                                  fontSize: ScreenUtil().setSp(35)),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(left: 40),
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChooseAddress(
                                                frmCheckout: true,
                                              )));
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      (hantarrBloc.state.user.currentContactInfo
                                              .address.isEmpty)
                                          ? "Select your address"
                                          : hantarrBloc.state.user
                                              .currentContactInfo.address
                                              .replaceAll("%address%", ", "),
                                      maxLines: 6,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          color: Colors.yellow[900],
                                          fontSize: ScreenUtil().setSp(35))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Payment Method",
                            style: TextStyle(
                                color: Colors.yellow[900],
                                fontSize: ScreenUtil().setSp(35)),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            paymentMethod = await showPaymentMethodDialog();
                            setState(() {});
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Method",
                                style: TextStyle(
                                    color: Colors.grey,
                                    height: 2,
                                    fontSize: ScreenUtil().setSp(35)),
                              ),
                              Text(
                                paymentMethod == null
                                    ? "Select a method"
                                    : paymentMethod,
                                style: TextStyle(
                                    height: 2,
                                    color: Colors.yellow[900],
                                    fontSize: ScreenUtil().setSp(35)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Delivery Time",
                            style: TextStyle(
                                color: Colors.yellow[900],
                                fontSize: ScreenUtil().setSp(35)),
                          ),
                        ),
                        InkWell(
                          onTap: null
                          // () async {
                          //   DateTime currentDT = await User().getCurrentTime();

                          //   if (widget.restaurant.allowPreorder) {
                          //     String preorderDatetime = await showDialog(
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         // return object of type Dialog
                          //         return PreorderDatetime(
                          //           currentDT: currentDT,
                          //           restaurant: widget.restaurant,
                          //           update: true,
                          //         );
                          //       },
                          //     );

                          //     setState(() {
                          //       hantarrBloc.state.user.restaurantCart
                          //           .preOrderDateTime = preorderDatetime;
                          //       hantarrBloc.add(Refresh());
                          //     });
                          //   } else {
                          //     unablePreorderDialog(context);
                          //   }
                          // }
                          ,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Time",
                                style: TextStyle(
                                    color: Colors.grey,
                                    height: 2,
                                    fontSize: ScreenUtil().setSp(35)),
                              ),
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      hantarrBloc.state.user.restaurantCart
                                              .preOrderDateTime.isNotEmpty
                                          ? hantarrBloc.state.user
                                              .restaurantCart.preOrderDateTime
                                              .toString()
                                              .substring(0, 16)
                                          : "Deliver Now",
                                      style: TextStyle(
                                          height: 2,
                                          color: Colors.yellow[900],
                                          fontSize: ScreenUtil().setSp(35)),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Icon(
                                    //   Icons.arrow_forward_ios,
                                    //   color: Colors.yellow[900],
                                    //   size: ScreenUtil()
                                    //       .setSp(38, allowFontScalingSelf: true),
                                    // )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(50),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: themeBloc.state.primaryColor,
                    onPressed: widget.restaurant.minOrderValue <= subtotal
                        ? () async {
                            if (hantarrBloc.state.user.phone != null) {
                              if (hantarrBloc.state.user.phone == "") {
                                BotToast.showText(
                                    text: hantarrBloc.state.translation.text(
                                        "Please validate your phone number first before checkout"),
                                    duration: Duration(seconds: 3));

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(),
                                  ),
                                );
                                return "";
                              }
                              loadingWidget(context);
                              DateTime currentDT;
                              currentDT =
                                  await hantarrUser.User().getCurrentTime();
                              var checkAvailability = RestaurantCart()
                                  .checkItemAvailability(
                                      context, currentDT, widget.restaurant);
                              if (checkAvailability['success']) {
                                if (hantarrBloc.state.user.currentContactInfo
                                        .address.isNotEmpty &&
                                    paymentMethod != null) {
                                  String response = await hantarrBloc
                                      .state.user.restaurantCart
                                      .checkout(
                                    grandTotal,
                                    subtotal,
                                    discountAmount,
                                    voucherAmount,
                                    deliveryFee,
                                    paymentMethod,
                                    voucherName,
                                    discount,
                                  );
                                  Navigator.pop(context);
                                  if (response.contains("success")) {
                                    Delivery().getPendingOrder();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        // return object of type Dialog
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(18.0),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                  child: Image.asset(
                                                      "assets/orderComplete.png",
                                                      width: ScreenUtil()
                                                          .setWidth(500),
                                                      height: ScreenUtil()
                                                          .setWidth(400))),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "Your order has been made successfully !",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.center,
                                                  textScaleFactor: 1,
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(10.0),
                                                  ),
                                                  color: themeBloc
                                                      .state.primaryColor,
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    "Got it !",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                    textScaleFactor: 1,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    showToast(response, context: context);
                                  }
                                  if (response == "preorder success") {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        // return object of type Dialog
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(18.0),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                  child: Image.asset(
                                                      "assets/orderComplete.png",
                                                      width: ScreenUtil()
                                                          .setWidth(500),
                                                      height: ScreenUtil()
                                                          .setWidth(400))),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  "Your pre-order has been made successfully !",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.center,
                                                  textScaleFactor: 1,
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(10.0),
                                                  ),
                                                  color: themeBloc
                                                      .state.primaryColor,
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    "Got it !",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                    textScaleFactor: 1,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                  // } else {
                                  //   showToast(
                                  //       "Sorry, ${hantarrBloc.state.user.restaurantCart.restaurant.name} has closed !",
                                  //       context: context);
                                  // }
                                } else {
                                  Navigator.pop(context);
                                  if (paymentMethod == null) {
                                    showToast("Please select a payment method!",
                                        context: context);
                                  } else {
                                    showToast(
                                        "Please enter your address details!",
                                        context: context);
                                  }
                                }
                              } else {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return checkAvailability['reason'];
                                  },
                                );
                              }
                              // widget.membershipBloc.state.user.riderChannel.push("rider_info", {"haha":"sadsadasd"});
                            } else {
                              // validate user's phone number
                              BotToast.showText(
                                  text: hantarrBloc.state.translation.text(
                                      "Please validate your phone number first before checkout"),
                                  duration: Duration(seconds: 3));

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          hantarrBloc.state.translation.text("Checkout"),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(45)),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          LineIcons.money,
                          color: Colors.white,
                          size: ScreenUtil()
                              .setSp(50, allowFontScalingSelf: true),
                        )
                      ],
                    ),
                  ),
                ),
                widget.restaurant.minOrderValue < subtotal
                    ? Text(
                        hantarrBloc.state.translation
                                .text("Minimum order value is ") +
                            " MYR ${widget.restaurant.minOrderValue.toStringAsFixed(2)}",
                        style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(35),
                          color: Colors.red,
                        )),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
