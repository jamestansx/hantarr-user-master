import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:timelines/timelines.dart';

// ignore: must_be_immutable
class FoodDeliveryStopsWidget extends StatefulWidget {
  NewFoodDelivery newFoodDelivery;
  FoodDeliveryStopsWidget({
    @required this.newFoodDelivery,
  });
  @override
  _FoodDeliveryStopsWidgetState createState() =>
      _FoodDeliveryStopsWidgetState();
}

class _FoodDeliveryStopsWidgetState extends State<FoodDeliveryStopsWidget> {
  List<Widget> stops = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    stops = [
      Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.newFoodDelivery.newRestaurant.name,
              style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 18.0,
                  ),
            ),
            Container(
              height: ScreenUtil().setHeight(50),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.newFoodDelivery.address,
              style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 18.0,
                  ),
            ),
            Container(
              height: ScreenUtil().setHeight(50),
            ),
          ],
        ),
      )
    ];
    return Center(
        child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Text(
                  'Delivery #${widget.newFoodDelivery.id}',
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(40.0),
                  ),
                ),
                Spacer(),
                Text(
                  "${widget.newFoodDelivery.orderDateTime.toString().substring(0, 16)}",
                  // '${orderInfo.date.day}/${orderInfo.date.month}/${orderInfo.date.year}',
                  style: TextStyle(
                    color: Color(0xffb6b2b2),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1.0),
          DefaultTextStyle(
            style: TextStyle(
              color: Color(0xff9b9b9b),
              fontSize: 12.5,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FixedTimeline.tileBuilder(
                theme: TimelineThemeData(
                  nodePosition: 0,
                  color: themeBloc.state.accentColor,
                  indicatorTheme: IndicatorThemeData(
                    position: 0,
                    size: 20.0,
                  ),
                  connectorTheme: ConnectorThemeData(
                    thickness: 2.5,
                  ),
                ),
                builder: TimelineTileBuilder.connected(
                  connectionDirection: ConnectionDirection.before,
                  itemCount: stops.length,
                  contentsBuilder: (_, index) {
                    return stops[index];
                  },
                  indicatorBuilder: (_, index) {
                    // if (false) {
                    //   return DotIndicator(
                    //     color: Color(0xff66c97f),
                    //     child: Icon(
                    //       Icons.check,
                    //       color: Colors.white,
                    //       size: 12.0,
                    //     ),
                    //   );
                    // } else {
                    //   return OutlinedDotIndicator(
                    //     borderWidth: 2.5,
                    //   );
                    // }
                    return OutlinedDotIndicator(
                      borderWidth: 2.5,
                    );
                  },
                  connectorBuilder: (_, index, ___) => SolidLineConnector(
                    color: (false) ? Color(0xff66c97f) : null,
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 1.0),
          ListTile(
            leading: Icon(
              Icons.person,
              color: themeBloc.state.primaryColor,
            ),
            title: Text(
              "Receiver Name",
              style: themeBloc.state.textTheme.headline6.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              "${widget.newFoodDelivery.customerName}",
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.phone,
              color: themeBloc.state.primaryColor,
            ),
            title: Text(
              "Receiver Phone",
              style: themeBloc.state.textTheme.headline6.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              "${widget.newFoodDelivery.phone}",
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: _OnTimeBar(driver: data.driverInfo),
          // ),
        ],
      ),
    ));
  }
}
