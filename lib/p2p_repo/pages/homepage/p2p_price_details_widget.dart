import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';

// ignore: must_be_immutable
class P2PPriceDetailWidget extends StatefulWidget {
  P2pTransaction p2pTransaction;
  P2PPriceDetailWidget({
    @required this.p2pTransaction,
  });
  @override
  _P2PPriceDetailWidgetState createState() => _P2PPriceDetailWidgetState();
}

class _P2PPriceDetailWidgetState extends State<P2PPriceDetailWidget> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      builder: (BuildContext context, HantarrState state) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "Price Summary",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(40.0),
                  ),
                ),
              ),
              ListTile(
                trailing: Icon(widget.p2pTransaction.vehicle.getIcon()),
                title: Text(
                  "Vehicle Type: ${widget.p2pTransaction.vehicle.vehicleName}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Base Fare",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
                trailing: Text(
                  "RM ${widget.p2pTransaction.vehicle.vehicleOption.firstWhere((x) => x.keyName == "base_fare").fareAmount.toStringAsFixed(2)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.p2pTransaction.vehicle.vehicleOption
                    .where((x) => x.showInUI && x.enable)
                    .toList()
                    .map(
                  (e) {
                    return ListTile(
                      title: Text(
                        "${e.optionTitle}",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontSize: ScreenUtil().setSp(35.0),
                        ),
                      ),
                      trailing: Text(
                        "RM ${e.fareAmount.toStringAsFixed(2)}",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontSize: ScreenUtil().setSp(35.0),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
              ListTile(
                title: Text(
                  "${(widget.p2pTransaction.getTotalValidStopsCount())} Stops",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
                trailing: Text(
                  "RM ${widget.p2pTransaction.getTotalStopsPrice().toStringAsFixed(2)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Distance Price",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
                subtitle: Text(
                  "${(widget.p2pTransaction.totalDistance / 1000).toStringAsFixed(2)} km",
                  style: themeBloc.state.textTheme.subtitle1.copyWith(
                    inherit: true,
                    fontSize: 12.0,
                    color: Colors.grey[500],
                  ),
                ),
                trailing: Text(
                  "RM ${widget.p2pTransaction.getDistancePrice().toStringAsFixed(2)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
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
                  "RM ${widget.p2pTransaction.getTotalPrice().toStringAsFixed(2)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Rounded Amount",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
                trailing: Text(
                  widget.p2pTransaction.getRoundPrice(
                              widget.p2pTransaction.getTotalPrice()) <
                          0
                      ? "- RM ${widget.p2pTransaction.getRoundPrice(widget.p2pTransaction.getTotalPrice()).abs().toStringAsFixed(2)}"
                      : "+ RM ${widget.p2pTransaction.getRoundPrice(widget.p2pTransaction.getTotalPrice()).abs().toStringAsFixed(2)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
              widget.p2pTransaction.getRoundedCurrency(
                          widget.p2pTransaction.getTotalPrice()) !=
                      0
                  ? ListTile(
                      title: Text(
                        "Grand Total",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[850],
                          fontSize: ScreenUtil().setSp(40.0),
                        ),
                      ),
                      trailing: Text(
                        "RM ${widget.p2pTransaction.getRoundedCurrency(widget.p2pTransaction.getTotalPrice()).toStringAsFixed(2)}",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[850],
                          fontSize: ScreenUtil().setSp(40.0),
                        ),
                      ),
                    )
                  : Container(),
              ListTile(
                onTap: () {
                  void setFunction() {
                    setState(() {});
                  }

                  widget.p2pTransaction.choosePaymentMethod(
                    context,
                    setFunction,
                  );
                },
                title: Text(
                  "Payment Method",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
                subtitle:
                    widget.p2pTransaction.paymentType == PaymentMethod.credit
                        ? Text(
                            "Balance: RM ${hantarrBloc.state.hUser.creditBalance.toStringAsFixed(0)}",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          )
                        : null,
                trailing: Text(
                  "${getPaymentMethod(widget.p2pTransaction.paymentType)}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
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
