import 'dart:async';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/new_food_history_tile.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/pages/history/p2p_tile_widget.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryOrderPage extends StatefulWidget {
  @override
  _HistoryOrderPageState createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends State<HistoryOrderPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  bool refreshing = false;
  Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await getOrders();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> getOrders() async {
    setState(() {
      refreshing = true;
    });
    var getFoodOrderListReq = await NewFoodDelivery().getPendingDelivery();
    var getP2PPendingOrderListReq = await P2pTransaction().getPendingP2Ps();
    if (getFoodOrderListReq['success'] &&
        getP2PPendingOrderListReq['success']) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
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

  List<Widget> getOrdersWidget(Size mediaQ) {
    List<Widget> widgetlist = [];
    // List<dynamic> orders = List.from(hantarrBloc.state.p2pPendingOrders);
    // orders.addAll(hantarrBloc.state.pendingFoodOrders);

    List<Widget> foodOrders = [];

    hantarrBloc.state.pendingFoodOrders
        .map(
          (e) => {
            foodOrders.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FoodDeliveryTileWidget(
                    newFoodDelivery: e,
                  ),
                  hantarrBloc.state.pendingFoodOrders.last != e
                      ? Divider()
                      : Container(),
                ],
              ),
            )
          },
        )
        .toList();

    Widget foodWidget = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Container(
        width: mediaQ.width,
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.transparent,
              elevation: 0.0,
              child: Text(
                "Pending Food Delivery",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  fontSize: ScreenUtil().setSp(50.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Divider(
              color: Colors.transparent,
            ),
            Container(
              width: mediaQ.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: foodOrders.isNotEmpty
                    ? foodOrders
                    : [
                        Container(
                          width: ScreenUtil().setWidth(700),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              "assets/delivery.png",
                            ),
                          ),
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
                          child: Text(
                            "No Ongoing Food Order",
                            textAlign: TextAlign.center,
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              color: themeBloc.state.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(45),
                            ),
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );

    List<Widget> p2pWidgets = [];
    hantarrBloc.state.p2pPendingOrders
        .map(
          (e) => {
            p2pWidgets.add(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  P2PTileWidget(
                    p2pTransaction: e,
                  ),
                  hantarrBloc.state.p2pPendingOrders.last != e
                      ? Divider()
                      : Container(),
                ],
              ),
            )
          },
        )
        .toList();
    Widget p2pWidget = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Container(
        width: mediaQ.width,
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.transparent,
              elevation: 0.0,
              child: Text(
                "P2P Pending Order",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  fontSize: ScreenUtil().setSp(50.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Divider(
              color: Colors.transparent,
            ),
            Container(
              width: mediaQ.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: p2pWidgets.isNotEmpty
                    ? p2pWidgets
                    : [
                        Container(
                          width: ScreenUtil().setWidth(700),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              "assets/delivery.png",
                            ),
                          ),
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
                          child: Text(
                            "No Ongoing P2P Order",
                            textAlign: TextAlign.center,
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              color: themeBloc.state.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(45),
                            ),
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );

    if (hantarrBloc.state.pendingFoodOrders.isNotEmpty) {
      widgetlist.add(foodWidget);
      widgetlist.add(p2pWidget);
    } else {
      widgetlist.add(p2pWidget);
      widgetlist.add(foodWidget);
    }
    return widgetlist;
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              kToolbarHeight,
            ),
            child: SafeArea(
              child: Container(
                height: kToolbarHeight,
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
                  boxShadow: [
                    new BoxShadow(
                      blurRadius: 15.0,
                      spreadRadius: 1.2,
                      color: Colors.grey,
                    ),
                  ],
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  title: Text(
                    "Pending Orders",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        _refreshController.requestRefresh();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.refresh,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            width: mediaQ.width,
            height: mediaQ.height,
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
              onRefresh: getOrders,
              onLoading: _onLoading,
              child: ListView(
                padding: EdgeInsets.all(ScreenUtil().setSp(15)),
                children: getOrdersWidget(mediaQ),
              ),
            ),
          ),
        );
      },
    );
  }
}
