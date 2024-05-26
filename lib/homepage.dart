import 'dart:io';
import 'package:hantarr/module/user_module.dart' as hantarrUser;
import 'package:flutter/cupertino.dart';
import 'package:hantarr/accountPage.dart';
import 'package:hantarr/addressBook.dart';
import 'package:hantarr/deliveryTrackingList.dart';
import 'package:hantarr/new_food_delivery_repo/ui/history_pages/historyPage.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/root_page_repo/ui/top_up_pages/topuphistoryPage.dart';
import 'package:launch_review/launch_review.dart';

class Homepage extends StatefulWidget {
  Homepage({Key key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _drawerController = ZoomDrawerController();
  @override
  void initState() {
    checkVersionUpdates();
    super.initState();
  }

  executeUpdateFunction(String newversion, List<String> splitversion) {
    if (newversion.split(".").length == 4) {
      if (Platform.isAndroid) {
        if (splitversion[3] == "1" || splitversion[3] == "3") {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                String title = "New Update Available !";
                String message =
                    "This update is compulsory , please update to continue using it.";
                String btnLabel = "Update Now";

                return new WillPopScope(
                  onWillPop: () {
                    return null;
                  },
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    title: Text(title,
                        style: TextStyle(fontSize: 15), textScaleFactor: 1),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(image: AssetImage("assets/update.png")),
                        Text(
                          message,
                          style: TextStyle(fontSize: 15),
                          textScaleFactor: 1,
                        )
                      ],
                    ),
                    actions: <Widget>[
                      RaisedButton(
                        color: themeBloc.state.primaryColor,
                        child: Text(
                          btnLabel,
                          style: TextStyle(color: Colors.white, fontSize: 13),
                          textScaleFactor: 1,
                        ),
                        onPressed: () {
                          LaunchReview.launch(
                              androidAppId: "com.resertech.hantarr",
                              iOSAppId: "1491122303");
                        },
                      ),
                    ],
                  ),
                );
              });
        }
      } else {
        if (splitversion[3] == "2" || splitversion[3] == "3") {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                String title = "New Update Available !";
                String message =
                    "This update is compulsory , please update to continue using it.";
                String btnLabel = "Update Now";

                return new WillPopScope(
                  onWillPop: () {
                    return null;
                  },
                  child: CupertinoAlertDialog(
                    title: Text(title,
                        style: TextStyle(fontSize: 15), textScaleFactor: 1),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(image: AssetImage("assets/update.png")),
                        Text(
                          message,
                          style: TextStyle(fontSize: 15),
                          textScaleFactor: 1,
                        )
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          btnLabel,
                          style: TextStyle(color: Colors.white, fontSize: 13),
                          textScaleFactor: 1,
                        ),
                        onPressed: () {
                          LaunchReview.launch(
                              androidAppId: "com.resertech.hantarr",
                              iOSAppId: "1491122303");
                        },
                      ),
                    ],
                  ),
                );
              });
        }
      }
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            String title = "New Update Available";
            String message =
                "There is a newer version of app available please update it now.";
            String btnLabel = "Update Now";
            String btnLabelCancel = "Later";
            if (Platform.isAndroid) {
              return new AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Text(title,
                    style: TextStyle(fontSize: 15), textScaleFactor: 1),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(image: AssetImage("assets/update.png")),
                    Text(
                      message,
                      style: TextStyle(fontSize: 15),
                      textScaleFactor: 1,
                    )
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabelCancel,
                        style: TextStyle(
                            fontSize: 13, color: themeBloc.state.primaryColor),
                        textScaleFactor: 1),
                    onPressed: () => Navigator.pop(context),
                  ),
                  RaisedButton(
                    color: themeBloc.state.primaryColor,
                    child: Text(
                      btnLabel,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      textScaleFactor: 1,
                    ),
                    onPressed: () {
                      LaunchReview.launch(
                          androidAppId: "com.resertech.hantarr",
                          iOSAppId: "1491122303");
                    },
                  ),
                ],
              );
            } else {
              return new CupertinoAlertDialog(
                title: Text(title,
                    style: TextStyle(fontSize: 15), textScaleFactor: 1),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(image: AssetImage("assets/update.png")),
                    Text(
                      message,
                      style: TextStyle(fontSize: 15),
                      textScaleFactor: 1,
                    )
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabelCancel,
                        style: TextStyle(fontSize: 13), textScaleFactor: 1),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FlatButton(
                    child: Text(
                      btnLabel,
                      style: TextStyle(fontSize: 13),
                      textScaleFactor: 1,
                    ),
                    onPressed: () {
                      LaunchReview.launch(
                          androidAppId: "com.resertech.hantarr",
                          iOSAppId: "1491122303");
                    },
                  ),
                ],
              );
            }
          });
    }
  }

  checkVersionUpdates() async {
    // var dtResponse = await http.get("${url}api/server_time");
    // restaurantDT =
    //     DateTime.parse(jsonDecode(dtResponse.body.replaceAll("Z", "")))
    //         .add(Duration(hours: 8));
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String os;
    if (Platform.isAndroid) {
      os = "h_android";
    } else if (Platform.isIOS) {
      os = "h_ios";
    } else {
      os = "unable_detect";
    }
    hantarrBloc.state.versionName = packageInfo.version;
    hantarrBloc.add(Refresh());

    get(Uri.tryParse(
            "$foodUrl/get_latest_apk/snaelMarketplace/${packageInfo.version}?uuid=${hantarrBloc.state.user.uuid}&os=$os"))
        .then((data) {
      if (data.body.isNotEmpty && data.body != "null") {
        // String newversion = "1.4.3.1";
        String newversion = json.decode(data.body)["version"];
        print(newversion + "versionnnn");
        print(packageInfo.version);
        List<String> splitversion = newversion.split(".");
        // List<String> oldSplitVersion = packageInfo.version.split(".");
        List<String> oldSplitVersion = packageInfo.version.split(".");
        if (num.tryParse(splitversion[0]).toInt() >
            num.tryParse(oldSplitVersion[0]).toInt()) {
          //first digit
          executeUpdateFunction(newversion, splitversion);
        } else if (num.tryParse(splitversion[0]).toInt() ==
            num.tryParse(oldSplitVersion[0]).toInt()) {
          if (num.tryParse(splitversion[1]).toInt() >
              num.tryParse(oldSplitVersion[1]).toInt()) {
            // second digit
            executeUpdateFunction(newversion, splitversion);
          } else if (num.tryParse(splitversion[1]).toInt() ==
              num.tryParse(oldSplitVersion[1]).toInt()) {
            if (num.tryParse(splitversion[2]).toInt() >
                num.tryParse(oldSplitVersion[2]).toInt()) {
              executeUpdateFunction(newversion, splitversion);
            }
          }
        }
      }
    }).catchError((e) {
      print("no latest version");
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      // return Scaffold(
      //   appBar: AppBar(
      //     elevation: 0,
      //     backgroundColor: Colors.white,
      //     title: Container(
      //       width: ScreenUtil().setSp(210),
      //       child: Image.asset("assets/logoword.png"),
      //     ),
      //   ),
      //   body: Container(),
      // );
      return ZoomDrawer(
        controller: _drawerController,
        menuScreen: Scaffold(
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: themeBloc.state.primaryColor,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      width: ScreenUtil().setSp(500),
                      child: Image.asset("assets/logowordWhite.png"),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(30),
                          right: ScreenUtil().setSp(10),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                              top: ScreenUtil().setSp(20),
                              bottom: ScreenUtil().setSp(20)),
                          width: ScreenUtil().setSp(500),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  if (hantarrBloc.state.user.uuid == null) {
                                    _drawerController.close();
                                    showSignInDialog(context);
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AccountPage()));
                                  }
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.people,
                                    color: themeBloc.state.primaryColor,
                                    size: ScreenUtil()
                                        .setSp(60, allowFontScalingSelf: true),
                                  ),
                                  title: Text(
                                    hantarrBloc.state.translation
                                        .text("My Account"),
                                    style: GoogleFonts.aBeeZee(
                                        textStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(40),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                color: themeBloc.state.primaryColor,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (hantarrBloc.state.user.uuid == null) {
                                    _drawerController.close();
                                    showSignInDialog(context);
                                  } else {
                                    await hantarrUser.User().getTopupHistory();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TopUpHistoryPage()));
                                  }
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.account_balance_wallet,
                                    color: themeBloc.state.primaryColor,
                                    size: ScreenUtil()
                                        .setSp(60, allowFontScalingSelf: true),
                                  ),
                                  title: Text(
                                    hantarrBloc.state.translation
                                        .text("Top-Up History"),
                                    style: GoogleFonts.aBeeZee(
                                        textStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(40),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                color: themeBloc.state.primaryColor,
                              ),
                              InkWell(
                                onTap: () {
                                  if (hantarrBloc.state.user.uuid == null) {
                                    _drawerController.close();
                                    showSignInDialog(context);
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddressBook()));
                                  }
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.book,
                                    color: themeBloc.state.primaryColor,
                                    size: ScreenUtil()
                                        .setSp(60, allowFontScalingSelf: true),
                                  ),
                                  title: Text(
                                    hantarrBloc.state.translation
                                        .text("Address Book"),
                                    style: GoogleFonts.aBeeZee(
                                        textStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(40),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                color: themeBloc.state.primaryColor,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (hantarrBloc.state.user.uuid == null) {
                                    _drawerController.close();
                                    showSignInDialog(context);
                                  } else {
                                    loadingWidget(context);
                                    await Delivery().getDoneOrder();
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HistoryPage()));
                                  }
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.history,
                                    color: themeBloc.state.primaryColor,
                                    size: ScreenUtil()
                                        .setSp(60, allowFontScalingSelf: true),
                                  ),
                                  title: Text(
                                    hantarrBloc.state.translation
                                        .text("Delivery History"),
                                    style: GoogleFonts.aBeeZee(
                                        textStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(40),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                color: themeBloc.state.primaryColor,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (hantarrBloc.state.user.uuid == null) {
                                    _drawerController.close();
                                    showSignInDialog(context);
                                  } else {
                                    loadingWidget(context);
                                    await Delivery().getPendingOrder();
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DeliveryTrackingList()));
                                  }
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.track_changes,
                                    color: themeBloc.state.primaryColor,
                                    size: ScreenUtil()
                                        .setSp(60, allowFontScalingSelf: true),
                                  ),
                                  title: Text(
                                    hantarrBloc.state.translation
                                        .text("Delivery Tracking"),
                                    style: GoogleFonts.aBeeZee(
                                        textStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(40),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Container(
                      width: ScreenUtil().setSp(550),
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(30),
                        right: ScreenUtil().setSp(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                              hantarrBloc.state.translation.text("Version") +
                                  " ${hantarrBloc.state.versionName}",
                              style: GoogleFonts.aBeeZee(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.w500))),
                          Text(hantarrBloc.state.translation.text("Language"),
                              style: GoogleFonts.aBeeZee(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.w500))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                // color: Colors.red,
                                padding: EdgeInsets.all(ScreenUtil().setSp(10)),
                                width: ScreenUtil().setWidth(160),
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                  color: Colors.white,
                                  onPressed: () async {
                                    hantarrBloc.state.translation.lang = "en";
                                    hantarrBloc.add(Refresh());
                                    await hantarrBloc.state.storage
                                        .write(key: "language", value: "en");
                                  },
                                  child: Text(
                                    "EN",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        color: hantarrBloc
                                                    .state.translation.lang ==
                                                "en"
                                            ? themeBloc.state.primaryColor
                                            : Colors.grey,
                                        fontSize: ScreenUtil().setSp(25)),
                                  ),
                                ),
                              ),
                              Container(
                                // color: Colors.red,
                                padding: EdgeInsets.all(ScreenUtil().setSp(10)),
                                width: ScreenUtil().setWidth(160),
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                  color: Colors.white,
                                  onPressed: () async {
                                    hantarrBloc.state.translation.lang = "cn";
                                    hantarrBloc.add(Refresh());
                                    await hantarrBloc.state.storage
                                        .write(key: "language", value: "cn");
                                  },
                                  child: Text(
                                    "中",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        color: hantarrBloc
                                                    .state.translation.lang ==
                                                "cn"
                                            ? themeBloc.state.primaryColor
                                            : Colors.grey,
                                        fontSize: ScreenUtil().setSp(25)),
                                  ),
                                ),
                              ),
                              Container(
                                // color: Colors.red,
                                padding: EdgeInsets.all(ScreenUtil().setSp(10)),
                                width: ScreenUtil().setWidth(160),
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                  color: Colors.white,
                                  onPressed: () async {
                                    hantarrBloc.state.translation.lang = "bm";
                                    hantarrBloc.add(Refresh());
                                    await hantarrBloc.state.storage
                                        .write(key: "language", value: "bm");
                                  },
                                  child: Text(
                                    "BM",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        color: hantarrBloc
                                                    .state.translation.lang ==
                                                "bm"
                                            ? themeBloc.state.primaryColor
                                            : Colors.grey,
                                        fontSize: ScreenUtil().setSp(25)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        mainScreen: MainScreen(
          drawerController: _drawerController,
        ),
        borderRadius: 24.0,
        showShadow: true,
        angle: 0.0,
        backgroundColor: Colors.grey[300],
        slideWidth: MediaQuery.of(context).size.width *
            (ZoomDrawer.isRTL() ? .45 : 0.65),
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.bounceIn,
      );
    });
  }
}
