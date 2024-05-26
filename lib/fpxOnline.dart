import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/root_page_repo/ui/login_overlay_page/login_overlay_page.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:http/http.dart';

// ignore: must_be_immutable
class FpxOnline extends StatefulWidget {
  bool hideAppBar;
  double minAmount;
  FpxOnline({
    this.hideAppBar = false,
    @required this.minAmount,
  });

  @override
  State<StatefulWidget> createState() => new FpxOnlineState();
}

class FpxOnlineState extends State<FpxOnline> {
  double presetAmount;
  TextEditingController amountController = TextEditingController();
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  FocusNode amountFnode = FocusNode();
  StreamSubscription<String> _onUrlChanged;
  @override
  void initState() {
    if (widget.minAmount <= 50) {
      presetAmount = 100;
    } else if (widget.minAmount < 100) {
      presetAmount = 1000;
    } else if (widget.minAmount < 150) {
      presetAmount = 1500;
    } else {
      presetAmount = 500;
    }

    // widget.minAmount = 1;

    _onUrlChanged =
        flutterWebViewPlugin.onUrlChanged.listen((String url) async {
      if (mounted) {
        String decodeUrl = Uri.decodeFull(url);
        print(decodeUrl);

        if (decodeUrl.contains("thank_you")) {
          String billPlzID = decodeUrl.split("=").last;
          var getPaidStatus = await get(Uri.tryParse(
              "$foodUrl/sales?field=billplz_status&bill_id=$billPlzID"));
          Navigator.of(context).pop();
          Navigator.of(context).pop();

          if (jsonDecode(getPaidStatus.body)['paid']) {
            hantarrBloc.state.hUser.creditBalance +=
                num.tryParse(amountController.text).toDouble();
            hantarrBloc.add(Refresh());
            showDialog(
                context: context,
                builder: (
                  BuildContext context,
                ) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.check_circle,
                          color: Colors.lightGreen,
                          size: ScreenUtil()
                              .setSp(150, allowFontScalingSelf: true),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(50),
                        ),
                        Text(
                          hantarrBloc.state.translation
                              .text("Reloaded Successfully !"),
                          style: themeBloc.state.textTheme.bodyText1,
                        ),
                      ],
                    ),
                  );
                });
          } else {
            showDialog(
                context: context,
                builder: (
                  BuildContext context,
                ) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: ScreenUtil()
                              .setSp(150, allowFontScalingSelf: true),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(50),
                        ),
                        Text(
                          hantarrBloc.state.translation
                              .text("Reload Failed ! Please try again later"),
                          style: themeBloc.state.textTheme.bodyText1,
                        )
                      ],
                    ),
                  );
                });
          }
        }
      } else {
        print("not mounted $url");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    print("dispose");
    _onUrlChanged.cancel();

    flutterWebViewPlugin.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
        bloc: hantarrBloc,
        builder: (context, state) {
          return Scaffold(
            appBar: !widget.hideAppBar
                ? AppBar(
                    iconTheme: IconThemeData(
                      color: Colors.black, //change your color here
                    ),
                    title: Text(
                      "FPX Online",
                      style: themeBloc.state.textTheme.headline6.copyWith(
                        inherit: true,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  )
                : null,
            body: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setSp(25.0)),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          !widget.hideAppBar
                              ? Card(
                                  color: themeBloc.state.primaryColor,
                                  child: Container(
                                    padding: themeBloc.state.cardTheme.margin,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: ScreenUtil().setSp(20),
                                              top: ScreenUtil().setSp(20)),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Text(
                                            hantarrBloc.state.translation
                                                .text("E-Wallet Balance"),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize:
                                                    ScreenUtil().setSp(50),
                                                color: Colors.white),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: ScreenUtil().setSp(250,
                                                allowFontScalingSelf: true),
                                            right: ScreenUtil().setSp(250,
                                                allowFontScalingSelf: true),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      15.0),
                                            ),
                                            // elevation: 20,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                              padding: EdgeInsets.all(
                                                  ScreenUtil().setSp(20)),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "MYR ${hantarrBloc.state.hUser.creditBalance.toStringAsFixed(2)}",
                                                    style: themeBloc.state
                                                        .textTheme.headline6,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.refresh),
                                                    onPressed: () async {
                                                      loadingWidget(context);
                                                      await hantarrBloc
                                                          .state.hUser
                                                          .getUserData();
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(height: ScreenUtil().setHeight(100)),
                          Container(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 5.0,
                              runSpacing: 5.0,
                              children: <Widget>[
                                RaisedButton(
                                  shape: themeBloc.state.cardTheme.shape,
                                  elevation: 0,
                                  color: themeBloc.state.accentColor,
                                  onPressed: () {
                                    setState(() {
                                      amountController.text =
                                          presetAmount.toStringAsFixed(0);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: AutoSizeText(
                                      "MYR ${(presetAmount).toStringAsFixed(0)}",
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  shape: themeBloc.state.cardTheme.shape,
                                  elevation: 0,
                                  color: themeBloc.state.accentColor,
                                  onPressed: () {
                                    setState(() {
                                      amountController.text =
                                          (presetAmount + 50)
                                              .toStringAsFixed(0);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "MYR ${(presetAmount + 50).toStringAsFixed(0)}",
                                      textAlign: TextAlign.center,
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  shape: themeBloc.state.cardTheme.shape,
                                  elevation: 0,
                                  color: themeBloc.state.accentColor,
                                  onPressed: () {
                                    setState(() {
                                      amountController.text =
                                          (presetAmount + 100)
                                              .toStringAsFixed(0);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "MYR ${(presetAmount + 100).toStringAsFixed(0)}",
                                      textAlign: TextAlign.center,
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  shape: themeBloc.state.cardTheme.shape,
                                  elevation: 0,
                                  color: themeBloc.state.accentColor,
                                  onPressed: () {
                                    setState(() {
                                      amountController.text =
                                          (presetAmount + 400)
                                              .toStringAsFixed(0);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "MYR ${(presetAmount + 400).toStringAsFixed(0)}",
                                      textAlign: TextAlign.center,
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  shape: themeBloc.state.cardTheme.shape,
                                  elevation: 0,
                                  color: themeBloc.state.accentColor,
                                  onPressed: () {
                                    setState(() {
                                      amountController.text =
                                          (presetAmount + 900)
                                              .toStringAsFixed(0);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "MYR ${(presetAmount + 900).toStringAsFixed(0)}",
                                      textAlign: TextAlign.center,
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  shape: themeBloc.state.cardTheme.shape,
                                  elevation: 0,
                                  color: themeBloc.state.accentColor,
                                  onPressed: () {
                                    setState(() {
                                      amountController.text =
                                          (presetAmount + 1900)
                                              .toStringAsFixed(0);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "MYR ${(presetAmount + 1900).toStringAsFixed(0)}",
                                      textAlign: TextAlign.center,
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(50),
                          ),
                          Container(
                            child: TextField(
                              controller: amountController,
                              focusNode: amountFnode,
                              keyboardType: TextInputType.number,
                              style: themeBloc.state.textTheme.headline6,
                              decoration: InputDecoration(
                                fillColor: Colors.grey[100],
                                filled: true,
                                labelText: hantarrBloc.state.translation
                                    .text("Enter Top-up Amount"),
                                prefix: Text(
                                  "MYR ",
                                  style: TextStyle(
                                    color: Colors.yellow[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(60),
                                  ),
                                ),
                                labelStyle: themeBloc.state.textTheme.bodyText1,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              "Min top-up amount is MYR ${widget.minAmount.toStringAsFixed(2)}",
                              style:
                                  themeBloc.state.textTheme.subtitle2.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 15,
                              left: 25,
                              right: 25,
                            ),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              onPressed: () async {
                                try {
                                  if (hantarrBloc.state.hUser.firebaseUser
                                          .phoneNumber !=
                                      null) {
                                    if (num.tryParse(amountController.text)
                                            .toDouble() >=
                                        widget.minAmount) {
                                      // loadingDialog(context);
                                      FormData formData = FormData.fromMap({
                                        "topup": {
                                          "uuid": hantarrBloc
                                              .state.hUser.firebaseUser.uid,
                                          "payment_method": "billplz",
                                          "amount": amountController.text
                                        }
                                      });

                                      var response = await Dio().post(
                                          "$foodUrl/topup/new",
                                          data: formData);
                                      print(response.data);
                                      try {
                                        if (response.data["id"] != null) {
                                          // Navigator.of(context).pop();
                                          // webViewWidget(
                                          //     context,
                                          //     response.data["remarks"],
                                          //     flutterWebViewPlugin,
                                          //     'Hantarr E-Wallet FPX Online');
                                          Navigator.pushNamed(
                                            context,
                                            topUpWebView,
                                            arguments: response.data["remarks"],
                                          );
                                        }
                                      } catch (e) {
                                        // Navigator.of(context).pop();
                                        BotToast.showText(
                                          text: "Failed to upload!",
                                          duration: Duration(seconds: 3),
                                        );
                                      }
                                    } else {
                                      BotToast.showText(
                                        text:
                                            "Top-up value lesser than MYR ${widget.minAmount.toStringAsFixed(2)}",
                                        duration: Duration(seconds: 3),
                                      );
                                    }
                                  } else {
                                    var getLoginReq = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              "Please bind to a phone number first"),
                                          actions: [
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context, "no");
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                              child: Text(
                                                "Cancel",
                                                style: themeBloc
                                                    .state.textTheme.button
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      ScreenUtil().setSp(32.0),
                                                ),
                                              ),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context, "yes");
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                              color:
                                                  themeBloc.state.primaryColor,
                                              child: Text(
                                                "Bind Phone Number",
                                                style: themeBloc
                                                    .state.textTheme.button
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize:
                                                      ScreenUtil().setSp(32.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (getLoginReq == "yes") {
                                      Navigator.pushNamed(
                                          context, manageMyAccountPage);
                                    }
                                  }
                                } catch (e) {
                                  BotToast.showText(
                                    text: "Invalid top-up amount!",
                                    duration: Duration(seconds: 3),
                                  );
                                }
                              },
                              color: themeBloc.state.primaryColor,
                              child: Container(
                                padding: EdgeInsets.all(ScreenUtil().setSp(25)),
                                child: Text(
                                  hantarrBloc.state.translation.text("Reload"),
                                  style: themeBloc.state.textTheme.headline6
                                      .copyWith(
                                    inherit: true,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ]),
                      )
                    ],
                  ),
                ),
                hantarrBloc.state.hUser.firebaseUser == null
                    ? loginOverylayWidget(context)
                    : Container(),
              ],
            ),
          );
        });
  }
}
