import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';

// ignore: must_be_immutable
class FoodDeliveryPriceDetailWidget extends StatefulWidget {
  NewFoodDelivery newFoodDelivery;
  FoodDeliveryPriceDetailWidget({
    @required this.newFoodDelivery,
  });
  @override
  _FoodDeliveryPriceDetailWidgetState createState() =>
      _FoodDeliveryPriceDetailWidgetState();
}

class _FoodDeliveryPriceDetailWidgetState
    extends State<FoodDeliveryPriceDetailWidget> {
  @override
  Widget build(BuildContext context) {
    // Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Container(
          padding: EdgeInsets.only(left: 10.0, right: 10, top: 20, bottom: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text(
                      'Price Detail',
                      style: themeBloc.state.textTheme.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: ScreenUtil().setSp(40.0),
                      ),
                    ),
                    Spacer(),
                    Text(
                      "",
                      // '${orderInfo.date.day}/${orderInfo.date.month}/${orderInfo.date.year}',
                      style: TextStyle(
                        color: Color(0xffb6b2b2),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.transparent,
              ),
              ListTile(
                title: Text(
                  "Subtotal",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
                trailing: Text(
                  "RM ${widget.newFoodDelivery.subtotal.toStringAsFixed(2)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Delivery Fee",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
                trailing: Text(
                  "RM ${widget.newFoodDelivery.deliveryFee.toStringAsFixed(2)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
              if (widget.newFoodDelivery.serviceFeePerOrder > 0)
                ListTile(
                  title: Text(
                    "Service Fee",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontSize: ScreenUtil().setSp(35.0),
                    ),
                  ),
                  trailing: Text(
                    "RM ${widget.newFoodDelivery.serviceFeePerOrder.toStringAsFixed(2)}",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontSize: ScreenUtil().setSp(35.0),
                    ),
                  ),
                ),
              if (widget.newFoodDelivery.smallOrderFee > 0)
                ListTile(
                  title: Text(
                    "Small Order Fee",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontSize: ScreenUtil().setSp(35.0),
                    ),
                  ),
                  trailing: Text(
                    "RM ${widget.newFoodDelivery.smallOrderFee.toStringAsFixed(2)}",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontSize: ScreenUtil().setSp(35.0),
                    ),
                  ),
                ),
              widget.newFoodDelivery.discountAmount > 0
                  ? ListTile(
                      title: Text(
                        "Dicount Amount",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontSize: ScreenUtil().setSp(35.0),
                        ),
                      ),
                      subtitle:
                          Text("${widget.newFoodDelivery.discountAmount}"),
                      trailing: Text(
                        "- RM ${widget.newFoodDelivery.discountAmount.toStringAsFixed(2)}",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontSize: ScreenUtil().setSp(35.0),
                        ),
                      ),
                    )
                  : Container(),
              widget.newFoodDelivery.voucherName.isNotEmpty
                  ? ListTile(
                      title: Text(
                        "Voucher",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontSize: ScreenUtil().setSp(35.0),
                        ),
                      ),
                      subtitle: Text("${widget.newFoodDelivery.voucherName}"),
                      trailing: Text(
                        "- RM ${widget.newFoodDelivery.voucherAmount.toStringAsFixed(2)}",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontSize: ScreenUtil().setSp(35.0),
                        ),
                      ),
                    )
                  : Container(),
              ListTile(
                title: Text(
                  "Grand Total",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
                    fontSize: ScreenUtil().setSp(40.0),
                  ),
                ),
                trailing: Text(
                  "RM ${widget.newFoodDelivery.getGrandTotal().toStringAsFixed(2)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
                    fontSize: ScreenUtil().setSp(40.0),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Payment Method",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
                trailing: Text(
                  "${widget.newFoodDelivery.paymentMethod}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Order Type",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
                trailing: Text(
                  widget.newFoodDelivery.isPreorder ? "Preorder" : "Ondemand",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.newFoodDelivery.chipStatusColors(),
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Status",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
                trailing: Text(
                  "${widget.newFoodDelivery.status.toUpperCase()}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.newFoodDelivery.chipStatusColors(),
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
