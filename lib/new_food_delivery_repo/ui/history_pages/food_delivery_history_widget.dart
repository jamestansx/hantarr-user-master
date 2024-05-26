import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/foodService/history_page/history_delivery.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/module/delivery_module.dart';

// ignore: must_be_immutable
class FoodDeliveryHistoryWidget extends StatefulWidget {
  Delivery delivery;
  FoodDeliveryHistoryWidget({
    @required this.delivery,
  });
  @override
  _FoodDeliveryHistoryWidgetState createState() =>
      _FoodDeliveryHistoryWidgetState();
}

class _FoodDeliveryHistoryWidgetState extends State<FoodDeliveryHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
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
            color: Colors.grey[700], fontSize: ScreenUtil().setSp(30)),
      );
    }

    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 15,
          child: InkWell(
              child: Stack(
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            widget.delivery.restaurant.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(35)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "ID: " + widget.delivery.id.toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                            Text(
                              "Subtotal: RM " +
                                  (widget.delivery.subTotal).toStringAsFixed(2),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                            Text(
                              "Delivery Fee: RM " +
                                  (widget.delivery.deliveryFee)
                                      .toStringAsFixed(2),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                            widget.delivery.voucherAmount > 0
                                ? Text(
                                    "Voucher Amount: - RM " +
                                        (widget.delivery.voucherAmount)
                                            .toStringAsFixed(2) +
                                        " (${widget.delivery.voucherName})",
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: ScreenUtil().setSp(30)),
                                  )
                                : Container(),
                            widget.delivery.discountAmount > 0
                                ? Text(
                                    "Discount Amount: - RM " +
                                        (widget.delivery.discountAmount)
                                            .toStringAsFixed(2) +
                                        " (${widget.delivery.discountName})",
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: ScreenUtil().setSp(30)),
                                  )
                                : Container(),
                            Text(
                              "Grand Total: RM " +
                                  (widget.delivery.subTotal +
                                          widget.delivery.deliveryFee -
                                          widget.delivery.voucherAmount -
                                          widget.delivery.discountAmount)
                                      .toStringAsFixed(2),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                            dateTimeFormat(widget.delivery.datetime),
                            Text(
                              "Status: " +
                                  widget.delivery.deliveryStatus.status
                                      .toUpperCase(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                          ],
                        )
                      ],
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () async {
                              Delivery selectedDelivery = widget.delivery;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HistoryDeliveryPage(
                                            delivery: selectedDelivery,
                                          )));
                            },
                            child: Text(
                              hantarrBloc.state.translation
                                  .text("View Details"),
                              style: TextStyle(
                                  color: Colors.yellow[800],
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
        );
      },
    );
  }
}
