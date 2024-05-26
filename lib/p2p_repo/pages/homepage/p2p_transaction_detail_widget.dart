import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/pages/homepage/p2p_price_details_widget.dart';
import 'package:hantarr/p2p_repo/pages/homepage/p2p__stop_timeline_widget.dart';
import 'package:hantarr/p2p_repo/pages/homepage/p2p_status_timeline_widget.dart';
import 'package:hantarr/route_setting/route_settings.dart';

// ignore: must_be_immutable
class P2PTransactionDetailWidget extends StatefulWidget {
  P2pTransaction p2pTransaction;
  P2PTransactionDetailWidget({
    @required this.p2pTransaction,
  });
  @override
  _P2PTransactionDetailWidgetState createState() =>
      _P2PTransactionDetailWidgetState();
}

class _P2PTransactionDetailWidgetState
    extends State<P2PTransactionDetailWidget> {
  ScrollController sc = ScrollController();
  bool _showAppbar = false;
  bool isScrollingDown = false;
  Timer timer;

  @override
  void initState() {
    widget.p2pTransaction.remark = "-";
    sc.addListener(() {
      if (sc.position.userScrollDirection == ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = true;
          setState(() {});
        }
      }

      if (sc.position.userScrollDirection == ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = false;
          setState(() {});
        }
      }
    });
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (widget.p2pTransaction.id != null) {
        await widget.p2pTransaction.getSpecificP2P();
      }
    });
    super.initState();
  }

  setFunction() {
    setState(() {});
  }

  @override
  void dispose() {
    timer.cancel();
    sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      builder: (BuildContext context, HantarrState state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: _showAppbar
                  ? Colors.white
                  : themeBloc.state.scaffoldBackgroundColor,
              elevation: !_showAppbar ? 0.0 : 3.0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey[850],
                ),
              ),
              title: AnimatedOpacity(
                opacity: !_showAppbar ? 0.0 : 1.0,
                duration: Duration(
                  milliseconds: 300,
                ),
                child: Text(
                  widget.p2pTransaction.id != null
                      ? "Delivery: #${widget.p2pTransaction.id}"
                      : "New Delivery",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    color: Colors.grey[850],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              actions: <Widget>[
                //add buttons here
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: widget.p2pTransaction.id == null
                ? Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: ScreenUtil().setHeight(15),
                      ),
                      Container(
                        padding: EdgeInsets.all(ScreenUtil().setSp(10.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: FlatButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                            "Sorry, this feature is not available yet"),
                                        content: Text("Please stay tuned"),
                                        actions: [
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "OK",
                                              style: themeBloc
                                                  .state.textTheme.button
                                                  .copyWith(
                                                inherit: true,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                ),
                                child: Text(
                                  "Scheduled For",
                                  style:
                                      themeBloc.state.textTheme.button.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[900],
                                    fontSize: ScreenUtil().setSp(30.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: ScreenUtil().setWidth(25),
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: () async {
                                  if (hantarrBloc.state.hUser.firebaseUser !=
                                      null) {
                                    if (widget
                                        .p2pTransaction.remark.isNotEmpty) {
                                      var confirmation = await widget
                                          .p2pTransaction
                                          .choosePaymentMethod(
                                              context, setFunction);
                                      if (confirmation == "yes") {
                                        loadingWidget(context);
                                        var validateOrder = await widget
                                            .p2pTransaction
                                            .ableToPlaceOrder();
                                        Navigator.pop(context);
                                        if (validateOrder['success']) {
                                          loadingWidget(context);
                                          debugPrint(jsonEncode(
                                              widget.p2pTransaction.toJson()));
                                          var createOrderReq = await widget
                                              .p2pTransaction
                                              .createTransaction();
                                          Navigator.pop(context);
                                          if (createOrderReq['success']) {
                                            // Navigator.of(context)
                                            //     .pushNamedAndRemoveUntil(
                                            //         newMainScreen,
                                            //         (Route<dynamic> route) =>
                                            //             false);
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                              p2pDetailPage,
                                              ModalRoute.withName(
                                                  newMainScreen),
                                              arguments: widget.p2pTransaction,
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      "Create Delivery Order Failed."),
                                                  content: Text(
                                                      "${createOrderReq['reason']}"),
                                                  actions: [
                                                    FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      color: Colors.orange[900],
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(25.0),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "OK",
                                                        style: themeBloc.state
                                                            .textTheme.button
                                                            .copyWith(
                                                          inherit: true,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "Create Delivery Order Failed."),
                                                content: Text(
                                                    "${validateOrder['reason']}"),
                                                actions: [
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: Colors.orange[900],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(25.0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "OK",
                                                      style: themeBloc.state
                                                          .textTheme.button
                                                          .copyWith(
                                                        inherit: true,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      }
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title:
                                                Text("Remark cannot be empty"),
                                            content: Text("Please add remark"),
                                            actions: [
                                              FlatButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                ),
                                                color: themeBloc
                                                    .state.primaryColor,
                                                child: Text(
                                                  "OK",
                                                  style: themeBloc
                                                      .state.textTheme.button
                                                      .copyWith(
                                                    inherit: true,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    Navigator.pushNamed(context, loginPage);
                                  }
                                },
                                color: Colors.orange[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                ),
                                child: Text(
                                  "Proceed",
                                  style:
                                      themeBloc.state.textTheme.button.copyWith(
                                    inherit: true,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(15),
                      ),
                    ],
                  )
                : null,
            body: Container(
              padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(25.0),
                right: ScreenUtil().setWidth(25.0),
              ),
              child: ListView(
                controller: sc,
                children: <Widget>[
                  AnimatedOpacity(
                    opacity: _showAppbar ? 0.0 : 1.0,
                    duration: Duration(
                      milliseconds: 300,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.transparent,
                        ),
                      ),
                      title: Text(
                        widget.p2pTransaction.id != null
                            ? "Delivery: #${widget.p2pTransaction.id}"
                            : "New Delivery",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: mediaQ.width,
                    padding: EdgeInsets.all(
                      ScreenUtil().setSp(10.0),
                    ),
                    child: Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: P2PStopsTimeLine(
                        p2pTransaction: widget.p2pTransaction,
                      ),
                    ),
                    //  GoogleMapWithRoute(
                    //   p2pTransaction: widget.p2pTransaction,
                    // ),
                  ),
                  Container(
                    padding: EdgeInsets.all(
                      ScreenUtil().setSp(10.0),
                    ),
                    child: Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(25.0),
                          right: ScreenUtil().setWidth(25.0),
                          top: ScreenUtil().setHeight(15.0),
                          bottom: ScreenUtil().setHeight(15.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                "Remarks",
                                style: themeBloc.state.textTheme.headline6
                                    .copyWith(
                                  inherit: true,
                                ),
                              ),
                            ),
                            Container(
                              width: mediaQ.width * .9,
                              child: TextFormField(
                                readOnly: widget.p2pTransaction.id == null
                                    ? false
                                    : true,
                                controller: TextEditingController(
                                  text: widget.p2pTransaction.remark,
                                ),
                                maxLines: null,
                                maxLengthEnforced: true,
                                maxLength: 500,
                                decoration: InputDecoration(
                                    hintText: "No Plastic Bag",
                                    hintStyle: themeBloc
                                        .state.textTheme.bodyText1
                                        .copyWith(
                                      color: Colors.grey[300],
                                    )),
                                onChanged: (val) {
                                  widget.p2pTransaction.remark = val;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  widget.p2pTransaction.id != null
                      ? Container(
                          padding: EdgeInsets.all(
                            ScreenUtil().setSp(10.0),
                          ),
                          child: Card(
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child: P2PTrackingTimeLine(
                              p2pTransaction: widget.p2pTransaction,
                            ),
                          ),
                        )
                      : Container(),
                  P2PPriceDetailWidget(
                    p2pTransaction: widget.p2pTransaction,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(160),
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
