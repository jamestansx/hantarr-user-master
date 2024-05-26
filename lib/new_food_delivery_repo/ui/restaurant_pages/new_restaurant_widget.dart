import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_favourite_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';

// ignore: must_be_immutable
class NewRestaurantWidget extends StatefulWidget {
  NewRestaurant newRestaurant;
  NewRestaurantWidget({
    @required this.newRestaurant,
  });
  @override
  _NewRestaurantWidgetState createState() => _NewRestaurantWidgetState();
}

class _NewRestaurantWidgetState extends State<NewRestaurantWidget> {
  void onpressedRest(BuildContext context) async {
    // await FirebaseAnalytics().logEvent(
    //     name: "view_menuitem_listing",
    //     parameters: {"rest_name": "${widget.newRestaurant.name}"});
    loadingWidget(context);
    var checkRestAvailable = await widget.newRestaurant.restaurantAvailable();
    Navigator.pop(context);
    if (checkRestAvailable['data']) {
      widget.newRestaurant.online = true;
      hantarrBloc.add(Refresh());
      Navigator.pushNamed(
        context,
        "$newMenuItemListPage",
        arguments: widget.newRestaurant,
      );
      // Navigator.pushNamed(
      //   context,
      //   "$deepLinkMenuItemPage?rest_id=${widget.newRestaurant.id}",
      //   arguments: widget.newRestaurant,
      // );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${checkRestAvailable['reason']}"),
            content: Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    checkRestAvailable['business_hours'] != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: widget.newRestaurant.businessHours.map(
                              (e) {
                                return ListTile(
                                  title: Text(
                                    "${e.dayString.toUpperCase()}",
                                    style: themeBloc.state.textTheme.headline6,
                                  ),
                                  trailing: Text(
                                    "${e.startTime.hour.toString().padLeft(2, '0')}:${e.startTime.minute.toString().padLeft(2, '0')} - ${e.endTime.hour.toString().padLeft(2, '0')}:${e.endTime.minute.toString().padLeft(2, '0')}",
                                    style: themeBloc.state.textTheme.subtitle2,
                                  ),
                                );
                              },
                            ).toList(),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: themeBloc.state.textTheme.button.copyWith(
                    inherit: true,
                    fontWeight: FontWeight.bold,
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
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(
            ScreenUtil().setSp(20.0),
          ),
          child: MaterialButton(
            onPressed: () async {
              onpressedRest(context);
            },
            // borderRadius: BorderRadius.all(Radius.circular(10.0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      height: ScreenUtil().setHeight(380),
                      width: mediaQ.width,
                      child: widget.newRestaurant.bannerImgUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://pos.str8.my/images/uploads/${widget.newRestaurant.id}_${widget.newRestaurant.bannerImgUrl}",
                                fit: BoxFit.cover,
                                placeholder: (context, url) => new Center(
                                  child: SpinKitDualRing(
                                    color: Colors.grey,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    new Icon(Icons.error),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              child: Image.asset(
                                "assets/sample1.jpg",
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(380),
                      width: mediaQ.width,
                      padding: EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            backgroundColor: Colors.white,
                            label: Text(
                              "${widget.newRestaurant.duration.toInt()} mins",
                              style:
                                  themeBloc.state.textTheme.subtitle1.copyWith(
                                fontWeight: FontWeight.w500,
                                color: themeBloc.state.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.newRestaurant.discounts
                                  .where(
                                    (x) =>
                                        x.startDateTime.isBefore(
                                            hantarrBloc.state.serverTime) &&
                                        x.endDateTime.isAfter(
                                            hantarrBloc.state.serverTime),
                                  )
                                  .toList()
                                  .isNotEmpty
                              ? Container(
                                  margin: EdgeInsets.only(top: 10),
                                  width: mediaQ.width,
                                  child: Wrap(
                                    spacing: 5.0,
                                    children: widget.newRestaurant.discounts
                                        .where(
                                          (x) =>
                                              x.startDateTime.isBefore(
                                                  hantarrBloc
                                                      .state.serverTime) &&
                                              x.endDateTime.isAfter(
                                                  hantarrBloc.state.serverTime),
                                        )
                                        .toList()
                                        .map(
                                          (e) => Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.yellowAccent,
                                            ),
                                            child: Text(
                                              "${e.name.toUpperCase()}",
                                              style: themeBloc
                                                  .state.textTheme.bodyText1
                                                  .copyWith(
                                                // fontSize:
                                                //     ScreenUtil().setSp(29.0),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                )
                              : Container(),
                          widget.newRestaurant.allowFreeDelivery &&
                                  widget.newRestaurant.distance <=
                                      widget.newRestaurant.freeDeliveryKM
                              ? Container(
                                  margin:
                                      widget.newRestaurant.discounts.isNotEmpty
                                          ? EdgeInsets.only(top: 5)
                                          : EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                  ),
                                  child: Text(
                                    "Free Delivery",
                                    style: themeBloc.state.textTheme.bodyText1
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Container(),
                          // widget.newRestaurant.allowPreorder
                          //     ? Container(
                          //         margin: widget.newRestaurant.allowFreeDelivery
                          //             ? EdgeInsets.only(top: 5)
                          //             : EdgeInsets.only(top: 10),
                          //         padding: EdgeInsets.all(5),
                          //         decoration: BoxDecoration(
                          //           color: themeBloc.state.primaryColor,
                          //         ),
                          //         child: Text(
                          //           "Preoder Available",
                          //           style: themeBloc.state.textTheme.bodyText1
                          //               .copyWith(
                          //             fontWeight: FontWeight.bold,
                          //             color: Colors.white,
                          //           ),
                          //         ),
                          //       )
                          //     : Container(),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Card(
                        shape: CircleBorder(),
                        child: IconButton(
                          onPressed: () async {
                            if (widget.newRestaurant.isFavorite == false) {
                              await RestaurantFavo()
                                  .addToFavo(widget.newRestaurant);
                            } else {
                              await RestaurantFavo()
                                  .removeFromFavoList(widget.newRestaurant.id);
                            }
                          },
                          icon: Icon(
                            widget.newRestaurant.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    !widget.newRestaurant.online &&
                            !widget.newRestaurant.allowPreorder
                        ? Container(
                            width: mediaQ.width,
                            height: ScreenUtil().setHeight(380),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.3),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Center(
                              child: Card(
                                color: themeBloc.state.primaryColor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  padding: EdgeInsets.all(
                                    ScreenUtil().setSp(15.0),
                                  ),
                                  child: Text(
                                    "\t\tCLOSED\t\t",
                                    textAlign: TextAlign.center,
                                    style: themeBloc.state.textTheme.headline6
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    !widget.newRestaurant.availableForNow() &&
                            !widget.newRestaurant.allowPreorder
                        ? Container(
                            width: mediaQ.width,
                            height: ScreenUtil().setHeight(380),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.7),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Shop Closed",
                                    style: themeBloc.state.textTheme.headline6
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: themeBloc.state.primaryColor,
                                      fontSize: ScreenUtil().setSp(55.0),
                                    ),
                                  ),
                                  widget.newRestaurant.allowPreorder
                                      ? FlatButton(
                                          onPressed: () {},
                                          color: themeBloc.state.primaryColor,
                                          child: Text(
                                            "Preorder for later",
                                            style: themeBloc
                                                .state.textTheme.headline6
                                                .copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(15.0),
                    right: ScreenUtil().setWidth(15.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: ScreenUtil().setHeight(15.0),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${widget.newRestaurant.name}",
                              style:
                                  themeBloc.state.textTheme.headline6.copyWith(
                                fontSize: ScreenUtil().setSp(45.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      widget.newRestaurant.allowPreorder
                          ? SizedBox(
                              height: ScreenUtil().setHeight(5.0),
                            )
                          : Container(),
                      widget.newRestaurant.allowPreorder
                          ? Container(
                              width: mediaQ.width,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  RaisedButton(
                                    onPressed: () async {
                                      onpressedRest(context);
                                    },
                                    color: Colors.yellow,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    child: Text(
                                      "Preorder Now",
                                      style: themeBloc.state.textTheme.button
                                          .copyWith(
                                        inherit: true,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: ScreenUtil().setHeight(5.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_city,
                            color: themeBloc.state.primaryColor,
                            size: themeBloc.state.textTheme.subtitle1.fontSize,
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(10.0),
                          ),
                          Expanded(
                            child: AutoSizeText(
                              "${widget.newRestaurant.city}",
                              maxLines: 2,
                              minFontSize: 8.0,
                              style:
                                  themeBloc.state.textTheme.subtitle1.copyWith(
                                fontSize: ScreenUtil().setSp(32.0),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(5.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.add_road_rounded,
                            color: themeBloc.state.primaryColor,
                            size: themeBloc.state.textTheme.subtitle1.fontSize,
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(10.0),
                          ),
                          Expanded(
                            child: AutoSizeText(
                              "${widget.newRestaurant.distance.toStringAsFixed(0)} km Away",
                              maxLines: 1,
                              minFontSize: 8.0,
                              style:
                                  themeBloc.state.textTheme.subtitle1.copyWith(
                                fontSize: ScreenUtil().setSp(32.0),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
