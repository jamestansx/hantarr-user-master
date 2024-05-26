import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_cart_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';

// ignore: must_be_immutable
class NewMenuItemWidget extends StatefulWidget {
  NewRestaurant newRestaurant;
  NewMenuItem newMenuItem;
  NewMenuItemWidget({
    @required this.newRestaurant,
    @required this.newMenuItem,
  });
  @override
  _NewMenuItemWidgetState createState() => _NewMenuItemWidgetState();
}

class _NewMenuItemWidgetState extends State<NewMenuItemWidget> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Container(
          child: Stack(
            children: [
              // ListTile(
              //   title: Text("${widget.newMenuItem.name}"),
              // )
              Card(
                // margin: EdgeInsets.zero,
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Container(
                  child: MaterialButton(
                    onPressed: widget.newMenuItem.availability(
                            !hantarrBloc.state.foodCart.isPreorder
                                ? hantarrBloc.state.foodCart.orderDateTime
                                : hantarrBloc.state.foodCart.preorderDateTime,
                            hantarrBloc.state.foodCart.isPreorder)['success']
                        ? () async {
                            if (hantarrBloc.state.foodCart == null) {
                              hantarrBloc.state.foodCart = FoodCart.initClass();
                            }
                            var addCartReq = await hantarrBloc.state.foodCart
                                .addToCart(widget.newRestaurant,
                                    widget.newMenuItem, context);
                            if (addCartReq['success'] == false) {
                              BotToast.showText(
                                  text: "${addCartReq['reason']}");
                            }
                          }
                        : () {
                            BotToast.showText(
                                text:
                                    "${widget.newMenuItem.availability(!hantarrBloc.state.foodCart.isPreorder ? hantarrBloc.state.foodCart.orderDateTime : hantarrBloc.state.foodCart.preorderDateTime, hantarrBloc.state.foodCart.isPreorder)['reason']}");
                          },
                    onLongPress: hantarrBloc.state.foodCart.menuItems
                            .where((x) => x.id == widget.newMenuItem.id)
                            .isNotEmpty
                        ? () async {
                            await hantarrBloc.state.foodCart
                                .removeItem(widget.newMenuItem, context);
                          }
                        : null,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(5),
                        right: ScreenUtil().setWidth(5),
                        top: ScreenUtil().setHeight(15.0),
                        bottom: ScreenUtil().setHeight(15.0),
                      ),
                      height: ScreenUtil().setHeight(280),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.all(ScreenUtil().setSp(15)),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: widget.newMenuItem.imageURL.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          child: Image.network(
                                            "${foodUrl.replaceAll("/api_v2", "").replaceAll("api", "")}/images/uploads/" +
                                                widget.newMenuItem.imageURL,
                                            fit: BoxFit.contain,
                                            errorBuilder: (BuildContext context,
                                                Object exception,
                                                StackTrace stackTrace) {
                                              return ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                child: Stack(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Image.asset(
                                                        "assets/foodIcon.png",
                                                        color: Colors.black,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: Icon(
                                                        Icons.warning,
                                                        color: Colors.red,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                            // color: Colors.black,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          child: Image.asset(
                                            "assets/foodIcon.png",
                                            color: Colors.black,
                                            fit: BoxFit.contain,
                                          ),
                                        )),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 15,
                                top: 15.0,
                              ),
                              width: mediaQ.width,
                              height: mediaQ.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          widget.newMenuItem.name,
                                          minFontSize: 8,
                                          textAlign: TextAlign.left,
                                          style: themeBloc
                                              .state.textTheme.headline6
                                              .copyWith(
                                            inherit: true,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: ScreenUtil().setSp(35.0),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: widget.newMenuItem.altName !=
                                                widget.newMenuItem.name
                                            ? AutoSizeText(
                                                widget.newMenuItem.altName
                                                    .replaceAll("*", ""),
                                                minFontSize: 8,
                                                textAlign: TextAlign.left,
                                                style: themeBloc
                                                    .state.textTheme.subtitle1
                                                    .copyWith(
                                                        inherit: true,
                                                        fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Container(),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [],
                                      ),
                                    ),
                                  ),
                                  widget.newMenuItem.itemDeliveryPrice >
                                          widget.newMenuItem.displayPrice(
                                              hantarrBloc
                                                  .state.foodCart.orderDateTime,
                                              false,
                                              widget.newRestaurant)
                                      ? Text.rich(
                                          TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: "RM " +
                                                    widget.newMenuItem
                                                        .itemDeliveryPrice
                                                        .toStringAsFixed(2),
                                                style: themeBloc
                                                    .state.textTheme.headline6
                                                    .copyWith(
                                                  fontSize:
                                                      ScreenUtil().setSp(35.0),
                                                  color: Colors.black,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "  RM " +
                                                    widget.newMenuItem
                                                        .displayPrice(
                                                            hantarrBloc
                                                                .state
                                                                .foodCart
                                                                .orderDateTime,
                                                            false,
                                                            widget
                                                                .newRestaurant)
                                                        .toStringAsFixed(2),
                                                style: themeBloc
                                                    .state.textTheme.headline6
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      ScreenUtil().setSp(35.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Text(
                                          "RM " +
                                              widget.newMenuItem
                                                  .itemPriceSetter(
                                                      hantarrBloc.state.foodCart
                                                          .orderDateTime,
                                                      false)
                                                  .toStringAsFixed(2),
                                          style: themeBloc
                                              .state.textTheme.headline6
                                              .copyWith(
                                            inherit: true,
                                            fontSize: ScreenUtil().setSp(35.0),
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: hantarrBloc.state.foodCart.menuItems
                        .where((x) => x.id == widget.newMenuItem.id)
                        .isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(
                          right: 15,
                          top: 10,
                        ),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeBloc.state.primaryColor,
                        ),
                        child: Text(
                          "${hantarrBloc.state.foodCart.menuItems.where((x) => x.id == widget.newMenuItem.id).length}",
                          style: themeBloc.state.textTheme.bodyText1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(35.0),
                          ),
                        ),
                      )
                    : Container(),
              ),
              !widget.newMenuItem.availability(
                      !hantarrBloc.state.foodCart.isPreorder
                          ? hantarrBloc.state.foodCart.orderDateTime
                          : hantarrBloc.state.foodCart.preorderDateTime,
                      hantarrBloc.state.foodCart.isPreorder)['success']
                  ? Align(
                      alignment: Alignment.center,
                      child: Card(
                        color: Colors.black.withOpacity(.8),
                        elevation: 0.0,
                        child: Container(
                          height: ScreenUtil().setHeight(280),
                          width: mediaQ.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: ScreenUtil().setWidth(380),
                                margin: EdgeInsets.only(right: 5, bottom: 5),
                                padding:
                                    EdgeInsets.all(ScreenUtil().setSp(15.0)),
                                decoration: BoxDecoration(
                                  color: themeBloc.state.primaryColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: AutoSizeText(
                                  "${widget.newMenuItem.availability(!hantarrBloc.state.foodCart.isPreorder ? hantarrBloc.state.foodCart.orderDateTime : hantarrBloc.state.foodCart.preorderDateTime, hantarrBloc.state.foodCart.isPreorder)['reason']}",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  minFontSize: 8,
                                  style: themeBloc.state.textTheme.bodyText1
                                      .copyWith(
                                    fontSize: ScreenUtil().setSp(32.0),
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
