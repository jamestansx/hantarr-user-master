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
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_favourite_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/cart_floating_action_button_widget/cart_floating_action_button_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/delivery_datetime_option_selection/deliveryDTOptionSelection.dart';
import 'package:hantarr/new_food_delivery_repo/ui/menu_items_pages/new_discount_tile_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/menu_items_pages/new_menu_item_widget.dart';
import 'package:hantarr/utilities/date_formater.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

// ignore: must_be_immutable
class NewMenuItemPage extends StatefulWidget {
  NewRestaurant newRestaurant;
  NewMenuItemPage({
    @required this.newRestaurant,
  });
  @override
  _NewMenuItemPageState createState() => _NewMenuItemPageState();
}

class _NewMenuItemPageState extends State<NewMenuItemPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  int currTab = 0;
  ScrollController scrollController = ScrollController();
  bool appBarCollapsed = false;
  bool _showAppbar = false;
  bool isScrollingDown = false;

  @override
  void initState() {
    super.initState();

    if (hantarrBloc.state.foodCart.orderDateTime == null) {
      hantarrBloc.state.foodCart.orderDateTime = hantarrBloc.state.serverTime;
      hantarrBloc.add(Refresh());
    }
    if (hantarrBloc.state.foodCart.newRestaurant == null) {
      hantarrBloc.state.foodCart.newRestaurant = widget.newRestaurant;
    }
    //  else if (hantarrBloc.state.foodCart.newRestaurant.id !=
    //     widget.newRestaurant.id) {
    //   hantarrBloc.state.foodCart.newRestaurant = widget.newRestaurant;
    // }
    hantarrBloc.add(Refresh());

    hantarrBloc.state.foodCart.initDeliveryDateTime(widget.newRestaurant);

    _tabController = TabController(
      initialIndex: currTab,
      length: widget.newRestaurant.categoriesTabs().length,
      vsync: this,
    );
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = true;
          setState(() {});
        }
      }

      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = false;
          setState(() {});
        }
      }
    });

    Future.delayed(Duration(milliseconds: 150), () {
      getMenuItems();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getMenuItems() async {
    loadingWidget(context);
    var getMenuItemsReq = await widget.newRestaurant.getMenuItems();
    Navigator.pop(context);
    if (getMenuItemsReq['success']) {
      setState(() {});
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Get Menu Items Failed"),
            content: Text("${getMenuItemsReq['reason']}"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  getMenuItems();
                },
                color: themeBloc.state.primaryColor,
                child: Text(
                  "Retry",
                  style: themeBloc.state.textTheme.button.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
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
          // appBar: AppBar(
          //   backgroundColor: Colors.white,
          //   leading: IconButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     icon: Icon(
          //       Icons.arrow_back,
          //       color: Colors.black,
          //     ),
          //   ),
          //   title: Row(
          //     children: [
          //       Expanded(
          //         child: AutoSizeText(
          //           "${widget.newRestaurant.name}",
          //           maxLines: 2,
          //           style: themeBloc.state.textTheme.headline6.copyWith(
          //             color: Colors.black,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          //   bottom: PreferredSize(
          //     child: TabBar(
          //       controller: _tabController,
          //       labelStyle: TextStyle(fontWeight: FontWeight.w700),
          //       indicatorSize: TabBarIndicatorSize.label,
          //       labelColor: Colors.blueAccent,
          //       unselectedLabelColor: Colors.black,
          //       isScrollable: true,
          //       indicator: MD2Indicator(
          //         indicatorSize: MD2IndicatorSize.normal,
          //         indicatorHeight: 3,
          //         indicatorColor: Color(0xff1967d2),
          //       ),
          //       onTap: (int i) {},
          //       tabs: widget.newRestaurant
          //           .categoriesTabs()
          //           .map(
          //             (e) => Tab(
          //               text: "${e.name.toUpperCase()}",
          //             ),
          //           )
          //           .toList(),
          //     ),
          //     preferredSize: Size.fromHeight(
          //       kToolbarHeight,
          //     ),
          //   ),
          // ),
          floatingActionButton: hantarrBloc.state.foodCart.menuItems.isNotEmpty
              ? cartFAB(context)
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: NestedScrollView(
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
                                child: StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter state) {
                                    return SingleChildScrollView(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: Text(
                                              "${widget.newRestaurant.name}",
                                              style: themeBloc
                                                  .state.textTheme.headline6
                                                  .copyWith(
                                                inherit: true,
                                                fontSize:
                                                    ScreenUtil().setSp(32.0),
                                                color: Colors.black,
                                              ),
                                            ),
                                            subtitle: Text(
                                              "Delivery Hours",
                                            ),
                                            trailing: IconButton(
                                              onPressed: () async {
                                                if (widget.newRestaurant
                                                        .isFavorite ==
                                                    false) {
                                                  await RestaurantFavo()
                                                      .addToFavo(
                                                          widget.newRestaurant);

                                                  setState(() {});
                                                  state(() {});
                                                } else {
                                                  await RestaurantFavo()
                                                      .removeFromFavoList(widget
                                                          .newRestaurant.id);
                                                  setState(() {});
                                                  state(() {});
                                                }
                                              },
                                              icon: Icon(
                                                widget.newRestaurant.isFavorite
                                                    ? Icons.favorite
                                                    : Icons
                                                        .favorite_border_rounded,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: widget
                                                .newRestaurant.deliveryHours
                                                .map(
                                                  (e) => ListTile(
                                                    title: Text(
                                                      "${e.dayString.toUpperCase()}",
                                                      style: themeBloc.state
                                                          .textTheme.headline6,
                                                    ),
                                                    trailing: Text(
                                                      "${e.startTime.hour.toString().padLeft(2, '0')}:${e.startTime.minute.toString().padLeft(2, '0')} - ${e.endTime.hour.toString().padLeft(2, '0')}:${e.endTime.minute.toString().padLeft(2, '0')}",
                                                      style: themeBloc.state
                                                          .textTheme.subtitle2,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          )
                                        ],
                                      ),
                                    );
                                  },
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
                            "${widget.newRestaurant.name}",
                            maxLines: 2,
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              inherit: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext ctxt, BoxConstraints constraints) {
                      if (constraints.biggest.height ==
                          MediaQuery.of(context).padding.top + kToolbarHeight) {
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
                                              widget.newRestaurant.id
                                                  .toString() +
                                              "_" +
                                              widget.newRestaurant.bannerImgUrl
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${widget.newRestaurant.name}",
                                        textAlign: TextAlign.center,
                                        style: themeBloc
                                            .state.textTheme.headline6
                                            .copyWith(
                                          inherit: true,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                          height: ScreenUtil().setHeight(10)),
                                      FlatButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                  Radius.circular(
                                                    10.0,
                                                  ),
                                                )),
                                                insetPadding: EdgeInsets.all(
                                                    ScreenUtil().setSp(10.0)),
                                                child: Container(
                                                  width: mediaQ.width * .9,
                                                  child:
                                                      DeliveryDateTimeOptionSelectionWidget(
                                                    newRestaurant:
                                                        widget.newRestaurant,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        color: Colors.black.withOpacity(.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          side: BorderSide(
                                            width: ScreenUtil().setSp(2.0),
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              !hantarrBloc
                                                      .state.foodCart.isPreorder
                                                  ? "Deliver Now"
                                                  : hantarrBloc.state.foodCart
                                                              .preorderDateTime !=
                                                          null
                                                      ? "${dateFormater(hantarrBloc.state.foodCart.preorderDateTime)}"
                                                      : "Please set preorder date time",
                                              style: themeBloc
                                                  .state.textTheme.button
                                                  .copyWith(
                                                inherit: true,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
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
                    widget.newRestaurant.discounts.isNotEmpty
                        ? Container(
                            child: dicountTile(widget.newRestaurant, context),
                          )
                        : Container(),
                    TabBar(
                      controller: _tabController,
                      labelStyle: TextStyle(fontWeight: FontWeight.w700),
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
                      tabs: widget.newRestaurant
                          .categoriesTabs()
                          .map(
                            (e) => Tab(
                              text: "${e.name.toUpperCase()}",
                            ),
                          )
                          .toList(),
                    ),
                    widget.newRestaurant,
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: widget.newRestaurant.categoriesTabs().map(
                (e) {
                  NewCategorySortRule cat = e;
                  List<NewMenuItem> thisItems = widget.newRestaurant.menuItems
                      .where((x) =>
                          x.categoryName.toLowerCase() ==
                          cat.name.toLowerCase())
                      .toList();
                  return Container(
                    margin: hantarrBloc.state.foodCart.menuItems.isNotEmpty
                        ? EdgeInsets.only(bottom: ScreenUtil().setHeight(150))
                        : EdgeInsets.zero,
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: thisItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        return NewMenuItemWidget(
                          newRestaurant: widget.newRestaurant,
                          newMenuItem: thisItems[index],
                        );
                      },
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          //  Container(
          //   width: mediaQ.width,
          //   height: mediaQ.height,
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Expanded(
          //         child: TabBarView(
          //             controller: _tabController,
          //             children: widget.newRestaurant.categoriesTabs().map(
          //               (e) {
          //                 NewCategorySortRule cat = e;
          //                 List<NewMenuItem> thisItems = widget
          //                     .newRestaurant.menuItems
          //                     .where((x) =>
          //                         x.categoryName.toLowerCase() ==
          //                         cat.name.toLowerCase())
          //                     .toList();
          //                 return ListView.builder(
          //                   padding: const EdgeInsets.all(8.0),
          //                   itemCount: thisItems.length,
          //                   itemBuilder: (BuildContext context, int index) {
          //                     return NewMenuItemWidget(
          //                       newMenuItem: thisItems[index],
          //                     );
          //                   },
          //                 );
          //               },
          //             ).toList()),
          //       ),
          //     ],
          //   ),
          // ),
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
