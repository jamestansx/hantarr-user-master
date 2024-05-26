import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/new_food_history_tile.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewFoodHistoryPage extends StatefulWidget {
  @override
  _NewFoodHistoryPageState createState() => _NewFoodHistoryPageState();
}

class _NewFoodHistoryPageState extends State<NewFoodHistoryPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void getOrders() async {
    setState(() {
      refreshing = true;
    });
    var getFoodOrderDoneListReq = await NewFoodDelivery().getDoneDelivery();
    var getFoodOrderPendingListReq =
        await NewFoodDelivery().getPendingDelivery();
    if (getFoodOrderDoneListReq['success'] &&
        getFoodOrderPendingListReq['success']) {
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
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
                    "History Orders",
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
              child: hantarrBloc.state.allFoodOrders.isNotEmpty
                  ? ListView(
                      padding: EdgeInsets.all(ScreenUtil().setSp(15)),
                      children: hantarrBloc.state.allFoodOrders
                          .map(
                            (e) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FoodDeliveryTileWidget(
                                  newFoodDelivery: e,
                                ),
                                Divider(
                                    // color: Colors.transparent,
                                    ),
                              ],
                            ),
                          )
                          .toList(),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                              style:
                                  themeBloc.state.textTheme.headline6.copyWith(
                                color: themeBloc.state.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil().setSp(45),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
