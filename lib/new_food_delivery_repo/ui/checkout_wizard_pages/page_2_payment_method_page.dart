import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_cart_module.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/route_setting/route_settings.dart';

// ignore: must_be_immutable
class PaymentMethodPage extends StatefulWidget {
  TextEditingController remarksCon;
  PaymentMethodPage({
    this.remarksCon,
  });
  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
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
    hantarrBloc.state.foodCart.getDistance();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget itemsWidget(context) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      elevation: 0.0,
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
      color: Colors.transparent,
      margin: EdgeInsets.zero,
      elevation: 0.0,
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
          child: Container(
            // padding: EdgeInsets.all(20.0),
            // color: Colors.red,
            child: hantarrBloc.state.foodCheckoutPageLoading
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
                : hantarrBloc.state.foodCheckoutErrorMsg.isNotEmpty
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
                              style:
                                  themeBloc.state.textTheme.headline6.copyWith(
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
                                  await hantarrBloc.state.foodCart
                                      .getDistance();
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
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            itemsWidget(context),
                            Divider(),
                            pricingWidget(context),
                            Divider(),
                            Card(
                              color: Colors.transparent,
                              margin: EdgeInsets.zero,
                              elevation: 0.0,
                              child: Container(
                                padding:
                                    EdgeInsets.all(ScreenUtil().setSp(25.0)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment Method",
                                      style: themeBloc.state.textTheme.headline6
                                          .copyWith(
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
                                              selected: hantarrBloc
                                                          .state
                                                          .foodCart
                                                          .paymentMethod ==
                                                      e
                                                  ? true
                                                  : false,
                                              activeColor: Colors.red,
                                              dense: true,
                                              title: Text(
                                                "$e",
                                                style: themeBloc
                                                    .state.textTheme.bodyText1
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              subtitle: e == "Credit"
                                                  ? Text(
                                                      "Balance: " +
                                                          "RM ${hantarrBloc.state.hUser.creditBalance.toStringAsFixed(2)}",
                                                      style: themeBloc.state
                                                          .textTheme.subtitle2
                                                          .copyWith(
                                                        color: themeBloc
                                                            .state.primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : null,
                                              groupValue: hantarrBloc
                                                  .state.foodCart.paymentMethod,
                                              onChanged: (String value) {
                                                hantarrBloc.state.foodCart
                                                    .paymentMethod = value;
                                                hantarrBloc.add(Refresh());
                                              },
                                              value: e,
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                    Text(
                                      "Order Remark",
                                      style: themeBloc.state.textTheme.headline6
                                          .copyWith(
                                        inherit: true,
                                        color: themeBloc.state.primaryColor,
                                      ),
                                    ),
                                    Container(
                                      width: mediaQ.width,
                                      child: TextFormField(
                                        controller: widget.remarksCon,
                                        maxLines: null,
                                        maxLength: 100,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.enforced,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }
}
