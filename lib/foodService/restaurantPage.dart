import 'dart:async';
import 'package:hantarr/module/user_module.dart' as hantarrUser;
import 'package:flutter_svg/svg.dart';
import 'package:hantarr/dragLocation.dart';
import 'package:hantarr/foodService/menuitemPage.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class RestaurantPage extends StatefulWidget {
  bool isPreorder;
  // RestaurantPage({Key key}) : super(key: key);
  RestaurantPage({
    this.isPreorder = false,
  });

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  DateTime restaurantDT;
  bool loading = true, refreshing = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  TextEditingController searchController = TextEditingController();
  FocusNode searchFnode = FocusNode();
  List<Restaurant> filteredRes = [];

  @override
  void initState() {
    filteredRes = hantarrBloc.state.allRestaurants;
    getRealDT();
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        filteredRes = hantarrBloc.state.allRestaurants
            .where((element) => element.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  filterRestaurant(Map payload) async {
    // get zone details //
    List<dynamic> zoneMap = payload["state"];
    hantarrBloc.state.zoneDetailList = [];
    for (var zone in zoneMap) {
      ZoneDetail zd = ZoneDetail.fromJson(zone);
      hantarrBloc.state.zoneDetailList.add(zd);
    }
    if (payload["restaurant"].isEmpty) {
      hantarrBloc.state.allRestaurants.clear();
      filteredRes.clear();
      hantarrBloc.add(Refresh());
    } else {
      for (var x in payload["restaurant"]) {
        if (payload["total"] != null) {
          if (hantarrBloc.state.allRestaurants.length < payload["total"]) {
            Restaurant res = Restaurant().restaurantToClass(x, null);
            print(res.name);
            if (res.forceClose == null) {
              res.forceClose = false;
            }
            res.online = x["online_stats"];

            //---------check stalls-----------//
            List<Restaurant> stalls = [];
            if (x["stalls"] == null) {
              x["stalls"] = [];
            }
            if (x["stalls"].isNotEmpty) {
              for (Map stall in x["stalls"]) {
                bool stallOnlineStatus = false;
                Restaurant resStall = Restaurant().restaurantToClass(stall, x);
                //get onlinestatus and force close//
                var result = await get(Uri.tryParse(
                    "$foodUrl/restaurants_online_status?rest_id=${stall["rest_id"]}"));
                if (result.body != "null") {
                  if (DateTime.now()
                          .difference(DateTime.parse(
                              json.decode(result.body)["last_update"]))
                          .inSeconds <=
                      45) {
                    stallOnlineStatus = true;
                  }
                }
                resStall.online = stallOnlineStatus;
                resStall.forceClose = result.body != "null"
                    ? json.decode(result.body)["force_close"]
                    : false;
                //get onlinestatus and force close//
                stalls.add(resStall);
              }
            }
            res.stalls = stalls;
            hantarrBloc.state.allRestaurants.add(res);
          }
        }
      }
      filteredRes.clear();
      if (!widget.isPreorder) {
        filteredRes.addAll(hantarrBloc.state.allRestaurants
            .where((x) => !x.allowPreorder)
            .toList());
      } else {
        filteredRes.addAll(hantarrBloc.state.allRestaurants
            .where((x) => x.allowPreorder)
            .toList());
      }

      print("[filteredRes][length] ${filteredRes.length}");
      var dtResponse = await get(Uri.tryParse("$foodUrl/server_time"));
      DateTime currentDT =
          DateTime.parse(jsonDecode(dtResponse.body.replaceAll("Z", "")))
              .add(Duration(hours: 8));
      // hantarrBloc.state.allRestaurants.sort((a, b) =>
      //     (Restaurant().onlineRuleResult(a, currentDT) ? 0 : 1).compareTo(
      //         ((Restaurant().onlineRuleResult(b, currentDT)) ? 0 : 1)));
      filteredRes.sort((a, b) => (Restaurant().onlineRuleResult(a, currentDT)
              ? 0
              : 1)
          .compareTo(((Restaurant().onlineRuleResult(b, currentDT)) ? 0 : 1)));
    }

    hantarrBloc.add(Refresh());
  }

  getRealDT() async {
    var dtResponse = await get(Uri.tryParse("$foodUrl/server_time"));
    restaurantDT =
        DateTime.parse(jsonDecode(dtResponse.body.replaceAll("Z", "")))
            .add(Duration(hours: 8));
    setState(() {
      loading = false;
    });
  }

  void _onRefresh() async {
    setState(() {
      refreshing = true;
    });
    var getRestReq = await Restaurant().getRestaurantList(filterRestaurant);
    if (getRestReq['success']) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
    // _filter.clear();
    // focusNode.unfocus();
    // monitor network fetch
    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   if(hantarrBloc.state.allRestaurants.isno){

    //   }
    // });

    // if failed,use refreshFailed()

    setState(() {
      refreshing = false;
    });
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
        floatingActionButton: hantarrBloc
                .state.user.restaurantCart.menuItems.isNotEmpty
            ? Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FloatingActionButton(
                    heroTag: "restaurantpage",
                    elevation: 2,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FoodCheckout(
                                    restaurant: hantarrBloc
                                        .state.user.restaurantCart.restaurant,
                                  )));
                    },
                    child: Stack(
                      children: [
                        Center(
                            child: Container(
                          width: MediaQuery.of(context).size.width * 0.12,
                          child: Image.asset(
                            "assets/foodbag.png",
                            fit: BoxFit.fill,
                          ),
                        )),
                        Positioned(
                          top: 0.0,
                          right: 5.0,
                          child: Container(
                            padding: EdgeInsets.all(ScreenUtil().setSp(15)),
                            // width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                                color: themeBloc.state.primaryColor
                                    .withOpacity(0.2),
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text(
                              hantarrBloc
                                  .state.user.restaurantCart.menuItems.length
                                  .toString(),
                              style: TextStyle(
                                  color: themeBloc.state.primaryColor),
                            )),
                          ),
                        )
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  ),
                ),
              )
            : null,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: InkWell(
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () async {
                        showModalBottomSheet<void>(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            context: context,
                            builder: (BuildContext context) {
                              String chosenValue = hantarrBloc
                                  .state.user.currentContactInfo.address;
                              return StatefulBuilder(
                                  builder: (context, StateSetter modalState) {
                                List<Widget> locationWidget = [];
                                locationWidget.add(
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setSp(10,
                                            allowFontScalingSelf: true),
                                        bottom: ScreenUtil().setSp(10,
                                            allowFontScalingSelf: true)),
                                    margin: EdgeInsets.only(
                                        left: ScreenUtil().setSp(40,
                                            allowFontScalingSelf: true),
                                        right: ScreenUtil().setSp(40,
                                            allowFontScalingSelf: true)),
                                    child: InkWell(
                                      onTap: () async {
                                        loadingWidget(context);
                                        ContactInfo contactInfo = ContactInfo(
                                            id: null,
                                            title: "Your Current Location",
                                            address: "");
                                        Location location = Location();
                                        LocationData locationData;
                                        PermissionStatus _permissionGranted =
                                            await location.hasPermission();
                                        if (_permissionGranted !=
                                            PermissionStatus.granted) {
                                          _permissionGranted = await Location()
                                              .requestPermission();
                                          if (_permissionGranted ==
                                              PermissionStatus.granted) {
                                            bool enabled =
                                                await location.serviceEnabled();

                                            if (!enabled) {
                                              Future.delayed(
                                                      Duration(seconds: 5))
                                                  .then((value) async {
                                                enabled = await location
                                                    .serviceEnabled();
                                              });
                                              await location.requestService();
                                            } else {
                                              locationData =
                                                  await location.getLocation();
                                            }
                                          } else {}
                                        } else {
                                          await location
                                              .serviceEnabled()
                                              .then((enabled) async {
                                            if (enabled) {
                                              locationData =
                                                  await location.getLocation();
                                              contactInfo.longitude =
                                                  locationData.longitude
                                                      .toString();
                                              contactInfo.latitude =
                                                  locationData.latitude
                                                      .toString();
                                            }
                                          });
                                        }
                                        Navigator.pop(context);
                                        hantarrBloc.state.user
                                            .currentContactInfo = contactInfo;
                                        hantarrBloc.add(Refresh());
                                        Navigator.of(context).pop();
                                        _refreshController.requestRefresh();
                                      },
                                      child: ListTile(
                                        leading: IconButton(
                                          icon: Icon(
                                            Icons.my_location,
                                            color: themeBloc.state.primaryColor,
                                          ),
                                          onPressed: () {},
                                        ),
                                        title: Text(
                                          hantarrBloc.state.translation
                                              .text("Your Current Location"),
                                          style: GoogleFonts.aBeeZee(
                                              textStyle: TextStyle(
                                                  color: themeBloc
                                                      .state.primaryColor,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                locationWidget.add(
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setSp(10,
                                            allowFontScalingSelf: true),
                                        bottom: ScreenUtil().setSp(10,
                                            allowFontScalingSelf: true)),
                                    margin: EdgeInsets.only(
                                        left: ScreenUtil().setSp(40,
                                            allowFontScalingSelf: true),
                                        right: ScreenUtil().setSp(40,
                                            allowFontScalingSelf: true)),
                                    child: InkWell(
                                      onTap: () async {
                                        // print("ss");
                                        bool _serviceEnabled =
                                            await Location().serviceEnabled();
                                        PermissionStatus _permissionGranted =
                                            await Location().hasPermission();
                                        if (_permissionGranted !=
                                            PermissionStatus.granted) {
                                          _permissionGranted = await Location()
                                              .requestPermission();
                                        }

                                        if (!_serviceEnabled) {
                                          _serviceEnabled =
                                              await Location().requestService();
                                        }
                                        if (_serviceEnabled) {
                                          Navigator.of(context).pop();
                                          bool result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DragLocation(
                                                        updateLocation: false,
                                                        createAddress: false,
                                                      )));
                                          // print("done");

                                          if (result) {
                                            _refreshController.requestRefresh();
                                          }
                                        }
                                      },
                                      child: ListTile(
                                        leading: IconButton(
                                          icon: Icon(
                                            Icons.location_on,
                                            color: themeBloc.state.primaryColor,
                                          ),
                                          onPressed: () async {},
                                        ),
                                        title: Text(
                                          hantarrBloc.state.translation
                                              .text("New Location"),
                                          style: GoogleFonts.aBeeZee(
                                              textStyle: TextStyle(
                                                  color: themeBloc
                                                      .state.primaryColor,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                // if (hantarrBloc.state.user != null) {
                                for (ContactInfo contactInfo
                                    in hantarrBloc.state.user.contactInfos) {
                                  bool same =
                                      chosenValue == contactInfo.address;
                                  locationWidget.add(Container(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setSp(10,
                                            allowFontScalingSelf: true),
                                        bottom: ScreenUtil().setSp(10,
                                            allowFontScalingSelf: true)),
                                    margin: EdgeInsets.only(
                                        left: ScreenUtil().setSp(40,
                                            allowFontScalingSelf: true),
                                        right: ScreenUtil().setSp(40,
                                            allowFontScalingSelf: true)),
                                    decoration: BoxDecoration(
                                        color: same
                                            ? themeBloc.state.primaryColor
                                                .withOpacity(0.3)
                                            : null,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: InkWell(
                                      onTap: () {
                                        modalState(() {
                                          chosenValue = contactInfo.address;
                                        });
                                        hantarrBloc.state.user
                                            .currentContactInfo = contactInfo;
                                        _refreshController.requestRefresh();
                                        Navigator.of(context).pop();
                                        hantarrBloc.add(Refresh());
                                      },
                                      child: ListTile(
                                        leading: Radio(
                                          value: contactInfo.address,
                                          groupValue: chosenValue,
                                          activeColor:
                                              themeBloc.state.primaryColor,
                                          onChanged: (String value) {
                                            // if (value == contactInfo.address) {
                                            //   modalState(() {
                                            //     chosenValue = value;
                                            //   });
                                            //   hantarrBloc.state.user
                                            //           .currentContactInfo =
                                            //       contactInfo;
                                            //   hantarrBloc.add(Refresh());
                                            //   Navigator.of(context).pop();
                                            //   _refreshController
                                            //       .requestRefresh();
                                            // }
                                          },
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(contactInfo.title,
                                                style: GoogleFonts.aBeeZee(
                                                    letterSpacing: 1,
                                                    textStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: same
                                                            ? themeBloc.state
                                                                .primaryColor
                                                            : Colors.black))),
                                            Text(
                                                contactInfo.address.replaceAll(
                                                    "%address%", "\n"),
                                                style: GoogleFonts.aBeeZee(
                                                    textStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: same
                                                            ? Colors.black54
                                                            : Colors.black54)))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ));
                                }
                                // }
                                return SingleChildScrollView(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: locationWidget,
                                  ),
                                );
                              });
                            });
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 12,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  hantarrBloc.state.user.currentContactInfo
                                              .title !=
                                          null
                                      ? Text(
                                          hantarrBloc.state.user
                                              .currentContactInfo.title,
                                          style: GoogleFonts.aBeeZee(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.w600)))
                                      : Container(),
                                  hantarrBloc.state.user.currentContactInfo
                                          .address.isEmpty
                                      ? Container()
                                      : Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          child: Text(
                                              hantarrBloc.state.user
                                                  .currentContactInfo.address
                                                  .replaceAll("%address%", ","),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.aBeeZee(
                                                  textStyle: TextStyle(
                                                      color: themeBloc
                                                          .state.primaryColor,
                                                      fontSize: ScreenUtil()
                                                          .setSp(35)))),
                                        )
                                ],
                              ),
                            ),
                            Flexible(
                              child: Icon(
                                Icons.edit,
                                size: ScreenUtil()
                                    .setSp(50, allowFontScalingSelf: true),
                                color: themeBloc.state.primaryColor,
                              ),
                            )
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(ScreenUtil().setSp(30)),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    // color: Colors.red,

                    padding: EdgeInsets.only(
                        left:
                            ScreenUtil().setSp(50, allowFontScalingSelf: true),
                        right:
                            ScreenUtil().setSp(50, allowFontScalingSelf: true),
                        bottom: 10,
                        top: 10),
                    child: TextField(
                      focusNode: searchFnode,
                      controller: searchController,
                      style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                      decoration: InputDecoration(
                          fillColor: Colors.deepOrangeAccent.withOpacity(0.07),
                          filled: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10.0),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                          hintText: hantarrBloc.state.translation
                              .text("Find your favourite restaurant"),
                          border: new OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(20.0),
                            ),
                          ),
                          hintStyle: TextStyle(
                              fontSize: ScreenUtil().setSp(40),
                              color: themeBloc.state.primaryColor)),
                    ),
                  ),
                ),
              ),
              // widget.isPreorder
              //     ? Chip(
              //         label: InkWell(
              //           onTap: () {
              //             setState(() {
              //               widget.isPreorder = false;
              //             });
              //             _refreshController.requestRefresh();
              //           },
              //           child: Row(
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               Text(
              //                 hantarrBloc.state.translation.text("Preorder"),
              //               ),
              //               // SizedBox(
              //               //   width: ScreenUtil().setWidth(5),
              //               // ),
              //               Icon(
              //                 Icons.remove,
              //                 color: themeBloc.state.primaryColor,
              //               ),
              //             ],
              //           ),
              //         ),
              //       )
              //     : Container(),
              Flexible(
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: WaterDropHeader(
                    waterDropColor: refreshing
                        ? Colors.transparent
                        : themeBloc.state.primaryColor,
                    // circleColor: refreshing ? Colors.transparent : Colors.white,
                    // bezierColor: refreshing ? Colors.transparent : themeBloc.state.primaryColor,
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: refreshing
                      ? Column(children: <Widget>[
                          Container(
                            width: ScreenUtil().setWidth(700),
                            child: Animator(
                                tween: Tween<double>(begin: 0.7, end: 1),
                                curve: Curves.elasticOut,
                                cycles: 0,
                                builder: (context, animatorState, child) =>
                                    Transform.scale(
                                        scale: animatorState.value,
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Image.asset("assets/map.png"),
                                        ))),
                          ),
                          Container(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil()
                                      .setSp(70, allowFontScalingSelf: true),
                                  right: ScreenUtil()
                                      .setSp(70, allowFontScalingSelf: true),
                                  top: ScreenUtil()
                                      .setSp(30, allowFontScalingSelf: true),
                                  bottom: ScreenUtil()
                                      .setSp(30, allowFontScalingSelf: true)),
                              decoration: BoxDecoration(
                                  color: themeBloc.state.primaryColor
                                      .withOpacity(0.3),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Text(
                                "Searching neaby restaurant",
                                style: GoogleFonts.aBeeZee(
                                  textStyle: TextStyle(
                                      color: themeBloc.state.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: ScreenUtil().setSp(45)),
                                ),
                              ))
                        ])
                      : filteredRes.isNotEmpty
                          ? ListView.builder(
                              itemCount: filteredRes.length,
                              padding: const EdgeInsets.all(8.0),
                              itemBuilder: (context, int index) {
                                return Card(
                                  elevation: 0,
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: InkWell(
                                      onTap: () async {
                                        // loadingDialog(context);
                                        try {
                                          try {
                                            loadingWidget(context);
                                            await MenuItem().getMenuitem(
                                                filteredRes[index]);
                                            DateTime restaurantDT =
                                                await hantarrUser.User()
                                                    .getCurrentTime();
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MenuItemPage(
                                                          restaurantDT:
                                                              restaurantDT,
                                                          currentRestaurant:
                                                              filteredRes[
                                                                  index],
                                                        )));
                                          } catch (c) {
                                            Navigator.pop(context);
                                            showToast(c.message,
                                                context: context);
                                          }
                                        } catch (e) {
                                          showToast(e.message,
                                              context: context);
                                        }
                                      },
                                      child: Container(
                                          color: Colors.transparent,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              AspectRatio(
                                                aspectRatio: 16 / 7,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: <Widget>[
                                                    filteredRes[index]
                                                                .bannerImage !=
                                                            null
                                                        ? ClipRRect(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                            child:
                                                                CachedNetworkImage(
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                              // height: 100,
                                                              // width: 100,
                                                              imageUrl: "https://pos.str8.my/images/uploads/" +
                                                                  filteredRes[
                                                                          index]
                                                                      .id
                                                                      .toString() +
                                                                  "_" +
                                                                  filteredRes[
                                                                          index]
                                                                      .bannerImage,
                                                              placeholder:
                                                                  (context,
                                                                          url) =>
                                                                      new Center(
                                                                child:
                                                                    SpinKitDualRing(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  new Icon(Icons
                                                                      .error),
                                                            ),
                                                          )
                                                        : ClipRRect(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        20),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        20)),
                                                            child: Image.asset(
                                                              "assets/sample1.jpg",
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                            ),
                                                          ),

                                                    Restaurant()
                                                            .onlineRuleResult(
                                                                filteredRes[
                                                                    index],
                                                                restaurantDT)
                                                        ? Positioned(
                                                            top: 10.0,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                filteredRes[index]
                                                                        .discounts
                                                                        .isNotEmpty
                                                                    ? Container(
                                                                        padding: EdgeInsets.all(ScreenUtil().setSp(
                                                                            20,
                                                                            allowFontScalingSelf:
                                                                                true)),
                                                                        decoration:
                                                                            BoxDecoration(color: Colors.red[600]),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Container(
                                                                              alignment: Alignment.center,
                                                                              child: Text(
                                                                                filteredRes[index].discounts.first.name,
                                                                                style: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: ScreenUtil().setSp(25), color: Colors.white)),
                                                                                maxLines: 1,

                                                                                // overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                                SizedBox(
                                                                  height: ScreenUtil()
                                                                      .setHeight(
                                                                          20),
                                                                ),
                                                                filteredRes[index]
                                                                        .freeDelivery
                                                                    ? filteredRes[index].freeDeliveryKm >=
                                                                            filteredRes[index].distance
                                                                        ? Container(
                                                                            padding:
                                                                                EdgeInsets.all(ScreenUtil().setSp(20, allowFontScalingSelf: true)),
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.yellow[600]),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Container(
                                                                                  alignment: Alignment.center,
                                                                                  child: Text(
                                                                                    "Free Delivery",
                                                                                    style: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: ScreenUtil().setSp(25), color: Colors.black)),
                                                                                    maxLines: 1,

                                                                                    // overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : Container()
                                                                    : Container(),
                                                                filteredRes[index]
                                                                        .allowPreorder
                                                                    ? Container(
                                                                        padding: EdgeInsets.all(ScreenUtil().setSp(
                                                                            20,
                                                                            allowFontScalingSelf:
                                                                                true)),
                                                                        decoration:
                                                                            BoxDecoration(color: Colors.yellow[600]),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Container(
                                                                              alignment: Alignment.center,
                                                                              child: Text(
                                                                                "Preorder",
                                                                                style: GoogleFonts.montserrat(
                                                                                    textStyle: TextStyle(
                                                                                  fontSize: ScreenUtil().setSp(25),
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.bold,
                                                                                )),
                                                                                maxLines: 1,

                                                                                // overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Container()
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                    Restaurant()
                                                            .onlineRuleResult(
                                                                filteredRes[
                                                                    index],
                                                                restaurantDT)
                                                        ? Positioned(
                                                            bottom: 5.0,
                                                            left: 10.0,
                                                            child: Container(
                                                                padding: EdgeInsets.all(
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            15)),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(
                                                                                8))),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                            text:
                                                                                filteredRes[index].prepareTime.toString(),
                                                                            style: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: ScreenUtil().setSp(25), color: Colors.yellow[900], fontWeight: FontWeight.w500))),
                                                                        TextSpan(
                                                                            text:
                                                                                " min",
                                                                            style:
                                                                                GoogleFonts.montserrat(textStyle: TextStyle(fontSize: ScreenUtil().setSp(25), color: Colors.yellow[900]))),
                                                                      ]),
                                                                )),
                                                          )
                                                        : Container(),
                                                    // Positioned(
                                                    //   bottom: 0.0,
                                                    //   right: 0.0,
                                                    //   child: Container(
                                                    //     padding:
                                                    //         EdgeInsets.all(5.0),
                                                    //     height: 30.0,
                                                    //     decoration: BoxDecoration(
                                                    //         color: Colors.black
                                                    //             .withOpacity(
                                                    //                 0.5),
                                                    //         borderRadius: new BorderRadius
                                                    //                 .only(
                                                    //             topLeft:
                                                    //                 const Radius
                                                    //                         .circular(
                                                    //                     10.0),
                                                    //             bottomRight: Radius
                                                    //                 .circular(
                                                    //                     10))),
                                                    //     child: filteredRes[
                                                    //                     index]
                                                    //                 .rating !=
                                                    //             -1.0
                                                    //         ? Row(
                                                    //             mainAxisAlignment:
                                                    //                 MainAxisAlignment
                                                    //                     .center,
                                                    //             crossAxisAlignment:
                                                    //                 CrossAxisAlignment
                                                    //                     .center,
                                                    //             children: <
                                                    //                 Widget>[
                                                    //               Container(
                                                    //                 // alignment: Alignment.center,
                                                    //                 height:
                                                    //                     40.0,
                                                    //                 width: 10.0,
                                                    //                 child: Text(
                                                    //                   filteredRes[
                                                    //                           index]
                                                    //                       .rating
                                                    //                       .toStringAsFixed(
                                                    //                           0),
                                                    //                   style: TextStyle(
                                                    //                       fontSize: ScreenUtil().setSp(
                                                    //                           24),
                                                    //                       color:
                                                    //                           Colors.white),
                                                    //                   maxLines:
                                                    //                       1,
                                                    //                   overflow:
                                                    //                       TextOverflow
                                                    //                           .ellipsis,
                                                    //                 ),
                                                    //               ),
                                                    //               Icon(
                                                    //                 Icons.star,
                                                    //                 color:
                                                    //                     themeBloc.state.primaryColor,
                                                    //                 size: 10,
                                                    //               ),
                                                    //             ],
                                                    //           )
                                                    //         : AutoSizeText(
                                                    //             "No Review",
                                                    //             style: TextStyle(
                                                    //                 fontSize: ScreenUtil()
                                                    //                     .setSp(
                                                    //                         20),
                                                    //                 color: Colors
                                                    //                     .white),
                                                    //             maxLines: 1,
                                                    //             overflow:
                                                    //                 TextOverflow
                                                    //                     .ellipsis,
                                                    //           ),
                                                    //   ),
                                                    // ),
                                                    //to-do close banner
                                                    Restaurant()
                                                            .onlineRuleResult(
                                                                filteredRes[
                                                                    index],
                                                                restaurantDT)
                                                        ? Container()
                                                        : Container(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.5),
                                                            child: Center(
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20,
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                color: themeBloc
                                                                    .state
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        0.8),
                                                                child: Text(
                                                                  // translation.text(
                                                                  //     "Restaurant_Closed")
                                                                  "Shop Closed",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(40)),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                  child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                          child: Text(
                                                            filteredRes[index]
                                                                .name,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            40)),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Row(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    color: themeBloc
                                                                        .state
                                                                        .primaryColor,
                                                                    size: 15,
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child: Text(
                                                                      " " +
                                                                          filteredRes[index]
                                                                              .area
                                                                              .toString() +
                                                                          "," +
                                                                          filteredRes[index]
                                                                              .state
                                                                              .toString(),
                                                                      style: TextStyle(
                                                                          fontSize: ScreenUtil().setSp(
                                                                              30),
                                                                          color:
                                                                              Colors.black),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              Row(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Icons
                                                                        .radio_button_checked,
                                                                    color: themeBloc
                                                                        .state
                                                                        .primaryColor,
                                                                    size: 15,
                                                                  ),
                                                                  // showDistance(
                                                                  //     hantarrBloc.state
                                                                  //             .allRestaurants[
                                                                  //         index],
                                                                  //     translation)
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    child: Text(
                                                                      " " +
                                                                          filteredRes[index]
                                                                              .distance
                                                                              .toStringAsFixed(1) +
                                                                          " km away",
                                                                      style: TextStyle(
                                                                          fontSize: ScreenUtil().setSp(
                                                                              30),
                                                                          color:
                                                                              Colors.black),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  )
                                                                  // Text(hantarrBloc.state.allRestaurants[index]
                                                                  //         .distance
                                                                  //         .toStringAsFixed(1) +
                                                                  //     " KM Away")
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          filteredRes[index]
                                                                  .stalls
                                                                  .isNotEmpty
                                                              ? Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              7),
                                                                  // color: Colors.black,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .black),
                                                                      color: themeBloc
                                                                          .state
                                                                          .primaryColor,
                                                                      borderRadius: new BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              40.0))),
                                                                  child: Text(
                                                                    "Food Court",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            ScreenUtil().setSp(25)),
                                                                  ),
                                                                )
                                                              : Container()
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )),
                                            ],
                                          ))),
                                );
                              })
                          : Column(children: <Widget>[
                              Container(
                                width: ScreenUtil().setWidth(700),
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
                                          allowFontScalingSelf: true),
                                      right: ScreenUtil().setSp(70,
                                          allowFontScalingSelf: true),
                                      top: ScreenUtil().setSp(30,
                                          allowFontScalingSelf: true),
                                      bottom: ScreenUtil().setSp(30,
                                          allowFontScalingSelf: true)),
                                  child: Text(
                                    "Sorry.\nNo Restaurant offer in your area.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.aBeeZee(
                                      textStyle: TextStyle(
                                          color: themeBloc.state.primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenUtil().setSp(45)),
                                    ),
                                  )),
                              FlatButton(
                                color: themeBloc.state.primaryColor
                                    .withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                onPressed: () async {
                                  loadingWidget(context);
                                  bool _serviceEnabled =
                                      await Location().serviceEnabled();
                                  PermissionStatus _permissionGranted =
                                      await Location().hasPermission();
                                  if (_permissionGranted !=
                                      PermissionStatus.granted) {
                                    _permissionGranted =
                                        await Location().requestPermission();
                                  }

                                  if (!_serviceEnabled) {
                                    _serviceEnabled =
                                        await Location().requestService();
                                  }
                                  if (_serviceEnabled) {
                                    Navigator.of(context).pop();
                                    bool result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DragLocation(
                                                  updateLocation: false,
                                                  createAddress: false,
                                                )));
                                    // print("done");

                                    if (result) {
                                      _refreshController.requestRefresh();
                                    }
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text(
                                  "Try other location",
                                  style: GoogleFonts.aBeeZee(
                                    textStyle: TextStyle(
                                        color: themeBloc.state.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: ScreenUtil().setSp(45)),
                                  ),
                                ),
                              ),
                            ]),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
