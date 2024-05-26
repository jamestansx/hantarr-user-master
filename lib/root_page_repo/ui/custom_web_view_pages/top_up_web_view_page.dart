import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:line_icons/line_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class TopUpWebViewPage extends StatefulWidget {
  String url;
  TopUpWebViewPage({@required this.url});
  @override
  _TopUpWebViewPageState createState() => _TopUpWebViewPageState();
}

class _TopUpWebViewPageState extends State<TopUpWebViewPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              "Hantarr E-Wallet FPX Online",
              style: TextStyle(
                color: Colors.yellow[800],
                fontSize: ScreenUtil().setSp(45),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                LineIcons.close,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Builder(builder: (BuildContext context) {
            return WebView(
              initialUrl: '${widget.url}',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              navigationDelegate: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onPageFinished: (String url) async {
                print('Page finished loading: $url');
                if (url.contains("thank_you")) {
                  try {
                    var decoded = Uri.decodeFull(url);
                    print(decoded);
                    Uri uri = Uri.dataFromString(decoded);
                    String billPlzID = "";

                    uri.queryParameters.forEach(
                      (k, v) {
                        print(k + " - " + v);
                        if (k == "billplz[id]") {
                          billPlzID = v;
                          debugPrint(billPlzID);
                        }
                      },
                    );

                    Dio dio = getDio(
                      baseOption: 1,
                      queries: {
                        "field": "billplz_status",
                        "bill_id": "$billPlzID"
                      },
                    );
                    Response response = await dio.get("/sales");
                    print(response.requestOptions.uri.toString());
                    print(response.data.toString());
                    if (response.data['paid'] == true) {
                      if (mounted) {
                        hantarrBloc.state.hUser.getUserData();
                        Navigator.of(context).pop();
                        UniqueKey key = UniqueKey();
                        BotToast.showWidget(
                            key: key,
                            toastBuilder: (_) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                title: Container(
                                    child: Image.asset(
                                        "assets/orderComplete.png",
                                        width: ScreenUtil().setWidth(500),
                                        height: ScreenUtil().setWidth(400))),
                                content: Text(
                                  "Top Up Successfully !",
                                  style: themeBloc.state.textTheme.headline6
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(30.0),
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      BotToast.remove(key);
                                    },
                                    child: Text(
                                      "GOT IT",
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(30.0),
                                        color: themeBloc.state.primaryColor,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            });
                      }
                    } else {
                      if (mounted) {
                        Navigator.of(context).pop();
                        UniqueKey key = UniqueKey();
                        BotToast.showWidget(
                            key: key,
                            toastBuilder: (_) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                title: Container(
                                    child: Image.asset("assets/warning.png",
                                        width: ScreenUtil().setWidth(500),
                                        height: ScreenUtil().setWidth(400))),
                                content: Text(
                                  "Top Up Failed !",
                                  style: themeBloc.state.textTheme.headline6
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(30.0),
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      BotToast.remove(key);
                                    },
                                    child: Text(
                                      "OK",
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(30.0),
                                        color: themeBloc.state.primaryColor,
                                      ),
                                    ),
                                  )
                                ],
                              );
                            });
                      }
                    }

                    // var getPaidStatus = await get(
                    //     "$foodUrl/sales?field=billplz_status&bill_id=$billPlzID");
                    // debugPrint(getPaidStatus.body.toString());

                  } catch (e) {
                    debugPrint("${e.toString()}");
                    Navigator.of(context).pop();
                  }
                }
              },
              gestureNavigationEnabled: true,
            );
          }),
        );
      },
    );
  }
}
