import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/food_delivery_menuitem_details_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/food_delivery_price_details_widge.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/food_delivery_stop_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/food_delivery_tracking_timeline_widget.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/new_food_tracking_widget.dart';

// ignore: must_be_immutable
class NewFoodDeliveryDetailsPage extends StatefulWidget {
  NewFoodDelivery newFoodDelivery;
  NewFoodDeliveryDetailsPage({
    @required this.newFoodDelivery,
  });
  @override
  _NewFoodDeliveryDetailsPageState createState() =>
      _NewFoodDeliveryDetailsPageState();
}

class _NewFoodDeliveryDetailsPageState
    extends State<NewFoodDeliveryDetailsPage> {
  ScrollController sc = ScrollController();
  bool _showAppbar = false;
  bool isScrollingDown = false;

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Scaffold(
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
                "Delivery: #${widget.newFoodDelivery.id}",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  color: Colors.grey[850],
                  fontWeight: FontWeight.w500,
                  fontSize: ScreenUtil().setSp(35),
                ),
              ),
            ),
            actions: <Widget>[
              //add buttons here
              Container(
                width: ScreenUtil().setWidth(300),
                child: FlatButton(
                  onPressed: null,
                  child: Text(
                    "Status: ${widget.newFoodDelivery.status.toUpperCase()}",
                    style: themeBloc.state.textTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(30.0),
                    ),
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
                      "Delivery: #${widget.newFoodDelivery.id}",
                      style: themeBloc.state.textTheme.headline6.copyWith(
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
                      newFoodDelivery: widget.newFoodDelivery,
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
                      newFoodDelivery: widget.newFoodDelivery,
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
                      newFoodDelivery: widget.newFoodDelivery,
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
                      newFoodDelivery: widget.newFoodDelivery,
                    ),
                  ),
                ),
                Container(
                  child: FoodDeliveryPriceDetailWidget(
                    newFoodDelivery: widget.newFoodDelivery,
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
