import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_category_sort_rule.module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/cart_floating_action_button_widget/cart_floating_action_button_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/delivery_datetime_option_selection/deliveryDTOptionSelection.dart';
import 'package:hantarr/new_food_delivery_repo/ui/menu_items_pages/new_discount_tile_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/menu_items_pages/new_menu_item_widget.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/date_formater.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

// ignore: must_be_immutable
class DeepLinkMenuItemPage extends StatefulWidget {
  int restID;
  DeepLinkMenuItemPage({@required this.restID});

  @override
  _DeepLinkMenuItemPageState createState() => _DeepLinkMenuItemPageState();
}

class _DeepLinkMenuItemPageState extends State<DeepLinkMenuItemPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  int currTab = 0;
  ScrollController scrollController = ScrollController();
  bool appBarCollapsed = false;
  bool _showAppbar = false;
  bool isScrollingDown = false;

  String errorMsg = "";
  bool isLoading = true;
  NewRestaurant newRestaurant;

  @override
  void initState() {
    if (hantarrBloc.state.newRestaurantList
        .where((x) => x.id == widget.restID)
        .isNotEmpty) {
      newRestaurant = hantarrBloc.state.newRestaurantList
          .where((x) => x.id == widget.restID)
          .first;
      if (newRestaurant.menuItems.isEmpty) {
        _load();
      } else {
        setController();
        isLoading = false;
        errorMsg = "";
      }
    } else {
      _load();
    }

    super.initState();
  }

  @override
  void dispose() {
    try {
      _tabController.dispose();
      scrollController.dispose();
    } catch (e) {}
    super.dispose();
  }

  void setController() {
    if (hantarrBloc.state.foodCart.orderDateTime == null) {
      hantarrBloc.state.foodCart.orderDateTime = hantarrBloc.state.serverTime;
      hantarrBloc.add(Refresh());
    }
    if (hantarrBloc.state.foodCart.newRestaurant == null) {
      hantarrBloc.state.foodCart.newRestaurant = newRestaurant;
    }
    hantarrBloc.add(Refresh());
    hantarrBloc.state.foodCart.initDeliveryDateTime(newRestaurant);
    _tabController = TabController(
      initialIndex: currTab,
      length: newRestaurant.categoriesTabs().length,
      vsync: this,
    );
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = true;
          if (mounted) {
            setState(() {});
          }
        }
      }

      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = false;
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
    });
    // await Future.delayed(Duration(seconds: 2));
    var getResReq = await NewRestaurant(id: widget.restID).getSpecificRest();

    if (getResReq['success']) {
      if (mounted) {
        setState(() {
          errorMsg = "";
          newRestaurant = getResReq['data'] as NewRestaurant;
          setController();
        });
        var getResAvailableReq = await newRestaurant.restaurantAvailable();
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        if (getResAvailableReq['success']) {
          bool available = getResAvailableReq['data'] as bool;
          newRestaurant.forceClose = !available;
          newRestaurant.online = available;
        } else {
          errorMsg = "${getResAvailableReq['reason']}";
        }
      }
    } else {
      if (mounted) {
        setState(() {
          errorMsg = "${getResReq['reason']}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Scaffold(
          floatingActionButton:
              hantarrBloc.state.foodCart.menuItems.isNotEmpty && !isLoading
                  ? cartFAB(context)
                  : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: isLoading
              ? Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    automaticallyImplyLeading: true,
                  ),
                  body: Container(
                    width: mediaQ.width,
                    height: mediaQ.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SpinKitDoubleBounce(
                          color: themeBloc.state.primaryColor,
                          size: ScreenUtil().setSp(55),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Loading Restaurant ...",
                          textAlign: TextAlign.center,
                          style: themeBloc.state.textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(35),
                            color: themeBloc.state.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : errorMsg.isNotEmpty
                  ? Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: true,
                        title: Text("Error"),
                      ),
                      body: Container(
                        padding: EdgeInsets.all(10),
                        width: mediaQ.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(errorMsg),
                            SizedBox(
                              height: 5,
                            ),
                            FlatButton(
                              onPressed: _load,
                              child: Text(
                                "Retry",
                                style:
                                    themeBloc.state.textTheme.button.copyWith(
                                  inherit: true,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(55.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : NestedScrollView(
                      controller: scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            elevation: 3.0,
                            backgroundColor: Colors.white,
                            pinned: true,
                            floating: true,
                            expandedHeight: ScreenUtil().setHeight(400),
                            automaticallyImplyLeading: false,
                            leading: Container(
                              padding: EdgeInsets.all(ScreenUtil().setSp(15)),
                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                color: Colors.white,
                                shape: CircleBorder(),
                                padding: EdgeInsets.zero,
                                elevation: 0.0,
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            actions: [
                              Container(
                                child: MaterialButton(
                                  onPressed: () async {
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
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    "${newRestaurant.name}",
                                                    style: themeBloc.state
                                                        .textTheme.headline6
                                                        .copyWith(
                                                      inherit: true,
                                                      fontSize: ScreenUtil()
                                                          .setSp(32.0),
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    "Delivery Hours",
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: newRestaurant
                                                      .deliveryHours
                                                      .map(
                                                        (e) => ListTile(
                                                          title: Text(
                                                            "${e.dayString.toUpperCase()}",
                                                            style: themeBloc
                                                                .state
                                                                .textTheme
                                                                .headline6,
                                                          ),
                                                          trailing: Text(
                                                            "${e.startTime.hour.toString().padLeft(2, '0')}:${e.startTime.minute.toString().padLeft(2, '0')} - ${e.endTime.hour.toString().padLeft(2, '0')}:${e.endTime.minute.toString().padLeft(2, '0')}",
                                                            style: themeBloc
                                                                .state
                                                                .textTheme
                                                                .subtitle2,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  shape: CircleBorder(),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.info,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            title: AnimatedOpacity(
                              opacity: !_showAppbar ? 0.0 : 1.0,
                              duration: Duration(
                                milliseconds: 300,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      "${newRestaurant.name}",
                                      maxLines: 2,
                                      style: themeBloc.state.textTheme.headline6
                                          .copyWith(
                                        inherit: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            flexibleSpace: LayoutBuilder(
                              builder: (BuildContext ctxt,
                                  BoxConstraints constraints) {
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
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            // height: ScreenUtil().setHeight(400),
                                            child: AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    "https://pos.str8.my/images/uploads/" +
                                                        newRestaurant.id
                                                            .toString() +
                                                        "_" +
                                                        newRestaurant
                                                            .bannerImgUrl
                                                            .toString(),
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  "assets/logoword.png",
                                                  fit: BoxFit.cover,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: mediaQ.width * .8,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${newRestaurant.name}",
                                                  textAlign: TextAlign.center,
                                                  style: themeBloc
                                                      .state.textTheme.headline6
                                                      .copyWith(
                                                    inherit: true,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(10)),
                                                FlatButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                            Radius.circular(
                                                              10.0,
                                                            ),
                                                          )),
                                                          insetPadding:
                                                              EdgeInsets.all(
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          10.0)),
                                                          child: Container(
                                                            width:
                                                                mediaQ.width *
                                                                    .9,
                                                            child:
                                                                DeliveryDateTimeOptionSelectionWidget(
                                                              newRestaurant:
                                                                  newRestaurant,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  color: Colors.black
                                                      .withOpacity(.3),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10.0),
                                                    ),
                                                    side: BorderSide(
                                                      width: ScreenUtil()
                                                          .setSp(2.0),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        !hantarrBloc
                                                                .state
                                                                .foodCart
                                                                .isPreorder
                                                            ? "Deliver Now"
                                                            : hantarrBloc
                                                                        .state
                                                                        .foodCart
                                                                        .preorderDateTime !=
                                                                    null
                                                                ? "${dateFormater(hantarrBloc.state.foodCart.preorderDateTime)}"
                                                                : "Please set preorder date time",
                                                        style: themeBloc.state
                                                            .textTheme.button
                                                            .copyWith(
                                                          inherit: true,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_drop_down,
                                                        color: Colors.white,
                                                      )
                                                    ],
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
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                              newRestaurant.discounts.isNotEmpty
                                  ? Container(
                                      child:
                                          dicountTile(newRestaurant, context),
                                    )
                                  : Container(),
                              TabBar(
                                controller: _tabController,
                                labelStyle:
                                    TextStyle(fontWeight: FontWeight.w700),
                                indicatorSize: TabBarIndicatorSize.label,
                                labelColor: themeBloc.state.primaryColor,
                                unselectedLabelColor: Colors.black,
                                isScrollable: true,
                                indicator: MD2Indicator(
                                  indicatorSize: MD2IndicatorSize.normal,
                                  indicatorHeight: 3,
                                  indicatorColor: themeBloc.state.primaryColor,
                                ),
                                onTap: (int i) {},
                                tabs: newRestaurant
                                    .categoriesTabs()
                                    .map(
                                      (e) => Tab(
                                        text: "${e.name.toUpperCase()}",
                                      ),
                                    )
                                    .toList(),
                              ),
                              newRestaurant,
                            ),
                            pinned: true,
                          ),
                        ];
                      },
                      body: TabBarView(
                        controller: _tabController,
                        children: newRestaurant.categoriesTabs().map(
                          (e) {
                            NewCategorySortRule cat = e;
                            List<NewMenuItem> thisItems = newRestaurant
                                .menuItems
                                .where((x) =>
                                    x.categoryName.toLowerCase() ==
                                    cat.name.toLowerCase())
                                .toList();
                            return Container(
                              margin: hantarrBloc
                                      .state.foodCart.menuItems.isNotEmpty
                                  ? EdgeInsets.only(
                                      bottom: ScreenUtil().setHeight(150))
                                  : EdgeInsets.zero,
                              child: ListView.builder(
                                padding: EdgeInsets.all(8.0),
                                itemCount: thisItems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return NewMenuItemWidget(
                                    newRestaurant: newRestaurant,
                                    newMenuItem: thisItems[index],
                                  );
                                },
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.discountWidget, this._tabBar, this.restaurant);
  final Widget discountWidget;
  final TabBar _tabBar;
  final NewRestaurant restaurant;

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey[300],
              offset: Offset(0.0, 5.0),
              blurRadius: 8.0)
        ],
      ),
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
