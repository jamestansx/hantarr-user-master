import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_cart_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/delivery_datetime_option_selection/deliveryDTOptionSelection.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:hantarr/utilities/date_formater.dart';

class NewFoodDeliveryCheckOutPage extends StatefulWidget {
  @override
  _NewFoodDeliveryCheckOutPageState createState() =>
      _NewFoodDeliveryCheckOutPageState();
}

class _NewFoodDeliveryCheckOutPageState
    extends State<NewFoodDeliveryCheckOutPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading;
  String errorMsg = "";
  String checkoutErrorMSG = "";

  @override
  void initState() {
    if (hantarrBloc.state.hUser.creditBalance >=
        hantarrBloc.state.foodCart.getGrantTotal()) {
      hantarrBloc.state.foodCart.paymentMethod = "Credit";
      hantarrBloc.add(Refresh());
    } else {
      hantarrBloc.state.foodCart.paymentMethod = "Cash On Delivery";
      hantarrBloc.add(Refresh());
    }

    hantarrBloc.state.foodCart.phoneNum =
        hantarrBloc.state.hUser.firebaseUser.phoneNumber;
    hantarrBloc.add(Refresh());
    if (hantarrBloc.state.foodCart.contactPerson == null) {
      hantarrBloc.state.foodCart.contactPerson = "";
      hantarrBloc.add(Refresh());
    }
    if (hantarrBloc.state.foodCart.newRestaurant.allowPreorder &&
        hantarrBloc.state.foodCart.isPreorder == false) {
      hantarrBloc.state.foodCart
          .initDeliveryDateTime(hantarrBloc.state.foodCart.newRestaurant);
    }

    if (hantarrBloc.state.foodCart.contactPerson.isEmpty) {
      hantarrBloc.state.foodCart.contactPerson =
          hantarrBloc.state.hUser.firebaseUser?.displayName;
      hantarrBloc.add(Refresh());
    }
    getDistance();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getDistance() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMsg = "";
      });
    }
    var getResDistanceReq = await hantarrBloc.state.foodCart.newRestaurant
        .getDistance(hantarrBloc.state.selectedLocation);

    if (getResDistanceReq['success']) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMsg = "";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMsg = "${getResDistanceReq['reason']}";
        });
      }
    }
  }

  Widget itemsWidget(context) {
    return Card(
      // shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(10.0))),
      margin: EdgeInsets.zero,
      elevation: 0.0,
      // color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setSp(5.0)),
        child: Column(
          children: hantarrBloc.state.foodCart.grouppedMenuItem().toList().map(
            (e) {
              Map<String, dynamic> result = e.availability(
                  !hantarrBloc.state.foodCart.isPreorder
                      ? hantarrBloc.state.foodCart.orderDateTime
                      : hantarrBloc.state.foodCart.preorderDateTime,
                  hantarrBloc.state.foodCart.isPreorder);
              return Stack(
                children: [
                  Container(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(ScreenUtil().setSp(10.0)),
                            child: Row(
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: result['success']
                                            ? () async {
                                                await hantarrBloc.state.foodCart
                                                    .removeItemFromCart(
                                                        e, context);
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: result['success']
                                              ? Colors.red
                                              : Colors.transparent,
                                        ),
                                      ),
                                      Text(
                                        "${hantarrBloc.state.foodCart.countForThisItem(e)}",
                                        style: themeBloc
                                            .state.textTheme.bodyText2
                                            .copyWith(
                                          inherit: true,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: result['success']
                                            ? () {
                                                hantarrBloc.state.foodCart
                                                    .addACloneItem(e);
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color: result['success']
                                              ? Colors.green
                                              : Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        child: Text(
                                          "${e.name} (RM${e.itemPriceSetter(hantarrBloc.state.foodCart.orderDateTime, false).toStringAsFixed(2)})",
                                          textAlign: TextAlign.left,
                                          style: themeBloc
                                              .state.textTheme.bodyText2
                                              .copyWith(
                                            inherit: true,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: e.confirmedCustomizations.map(
                                          (b) {
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "\t\t\t${b.name} (RM ${b.price.toStringAsFixed(2)}) x ${b.qty}",
                                                    style: themeBloc.state
                                                        .textTheme.subtitle2
                                                        .copyWith(
                                                      inherit: true,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: AutoSizeText(
                                      "RM ${(e.getItemExactPrice(hantarrBloc.state.foodCart.orderDateTime, false) * hantarrBloc.state.foodCart.countForThisItem(e)).toStringAsFixed(2)}",
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      minFontSize: 8,
                                      style: themeBloc.state.textTheme.headline6
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.grey[850],
                                        fontWeight: FontWeight.w400,
                                        fontSize: ScreenUtil().setSp(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  result['success'] == false
                      ? Align(
                          alignment: Alignment.center,
                          child: Container(
                            color: Colors.black.withOpacity(.8),
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${e.name} not available at this time.\n${result['reason']}",
                                    textAlign: TextAlign.left,
                                    style: themeBloc.state.textTheme.button
                                        .copyWith(
                                      inherit: true,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    await hantarrBloc.state.foodCart
                                        .removeAllThisItemFromCart(e, context);
                                  },
                                  color: themeBloc.state.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Remove  ",
                                          textAlign: TextAlign.left,
                                          style: themeBloc
                                              .state.textTheme.button
                                              .copyWith(
                                            inherit: true,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget pricingWidget(BuildContext context) {
    return Card(
      // margin: EdgeInsets.zero,
      // elevation: 0.0,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setSp(25.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    "Subtotal",
                    textAlign: TextAlign.left,
                    style: themeBloc.state.textTheme.bodyText1.copyWith(),
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    "RM ${hantarrBloc.state.foodCart.getSubtotal().toStringAsFixed(2)}",
                    textAlign: TextAlign.right,
                    style: themeBloc.state.textTheme.bodyText1.copyWith(),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    "Delivery Fee",
                    textAlign: TextAlign.left,
                    style: themeBloc.state.textTheme.bodyText1.copyWith(),
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    "RM ${hantarrBloc.state.foodCart.getDeliveryFee().toStringAsFixed(2)}",
                    textAlign: TextAlign.right,
                    style: themeBloc.state.textTheme.bodyText1.copyWith(),
                  ),
                ),
              ],
            ),
            if (hantarrBloc.state.foodCart.getServiceFee() > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      "Service Fee",
                      textAlign: TextAlign.left,
                      style: themeBloc.state.textTheme.bodyText1.copyWith(),
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      "RM ${hantarrBloc.state.foodCart.getServiceFee().toStringAsFixed(2)}",
                      textAlign: TextAlign.right,
                      style: themeBloc.state.textTheme.bodyText1.copyWith(),
                    ),
                  ),
                ],
              ),
            if (hantarrBloc.state.foodCart.getSmallOrderFee() > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      "Small Order Fee",
                      textAlign: TextAlign.left,
                      style: themeBloc.state.textTheme.bodyText1.copyWith(),
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      "RM ${hantarrBloc.state.foodCart.getSmallOrderFee().toStringAsFixed(2)}",
                      textAlign: TextAlign.right,
                      style: themeBloc.state.textTheme.bodyText1.copyWith(),
                    ),
                  ),
                ],
              ),
            hantarrBloc.state.foodCart.getDiscount() != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          "${hantarrBloc.state.foodCart.getDiscount().name}",
                          textAlign: TextAlign.left,
                          style: themeBloc.state.textTheme.bodyText1.copyWith(),
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          "- RM ${hantarrBloc.state.foodCart.getDiscountAmount().toStringAsFixed(2)}",
                          textAlign: TextAlign.right,
                          style: themeBloc.state.textTheme.bodyText1.copyWith(),
                        ),
                      ),
                    ],
                  )
                : Container(),
            hantarrBloc.state.foodCart.voucherName.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          "${hantarrBloc.state.foodCart.voucherName}",
                          textAlign: TextAlign.left,
                          style: themeBloc.state.textTheme.bodyText1.copyWith(),
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          "- RM ${hantarrBloc.state.foodCart.getVoucherAmount().toStringAsFixed(2)}",
                          textAlign: TextAlign.right,
                          style: themeBloc.state.textTheme.bodyText1.copyWith(),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    "Total",
                    textAlign: TextAlign.left,
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      inherit: true,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: AutoSizeText(
                    "RM ${hantarrBloc.state.foodCart.getGrantTotal().toStringAsFixed(2)}",
                    textAlign: TextAlign.right,
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      inherit: true,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            RaisedButton(
              onPressed: () async {
                await Navigator.pushNamed(context, applyVoucherPage);
              },
              color: themeBloc.state.primaryColor,
              shape: themeBloc.state.cardTheme.shape,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Text(
                  "Do you have promo code?",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontSize: ScreenUtil().setSp(45.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addressWidget(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    return Card(
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setSp(25.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contact Info",
              style: themeBloc.state.textTheme.headline6.copyWith(
                inherit: true,
                color: themeBloc.state.primaryColor,
              ),
            ),
            ListTile(
              onTap: () {},
              contentPadding: EdgeInsets.zero,
              title: TextFormField(
                controller: TextEditingController(
                  text: hantarrBloc.state.foodCart.contactPerson != null
                      ? "${hantarrBloc.state.foodCart.contactPerson}"
                      : "",
                ),
                style: themeBloc.state.textTheme.bodyText1.copyWith(),
                decoration: InputDecoration(
                  labelText: "Contact Person",
                  border: InputBorder.none,
                  errorStyle: themeBloc.state.textTheme.subtitle2.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onChanged: (val) {
                  hantarrBloc.state.foodCart.contactPerson = val;
                },
                validator: (val) {
                  if (val.replaceAll(" ", "").isEmpty) {
                    return "Cannot empty";
                  } else {
                    return null;
                  }
                },
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[850],
                size: ScreenUtil().setSp(30),
              ),
            ),
            ListTile(
              onTap: () {},
              contentPadding: EdgeInsets.zero,
              title: TextFormField(
                // readOnly: true,
                controller: TextEditingController(
                  text: hantarrBloc.state.foodCart.phoneNum != null
                      ? "${hantarrBloc.state.foodCart.phoneNum}"
                      : "",
                ),
                style: themeBloc.state.textTheme.bodyText1.copyWith(),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: InputBorder.none,
                  errorStyle: themeBloc.state.textTheme.subtitle2.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onChanged: (val) {
                  hantarrBloc.state.foodCart.phoneNum = val;
                },
                validator: (val) {
                  if (val.replaceAll(" ", "").isEmpty) {
                    return "Cannot empty";
                  } else {
                    return null;
                  }
                },
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[850],
                size: ScreenUtil().setSp(30),
              ),
            ),
            ListTile(
              onTap: () async {
                await hantarrBloc.state.foodCart.changeLocation(context);
              },
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Deliver To",
                style: themeBloc.state.textTheme.bodyText1.copyWith(),
              ),
              subtitle: Text(
                "${hantarrBloc.state.foodCart.address.replaceAll("%address%", "")}",
                style: themeBloc.state.textTheme.subtitle1.copyWith(),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[850],
                size: ScreenUtil().setSp(30),
              ),
            ),
            Divider(),
            Text(
              "Payment Method",
              style: themeBloc.state.textTheme.headline6.copyWith(
                inherit: true,
                color: themeBloc.state.primaryColor,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: paymentMethods.map(
                  (e) {
                    return RadioListTile(
                      selected: hantarrBloc.state.foodCart.paymentMethod == e
                          ? true
                          : false,
                      activeColor: Colors.red,
                      dense: true,
                      title: Text(
                        "$e",
                        style: themeBloc.state.textTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: e == "Credit"
                          ? Text(
                              "Balance: " +
                                  "RM ${hantarrBloc.state.hUser.creditBalance.toStringAsFixed(2)}",
                              style:
                                  themeBloc.state.textTheme.subtitle2.copyWith(
                                color: themeBloc.state.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                      groupValue: hantarrBloc.state.foodCart.paymentMethod,
                      onChanged: (String value) {
                        hantarrBloc.state.foodCart.paymentMethod = value;
                        hantarrBloc.add(Refresh());
                      },
                      value: e,
                    );
                  },
                ).toList(),
              ),
            ),
            Divider(),
            Text(
              "Delivery Time",
              style: themeBloc.state.textTheme.headline6.copyWith(
                inherit: true,
                color: themeBloc.state.primaryColor,
              ),
            ),
            ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(
                          10.0,
                        ),
                      )),
                      insetPadding: EdgeInsets.all(ScreenUtil().setSp(10.0)),
                      child: Container(
                        width: mediaQ.width * .9,
                        child: DeliveryDateTimeOptionSelectionWidget(
                          newRestaurant:
                              hantarrBloc.state.foodCart.newRestaurant,
                        ),
                      ),
                    );
                  },
                );
              },
              contentPadding: EdgeInsets.zero,
              title: Text(
                hantarrBloc.state.foodCart.isPreorder
                    ? "${dateFormater(hantarrBloc.state.foodCart.preorderDateTime)}"
                    : "Deliver Now",
                style: themeBloc.state.textTheme.bodyText1.copyWith(),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[850],
                size: ScreenUtil().setSp(30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget checkOutButtonWidget(BuildContext context, Size mediaQ) {
    return Container(
      width: mediaQ.width,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                loadingWidget(context);
                var getCurrentTimeReq =
                    await hantarrBloc.state.foodCart.getCurrentTime();
                Navigator.pop(context);
                if (getCurrentTimeReq['success']) {
                  if (hantarrBloc.state.foodCart.menuItems.isNotEmpty) {
                    if (_formKey.currentState.validate()) {
                      setState(() {});
                      var validateBindPhonereq =
                          hantarrBloc.state.foodCart.validateBindedphone();
                      if (validateBindPhonereq['success']) {
                        var validateAllReq =
                            await hantarrBloc.state.foodCart.validateAll();
                        if (validateAllReq['success']) {
                          Navigator.pushNamed(context, foodCheckoutWizardPage);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                title: Text("${validateAllReq['reason']}"),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "OK",
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(32),
                                        color: themeBloc.state.primaryColor,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        UniqueKey key = UniqueKey();
                        BotToast.showWidget(
                          key: key,
                          toastBuilder: (_) => AlertDialog(
                            title: Text("Please bind your phone number first"),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  BotToast.remove(key);
                                },
                                color: themeBloc.state.primaryColor,
                                child: Text(
                                  "OK",
                                  style:
                                      themeBloc.state.textTheme.button.copyWith(
                                    inherit: true,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        Navigator.pushNamed(context, manageMyAccountPage);
                      }
                    } else {
                      BotToast.showText(
                          text: "Please key in your phone number and name");
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Please add items to cart."),
                          actions: [
                            MaterialButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "OK",
                                style:
                                    themeBloc.state.textTheme.button.copyWith(
                                  inherit: true,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                    Navigator.popUntil(
                        context, ModalRoute.withName(newMenuItemListPage));
                  }
                } else {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("${getCurrentTimeReq['reason']}"),
                        actions: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "OK",
                              style: themeBloc.state.textTheme.button.copyWith(
                                inherit: true,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  );
                }
              },
              color: themeBloc.state.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              )),
              child: Container(
                height: ScreenUtil().setHeight(120),
                padding: EdgeInsets.all(ScreenUtil().setSp(20.0)),
                width: mediaQ.width * .9,
                // padding: EdgeInsets.all(ScreenUtil().setSp(15.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Checkout",
                      style: themeBloc.state.textTheme.headline6.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(45.0),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Icon(
                      Icons.money_rounded,
                      color: Colors.white,
                      size: ScreenUtil().setSp(45.0),
                    ),
                  ],
                ),
              ),
            ),
            hantarrBloc.state.foodCart.newRestaurant.minOrderValue >
                    hantarrBloc.state.foodCart.getSubtotal()
                ? Text(
                    "Minimum order value is MYR ${hantarrBloc.state.foodCart.newRestaurant.minOrderValue.toStringAsFixed(2)}",
                    style: themeBloc.state.textTheme.subtitle2.copyWith(
                      color: themeBloc.state.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(35.0),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
            key: _formKey,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: themeBloc.state.primaryColor,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  "${hantarrBloc.state.foodCart.newRestaurant.name}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                      fontSize: ScreenUtil().setSp(35.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                actions: [
                  hantarrBloc.state.hUser.firebaseUser == null
                      ? FlatButton(
                          onPressed: () {
                            Navigator.pushNamed(context, loginPage);
                          },
                          child: Text(
                            "Login",
                            style: themeBloc.state.textTheme.button.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(32.0),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              floatingActionButton: (isLoading == false && errorMsg.isEmpty)
                  ? checkOutButtonWidget(context, mediaQ)
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: isLoading
                  ? Container(
                      width: mediaQ.width,
                      height: mediaQ.height,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SpinKitDoubleBounce(
                            color: themeBloc.state.primaryColor,
                            size: ScreenUtil().setSp(55),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Loading ...",
                            textAlign: TextAlign.center,
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(35),
                              color: themeBloc.state.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : errorMsg.isNotEmpty
                      ? Container(
                          width: mediaQ.width,
                          height: mediaQ.height,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "$errorMsg",
                                textAlign: TextAlign.center,
                                style: themeBloc.state.textTheme.headline6
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(35),
                                  color: themeBloc.state.primaryColor,
                                ),
                              ),
                              SizedBox(height: 15),
                              FlatButton(
                                onPressed: () async {
                                  if (errorMsg
                                      .toLowerCase()
                                      .contains("other location")) {
                                    await hantarrBloc.state.foodCart
                                        .changeLocation(context);
                                  } else {
                                    getDistance();
                                  }
                                },
                                color: themeBloc.state.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    errorMsg
                                            .toLowerCase()
                                            .contains("other location")
                                        ? "Change location"
                                        : "RETRY",
                                    textAlign: TextAlign.center,
                                    style: themeBloc.state.textTheme.headline6
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(55),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: mediaQ.width,
                          height: mediaQ.height,
                          child: ListView(
                            padding: EdgeInsets.all(ScreenUtil().setSp(5.0)),
                            children: [
                              itemsWidget(context),
                              Divider(),
                              pricingWidget(context),
                              Divider(color: Colors.transparent),
                              addressWidget(context),
                              Divider(color: Colors.transparent),
                              SizedBox(
                                height: mediaQ.height * .1,
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }
}
