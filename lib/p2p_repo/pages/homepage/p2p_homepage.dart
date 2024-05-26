import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/stop_module.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/root_page_repo/ui/address_page/addressSelection.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

// ignore: must_be_immutable
class P2pHomepage extends StatefulWidget {
  P2pTransaction p2pTransaction;
  P2pHomepage({
    @required this.p2pTransaction,
  });
  @override
  _P2pHomepageState createState() => _P2pHomepageState();
}

class _P2pHomepageState extends State<P2pHomepage>
    with SingleTickerProviderStateMixin {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController headerscrollController = ScrollController();
  int intialTabbar = 0;
  TabController tabController;

  @override
  void initState() {
    headerscrollController.addListener(() {
      try {
        if (headerscrollController.offset >=
                headerscrollController.position.maxScrollExtent &&
            !headerscrollController.position.outOfRange) {
          headerscrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
        if (headerscrollController.offset <=
                headerscrollController.position.minScrollExtent &&
            !headerscrollController.position.outOfRange) {
          headerscrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      } catch (e) {}
    });
    tabController = TabController(
      initialIndex: intialTabbar,
      length: hantarrBloc.state.vehicleList.length,
      vsync: this,
    );
    widget.p2pTransaction.vehicle = hantarrBloc.state.vehicleList[intialTabbar];
    tabController.addListener(() {
      print("changed ${tabController.index}");
      setState(() {
        widget.p2pTransaction.vehicle =
            hantarrBloc.state.vehicleList[tabController.index];
      });
    });
    print(hantarrBloc.state.vehicleList.length);
    Future.delayed(Duration(milliseconds: 1), () {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void getTotalDistance() async {
    BotToast.showLoading();
    var getDistanceReq = await widget.p2pTransaction.getTotalDistance();
    setState(() {});
    BotToast.closeAllLoading();
    if (getDistanceReq['success']) {
      debugPrint("get total distance success");
    } else {
      BotToast.showText(text: "Something went wrong");
      showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () {
              return null;
            },
            child: AlertDialog(
              title: Text("Something went wrong"),
              content: Text("${getDistanceReq['reason']}"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    getTotalDistance();
                  },
                  color: Colors.orange[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                  child: Text(
                    "Ok",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(30.0),
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

  void addStop() {
    if (widget.p2pTransaction.canAddMoreStops()) {
      widget.p2pTransaction.stops.add(Stop.initClass());

      widget.p2pTransaction.getTotalDistance();
      setState(() {});
    } else {
      BotToast.showText(
          text:
              "Cannot add more than ${widget.p2pTransaction.maxStops()} stops");
    }
  }

  Future<void> deleteStop(Stop stop) async {
    if (widget.p2pTransaction.stops.length > 2) {
      widget.p2pTransaction.stops.remove(stop);
      setState(() {});
      await widget.p2pTransaction.getTotalDistance();
      setState(() {});
    } else {
      BotToast.showText(text: "Must At least 2 stops");
    }
  }

  void onSelectLocation(Stop stop) async {
    var confirmation = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: Text("Choose Address From"),
          content: Container(
            width: MediaQuery.of(context).size.width * .95,
            height: ScreenUtil().setHeight(300),
            child: Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context, "address");
                    },
                    padding: EdgeInsets.zero,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_filled,
                            color: Colors.grey[600],
                            size: ScreenUtil().setSp(55),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(15),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  "Address Book",
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: themeBloc.state.textTheme.headline6
                                      .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: ScreenUtil().setSp(55),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context, "map");
                    },
                    padding: EdgeInsets.zero,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            color: Colors.grey[600],
                            size: ScreenUtil().setSp(55),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(15),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  "Map",
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: themeBloc.state.textTheme.headline6
                                      .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: ScreenUtil().setSp(55),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmation == "address") {
      print(stop.address);
      Address thisAddress = await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: AddressSelectUtil(),
          );
        },
      );
      try {
        if (stop.address != null) {
          stop.address.mapToLocal(thisAddress);
          setState(() {});
        }
        getTotalDistance();
      } catch (e) {}
    } else if (confirmation == "map") {
      var thisAddress = await Navigator.pushNamed(context, manageAddressPage);
      if (thisAddress != null) {
        try {
          if (thisAddress != null) {
            stop.address.mapToLocal(thisAddress);
            setState(() {});
          }
          getTotalDistance();
        } catch (e) {}
      }
    }
    Future.delayed(Duration(milliseconds: 200), () {
      FocusScope.of(context).unfocus();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      builder: (BuildContext context, HantarrState state) {
        return WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
            return null;
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              key: _scaffoldKey,
              // backgroundColor: themeBloc.state.primaryColor,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight * 2.4),
                child: Container(
                  decoration: BoxDecoration(
                    // color: themeBloc.state.primaryColor,
                    gradient: new LinearGradient(
                      colors: [Colors.orange, themeBloc.state.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.3, 1],
                    ),
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.grey[500],
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  child: AppBar(
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(
                                right: ScreenUtil().setWidth(150)),
                            child: Image.asset(
                              "assets/logowordWhite.png",
                              height: kToolbarHeight - 10,
                              width: mediaQ.width,
                              fit: BoxFit.contain,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    bottom: TabBar(
                      controller: tabController,
                      labelStyle: TextStyle(fontWeight: FontWeight.w700),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.blueAccent,
                      unselectedLabelColor: Colors.black,
                      isScrollable: true,
                      indicator: MD2Indicator(
                        indicatorSize: MD2IndicatorSize.normal,
                        indicatorHeight: 3,
                        indicatorColor: Color(0xff1967d2),
                      ),
                      tabs: hantarrBloc.state.vehicleList
                          .map(
                            (e) => Tab(
                              icon: Icon(
                                e.getIcon(),
                                size: ScreenUtil().setSp(35),
                              ),
                              text: e.vehicleName,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: hantarrBloc.state.p2pVehicleLoaded
                  ? BottomAppBar(
                      elevation: 0.0,
                      child: widget.p2pTransaction.vehicle.disable == false
                          ? ListTile(
                              title: Container(
                                margin: EdgeInsets.only(right: 15),
                                child: Text(
                                  "RM ${(widget.p2pTransaction.getRoundedCurrency(widget.p2pTransaction.getTotalPrice())).toStringAsFixed(2)}",
                                  textAlign: TextAlign.end,
                                  style: themeBloc.state.textTheme.headline6
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: ScreenUtil().setSp(40.0),
                                  ),
                                ),
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RaisedButton(
                                    onPressed: () async {
                                      if (widget.p2pTransaction
                                              .getTotalValidStopsCount() >=
                                          2) {
                                        if (widget.p2pTransaction
                                                .exceedVehicleKM() ==
                                            true) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "Exceed Vehicle Travel Distance"),
                                                content: Text(
                                                    "${widget.p2pTransaction.vehicle.vehicleName} Max travel distance ${widget.p2pTransaction.vehicle.kmLimit} km.\nYour distance: ${(widget.p2pTransaction.totalDistance / 1000).toStringAsFixed(2)} km"),
                                                actions: [
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: themeBloc
                                                        .state.accentColor,
                                                    child: Text(
                                                      "OK",
                                                      style: themeBloc.state
                                                          .textTheme.headline6
                                                          .copyWith(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                          return;
                                        }
                                        loadingWidget(context);
                                        var checkAreaRea = await widget
                                            .p2pTransaction
                                            .getSupportAreas();
                                        Navigator.pop(context);
                                        List areas = checkAreaRea['data'];
                                        if (checkAreaRea['success'] &&
                                            areas.isNotEmpty) {
                                          Navigator.pushNamed(
                                            context,
                                            p2pDetailPage,
                                            arguments: widget.p2pTransaction,
                                          );
                                        } else if (checkAreaRea['success'] &&
                                            areas.isEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "${checkAreaRea['reason']}"),
                                                content: Text(""),
                                                actions: [
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: themeBloc
                                                        .state.accentColor,
                                                    child: Text(
                                                      "OK",
                                                      style: themeBloc.state
                                                          .textTheme.headline6
                                                          .copyWith(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title:
                                                    Text("Get Coverage Failed"),
                                                content: Text(
                                                    "${checkAreaRea['reason']}"),
                                                actions: [
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: themeBloc
                                                        .state.accentColor,
                                                    child: Text(
                                                      "OK",
                                                      style: themeBloc.state
                                                          .textTheme.headline6
                                                          .copyWith(
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                              title: Text(
                                                  "Must add atleast 2 stops"),
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
                                    },
                                    color: Colors.orange[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25.0),
                                      ),
                                    ),
                                    child: Text(
                                      "Proceed",
                                      style: themeBloc.state.textTheme.headline6
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(35.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: ScreenUtil().setWidth(30)),
                                ],
                              ),
                            )
                          : ListTile(
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RaisedButton(
                                    onPressed: () async {
                                      // TODO: register intereset
                                      if (widget.p2pTransaction
                                              .getTotalValidStopsCount() >=
                                          2) {
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                              title: Text(
                                                  "Must add atleast 2 stops"),
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
                                    },
                                    color: Colors.orange[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25.0),
                                      ),
                                    ),
                                    child: Text(
                                      "SUBMIT YOUR INTEREST",
                                      style: themeBloc.state.textTheme.headline6
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(35.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: ScreenUtil().setWidth(30)),
                                ],
                              ),
                            ),
                    )
                  : null,
              body: Container(
                child: Container(
                  width: mediaQ.width,
                  height: mediaQ.height,
                  child: hantarrBloc.state.p2pVehicleLoaded
                      ? Column(
                          children: [
                            ConstrainedBox(
                              constraints: new BoxConstraints(
                                minHeight: 20.0,
                                maxHeight: mediaQ.height * .4,
                              ),
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 20, bottom: 20, left: 20, right: 20),
                                width: mediaQ.width,
                                child: ImplicitlyAnimatedReorderableList<Stop>(
                                  items: widget.p2pTransaction.stops,
                                  areItemsTheSame: (oldItem, newItem) =>
                                      oldItem.hashCode == newItem.hashCode,
                                  onReorderFinished:
                                      (item, from, to, newItems) async {
                                    setState(() {
                                      widget.p2pTransaction.stops
                                        ..clear()
                                        ..addAll(newItems);
                                    });
                                    getTotalDistance();
                                    setState(() {});
                                  },
                                  itemBuilder:
                                      (context, itemAnimation, item, index) {
                                    return Reorderable(
                                      key: ValueKey(item),
                                      builder:
                                          (context, dragAnimation, inDrag) {
                                        final t = dragAnimation.value;
                                        final elevation = lerpDouble(0, 8, t);
                                        final color = Color.lerp(Colors.white,
                                            Colors.white.withOpacity(0.8), t);

                                        return SizeFadeTransition(
                                          sizeFraction: 0.7,
                                          curve: Curves.easeInOut,
                                          animation: itemAnimation,
                                          child: Material(
                                            color: color,
                                            elevation: elevation,
                                            type: MaterialType.transparency,
                                            child: Container(
                                              child: ListTile(
                                                isThreeLine: false,
                                                dense: true,
                                                key: Key(
                                                    item.hashCode.toString()),
                                                contentPadding: EdgeInsets.zero,
                                                title: Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      child: TextField(
                                                        // onTap: () async {
                                                        //   onSelectLocation(item);
                                                        // },
                                                        readOnly: true,
                                                        enableInteractiveSelection:
                                                            false,
                                                        controller:
                                                            TextEditingController(
                                                          text: item
                                                              .address.address,
                                                        ),
                                                        style: themeBloc.state
                                                            .textTheme.headline6
                                                            .copyWith(
                                                          color: Colors.black,

                                                          // fontSize: 9,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          labelText: widget
                                                                      .p2pTransaction
                                                                      .stops
                                                                      .indexOf(
                                                                          item) ==
                                                                  0
                                                              ? "Pick Up"
                                                              : item ==
                                                                      widget
                                                                          .p2pTransaction
                                                                          .stops
                                                                          .last
                                                                  ? "Drop Off"
                                                                  : "Stop NO: ${widget.p2pTransaction.stops.indexOf(item) + 1}",
                                                          labelStyle: themeBloc
                                                              .state
                                                              .textTheme
                                                              .headline6
                                                              .copyWith(
                                                            color: Colors
                                                                .grey[500],
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .grey[600],
                                                              width: 0.1,
                                                            ),
                                                          ),
                                                          suffixIcon: widget
                                                                          .p2pTransaction
                                                                          .stops
                                                                          .indexOf(
                                                                              item) !=
                                                                      0 &&
                                                                  widget.p2pTransaction
                                                                          .stops
                                                                          .indexOf(
                                                                              item) !=
                                                                      1
                                                              ? IconButton(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  onPressed:
                                                                      () async {
                                                                    loadingWidget(
                                                                        context);
                                                                    await deleteStop(
                                                                        item);
                                                                    Navigator.pop(
                                                                        context);
                                                                    // Navigator.pop(
                                                                    //     context);
                                                                  },
                                                                  icon: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                )
                                                              : null,
                                                        ),
                                                      ),
                                                    ),
                                                    MaterialButton(
                                                      onPressed: () async {
                                                        onSelectLocation(item);
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      child: Container(
                                                        width:
                                                            mediaQ.width * .66,
                                                        height: kToolbarHeight,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: Handle(
                                                    delay: const Duration(
                                                        milliseconds: 100),
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: null,
                                                      icon: Icon(
                                                        Icons.menu,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  shrinkWrap: true,
                                ),
                              ),
                            ),
                            widget.p2pTransaction.canAddMoreStops()
                                ? FlatButton(
                                    onPressed: addStop,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Add Stop",
                                          style: themeBloc
                                              .state.textTheme.headline6
                                              .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: ScreenUtil().setSp(35.0),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: addStop,
                                          icon: Icon(Icons.add),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: TabBarView(
                                              controller: tabController,
                                              children:
                                                  hantarrBloc.state.vehicleList
                                                      .map(
                                                        (e) => e.getTabPage(() {
                                                          setState(() {
                                                            widget
                                                                .p2pTransaction
                                                                .vehicle = hantarrBloc
                                                                    .state
                                                                    .vehicleList[
                                                                tabController
                                                                    .index];
                                                          });
                                                        }),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SpinKitDoubleBounce(
                                size: ScreenUtil().setSp(55.0),
                                color: themeBloc.state.primaryColor,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Loading...",
                                style: themeBloc.state.textTheme.headline6
                                    .copyWith(
                                  inherit: true,
                                  fontSize: ScreenUtil().setSp(55.0),
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
