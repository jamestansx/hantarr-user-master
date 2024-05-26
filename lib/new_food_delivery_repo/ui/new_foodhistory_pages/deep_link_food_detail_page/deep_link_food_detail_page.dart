import 'package:flutter/rendering.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/food_delivery_menuitem_details_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/food_delivery_stop_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/food_delivery_tracking_timeline_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/new_food_tracking_widget.dart';
import 'package:hantarr/packageUrl.dart';

import '../food_delivery_price_details_widge.dart';

// ignore: must_be_immutable
class DeepLinkFoodOrderDetailPage extends StatefulWidget {
  int orderID;
  DeepLinkFoodOrderDetailPage({
    @required this.orderID,
  });
  @override
  _DeepLinkFoodOrderDetailPageState createState() =>
      _DeepLinkFoodOrderDetailPageState();
}

class _DeepLinkFoodOrderDetailPageState
    extends State<DeepLinkFoodOrderDetailPage> {
  ScrollController sc = ScrollController();
  bool _showAppbar = false;
  bool isScrollingDown = false;

  NewFoodDelivery newFoodDelivery;
  String errorMsg = "";
  bool isLoading = true;

  @override
  void initState() {
    _load();
    sc.addListener(() {
      if (sc.position.userScrollDirection == ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = true;
          setState(() {});
        }
      }

      if (sc.position.userScrollDirection == ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = false;
          setState(() {});
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getLatest() async {
    await newFoodDelivery.getRiderLocation();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
    });
    // await Future.delayed(Duration(seconds: 2));
    var getOrderReq =
        await NewFoodDelivery(id: widget.orderID).getRiderLocation();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    if (getOrderReq['success']) {
      if (mounted) {
        setState(() {
          errorMsg = "";
          newFoodDelivery = getOrderReq['data'] as NewFoodDelivery;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          errorMsg = "${getOrderReq['reason']}";
        });
      }
      // throw (getResReq['reason']);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return isLoading
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  automaticallyImplyLeading: true,
                  title: Text("Order: ${widget.orderID}"),
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
                        "Loading Order Detail #${widget.orderID} ...",
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
                      child: Center(
                        child: Text(errorMsg),
                      ),
                    ),
                  )
                : Scaffold(
                    appBar: AppBar(
                      backgroundColor: _showAppbar
                          ? Colors.white
                          : themeBloc.state.scaffoldBackgroundColor,
                      elevation: !_showAppbar ? 0.0 : 3.0,
                      leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.grey[850],
                        ),
                      ),
                      title: AnimatedOpacity(
                        opacity: !_showAppbar ? 0.0 : 1.0,
                        duration: Duration(
                          milliseconds: 300,
                        ),
                        child: Text(
                          "Delivery: #${newFoodDelivery.id}",
                          style: themeBloc.state.textTheme.headline6.copyWith(
                            color: Colors.grey[850],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        //add buttons here
                        FlatButton(
                          onPressed: null,
                          child: Text(
                            "Status: ${newFoodDelivery.status.toUpperCase()}",
                            style: themeBloc.state.textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(30.0),
                            ),
                          ),
                        )
                      ],
                    ),
                    body: Container(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(25.0),
                        right: ScreenUtil().setWidth(25.0),
                      ),
                      child: ListView(
                        controller: sc,
                        children: <Widget>[
                          AnimatedOpacity(
                            opacity: _showAppbar ? 0.0 : 1.0,
                            duration: Duration(
                              milliseconds: 300,
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.transparent,
                                ),
                              ),
                              title: Text(
                                "Delivery: #${newFoodDelivery.id}",
                                style: themeBloc.state.textTheme.headline6
                                    .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenUtil().setSp(55),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: mediaQ.width,
                            padding: EdgeInsets.all(
                              ScreenUtil().setSp(10.0),
                            ),
                            child: Card(
                              child: FoodDeliveryStopsWidget(
                                newFoodDelivery: newFoodDelivery,
                              ),
                            ),
                            //  GoogleMapWithRoute(
                            //   p2pTransaction: widget.p2pTransaction,
                            // ),
                          ),
                          Container(
                            width: mediaQ.width,
                            padding: EdgeInsets.all(
                              ScreenUtil().setSp(10.0),
                            ),
                            child: Card(
                              child: FoodDeliveryTimelineTrackingWidget(
                                newFoodDelivery: newFoodDelivery,
                              ),
                            ),
                          ),
                          Container(
                            width: mediaQ.width,
                            padding: EdgeInsets.all(
                              ScreenUtil().setSp(10.0),
                            ),
                            child: Card(
                              child: NewFoodTrackingWidget(
                                newFoodDelivery: newFoodDelivery,
                              ),
                            ),
                          ),
                          Container(
                            width: mediaQ.width,
                            padding: EdgeInsets.all(
                              ScreenUtil().setSp(10.0),
                            ),
                            child: Card(
                              child: FoodDeliveryMenuItemDetailWidget(
                                newFoodDelivery: newFoodDelivery,
                              ),
                            ),
                          ),
                          Container(
                            child: FoodDeliveryPriceDetailWidget(
                              newFoodDelivery: newFoodDelivery,
                            ),
                          ),
                          SizedBox(
                            height: mediaQ.height * .1,
                          ),
                        ],
                      ),
                    ),
                  );
      },
    );
  }
}
