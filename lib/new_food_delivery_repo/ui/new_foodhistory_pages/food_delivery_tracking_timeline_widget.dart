import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:timelines/timelines.dart';

// ignore: must_be_immutable
class FoodDeliveryTimelineTrackingWidget extends StatefulWidget {
  NewFoodDelivery newFoodDelivery;
  FoodDeliveryTimelineTrackingWidget({
    @required this.newFoodDelivery,
  });
  @override
  _FoodDeliveryTimelineTrackingWidgetState createState() =>
      _FoodDeliveryTimelineTrackingWidgetState();
}

class _FoodDeliveryTimelineTrackingWidgetState
    extends State<FoodDeliveryTimelineTrackingWidget> {
  List<Widget> timelineList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
    timelineList = widget.newFoodDelivery
        .generateTimeLine()
        .map(
          (e) => Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${e.keys.first}",
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: ScreenUtil().setSp(35.0),
                        fontWeight: FontWeight.bold,
                        color: e.keys.first
                                .toString()
                                .toLowerCase()
                                .contains("cancel")
                            ? Colors.red
                            : Colors.grey[850],
                      ),
                ),
                Text(
                  e.values.first['datetime'] != null
                      ? "${e.values.first['datetime']}"
                      : "",
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: ScreenUtil().setSp(30.0),
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                ),
                Container(
                  height: ScreenUtil().setHeight(50),
                ),
              ],
            ),
          ),
        )
        .toList();
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
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
                        'Delivery Status',
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(40.0),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "",
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
                        itemCount: timelineList.length,
                        contentsBuilder: (_, index) {
                          return timelineList[index];
                        },
                        indicatorBuilder: (_, index) {
                          if (widget.newFoodDelivery
                              .generateTimeLine()[index]
                              .values
                              .first['bool']) {
                            return DotIndicator(
                              color: Color(0xff66c97f),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12.0,
                              ),
                            );
                          } else {
                            return OutlinedDotIndicator(
                              borderWidth: 2.5,
                            );
                          }
                        },
                        connectorBuilder: (_, index, ___) => SolidLineConnector(
                          color: (false) ? Color(0xff66c97f) : null,
                        ),
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
  }
}
