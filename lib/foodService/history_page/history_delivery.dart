import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class HistoryDeliveryPage extends StatefulWidget {
  Delivery delivery;
  HistoryDeliveryPage({
    @required this.delivery,
  });
  @override
  _HistoryDeliveryPageState createState() => _HistoryDeliveryPageState();
}

class _HistoryDeliveryPageState extends State<HistoryDeliveryPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget dateTimeFormat(String dateTime) {
    DateTime dt = DateTime.parse(dateTime);
    print(dt);
    String min = (dt.minute.toString().length == 1)
        ? "0" + dt.minute.toString()
        : dt.minute.toString();
    return Text(
      dt.day.toString() +
          "/" +
          dt.month.toString() +
          "/" +
          dt.year.toString() +
          " " +
          (dt.hour >= 12 ? (dt.hour - 12).toString() : dt.hour.toString()) +
          ":" +
          min +
          (dt.hour >= 12 ? " pm" : " am"),
      style: TextStyle(
        height: 2,
        fontSize: ScreenUtil().setSp(30),
      ),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> menuItemsWidget(Size mediaQ) {
    List<Widget> widgetlist = [];
    List<MenuItem> filteredMenuItem = [];
    widget.delivery.menuItem.forEach((element) {
      element.viewQty = 1;
    });
    for (MenuItem menuItem in widget.delivery.menuItem) {
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

    for (MenuItem menuItem in filteredMenuItem) {
      // double price = menuItem.itemPriceSetter(menuItem, DateTime.now(), false);
      List<Widget> nameDetails = [];
      nameDetails.add(Container(
        alignment: Alignment.centerLeft,
        width: ScreenUtil().setWidth(550),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(85),
              child: AutoSizeText(
                "X ${menuItem.viewQty} ",
                style: GoogleFonts.lato(
                    textStyle: TextStyle(fontSize: ScreenUtil().setSp(30))),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              menuItem.name,
              style: GoogleFonts.lato(
                  textStyle: TextStyle(fontSize: ScreenUtil().setSp(30))),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ));
      for (Customization cus in menuItem.selectedCustomizations) {
        // if (cus.price != null) {
        //   price = price + cus.price;
        // }
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
      // price = price * menuItem.viewQty;

      widgetlist.add(Container(
        padding: EdgeInsets.only(
            top: ScreenUtil().setSp(20),
            bottom: ScreenUtil().setSp(20),
            left: ScreenUtil().setSp(40),
            right: ScreenUtil().setSp(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: nameDetails,
            ),
            Container(
                child: Text(
              'RM ${menuItem.itemPriceSetter(menuItem, DateTime.now(), false).toStringAsFixed(2)}',
              style: GoogleFonts.lato(
                  textStyle: TextStyle(fontSize: ScreenUtil().setSp(30))),
              overflow: TextOverflow.ellipsis,
            ))
          ],
        ),
      ));
    }
    return widgetlist;
  }

  List<Widget> bodyContent(Size mediaQ) {
    List<Widget> widgetlist = [];
    widgetlist.add(SizedBox(height: ScreenUtil().setHeight(15.0)));
    Widget itemsWidget = Card(
      child: Container(
        child: Column(
          children: menuItemsWidget(mediaQ),
        ),
      ),
    );
    widgetlist.add(itemsWidget);
    Widget amountWidget = Card(
      child: Container(
        padding: EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 15),
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
                  "RM " + widget.delivery.subTotal.toStringAsFixed(2),
                  style: TextStyle(
                      color: Colors.grey,
                      height: 2,
                      fontSize: ScreenUtil().setSp(35)),
                )
              ],
            ),
            widget.delivery.discountAmount != 0.00
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Discount(${widget.delivery.discountName})",
                        style: TextStyle(
                            color: Colors.grey,
                            height: 2,
                            fontSize: ScreenUtil().setSp(35)),
                      ),
                      Text(
                        "- RM " +
                            widget.delivery.discountAmount.toStringAsFixed(2),
                        style: TextStyle(
                            color: Colors.grey,
                            height: 2,
                            fontSize: ScreenUtil().setSp(35)),
                      )
                    ],
                  )
                : Container(),
            widget.delivery.voucherAmount != 0.00
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Voucher(${widget.delivery.voucherName})",
                        style: TextStyle(
                            color: Colors.grey,
                            height: 2,
                            fontSize: ScreenUtil().setSp(35)),
                      ),
                      Text(
                        "- RM " +
                            widget.delivery.voucherAmount.toStringAsFixed(2),
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
                  "RM " + widget.delivery.deliveryFee.toStringAsFixed(2),
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
                  "RM " +
                      (widget.delivery.subTotal +
                              widget.delivery.deliveryFee -
                              widget.delivery.discountAmount -
                              widget.delivery.voucherAmount)
                          .toStringAsFixed(2),
                  style: TextStyle(
                      color: Colors.yellow[900],
                      fontSize: ScreenUtil().setSp(35),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    widgetlist.add(amountWidget);
    widgetlist.add(SizedBox(
      height: ScreenUtil().setHeight(25),
    ));
    Widget contactInfoWidget = Card(
      child: Container(
        padding: EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 15),
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
                  widget.delivery.contactInfo != null
                      ? widget.delivery.contactInfo.name != null
                          ? widget.delivery.contactInfo.name.toString()
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
                    onTap: null,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                          (widget.delivery.contactInfo.address.isEmpty)
                              ? "No Record"
                              : widget.delivery.contactInfo.address
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
              onTap: null,
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
                    widget.delivery.paymentMethod != null
                        ? widget.delivery.paymentMethod
                        : "Cash",
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
              onTap: null,
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        widget.delivery.isPreOrder
                            ? Row(
                                children: [
                                  Text(
                                    "Preoder: ",
                                    style: TextStyle(
                                        height: 2,
                                        color: Colors.yellow[900],
                                        fontSize: ScreenUtil().setSp(35)),
                                    textAlign: TextAlign.center,
                                  ),
                                  widget.delivery.preOrderDateTime != null
                                      ? widget.delivery.preOrderDateTime
                                              .isNotEmpty
                                          ? dateTimeFormat(
                                              widget.delivery.preOrderDateTime)
                                          : Container()
                                      : Container(),
                                ],
                              )
                            : dateTimeFormat(widget.delivery.datetime),
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
            ),
            Container(
              child: Divider(
                color: Colors.grey,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Status",
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
                        widget.delivery.deliveryStatus.status != null
                            ? widget.delivery.deliveryStatus.status
                            : "unknown",
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
          ],
        ),
      ),
    );
    widgetlist.add(contactInfoWidget);
    return widgetlist;
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black, //change your colo here
            ),
            title: Text(
              hantarrBloc.state.translation.text("Delivery History") +
                  " #${widget.delivery.id}",
              style: TextStyle(
                  color: themeBloc.state.primaryColor,
                  fontSize: ScreenUtil().setSp(40)),
            ),
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setSp(10)),
            child: Column(
              children: bodyContent(mediaQ),
            ),
          ),
        );
      },
    );
  }
}
