import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/cart_floating_action_button_widget/cart_floating_action_button_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/get_location_pages/get_location_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/restaurant_pages/new_restaurant_widget.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/root_page_repo/modules/user_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:hantarr/utilities/geo_decode.dart';
import 'package:location/location.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/global.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart'
    as gL;

// ignore: must_be_immutable
class NewRestaurantPage extends StatefulWidget {
  bool preoder;
  bool isRetail;
  NewRestaurantPage({
    this.preoder = false,
    this.isRetail = false,
  });
  @override
  _NewRestaurantPageState createState() => _NewRestaurantPageState();
}

class _NewRestaurantPageState extends State<NewRestaurantPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController sc = ScrollController();
  bool isLoading = true;
  String errorMsg = "";

  @override
  void initState() {
    if (hantarrBloc.state.foodCart.address == null) {
      hantarrBloc.state.foodCart.address = "";
      hantarrBloc.add(Refresh());
    }
    setAddress();
    if (hantarrBloc.state.selectedLocation != null) {
      getRestList();
    }
    super.initState();
  }

  setAddress() async {
    if (hantarrBloc.state.foodCart.address.isEmpty) {
      hantarrBloc.state.foodCart.address =
          await geoDecode(hantarrBloc.state.selectedLocation);
      hantarrBloc.add(Refresh());
    }
  }

  void getRestList() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMsg = "";
      });
    }
    var getTimeReq = await HantarrUser.initClass().getCurrentTime();
    if (getTimeReq['success']) {
      // NewRestaurant.initClass().getListRestaurant();
      NewRestaurant.initClass().getRestListNew(isRetail: widget.isRetail);
      hantarrBloc.state.streamController.stream.listen((data) {
        try {
          Map<String, dynamic> payload = jsonDecode(data);
          if (payload['success']) {
            Future.delayed(Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  isLoading = false;
                  errorMsg = "";
                });
                _refreshController.refreshCompleted();
              }
            });
          } else {
            if (mounted) {
              setState(() {
                isLoading = false;
                errorMsg = "${payload['reason']}";
              });
            }
            _refreshController.refreshFailed();
          }
        } catch (e) {}
      });
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMsg = "${getTimeReq['reason']}";
        });
      }
    }
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  void locationBottomSheet(BuildContext context) async {
    loadingWidget(context);

    String curLocation = "";
    LatLng curLatLong;
    try {
      var location = new Location();
      await location.requestPermission();
      LocationData currentLocation;
      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.granted) {
        currentLocation = await Location().getLocation();
        if (currentLocation != null) {
          curLatLong =
              LatLng(currentLocation.latitude, currentLocation.longitude);
          // curLocation = await _getPlace(
          //     LatLng(currentLocation.latitude, currentLocation.longitude));
          curLocation = await geoDecode(
              LatLng(currentLocation.latitude, currentLocation.longitude));
          hantarrBloc.state.currentLocation =
              LatLng(currentLocation.latitude, currentLocation.longitude);
        }
      }
    } catch (e) {
      BotToast.showText(text: "Get location failed");
    }

    var getAllAddressReq = await AddressInterface().getListAddress();
    Navigator.pop(context);
    if (getAllAddressReq['success']) {
    } else {
      BotToast.showText(
          text: "Get Address List Failed. ${getAllAddressReq['reason']}");
    }

    showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        context: context,
        builder: (BuildContext context) {
          List<Widget> widgetlist = [];
          if (curLatLong != null) {
            Widget currentLocation = ListTile(
              onTap: () async {
                hantarrBloc.state.foodCart.address = curLocation;
                hantarrBloc.state.selectedLocation = curLatLong;
                hantarrBloc.add(Refresh());
                await hantarrBloc.state.hUser
                    .setLocalOnSelectedAddress(curLatLong, curLocation);
                Navigator.pop(context);

                _refreshController.requestRefresh();
              },
              leading: Icon(
                Icons.location_on,
                color: themeBloc.state.primaryColor,
              ),
              title: Text(
                "Current Location",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  inherit: true,
                ),
              ),
              subtitle: Text(
                "$curLocation",
                style: themeBloc.state.textTheme.subtitle2.copyWith(),
              ),
            );
            widgetlist.add(currentLocation);
            widgetlist.add(Divider());
          }

          Widget editSelectedLocationWidget = ListTile(
            onTap: () async {
              await hantarrBloc.state.hUser.setLocalOnSelectedAddress(
                  hantarrBloc.state.selectedLocation,
                  hantarrBloc.state.foodCart.address);
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.location_on,
              color: themeBloc.state.primaryColor,
            ),
            title: Text(
              "Selected Address",
              style: themeBloc.state.textTheme.headline6.copyWith(
                inherit: true,
              ),
            ),
            subtitle: Text(
              "${hantarrBloc.state.foodCart.address.replaceAll("%address%", "")}",
              style: themeBloc.state.textTheme.subtitle2.copyWith(),
            ),
            trailing: IconButton(
              onPressed: () async {
                String jAddress = "";
                String jBloc = "";
                if (hantarrBloc.state.foodCart.address
                        .split("%address%")
                        .length >
                    1) {
                  jAddress =
                      hantarrBloc.state.foodCart.address.split("%address%")[1];
                  jBloc =
                      hantarrBloc.state.foodCart.address.split("%address%")[0];
                } else {
                  jBloc = "";
                  jAddress = hantarrBloc.state.foodCart.address;
                }

                TextEditingController blockCon =
                    TextEditingController(text: jBloc);
                TextEditingController addCon =
                    TextEditingController(text: jAddress);

                var result = await showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter state) {
                        return AlertDialog(
                          title: Text("Edit Address"),
                          content: Container(
                            width: MediaQuery.of(context).size.width * .9,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: blockCon,
                                      validator: (val) {
                                        if (val.replaceAll(" ", "").isEmpty) {
                                          return "Cannot Empty";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Company / Building Name",
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                            width: .4,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: .4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: addCon,
                                      maxLines: null,
                                      maxLengthEnforced: false,
                                      validator: (val) {
                                        if (val.replaceAll(" ", "").isEmpty) {
                                          return "Cannot Empty";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Address",
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                            width: .4,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: .4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            FlatButton(
                              onPressed: () {
                                Navigator.pop(context, 'no');
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style:
                                    themeBloc.state.textTheme.button.copyWith(
                                  inherit: true,
                                  color: themeBloc.state.primaryColor,
                                ),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.pop(context, 'yes');
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              color: themeBloc.state.primaryColor,
                              child: Text(
                                "OK",
                                style:
                                    themeBloc.state.textTheme.button.copyWith(
                                  inherit: true,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
                if (result == "yes") {
                  debugPrint(addCon.text);
                  if (addCon.text.replaceAll(" ", "").isNotEmpty &&
                      blockCon.text.replaceAll(" ", "").isNotEmpty) {
                    String merged = "${blockCon.text}%address%${addCon.text}";
                    hantarrBloc.state.foodCart.address = merged;
                    await hantarrBloc.state.hUser.setLocalOnSelectedAddress(
                        hantarrBloc.state.selectedLocation, merged);
                    hantarrBloc.add(Refresh());
                    Navigator.pop(context);
                  }
                }
              },
              icon: Icon(Icons.edit),
            ),
          );
          widgetlist.add(editSelectedLocationWidget);
          widgetlist.add(Divider());

          hantarrBloc.state.addressList.map(
            (e) {
              Widget addTile = ListTile(
                onTap: () async {
                  hantarrBloc.state.foodCart.address = e.address;
                  hantarrBloc.state.selectedLocation =
                      LatLng(e.latitude, e.longitude);
                  hantarrBloc.add(Refresh());
                  await hantarrBloc.state.hUser.setLocalOnSelectedAddress(
                      LatLng(e.latitude, e.longitude), e.address);
                  Navigator.pop(context);
                  _refreshController.requestRefresh();
                },
                leading: Icon(
                  e.title.toLowerCase().contains("home")
                      ? Icons.home
                      : e.title.toLowerCase().contains("work")
                          ? Icons.work
                          : Icons.location_on,
                  color: themeBloc.state.primaryColor,
                ),
                title: Text(
                  "${e.title}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    inherit: true,
                  ),
                ),
                subtitle: Text(
                  "${e.address}",
                  style: themeBloc.state.textTheme.subtitle2.copyWith(),
                ),
              );
              widgetlist.add(addTile);
              widgetlist.add(Divider());
            },
          ).toList();

          widgetlist.add(
            ListTile(
              onTap: () async {
                // var getosmplace =
                //     await Navigator.popAndPushNamed(context, searchPlacePage);
                // if (getosmplace != null) {
                //   OSMPlace osmplace = getosmplace as OSMPlace;
                //   if (osmplace.osmCoordinate.lat != null &&
                //       osmplace.osmCoordinate.long != null) {
                //     hantarrBloc.state.selectedLocation = LatLng(
                //         osmplace.osmCoordinate.lat,
                //         osmplace.osmCoordinate.long);
                //     hantarrBloc.add(Refresh());
                //     _getPlace(hantarrBloc.state.selectedLocation);
                //     _refreshController.requestRefresh();
                //   }
                // }

                gL.LocationResult _pickedLocation;
                gL.LocationResult result = await gL.showLocationPicker(
                  context, "AIzaSyCP6DCTU7pUCg-ELswj1bxe1jABsCntkHo",
                  initialCenter: hantarrBloc.state.selectedLocation,
                  automaticallyAnimateToCurrentLocation: false,
//                      mapStylePath: 'assets/mapStyle.json',
                  myLocationButtonEnabled: true,
                  requiredGPS: false,
                  layersButtonEnabled: true,
                  countries: ["MY"],
                  // countries: ['AE', 'NG']
                  resultCardAlignment: Alignment.bottomCenter,
                  desiredAccuracy: gL.LocationAccuracy.best,
                );
                print("result = $result");
                setState(() => _pickedLocation = result);
                if (_pickedLocation != null) {
                  hantarrBloc.state.selectedLocation = _pickedLocation.latLng;
                  hantarrBloc.state.foodCart.address =
                      _pickedLocation.address != null
                          ? "${_pickedLocation.address}"
                          : await geoDecode(_pickedLocation.latLng);
                  await hantarrBloc.state.hUser.setLocalOnSelectedAddress(
                      _pickedLocation.latLng, _pickedLocation.address);
                  hantarrBloc.add(Refresh());
                  Navigator.pop(context);
                  _refreshController.requestRefresh();
                }
              },
              leading: Icon(
                Icons.add,
                color: themeBloc.state.primaryColor,
              ),
              title: Text(
                "Use Another Address",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  inherit: true,
                ),
              ),
            ),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: widgetlist,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (context, state) {
        return hantarrBloc.state.selectedLocation != null
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  title: ListTile(
                    onTap: () async {
                      locationBottomSheet(context);
                      // var result =
                      //     await Navigator.pushNamed(context, searchPlacePage);
                      // if (result != null) {}
                      // var result = await Navigator.pushNamed(
                      //     context, getlocationPage,
                      //     arguments: null);
                      // await hantarrBloc.state.hUser.getLocalStrorageLocation();
                    },
                    contentPadding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(15),
                      bottom: ScreenUtil().setHeight(15),
                    ),
                    title: Text(
                      "Location",
                      style: themeBloc.state.textTheme.headline6.copyWith(
                        fontSize: ScreenUtil().setSp(35.0),
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Container(
                      width: mediaQ.width * .8,
                      child: Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              hantarrBloc.state.foodCart.address
                                      .contains("%address%")
                                  ? hantarrBloc.state.foodCart.address
                                          .split("%address%")
                                          .first
                                          .isNotEmpty
                                      ? "${hantarrBloc.state.foodCart.address.replaceAll("%address%", ", ")}"
                                      : "${hantarrBloc.state.foodCart.address.replaceAll("%address%", "")}"
                                  : "${hantarrBloc.state.foodCart.address}",
                              maxLines: 2,
                              style:
                                  themeBloc.state.textTheme.subtitle1.copyWith(
                                inherit: true,
                                fontSize: ScreenUtil().setSp(30.0),
                                color: Colors.grey[850],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        // var rest = await Navigator.pushNamed(
                        //     context, searchRestaurantPage);
                        // if (rest != null) {
                        //   NewRestaurant thisRes = rest as NewRestaurant;
                        // }
                        await Navigator.pushNamed(
                            context, searchRestaurantPage);

                        // Dio dio = Dio(BaseOptions(
                        //   baseUrl: foodUrl,
                        //   queryParameters: {
                        //     "country": "malaysia",
                        //     "user_long": hantarrBloc
                        //         .state.selectedLocation.longitude
                        //         .toStringAsFixed(5),
                        //     "user_lat": hantarrBloc
                        //         .state.selectedLocation.latitude
                        //         .toStringAsFixed(5),
                        //   },
                        //   connectTimeout: 40000,
                        //   receiveTimeout: 40000,
                        //   headers: {
                        //     "Content-Type": "application/json",
                        //     "Accept": "*/*",
                        //     "Connection": "keep-alive",
                        //     "Accept-Encoding": "gzip, deflate, br",
                        //   },
                        //   // responseType: ResponseType.stream,
                        // ));
                        // Response response = await dio.post(
                        //   "/marketplace/get_restaurant_v2",
                        // );
                        // print(response.data);
                      },
                      icon: Icon(
                        Icons.search,
                        color: themeBloc.state.textTheme.headline6.color,
                      ),
                    ),
                  ),
                  // actions: [
                  //   IconButton(
                  //     onPressed: () {
                  //       getRestList();
                  //     },
                  //     icon: Icon(Icons.refresh),
                  //   ),
                  // ],
                ),
                floatingActionButton:
                    hantarrBloc.state.foodCart.menuItems.isNotEmpty &&
                            isLoading == false &&
                            errorMsg.isEmpty
                        ? cartFAB(context)
                        : null,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                body: Container(
                  margin: hantarrBloc.state.foodCart.menuItems.isNotEmpty
                      ? EdgeInsets.only(bottom: ScreenUtil().setHeight(150))
                      : EdgeInsets.zero,
                  child: hantarrBloc.state.foodCart.address.isNotEmpty
                      ? SmartRefresher(
                          scrollController: sc,
                          enablePullDown: true,
                          enablePullUp: false,
                          // header: WaterDropHeader(
                          //   waterDropColor: _refreshController.isLoading
                          //       ? Colors.transparent
                          //       : themeBloc.state.primaryColor,
                          // ),
                          controller: _refreshController,
                          onRefresh: getRestList,
                          onLoading: _onLoading,
                          child: isLoading
                              ? Container(
                                  width: mediaQ.width,
                                  height: mediaQ.height,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SpinKitDoubleBounce(
                                        color: themeBloc.state.primaryColor,
                                        size: ScreenUtil().setSp(55),
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        "Loading ...",
                                        textAlign: TextAlign.center,
                                        style: themeBloc
                                            .state.textTheme.headline6
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ScreenUtil().setSp(35),
                                          color: themeBloc.state.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : errorMsg.isNotEmpty
                                  ? Container(
                                      width: mediaQ.width,
                                      height: mediaQ.height,
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child: Text(errorMsg),
                                      ),
                                    )
                                  : hantarrBloc
                                          .state.newRestaurantList.isNotEmpty
                                      ? ListView.builder(
                                          controller: sc,
                                          padding: EdgeInsets.all(
                                            ScreenUtil().setSp(10.0),
                                          ),
                                          itemCount: widget.preoder
                                              ? NewRestaurant.initClass()
                                                  .filterByPreoder()
                                                  .length
                                              : NewRestaurant.initClass()
                                                  .filterByOndemand()
                                                  .length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            List<NewRestaurant> restist = [];
                                            if (widget.preoder == true) {
                                              restist =
                                                  NewRestaurant.initClass()
                                                      .filterByPreoder();
                                            } else {
                                              restist =
                                                  NewRestaurant.initClass()
                                                      .filterByOndemand();
                                            }
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                NewRestaurantWidget(
                                                  newRestaurant: restist[index],
                                                ),
                                                Divider(
                                                    color: Colors.transparent),
                                              ],
                                            );
                                          },
                                        )
                                      : Container(
                                          width: mediaQ.width,
                                          height: mediaQ.height * .6,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width:
                                                    ScreenUtil().setWidth(700),
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: SvgPicture.asset(
                                                    "assets/empty_res.svg",
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil().setSp(70,
                                                        allowFontScalingSelf:
                                                            true),
                                                    right: ScreenUtil().setSp(
                                                        70,
                                                        allowFontScalingSelf:
                                                            true),
                                                    top: ScreenUtil().setSp(30,
                                                        allowFontScalingSelf:
                                                            true),
                                                    bottom: ScreenUtil().setSp(
                                                        30,
                                                        allowFontScalingSelf:
                                                            true)),
                                                child: Text(
                                                  "Sorry.\nNo Merchant offer in your area.",
                                                  textAlign: TextAlign.center,
                                                  style: themeBloc
                                                      .state.textTheme.headline6
                                                      .copyWith(
                                                    color: themeBloc
                                                        .state.primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        ScreenUtil().setSp(45),
                                                  ),
                                                ),
                                              ),
                                              FlatButton(
                                                color: themeBloc
                                                    .state.primaryColor
                                                    .withOpacity(0.2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  locationBottomSheet(context);
                                                },
                                                child: Text(
                                                  "Try other location",
                                                  style: GoogleFonts.aBeeZee(
                                                    textStyle: TextStyle(
                                                        color: themeBloc
                                                            .state.primaryColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: ScreenUtil()
                                                            .setSp(45)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SpinKitWave(
                              size: ScreenUtil().setSp(85.0),
                              color: themeBloc.state.primaryColor,
                            ),
                            SizedBox(height: ScreenUtil().setHeight(15)),
                            Text(
                              "Getting Location ...",
                              style:
                                  themeBloc.state.textTheme.headline6.copyWith(
                                fontSize: ScreenUtil().setSp(55.0),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                ),
              )
            : GetLocationPage(
                getRest: getRestList,
              );
      },
    );
  }
}
