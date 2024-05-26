import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';

// ignore: must_be_immutable
class FoodDeliveryMenuItemDetailWidget extends StatefulWidget {
  NewFoodDelivery newFoodDelivery;
  FoodDeliveryMenuItemDetailWidget({
    @required this.newFoodDelivery,
  });
  @override
  _FoodDeliveryMenuItemDetailWidgetState createState() =>
      _FoodDeliveryMenuItemDetailWidgetState();
}

class _FoodDeliveryMenuItemDetailWidgetState
    extends State<FoodDeliveryMenuItemDetailWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget menuItemWidet(NewMenuItem menuItem) {
    // return ListTile(
    //   leading: Text(
    //     "x ${widget.newFoodDelivery.countForThisItem(menuItem)}",
    //     style: themeBloc.state.textTheme.headline6.copyWith(
    //       fontWeight: FontWeight.bold,
    //       fontSize: ScreenUtil().setSp(32.0),
    //     ),
    //   ),
    //   title: Text(
    //     "${menuItem.name}",
    //     style: themeBloc.state.textTheme.headline6.copyWith(
    //       fontWeight: FontWeight.bold,
    //       fontSize: ScreenUtil().setSp(32.0),
    //     ),
    //   ),
    //   // trailing: ,
    // );
    return Container(
      // margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "x ${widget.newFoodDelivery.countForThisItem(menuItem)}",
              textAlign: TextAlign.center,
              style: themeBloc.state.textTheme.headline6.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(32.0),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${menuItem.name} (RM${(menuItem.itemDeliveryPrice).toStringAsFixed(2)})",
                  textAlign: TextAlign.left,
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: menuItem.confirmedCustomizations.map(
                    (b) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              "\t\t\t${b.name} (RM ${b.price.toStringAsFixed(2)}) x ${b.qty}",
                              style:
                                  themeBloc.state.textTheme.headline6.copyWith(
                                fontSize: ScreenUtil().setSp(30.0),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                "RM ${(widget.newFoodDelivery.countForThisItem(menuItem) * menuItem.getDeliveryItemExactPrice()).toStringAsFixed(2)}",
                textAlign: TextAlign.right,
                style: themeBloc.state.textTheme.headline6.copyWith(
                  color: Colors.grey[850],
                  fontWeight: FontWeight.w400,
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Center(
          child: Container(
            padding:
                EdgeInsets.only(left: 10.0, right: 10, top: 20, bottom: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        'Menu Items',
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
                Divider(
                  color: Colors.transparent,
                ),
                Column(
                  children: widget.newFoodDelivery
                      .grouppedMenuItem()
                      .map(
                        (e) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            menuItemWidet(e),
                            Divider(
                              color: Colors.transparent,
                            )
                          ],
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
  }
}
