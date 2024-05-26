import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hantarr/module/user_module.dart' as hantarrUser;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hantarr/foodService/foodCustomization.dart';
import 'package:hantarr/foodService/preorderDialog.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'discountTileWidgets/discountTile.dart';

// ignore: must_be_immutable
class MenuItemPage extends StatefulWidget {
  Restaurant currentRestaurant;
  DateTime restaurantDT;
  MenuItemPage({
    Key key,
    @required this.currentRestaurant,
    @required this.restaurantDT,
  }) : super(key: key);

  @override
  _MenuItemPageState createState() => _MenuItemPageState();
}

class _MenuItemPageState extends State<MenuItemPage>
    with TickerProviderStateMixin {
  bool appBarCollapsed = false, loading = true;
  TabController _tabController;
  List<String> categories = [];
  List<Tab> _tabCategory = List<Tab>();
  List<Widget> _menuitemTabView = List<Widget>();
  ScrollController mainScrollController = ScrollController();
  ScrollController itemScrollController = ScrollController();
  int index = 0;
  BuildContext myContext;
  GlobalKey _one = GlobalKey();

  @override
  void initState() {
    mainScrollController.addListener(() {
      setState(() {});
    });
    getCategory();
    super.initState();
    if (widget.currentRestaurant.allowPreorder) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(myContext).startShowCase([_one]),
      );
    }
  }

  @override
  void dispose() {
    if (_tabController != null) {
      _tabController.dispose();
    }
    mainScrollController.dispose();
    super.dispose();
  }

  onPreorderClicked() async {
    if (widget.currentRestaurant.allowPreorder) {
      DateTime currentDT = await hantarrUser.User().getCurrentTime();
      var preorderDatetimeAwait = await
          // showDialog(
          //   context: context,
          //   builder: (BuildContext context) {
          //     // return object of type Dialog
          //     return ChooseDeliveryTimeWidget(
          //       curTime: currentDT,
          //       restaurant: widget.currentRestaurant,
          //     );
          //   },
          // );
          showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return PreorderDatetime(
            currentDT: currentDT,
            restaurant: widget.currentRestaurant,
            update: false,
          );
        },
      );
      if (preorderDatetimeAwait != null) {
        setState(() {
          String preorderDatetime = preorderDatetimeAwait;
          hantarrBloc.state.user.restaurantCart.preOrderDateTime =
              preorderDatetime;
          hantarrBloc.add(Refresh());
        });
      }
    } else {
      unablePreorderDialog(context);
    }
  }

  getCategory() {
    categories.clear();
    for (var map in widget.currentRestaurant.categorySortRule) {
      try {
        if (!map["name"].contains("_")) {
          categories.add(map["name"]);
        }
      } catch (e) {
        String msg = getExceptionMsg(e);
        Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
        JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        String jsonString = encoder.convert(getExceptionLogReq);
        FirebaseCrashlytics.instance
            .recordError(getExceptionLogReq, StackTrace.current);
        FirebaseCrashlytics.instance.log(jsonString);
        debugPrint("categorySortRule hit error. $msg");
      }
    }
    int tabLength = 0;
    for (String cat in categories) {
      List<MenuItem> menuItems = widget.currentRestaurant.menuItems
          .where((element) => element.category == cat)
          .toList();
      if (menuItems.isNotEmpty) {
        tabLength++;
      }
    }
    _tabController = TabController(length: tabLength, vsync: this);

    getTabViewWidgets();
  }

  List<Widget> getTabViewWidgets() {
    _tabCategory.clear();
    _menuitemTabView.clear();

    // _menuitemTabView.add(

    // );
    for (String cat in categories) {
      // List<Widget> menuItemWidgets = [];

      List<MenuItem> menuItems = widget.currentRestaurant.menuItems
          .where((element) => element.category == cat)
          .toList();

      if (menuItems.isNotEmpty) {
        _tabCategory.add(Tab(
          child: Container(
            constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(400)),
            // height: MediaQuery.of(context).size.height,
            child: Text(
              cat,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));

        // Widget tabViewWidget =
        //     SliverList(delegate: SliverChildListDelegate(menuItemWidgets));
        _menuitemTabView.add(TabBarViewWidgets(
          restaurant: widget.currentRestaurant,
          menuItems: menuItems,
          restaurantDT: widget.restaurantDT,
          triggerPreorder: onPreorderClicked,
        ));
      }
    }
    return _menuitemTabView;
  }

  Widget deliveryTimeSetting() {
    String preorderDateTime = "";
    if (hantarrBloc.state.user.restaurantCart.preOrderDateTime != null &&
        hantarrBloc.state.user.restaurantCart.preOrderDateTime != "") {
      try {
        preorderDateTime = hantarrBloc
            .state.user.restaurantCart.preOrderDateTime
            .toString()
            .substring(0, 16);
      } catch (e) {
        preorderDateTime = "Deliver ASAP";
      }
    } else {
      preorderDateTime = "Deliver ASAP";
    }
    return Text(
      preorderDateTime,
      style: GoogleFonts.aBeeZee(
          color: appBarCollapsed ? themeBloc.state.primaryColor : Colors.white,
          fontWeight: FontWeight.w300,
          fontSize: ScreenUtil().setSp(40)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return ShowCaseWidget(
        onFinish: () {
          onPreorderClicked();
        },
        // onFinish: ,
        builder: Builder(
          builder: (context) {
            myContext = context;
            return Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: hantarrBloc
                        .state.user.restaurantCart.menuItems.isNotEmpty
                    ? FloatingActionButton(
                        heroTag: "menuitem",
                        elevation: 5,
                        backgroundColor:
                            themeBloc.state.primaryColor.withOpacity(0.8),
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FoodCheckout(
                                        restaurant: hantarrBloc.state.user
                                            .restaurantCart.restaurant,
                                      )));
                          Timer(Duration(milliseconds: 500), () {
                            print("refresheddddd");
                            hantarrBloc.add(Refresh());
                            setState(() {});
                          });
                        },
                        child: Center(
                            child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(50),
                              ),
                              Text("View Your Cart",
                                  style: GoogleFonts.aBeeZee(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil().setSp(40)))),
                              SizedBox(
                                width: ScreenUtil().setWidth(50),
                              ),
                              Container(
                                // width: MediaQuery.of(context).size.width,
                                // height: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.all(ScreenUtil().setSp(10)),
                                child: Center(
                                    child: Text(
                                  hantarrBloc.state.user.restaurantCart
                                      .menuItems.length
                                      .toString(),
                                  style: TextStyle(
                                      color: themeBloc.state.primaryColor),
                                )),
                              )
                            ],
                          ),
                        )),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                      )
                    : null,
              ),
              body: DefaultTabController(
                length: _menuitemTabView.length,
                child: NestedScrollView(
                  controller: mainScrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        pinned: true,
                        floating: true,
                        expandedHeight: ScreenUtil().setHeight(400),
                        automaticallyImplyLeading: false,
                        // collapsedHeight: ScreenUtil().setHeighfcat(300),
                        flexibleSpace: LayoutBuilder(builder:
                            (BuildContext ctxt, BoxConstraints constraints) {
                          if (constraints.biggest.height ==
                              MediaQuery.of(context).padding.top +
                                  kToolbarHeight) {
                            appBarCollapsed = true;
                          } else {
                            appBarCollapsed = false;
                          }
                          return FlexibleSpaceBar(
                              background: Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    // height: ScreenUtil().setHeight(400),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://pos.str8.my/images/uploads/" +
                                                widget.currentRestaurant.id
                                                    .toString() +
                                                "_" +
                                                widget.currentRestaurant
                                                    .bannerImage
                                                    .toString(),
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          "assets/logoword.png",
                                          fit: BoxFit.cover,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      // Image.network(
                                      //   "https://pos.str8.my/images/uploads/" +
                                      //       widget.currentRestaurant.id.toString() +
                                      //       "_" +
                                      //       widget.currentRestaurant.bannerImage,
                                      //   fit: BoxFit.cover,
                                      // ),
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                SafeArea(
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            onPreorderClicked();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                border: Border.all(
                                                    color: Colors.white)),
                                            padding: EdgeInsets.only(
                                                top: ScreenUtil().setSp(15),
                                                bottom: ScreenUtil().setSp(15),
                                                left: ScreenUtil().setSp(60),
                                                right: ScreenUtil().setSp(60)),
                                            child: Showcase(
                                              key: _one,
                                              title: "Preorder",
                                              description:
                                                  "Click this to change preorder DateTime",
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  deliveryTimeSetting(),
                                                  Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: appBarCollapsed
                                                        ? themeBloc
                                                            .state.primaryColor
                                                        : Colors.white,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SafeArea(
                                  child: Container(
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                              margin: EdgeInsets.all(
                                                  ScreenUtil().setSp(20)),
                                              padding: EdgeInsets.all(
                                                  ScreenUtil().setSp(15)),
                                              decoration: BoxDecoration(
                                                // borderRadius:
                                                //     BorderRadius.all(Radius.circular(20)),
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: Icon(
                                                Icons.arrow_back_ios,
                                                color: themeBloc
                                                    .state.primaryColor,
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    onPressed: () {
                                      // print(widget.currentRestaurant.businessHours);
                                      if (widget.currentRestaurant.businessHours
                                          .isEmpty) {
                                        widget.currentRestaurant.businessHours =
                                            [];
                                      }

                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                            ),
                                            child: SingleChildScrollView(
                                              padding: EdgeInsets.all(
                                                ScreenUtil().setSp(15.0),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                      "Business Hour",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children:
                                                        widget.currentRestaurant
                                                            .businessHours
                                                            .map(
                                                              (e) => Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  ListTile(
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: ScreenUtil()
                                                                          .setWidth(
                                                                              30),
                                                                    ),
                                                                    title: Text(
                                                                      weekday[
                                                                          e.numOfDay -
                                                                              1],
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    subtitle: Text(
                                                                        "${e.startTime.substring(0, 5)} - ${e.endTime.substring(0, 5)}"),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                            .toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.info,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ));
                        }),
                        title: appBarCollapsed
                            ? InkWell(
                                onTap: () async {
                                  if (widget.currentRestaurant.allowPreorder) {
                                    DateTime currentDT =
                                        await hantarrUser.User()
                                            .getCurrentTime();
                                    String preorderDatetime = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        // return object of type Dialog
                                        return PreorderDatetime(
                                          currentDT: currentDT,
                                          restaurant: widget.currentRestaurant,
                                          update: false,
                                        );
                                      },
                                    );
                                    setState(() {
                                      hantarrBloc.state.user.restaurantCart
                                          .preOrderDateTime = preorderDatetime;
                                      hantarrBloc.add(Refresh());
                                    });
                                  } else {
                                    print("not allow");
                                    unablePreorderDialog(context);
                                  }
                                },
                                child: Container(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      deliveryTimeSetting(),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: appBarCollapsed
                                            ? themeBloc.state.primaryColor
                                            : Colors.white,
                                      )
                                    ],
                                  ),
                                ))
                            : null,
                        backgroundColor: Colors.white,
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          widget.currentRestaurant.discounts.isNotEmpty
                              ? Container(
                                  child: dicountTile(
                                      widget.currentRestaurant, context),
                                )
                              : Container(),
                          TabBar(
                            isScrollable: true,
                            controller: _tabController,
                            labelColor: Colors.black87,
                            unselectedLabelColor: Colors.grey,
                            tabs: _tabCategory,
                          ),
                          widget.currentRestaurant,
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: Container(
                      color: Colors.grey[100],
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            height: ScreenUtil().setHeight(150),
                            color: Colors.white,
                            padding: EdgeInsets.all(ScreenUtil().setSp(30)),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              widget.currentRestaurant.name,
                              style: GoogleFonts.aBeeZee(
                                textStyle: TextStyle(
                                    fontSize: ScreenUtil().setSp(50),
                                    fontWeight: FontWeight.w600),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(80),
                            color: Colors.white,
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setSp(30),
                                right: ScreenUtil().setSp(30)),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: ScreenUtil().setSp(50,
                                          allowFontScalingSelf: true),
                                      color: Colors.yellow[700],
                                    ),
                                    Text(
                                        " ${state.user.restaurantCart.menuItems.length}")
                                  ],
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(30),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: ScreenUtil().setSp(50,
                                          allowFontScalingSelf: true),
                                      color: themeBloc.state.primaryColor,
                                    ),
                                    Text(widget.currentRestaurant.distance
                                            .toStringAsFixed(1) +
                                        " " +
                                        "km")
                                  ],
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(30),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      LineIcons.motorcycle,
                                      size: ScreenUtil().setSp(50,
                                          allowFontScalingSelf: true),
                                      color: themeBloc.state.primaryColor,
                                    ),
                                    Text(" - ")
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: TabBarView(
                              controller: _tabController,
                              children: getTabViewWidgets(),
                            ),
                          )
                        ],
                      )),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.discountWidget, this._tabBar, this.restaurant);
  final Widget discountWidget;
  final TabBar _tabBar;
  final Restaurant restaurant;

  // @override
  // double get minExtent => _tabBar.preferredSize.height;
  // @override
  // double get maxExtent => _tabBar.preferredSize.height;
  @override
  double get minExtent => restaurant.discounts.isNotEmpty
      ? ScreenUtil().setHeight(240)
      : _tabBar.preferredSize.height;
  @override
  double get maxExtent => restaurant.discounts.isNotEmpty
      ? ScreenUtil().setHeight(240)
      : _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: discountWidget,
          ),
          _tabBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// ignore: must_be_immutable
class TabBarViewWidgets extends StatefulWidget {
  List<MenuItem> menuItems;
  Restaurant restaurant;
  DateTime restaurantDT;
  dynamic triggerPreorder;
  TabBarViewWidgets({
    Key key,
    this.menuItems,
    this.restaurant,
    @required this.restaurantDT,
    @required this.triggerPreorder,
  }) : super(key: key);

  @override
  TabBarViewWidgetsState createState() => TabBarViewWidgetsState();
}

class TabBarViewWidgetsState extends State<TabBarViewWidgets> {
  initCart() async {
    print("not this res");
    var confirmClearCart = await showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () {
            Navigator.pop(context, "No");
            return null;
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: Container(
              width: ScreenUtil().setWidth(500),
              height: ScreenUtil().setHeight(300),
              child: SvgPicture.asset(
                "assets/warning_cart.svg",
              ),
            ),
            content: Text(
              "If you proceed to add item your item will be cleared!",
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, "No");
                },
                child: Text(
                  "Cancel",
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, "Ok");
                },
                child: Text(
                  "Proceed",
                ),
              )
            ],
          ),
        );
      },
    );
    // print(confirmClearCart);
    if (confirmClearCart == "Ok") {
      if (!widget.restaurant.allowPreorder) {
        hantarrBloc.state.user.restaurantCart.preOrderDateTime = "";
        hantarrBloc.state.user.restaurantCart.restaurant = widget.restaurant;
        hantarrBloc.state.user.restaurantCart.menuItems = [];
      } else {
        if (hantarrBloc.state.user.restaurantCart.preOrderDateTime.isNotEmpty) {
          hantarrBloc.state.user.restaurantCart.restaurant = widget.restaurant;
          hantarrBloc.state.user.restaurantCart.menuItems = [];
        } else {
          hantarrBloc.state.user.restaurantCart.restaurant = widget.restaurant;
          hantarrBloc.state.user.restaurantCart.menuItems = [];
          widget.triggerPreorder();
        }
      }
      setState(() {});
      hantarrBloc.add(Refresh());
    }
  }

  List<Widget> menuItemWidgets = [];
  List<Widget> generateMenuItemList() {
    menuItemWidgets.clear();
    for (MenuItem menuItem in widget.menuItems) {
      print(
        hantarrBloc.state.user.restaurantCart.menuItems
            .where((element) => element.name == menuItem.name)
            .length
            .toString(),
      );
      DateTime menuItemDateTime;
      bool disableOrder = false;
      bool shownNextDay = false;
      String deliveryStartTime;
      String deliveryEndTime;
      // ignore: unused_local_variable
      String formattedDST, formattedDET;

      // if (preOrderDateTime != "Now") {
      //   menuItemDateTime = DateTime.parse(preOrderDateTime);
      // } else {
      menuItemDateTime = DateTime.now();
      // }
      if (menuItem.deliveryStartTime != null &&
          menuItem.deliveryEndTime != null) {
        deliveryStartTime = menuItemDateTime.toString().split(" ").first +
            " " +
            menuItem.deliveryStartTime;
        deliveryEndTime = menuItemDateTime.toString().split(" ").first +
            " " +
            menuItem.deliveryEndTime;
        if (menuItem.allowSameDayDelivert == false) {
          if (menuItemDateTime.day == DateTime.now().day) {
            disableOrder = true;
            shownNextDay = true;
          }
        }
        if ((menuItemDateTime.isAfter(DateTime.parse(deliveryStartTime)) &&
                menuItemDateTime.isBefore(DateTime.parse(deliveryEndTime))) ||
            (DateTime.parse(deliveryEndTime)
                    .isAtSameMomentAs(menuItemDateTime) ||
                DateTime.parse(deliveryStartTime)
                    .isAtSameMomentAs(menuItemDateTime))) {
          if (shownNextDay) {
            disableOrder = true;
          } else {
            disableOrder = false;
          }
        } else {
          disableOrder = true;
        }
        if (disableOrder) {
          String dayNightDST;
          String dayNightDET;
          if (DateTime.parse(deliveryStartTime).hour > 12) {
            formattedDST = "${DateTime.parse(deliveryStartTime).hour - 12}:";
            dayNightDST = " pm";
          } else {
            formattedDST = "${DateTime.parse(deliveryStartTime).hour}:";
            dayNightDST = " am";
          }
          if (DateTime.parse(deliveryEndTime).hour > 12) {
            formattedDET = "${DateTime.parse(deliveryEndTime).hour - 12}:";
            dayNightDET = " pm";
          } else {
            formattedDET = "${DateTime.parse(deliveryEndTime).hour}:";
            dayNightDET = " am";
          }
          if (DateTime.parse(deliveryStartTime).minute == 0) {
            formattedDST += "00";
          } else {
            formattedDST += DateTime.parse(deliveryStartTime).minute.toString();
          }
          if (DateTime.parse(deliveryEndTime).minute == 0) {
            formattedDET += "00";
          } else {
            formattedDET += DateTime.parse(deliveryEndTime).minute.toString();
          }
          formattedDET += dayNightDET;
          formattedDST += dayNightDST;
        }
      }
      menuItemWidgets.add(InkWell(
        onTap: () async {
          // need check customization
          if (hantarrBloc.state.user.uuid != null) {
            if (Restaurant()
                    .onlineRuleResult(widget.restaurant, widget.restaurantDT) &&
                menuItem.allowAddToCard(
                    widget.restaurant, widget.restaurantDT)) {
              if (hantarrBloc.state.user.restaurantCart.menuItems == null) {
                hantarrBloc.state.user.restaurantCart.menuItems = [];
              }
              if (hantarrBloc.state.user.restaurantCart.menuItems.isNotEmpty) {
                if (hantarrBloc.state.user.restaurantCart.menuItems.first
                        .restaurantID ==
                    widget.restaurant.id) {
                  if (menuItem.customizations.isNotEmpty ||
                      menuItem.comboItems.isNotEmpty) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoodCustomization(
                                currentMenuItem: MenuItem().clone(menuItem),
                              )),
                    );
                    setState(() {});
                  } else {
                    MenuItem newMenuItem = MenuItem().clone(menuItem);
                    newMenuItem.viewQty = 1;
                    hantarrBloc.state.user.restaurantCart.menuItems
                        .add(newMenuItem);
                    hantarrBloc.add(Refresh());
                  }
                } else {
                  initCart();
                }
              } else {
                if (hantarrBloc.state.user.restaurantCart.restaurant != null) {
                  if (!widget.restaurant.allowPreorder) {
                    hantarrBloc.state.user.restaurantCart.preOrderDateTime = "";
                    hantarrBloc.state.user.restaurantCart.restaurant =
                        widget.restaurant;
                    hantarrBloc.state.user.restaurantCart.menuItems = [];
                  } else {
                    if (hantarrBloc.state.user.restaurantCart.preOrderDateTime
                        .isNotEmpty) {
                      hantarrBloc.state.user.restaurantCart.restaurant =
                          widget.restaurant;
                      hantarrBloc.state.user.restaurantCart.menuItems = [];
                    } else {
                      hantarrBloc.state.user.restaurantCart.restaurant =
                          widget.restaurant;
                      hantarrBloc.state.user.restaurantCart.menuItems = [];
                      widget.triggerPreorder();
                    }
                  }
                  setState(() {});
                  hantarrBloc.add(Refresh());
                }
                hantarrBloc.state.user.restaurantCart.restaurant =
                    widget.restaurant;

                if (menuItem.customizations.isNotEmpty ||
                    menuItem.comboItems.isNotEmpty) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FoodCustomization(
                              currentMenuItem: MenuItem().clone(menuItem),
                            )),
                  );
                  setState(() {});
                } else {
                  MenuItem newMenuItem = MenuItem().clone(menuItem);
                  newMenuItem.viewQty = 1;
                  hantarrBloc.state.user.restaurantCart.menuItems
                      .add(newMenuItem);
                  hantarrBloc.add(Refresh());
                  setState(() {});
                }
              }
            }
          } else {
            var loginReq = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Please Login First"),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context, "Cancel");
                      },
                      child: Text("Cancel"),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context, "Ok");
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
            if (loginReq == "Ok") {
              showSignInDialog(context);
            }
          }
        },
        child: Stack(
          children: [
            Card(
              elevation: 0,
              // color: Colors.red,
              child: Container(
                height: ScreenUtil().setHeight(250),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(ScreenUtil().setSp(5)),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: menuItem.imageUrl != null
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    child: Image.network(
                                      "https://pos.str8.my/images/uploads/" +
                                          menuItem.imageUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    child: Image.asset(
                                      "assets/foodIcon.png",
                                      color: Colors.black,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                            // AspectRatio(
                            //     aspectRatio: 1,
                            //     child: menuItem.imageUrl != null
                            //         ? ClipRRect(
                            //             borderRadius:
                            //                 BorderRadius.all(Radius.circular(10)),
                            //             child: Image.network(
                            //               "https://pos.str8.my/images/uploads/" +
                            //                   menuItem.imageUrl,
                            //               fit: BoxFit.contain,
                            //             ),
                            //           )
                            //         : ClipRRect(
                            //             borderRadius:
                            //                 BorderRadius.all(Radius.circular(10)),
                            //             child: Image.asset(
                            //               "assets/foodIcon.png",
                            //               color: Colors.black,
                            //               fit: BoxFit.contain,
                            //             ),
                            //           )),
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setSp(30),
                            // right: ScreenUtil().setSp(35),
                            left: ScreenUtil().setSp(30)),
                        // height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AutoSizeText(
                              menuItem.name,
                              minFontSize: 8,
                              style: GoogleFonts.aBeeZee(
                                  textStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.w600)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            menuItem.alt_name != menuItem.name
                                ? AutoSizeText(
                                    menuItem.alt_name.replaceAll("*", ""),
                                    style: GoogleFonts.aBeeZee(
                                        textStyle: TextStyle(
                                            fontSize: ScreenUtil().setSp(40),
                                            fontWeight: FontWeight.w600)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Container(),
                            // SizedBox(
                            //   height: ScreenUtil().setHeight(70),
                            // ),
                            menuItem.price >
                                    menuItem.displayPriceInMenuItem(
                                        menuItem,
                                        DateTime.now(),
                                        false,
                                        widget.restaurant)
                                // menuItem.itemPriceSetter(
                                //     menuItem, DateTime.now(), false)
                                ? Text.rich(
                                    TextSpan(
                                      children: <TextSpan>[
                                        new TextSpan(
                                          text: "RM " +
                                              menuItem
                                                  .displayPriceInMenuItem(
                                                      menuItem,
                                                      DateTime.now(),
                                                      false,
                                                      widget.restaurant)
                                                  .toStringAsFixed(2),
                                          style: GoogleFonts.aBeeZee(
                                              textStyle: TextStyle(
                                                  color: themeBloc
                                                      .state.primaryColor,
                                                  fontSize:
                                                      ScreenUtil().setSp(50),
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                        new TextSpan(
                                          text: " RM " +
                                              menuItem.price.toStringAsFixed(2),
                                          style: new TextStyle(
                                            color: Colors.grey,
                                            fontSize: ScreenUtil().setSp(45),
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(
                                    "RM " +
                                        menuItem
                                            .itemPriceSetter(
                                                menuItem, DateTime.now(), false)
                                            .toStringAsFixed(2),
                                    style: GoogleFonts.aBeeZee(
                                        textStyle: TextStyle(
                                            color: themeBloc.state.primaryColor,
                                            fontSize: ScreenUtil().setSp(45),
                                            fontWeight: FontWeight.w400)),
                                  )
                          ],
                        ),
                      ),
                    ),
                    hantarrBloc.state.user.restaurantCart.menuItems
                                .where(
                                    (element) => element.name == menuItem.name)
                                .length >
                            0
                        ? Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(ScreenUtil().setSp(40)),
                              child: Container(
                                // width: MediaQuery.of(context).size.width,
                                // height: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(
                                    color: themeBloc.state.primaryColor
                                        .withOpacity(0.2),
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Text(
                                  hantarrBloc
                                      .state.user.restaurantCart.menuItems
                                      .where((element) =>
                                          element.name == menuItem.name)
                                      .length
                                      .toString(),
                                  style: TextStyle(
                                      color: themeBloc.state.primaryColor),
                                )),
                              ),
                            ),
                          )
                        : Expanded(
                            flex: 1,
                            child: Container(),
                          )
                  ],
                ),
              ),
            ),
            // menuItem.isAvailable != "Yes" &&
            //         !menuItem.allowAddToCard(widget.restaurant)
            //     ? Card(
            //         color: Colors.black.withOpacity(0.5),
            //         child: Container(
            //           width: MediaQuery.of(context).size.width,
            //           height: ScreenUtil().setHeight(250),
            //           child: Center(
            //               child: Container(
            //                   padding: EdgeInsets.only(
            //                       top: ScreenUtil()
            //                           .setSp(12, allowFontScalingSelf: true),
            //                       bottom: ScreenUtil()
            //                           .setSp(12, allowFontScalingSelf: true),
            //                       left: ScreenUtil()
            //                           .setSp(22, allowFontScalingSelf: true),
            //                       right: ScreenUtil()
            //                           .setSp(22, allowFontScalingSelf: true)),
            //                   color: themeBloc.state.primaryColor,
            //                   child: Text(
            //                     "Temporarily Sold Out",
            //                     style: GoogleFonts.montserrat(
            //                         textStyle: TextStyle(
            //                             fontWeight: FontWeight.w500,
            //                             fontSize: ScreenUtil().setSp(30),
            //                             color: Colors.white)),
            //                   ))),
            //         ),
            //       )
            //     : Container(),
            menuItem.isSuggested()
                ? Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      height: ScreenUtil().setHeight(250),
                      child: Container(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: ScreenUtil()
                                  .setSp(15, allowFontScalingSelf: true),
                              bottom: ScreenUtil()
                                  .setSp(15, allowFontScalingSelf: true),
                              left: ScreenUtil()
                                  .setSp(15, allowFontScalingSelf: true),
                              right: ScreenUtil()
                                  .setSp(15, allowFontScalingSelf: true)),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(
                                  Icons.thumb_up,
                                  color: themeBloc.state.primaryColor,
                                  size: ScreenUtil().setSp(40.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),

            !menuItem.allowAddToCard(widget.restaurant, widget.restaurantDT)
                ? Card(
                    color: Colors.black.withOpacity(0.6),
                    elevation: 0,
                    child: Container(
                      height: ScreenUtil().setHeight(250),
                      child: Container(
                          child: Container(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil()
                                      .setSp(15, allowFontScalingSelf: true),
                                  bottom: ScreenUtil()
                                      .setSp(15, allowFontScalingSelf: true),
                                  left: ScreenUtil()
                                      .setSp(15, allowFontScalingSelf: true),
                                  right: ScreenUtil()
                                      .setSp(15, allowFontScalingSelf: true)),
                              child: Stack(
                                children: [
                                  menuItem.isAvailable == "Yes"
                                      ? Align(
                                          alignment: Alignment.centerRight,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Available Days: ",
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: ScreenUtil()
                                                              .setSp(25),
                                                          color: Colors.white)),
                                                ),
                                                SizedBox(
                                                  height: 3.0,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: widget
                                                      .restaurant.businessHours
                                                      .map(
                                                        (e) => AutoSizeText(
                                                          menuItem.deliveryStartTime
                                                                          .length >=
                                                                      5 &&
                                                                  menuItem.deliveryEndTime
                                                                          .length >=
                                                                      5
                                                              ? "${weekday[e.numOfDay - 1]}:" +
                                                                  " ${menuItem.deliveryStartTime.substring(0, 5)} - ${menuItem.deliveryEndTime.substring(0, 5)}"
                                                              : "${weekday[e.numOfDay - 1]}: No State",
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: GoogleFonts.montserrat(
                                                              textStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              25),
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  menuItem.isAvailable != "Yes"
                                      ? Center(
                                          child: Text(
                                            "Temporarily Sold Out",
                                            style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        ScreenUtil().setSp(30),
                                                    color: Colors.white)),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            "Not Available On \nSelected Time",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        ScreenUtil().setSp(35),
                                                    color: Colors.white)),
                                          ),
                                        ),
                                ],
                              ))),
                    ),
                  )
                : Container(),
            // disableOrder
            //     ? Card(
            //         color: Colors.black.withOpacity(0.5),
            //         child: Container(
            //           height: ScreenUtil().setHeight(250),
            //           child: ,
            //         ),
            //       )
            //     : Container()
          ],
        ),
      ));
    }
    menuItemWidgets.add(Container(
      height: ScreenUtil().setHeight(250),
    ));

    return menuItemWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: generateMenuItemList(),
        ),
      );
    });
  }
}
