import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hantarr/accountPage.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/fpxOnline.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_advertisement_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/ads_pages/ads_page.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/vehicle_module.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/root_page_repo/modules/user_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:hantarr/utilities/new_check_version.dart';
import 'package:hantarr/utilities/update_dialog.dart';
import 'package:line_icons/line_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:version/version.dart';

class NewMainScreen extends StatefulWidget {
  @override
  _NewMainScreenState createState() => _NewMainScreenState();
}

class _NewMainScreenState extends State<NewMainScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  ScrollController sc = ScrollController();
  int _selectedItemPosition = 1;
  PageController pageController;

  @override
  void initState() {
    checking();
    pageController = PageController(
      initialPage: _selectedItemPosition,
      keepPage: true,
    );
    checkVersion();

    Future.delayed(Duration(milliseconds: 200), () {
      getServerTime();
    });
    super.initState();
  }

  checking() {
    Future.delayed(Duration(milliseconds: 2000), () {
      if (hantarrBloc.state.hUser.firebaseUser != null) {
        if (hantarrBloc.state.hUser.firebaseUser.email == null) {
          BotToast.showText(text: "Please connect to your social account");
          Navigator.pushNamed(context, manageMyAccountPage);
        }
      }
    });
  }

  @override
  void dispose() {
    sc.dispose();
    _refreshController.dispose();
    pageController.dispose();
    super.dispose();
  }

  getAds() async {
    // hantarrBloc.state.showedAds = false; // for debug purpose
    if (hantarrBloc.state.showedAds == false) {
      var getAdsReq = await NewAdvertisement().getListAdvertisement();
      if (getAdsReq['success']) {
        hantarrBloc.state.showedAds = true;
        hantarrBloc.add(Refresh());
        if (hantarrBloc.state.advertisements.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                backgroundColor: themeBloc.state.scaffoldBackgroundColor,
                insetPadding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: AdsPage(),
              );
            },
          );
        }
      } else {
        debugPrint("get ads failed.");
      }
    }
  }

  checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    hantarrBloc.state.versionName = packageInfo.version;
    await hantarrBloc.state.hUser.logVersion(hantarrBloc.state.versionName);
    hantarrBloc.add(Refresh());
    getVersion(hantarrBloc.state.app).then(
      (val) {
        print(val);
        try {
          if (Platform.isAndroid) {
            bool isLower = false;
            try {
              Version thisVersion =
                  Version.parse(hantarrBloc.state.versionName);
              Version newVersion = Version.parse(val['androidVersion']);
              if (thisVersion < newVersion) {
                isLower = true;
              } else {
                isLower = false;
              }
            } catch (e) {
              isLower = false;
            }

            if (isLower && val['forceAndroid'] == true) {
              print("Force Update");
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return UpdateVersionDialog(
                      force: val['forceAndroid'],
                      androidAppID: val['playstore'],
                      iosAppID: val['appstore'],
                      newAndroidVersion: val['androidVersion'],
                      newIosVersion: val['iosVersion'],
                    );
                  });
            } else if (isLower) {
              print("new android version available ${val['androidVersion']}");
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return UpdateVersionDialog(
                      force: val['forceAndroid'],
                      androidAppID: val['playstore'],
                      iosAppID: val['appstore'],
                      newAndroidVersion: val['androidVersion'],
                      newIosVersion: val['iosVersion'],
                    );
                  });
            }
          } else {
            bool isLower = false;
            try {
              Version thisVersion =
                  Version.parse(hantarrBloc.state.versionName);
              Version newVersion = Version.parse(val['iosVersion']);
              if (thisVersion < newVersion) {
                isLower = true;
              } else {
                isLower = false;
              }
            } catch (e) {
              isLower = false;
            }
            if (isLower && val['forceIOS'] == true) {
              print("Force Update");
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return UpdateVersionDialog(
                      force: val['forceIOS'],
                      androidAppID: val['playstore'],
                      iosAppID: val['appstore'],
                      newAndroidVersion: val['androidVersion'],
                      newIosVersion: val['iosVersion'],
                    );
                  });
            } else if (isLower) {
              print("new ios version available ${val['androidVersion']}");
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return UpdateVersionDialog(
                      force: val['forceIOS'],
                      androidAppID: val['playstore'],
                      iosAppID: val['appstore'],
                      newAndroidVersion: val['androidVersion'],
                      newIosVersion: val['iosVersion'],
                    );
                  });
            }
          }
        } catch (e) {
          print(e);
        }
      },
    );
  }

  void getOrders() async {
    var getFoodOrderListReq = await NewFoodDelivery().getPendingDelivery();
    var getP2PPendingOrderListReq = await P2pTransaction().getPendingP2Ps();
    if (getFoodOrderListReq['success'] &&
        getP2PPendingOrderListReq['success']) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  void getServerTime() async {
    loadingWidget(context);
    var getServerTimeReq = await HantarrUser.initClass().getCurrentTime();
    Navigator.pop(context);
    if (getServerTimeReq['success']) {
      getAds();
      // getAddress();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () {
              return null;
            },
            child: AlertDialog(
              title: Text(
                "Get Time Failed.",
              ),
              content: Text(
                "${getServerTimeReq['reason']}",
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    getServerTime();
                  },
                  child: Text(
                    "Retry",
                    style: themeBloc.state.textTheme.button.copyWith(
                      inherit: true,
                      fontWeight: FontWeight.bold,
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

  // getAddress() async {
  //   if (hantarrBloc.state.hUser.id != null) {
  //     BotToast.showLoading();
  //     var getAddresReq = await Address().getListAddress();
  //     BotToast.closeAllLoading();
  //     List<Address> addressList = getAddresReq['data'];
  //     if (addressList
  //         .where((x) => x.address == hantarrBloc.state.foodCart.address)
  //         .isEmpty) {
  //       BotToast.showLoading();
  //     } else {
  //       hantarrBloc.state.foodCart.addressID = addressList
  //           .where((x) => x.address == hantarrBloc.state.foodCart.address)
  //           .first
  //           .id;
  //     }
  //   }
  // }

  bool loginCheck() {
    if (hantarrBloc.state.hUser.firebaseUser != null) {
      return true;
    } else {
      return false;
    }
  }

  void routing(String routename, Map<String, dynamic> arguments) {
    if (routename.contains(newRestaurantPage)) {
      Navigator.pushNamed(
        context,
        routename,
        arguments: arguments,
      );
    } else {
      if (hantarrBloc.state.hUser.firebaseUser != null) {
        Navigator.pushNamed(context, routename, arguments: arguments);
      } else {
        BotToast.showText(
            text: "Please login first", duration: Duration(seconds: 5));
        Navigator.pushNamed(context, loginPage, arguments: arguments);
      }
    }
  }

  void askLogout() async {
    var confirmation = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Proceed to logout?",
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context, 'no');
              },
              child: Text(
                "Cancel",
                style: themeBloc.state.textTheme.button.copyWith(
                  inherit: true,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context, 'yes');
              },
              child: Text(
                "Log Out",
                style: themeBloc.state.textTheme.button.copyWith(
                  inherit: true,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmation == "yes") {
      await hantarrBloc.state.user.signOut();
      Phoenix.rebirth(context);
    }
  }

  // void _getPlace() async {
  //   try {
  //     if (hantarrBloc.state.hUser.longitude != null &&
  //         hantarrBloc.state.hUser.latitude != null) {
  //       List<Placemark> newPlace = await placemarkFromCoordinates(
  //         hantarrBloc.state.hUser.latitude,
  //         hantarrBloc.state.hUser.longitude,
  //       );
  //       // this is all you need
  //       Placemark placeMark = newPlace[0];
  //       String name = placeMark.name;
  //       String subLocality = placeMark.subLocality;
  //       String locality = placeMark.locality;
  //       String administrativeArea = placeMark.administrativeArea;
  //       String postalCode = placeMark.postalCode;
  //       String country = placeMark.country;
  //       hantarrBloc.state.foodCart.address =
  //           "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
  //       print(hantarrBloc.state.foodCart.address);
  //       hantarrBloc.add(Refresh());
  //     } else {
  //       print("getting location");
  //       var getLocation = await hantarrBloc.state.hUser.getCurrentLocation();
  //       if (getLocation["success"]) {
  //         _getPlace();
  //       } else {
  //         print("get locaton failed ");
  //       }
  //     }
  //   } catch (e) {
  //     print("get locaton failed. ${e.toString()}");
  //   }
  // }

  Widget buttonWidget(String title, String imgPath, dynamic onPressed) {
    return Card(
      child: MaterialButton(
        onPressed: onPressed,
        shape: themeBloc.state.cardTheme.shape,
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            ScreenUtil().setSp(30.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          // color: Colors.yellow[800],
                        ),
                        padding: EdgeInsets.all(ScreenUtil().setSp(20)),
                        width: ScreenUtil().setSp(200),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Icon(
                            LineIcons.question_circle,
                            size: ScreenUtil().setSp(200),
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      Align(
                        alignment: new FractionalOffset(0.5, 0.5),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SvgPicture.asset(
                            "$imgPath",
                            excludeFromSemantics: true,
                            allowDrawingOutsideViewBox: false,
                            cacheColorFilter: true,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: Text(
                  hantarrBloc.state.translation.text("$title") != null
                      ? "${hantarrBloc.state.translation.text("$title")}"
                      : "$title",
                  style: themeBloc.state.textTheme.button.copyWith(
                    inherit: true,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> bodyContent(Size mediaQ) {
    List<Widget> widgetlist = [];
    widgetlist.add(
      Row(
        children: [
          Expanded(
            child: buttonWidget(
              "Foods",
              "assets/food.svg",
              () async {
                routing(newRestaurantPage, {
                  "is_preorder": false,
                  "is_retail": false,
                });
              },
            ),
          ),
          SizedBox(
            width: 2,
          ),
          Expanded(
            child: buttonWidget(
              "Preorder",
              "assets/preorder_img.svg",
              () async {
                routing("$newRestaurantPage", {
                  "is_preorder": true,
                  "is_retail": false,
                });
              },
            ),
          ),
        ],
      ),
    );
    widgetlist.add(SizedBox(height: ScreenUtil().setHeight(15)));
    widgetlist.add(
      Row(
        children: [
          Expanded(
            child: buttonWidget(
              "P2P",
              "assets/p2pDelivery.svg",
              () async {
                if (loginCheck() == false) {
                  BotToast.showText(
                      text: "Please login first",
                      duration: Duration(seconds: 3));
                  Navigator.pushNamed(context, loginPage);
                } else {
                  if (hantarrBloc.state.hUser.id == null) {
                    loadingWidget(context);
                    var getUserDate =
                        await hantarrBloc.state.hUser.getUserData();

                    Navigator.pop(context);
                    if (getUserDate['success']) {
                      Navigator.pushNamed(
                        context,
                        p2pHomepage,
                        arguments: P2pTransaction.initClass(),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Something went wrong",
                            ),
                            content: Text("${getUserDate['reason']}"),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    loadingWidget(context);
                    var getAllVehicleReq =
                        await VehicleInterface().getAllVehicle();
                    Navigator.pop(context);
                    if (getAllVehicleReq['success']) {
                      Navigator.pushNamed(
                        context,
                        p2pHomepage,
                        arguments: P2pTransaction.initClass(),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Something went wrong"),
                            content: Text(
                                "${getAllVehicleReq['reason']}\nPlease try again."),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("OK"),
                              )
                            ],
                          );
                        },
                      );
                    }
                  }
                }
              },
            ),
          ),
          SizedBox(
            width: 2,
          ),
          Expanded(
            child: buttonWidget(
              "Retail",
              "assets/retail.svg",
              () async {
                routing("$newRestaurantPage", {
                  "is_preorder": false,
                  "is_retail": true,
                });
              },
            ),
          ),
        ],
      ),
    );
    return widgetlist;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return WillPopScope(
          onWillPop: () {
            if (hantarrBloc.state.hUser.firebaseUser == null) {
              // Navigator.pushNamed(context, routeName);
            } else {
              if (_selectedItemPosition == 1) {
                askLogout();
              } else {
                pageController.animateToPage(
                  1,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              }
            }
            return null;
          },
          child: Scaffold(
            key: _scaffoldKey,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                ScreenUtil().setHeight(450),
              ),
              child: Container(
                height: ScreenUtil().setHeight(450),
                width: mediaQ.width,
                decoration: BoxDecoration(
                  // color: Colors.orange,
                  gradient: new LinearGradient(
                    colors: [
                      themeBloc.state.primaryColor,
                      Colors.orange[300],
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.4, 1],
                  ),
                  borderRadius: new BorderRadius.vertical(
                    bottom: new Radius.elliptical(
                        MediaQuery.of(context).size.width,
                        kToolbarHeight * 1.6),
                  ),
                  boxShadow: [
                    new BoxShadow(
                      blurRadius: 15.0,
                      spreadRadius: 1.2,
                      color: Colors.grey,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Container(
                    height: ScreenUtil().setHeight(450),
                    // color: Colors.blue.withOpacity(.6),
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            "Hantarr Balance",
                                            maxLines: 1,
                                            style: themeBloc
                                                .state.textTheme.headline6
                                                .copyWith(
                                              inherit: true,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: ScreenUtil().setHeight(75),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          hantarrBloc.state.hUser
                                                      .firebaseUser !=
                                                  null
                                              ? AutoSizeText(
                                                  "RM " +
                                                      "${hantarrBloc.state.hUser.creditBalance.toStringAsFixed(2)}  ",
                                                  maxLines: 1,
                                                  style: themeBloc
                                                      .state.textTheme.headline5
                                                      .copyWith(
                                                    inherit: true,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : AutoSizeText(
                                                  "RM 0.00  ",
                                                  maxLines: 1,
                                                  style: themeBloc
                                                      .state.textTheme.headline5
                                                      .copyWith(
                                                    inherit: true,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          hantarrBloc.state.hUser
                                                      .firebaseUser !=
                                                  null
                                              ? InkWell(
                                                  onTap: () async {
                                                    loadingWidget(context);
                                                    var getUserDataReq =
                                                        await hantarrBloc
                                                            .state.hUser
                                                            .getUserData();
                                                    Navigator.pop(context);
                                                    if (getUserDataReq[
                                                        'success']) {
                                                      BotToast.showText(
                                                          text:
                                                              "Retrieve Success");
                                                    } else {
                                                      BotToast.showText(
                                                          text:
                                                              "Retrieve Data Failed. ${getUserDataReq['reason']}");
                                                    }
                                                  },
                                                  // padding: EdgeInsets.zero,
                                                  child: Icon(
                                                    Icons.refresh,
                                                    size: themeBloc
                                                        .state
                                                        .textTheme
                                                        .headline6
                                                        .fontSize,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  routing(myAccountPage, null);
                                },
                                onLongPress: () async {
                                  await hantarrBloc.state.hUser.firebaseUser
                                      .reload();
                                  hantarrBloc.state.hUser.firebaseUser =
                                      FirebaseAuth.instance.currentUser;
                                  hantarrBloc.add(Refresh());
                                  debugPrint(
                                      "${hantarrBloc.state.hUser.firebaseUser.phoneNumber}");
                                  BotToast.showText(text: "My Profile");
                                },
                                padding: EdgeInsets.zero,
                                shape: CircleBorder(),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: ScreenUtil().setSp(60.0),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: ScreenUtil().setSp(60.0),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: (hantarrBloc.state.hUser
                                                        .firebaseUser !=
                                                    null &&
                                                hantarrBloc
                                                        .state
                                                        .hUser
                                                        .firebaseUser
                                                        .phoneNumber !=
                                                    null)
                                            ? hantarrBloc
                                                    .state
                                                    .hUser
                                                    .firebaseUser
                                                    .phoneNumber
                                                    .isNotEmpty
                                                ? Icon(
                                                    Icons.verified_sharp,
                                                    color: Colors.greenAccent,
                                                  )
                                                : Icon(
                                                    Icons.error,
                                                    color: Colors.redAccent,
                                                  )
                                            : Icon(
                                                Icons.error,
                                                color: Colors.redAccent,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: mediaQ.width,
                            child: Row(
                              children: [
                                Expanded(
                                  child: RaisedButton(
                                    onPressed: () {
                                      routing(billPlzPage, {"amount": 50.0});
                                    },
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(22.0),
                                      ),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setSp(5.0),
                                      ),
                                      child: Text(
                                        hantarrBloc.state.translation
                                                    .text("Reload Credit") !=
                                                null
                                            ? "+ ${hantarrBloc.state.translation.text("Reload Credit")}"
                                            : "+ Reload Credit",
                                        style: themeBloc.state.textTheme.button
                                            .copyWith(
                                          inherit: true,
                                          fontSize: ScreenUtil().setSp(32.0),
                                          color: themeBloc
                                              .state.textTheme.headline6.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    onPressed: () {
                                      setState(() {});
                                      showModalBottomSheet<void>(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset(0.0, 8.0),
                                                  blurRadius: 25.0,
                                                )
                                              ],
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                ScreenUtil().setSp(20.0),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    title: Text(
                                                      hantarrBloc.state
                                                                  .translation
                                                                  .text(
                                                                      "Transaction History") !=
                                                              null
                                                          ? "${hantarrBloc.state.translation.text("Transaction History")}"
                                                          : "Transaction History",
                                                      style: themeBloc.state
                                                          .textTheme.headline6
                                                          .copyWith(
                                                        inherit: true,
                                                      ),
                                                    ),
                                                    trailing: IconButton(
                                                      icon: Icon(
                                                        Icons.close_rounded,
                                                        color: Colors.red,
                                                        size: themeBloc
                                                            .state
                                                            .textTheme
                                                            .headline6
                                                            .fontSize,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: ScreenUtil()
                                                          .setHeight(35.0)),
                                                  Container(
                                                    margin: EdgeInsets.zero,
                                                    child: Container(
                                                      width: mediaQ.width,
                                                      child: Column(
                                                        children: [
                                                          Divider(),
                                                          ListTile(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              routing(
                                                                  topupHistory,
                                                                  null);
                                                            },
                                                            title: Text(
                                                              hantarrBloc.state
                                                                          .translation
                                                                          .text(
                                                                              "Top Up History") !=
                                                                      null
                                                                  ? "${hantarrBloc.state.translation.text("Top Up History")}"
                                                                  : "Top Up History",
                                                              style: themeBloc
                                                                  .state
                                                                  .textTheme
                                                                  .button
                                                                  .copyWith(
                                                                inherit: true,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            trailing: Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: themeBloc
                                                                  .state
                                                                  .textTheme
                                                                  .button
                                                                  .fontSize,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          Divider(),
                                                          ListTile(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              routing(
                                                                  foodDeliveriesHistoryPage,
                                                                  null);
                                                            },
                                                            title: Text(
                                                              hantarrBloc.state
                                                                          .translation
                                                                          .text(
                                                                              "Food Delivery History") !=
                                                                      null
                                                                  ? "${hantarrBloc.state.translation.text("Food Delivery History")}"
                                                                  : "Food Delivery History",
                                                              style: themeBloc
                                                                  .state
                                                                  .textTheme
                                                                  .button
                                                                  .copyWith(
                                                                inherit: true,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            trailing: Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: themeBloc
                                                                  .state
                                                                  .textTheme
                                                                  .button
                                                                  .fontSize,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          Divider(),
                                                          ListTile(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              routing(
                                                                  p2psHistoryPage,
                                                                  null);
                                                            },
                                                            title: Text(
                                                              hantarrBloc.state
                                                                          .translation
                                                                          .text(
                                                                              "P2P Delivery History") !=
                                                                      null
                                                                  ? "${hantarrBloc.state.translation.text("P2P Delivery History")}"
                                                                  : "P2P Delivery History",
                                                              style: themeBloc
                                                                  .state
                                                                  .textTheme
                                                                  .button
                                                                  .copyWith(
                                                                inherit: true,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            trailing: Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: themeBloc
                                                                  .state
                                                                  .textTheme
                                                                  .button
                                                                  .fontSize,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            hantarrBloc.state.translation.text(
                                                        "Transaction History") !=
                                                    null
                                                ? "${hantarrBloc.state.translation.text("Transaction History")}"
                                                : "Transaction History",
                                            maxLines: 1,
                                            style: themeBloc
                                                .state.textTheme.button
                                                .copyWith(
                                              inherit: true,
                                              color: Colors.grey[850],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey[850],
                                          size: themeBloc
                                              .state.textTheme.button.fontSize,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // drawer: Drawer(
            //   child: Container(
            //     height: mediaQ.height,
            //     child: Column(
            //       children: [
            //         Container(
            //           color: themeBloc.state.primaryColor.withOpacity(.9),
            //           height: ScreenUtil().setHeight(450),
            //           width: mediaQ.width,
            //           padding: EdgeInsets.only(
            //             bottom: ScreenUtil().setHeight(35.0),
            //             left: ScreenUtil().setWidth(35.0),
            //           ),
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               CircleAvatar(
            //                 backgroundColor: Colors.white,
            //                 radius: ScreenUtil().setWidth(85),
            //                 child: Container(
            //                   child: Text(
            //                     hantarrBloc.state.hUser.firebaseUser != null
            //                         ? hantarrBloc.state.hUser.firebaseUser
            //                                 ?.displayName.isNotEmpty
            //                             ? "${hantarrBloc.state.hUser.firebaseUser?.displayName[0]}"
            //                             : "H"
            //                         : "Guest",
            //                     style: themeBloc.state.textTheme.headline6
            //                         .copyWith(
            //                       inherit: true,
            //                       color: Colors.black,
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               SizedBox(height: ScreenUtil().setHeight(35.0)),
            //               Text(
            //                 hantarrBloc.state.hUser.firebaseUser != null
            //                     ? hantarrBloc.state.hUser.firebaseUser
            //                             ?.displayName.isNotEmpty
            //                         ? "${hantarrBloc.state.hUser.firebaseUser?.displayName}"
            //                         : "Hantarr User"
            //                     : "Guest",
            //                 style: themeBloc.state.textTheme.headline6.copyWith(
            //                   fontSize: ScreenUtil().setSp(35.0),
            //                   fontWeight: FontWeight.w600,
            //                   color: Colors.black,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //         Expanded(
            //           child: SingleChildScrollView(
            //             child: Column(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 Divider(
            //                   color: Colors.transparent,
            //                 ),
            //                 ListTile(
            //                   onTap: () {
            //                     if (loginCheck()) {
            //                       Navigator.pushNamed(context, myAccountPage);
            //                     } else {
            //                       Navigator.pushNamed(context, loginPage);
            //                     }
            //                   },
            //                   leading: Icon(Icons.person),
            //                   title: Text("Profile"),
            //                 ),
            //                 ListTile(
            //                   onTap: () {
            //                     if (loginCheck()) {
            //                       Navigator.pushNamed(context, newAddressPage);
            //                     } else {
            //                       Navigator.pushNamed(context, loginPage);
            //                     }
            //                   },
            //                   leading: Icon(Icons.location_history),
            //                   title: Text("Address Book"),
            //                 ),
            //                 Divider(),
            //                 ListTile(
            //                   onTap: () {
            //                     if (loginCheck()) {
            //                       Navigator.pushNamed(
            //                           context, topUpMethodSelectionPage);
            //                     } else {
            //                       Navigator.pushNamed(context, loginPage);
            //                     }
            //                   },
            //                   leading: Icon(Icons.money),
            //                   title: Text("Top Up"),
            //                 ),
            //                 ListTile(
            //                   onTap: () {
            //                     if (loginCheck()) {
            //                       Navigator.pushNamed(context, topupHistory);
            //                     } else {
            //                       Navigator.pushNamed(context, loginPage);
            //                     }
            //                   },
            //                   leading: Icon(Icons.history),
            //                   title: Text("Top Up History"),
            //                 ),
            //                 Divider(),
            //                 ListTile(
            //                   onTap: () {},
            //                   leading: Icon(Icons.motorcycle),
            //                   title: Text("Food Delivery"),
            //                 ),
            //                 ListTile(
            //                   onTap: () {},
            //                   leading: Icon(Icons.history),
            //                   title: Text("Food Delivery History"),
            //                 ),
            //                 Divider(),
            //                 ListTile(
            //                   onTap: () {
            //                     if (loginCheck()) {
            //                       Navigator.pushNamed(context, p2pHomepage);
            //                     } else {
            //                       Navigator.pushNamed(context, loginPage);
            //                     }
            //                   },
            //                   leading: Icon(Icons.motorcycle),
            //                   title: Text("P2P Delivery"),
            //                 ),
            //                 ListTile(
            //                   onTap: () {
            //                     if (loginCheck()) {
            //                       Navigator.pushNamed(context, p2psHistoryPage);
            //                     } else {
            //                       Navigator.pushNamed(context, loginPage);
            //                     }
            //                   },
            //                   leading: Icon(Icons.history),
            //                   title: Text("P2P Delivery History"),
            //                 ),
            //                 Divider(),
            //                 ListTile(
            //                   title: Text(
            //                     "Version",
            //                     textAlign: TextAlign.right,
            //                   ),
            //                   subtitle: Text(
            //                     "${hantarrBloc.state.versionName}",
            //                     textAlign: TextAlign.right,
            //                   ),
            //                 ),
            //                 SizedBox(height: ScreenUtil().setHeight(15.0)),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: [
            //                     hantarrBloc.state.hUser.firebaseUser != null
            //                         ? RaisedButton(
            //                             onPressed: () async {
            //                               askLogout();
            //                             },
            //                             color: themeBloc.state.primaryColor,
            //                             shape: RoundedRectangleBorder(
            //                               borderRadius: BorderRadius.all(
            //                                 Radius.circular(10.0),
            //                               ),
            //                             ),
            //                             child: Text(
            //                               "Log Out",
            //                               style: themeBloc
            //                                   .state.textTheme.headline6
            //                                   .copyWith(
            //                                 fontWeight: FontWeight.bold,
            //                                 color: Colors.white,
            //                               ),
            //                             ),
            //                           )
            //                         : RaisedButton(
            //                             onPressed: () async {
            //
            //                             },
            //                             color: themeBloc.state.primaryColor,
            //                             shape: RoundedRectangleBorder(
            //                               borderRadius: BorderRadius.all(
            //                                 Radius.circular(10.0),
            //                               ),
            //                             ),
            //                             child: Text(
            //                               "Log In",
            //                               style: themeBloc
            //                                   .state.textTheme.headline6
            //                                   .copyWith(
            //                                 fontWeight: FontWeight.bold,
            //                                 color: Colors.white,
            //                               ),
            //                             ),
            //                           ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            body: PageView(
              controller: pageController,
              // physics: NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _selectedItemPosition = page;
                });
              },
              children: [
                // TopUpHistoryPage(
                //   hideAppBar: true,
                // ),4
                FpxOnline(
                  hideAppBar: true,
                  minAmount: 50.0,
                  // hideAppBar: true,
                ),
                hantarrBloc.state.serverTime != null
                    ? GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: SafeArea(
                          child: ScrollConfiguration(
                            behavior: ScrollBehavior(),
                            child: SmartRefresher(
                              enablePullDown: true,
                              enablePullUp: false,
                              controller: _refreshController,
                              onRefresh: getOrders,
                              onLoading: _onLoading,
                              child: SingleChildScrollView(
                                controller: sc,
                                padding: EdgeInsets.all(
                                  ScreenUtil().setSp(15.0),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    // Container(
                                    //   child: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: <Widget>[
                                    //       Text(
                                    //         'Hantarr Delivery',
                                    //         style: themeBloc
                                    //             .state.textTheme.headline6
                                    //             .copyWith(
                                    //           fontSize: ScreenUtil().setSp(55.0),
                                    //           fontWeight: FontWeight.w700,
                                    //         ),
                                    //       ),
                                    //       SizedBox(height: spaceM),
                                    //       Row(
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.center,
                                    //         children: <Widget>[
                                    //           SizedBox(
                                    //             width: ScreenUtil().setWidth(60.0),
                                    //           ),
                                    //           Expanded(
                                    //             child: AutoSizeText(
                                    //               'Anywhere, Anything.\n    Your Demand We Deliver !',
                                    //               textAlign: TextAlign.start,
                                    //               style: themeBloc
                                    //                   .state.textTheme.headline2
                                    //                   .copyWith(
                                    //                 fontSize:
                                    //                     ScreenUtil().setSp(45.0),
                                    //                 fontWeight: FontWeight.w600,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(45.0),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setSp(15.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          hantarrBloc.state.hUser
                                                      .firebaseUser !=
                                                  null
                                              ? Expanded(
                                                  child: Text(
                                                    hantarrBloc
                                                                .state
                                                                .hUser
                                                                .firebaseUser
                                                                ?.displayName !=
                                                            null
                                                        ? "Hello, ${hantarrBloc.state.hUser.firebaseUser?.displayName}"
                                                        : "Hello",
                                                    textAlign: TextAlign.start,
                                                    style: themeBloc.state
                                                        .textTheme.headline6
                                                        .copyWith(
                                                      inherit: true,
                                                      color: themeBloc
                                                          .state.primaryColor,
                                                      fontSize: ScreenUtil()
                                                          .setSp(45.0),
                                                    ),
                                                  ),
                                                )
                                              : RaisedButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                        context, loginPage);
                                                  },
                                                  color: themeBloc
                                                      .state.primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Login / Register",
                                                    style: themeBloc
                                                        .state.textTheme.button
                                                        .copyWith(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    hantarrBloc.state.p2pPendingOrders
                                                .isNotEmpty ||
                                            hantarrBloc
                                                .state.pendingOrders.isNotEmpty
                                        ? SizedBox(
                                            height:
                                                ScreenUtil().setHeight(10.0),
                                          )
                                        : Container(),
                                    hantarrBloc.state.p2pPendingOrders
                                                .isNotEmpty ||
                                            hantarrBloc.state.pendingFoodOrders
                                                .isNotEmpty
                                        ? Card(
                                            margin: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                            ),
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          pendingOrdersPage);
                                                    },
                                                    title: Row(
                                                      children: [
                                                        Text(
                                                          "Pending Orders",
                                                          style: themeBloc
                                                              .state
                                                              .textTheme
                                                              .headline6,
                                                        ),
                                                        // SizedBox(
                                                        //   width: 5.0,
                                                        // ),
                                                      ],
                                                    ),
                                                    leading: Container(
                                                      width: ScreenUtil()
                                                          .setSp(45.0),
                                                      child: SpinKitRipple(
                                                        size: ScreenUtil()
                                                            .setSp(45.0),
                                                        color: themeBloc
                                                            .state.primaryColor,
                                                        duration: Duration(
                                                            milliseconds: 1600),
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      hantarrBloc
                                                                      .state
                                                                      .p2pPendingOrders
                                                                      .length +
                                                                  hantarrBloc
                                                                      .state
                                                                      .pendingFoodOrders
                                                                      .length >
                                                              1
                                                          ? "${(hantarrBloc.state.p2pPendingOrders.length + hantarrBloc.state.pendingFoodOrders.length)} Orders"
                                                          : "${(hantarrBloc.state.p2pPendingOrders.length + hantarrBloc.state.pendingFoodOrders.length)} Order",
                                                      style: themeBloc.state
                                                          .textTheme.subtitle1,
                                                    ),
                                                    trailing: Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: themeBloc
                                                          .state
                                                          .textTheme
                                                          .headline6
                                                          .color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: ScreenUtil().setHeight(15),
                                    ),
                                    Column(
                                      children: bodyContent(mediaQ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: SpinKitDualRing(
                          color: themeBloc.state.primaryColor,
                          size: ScreenUtil().setSp(50.0),
                        ),
                      ),
                AccountPage(
                  isFromMainScreen: true,
                ),
              ],
            ),
            bottomNavigationBar: SnakeNavigationBar.color(
              behaviour: SnakeBarBehaviour.floating,
              snakeShape: SnakeShape.circle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              padding: EdgeInsets.all(12),
              snakeViewColor: themeBloc.state.primaryColor,
              selectedItemColor: SnakeShape.circle == SnakeShape.indicator
                  ? Colors.black
                  : null,
              unselectedItemColor: Colors.blueGrey,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              currentIndex: _selectedItemPosition,
              onTap: (index) {
                pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
                setState(() {
                  _selectedItemPosition = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money_outlined),
                  label: 'topup',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'account',
                ),
              ],
              selectedLabelStyle: themeBloc.state.textTheme.button.copyWith(
                inherit: true,
                fontSize: 14,
              ),
              unselectedLabelStyle: themeBloc.state.textTheme.button.copyWith(
                inherit: true,
                fontSize: 10,
              ),
            ),
          ),
        );
      },
    );
  }
}
