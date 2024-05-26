import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';

// ignore: must_be_immutable
class FoodDeliveryTileWidget extends StatefulWidget {
  NewFoodDelivery newFoodDelivery;
  FoodDeliveryTileWidget({
    @required this.newFoodDelivery,
  });
  @override
  _FoodDeliveryTileWidgetState createState() => _FoodDeliveryTileWidgetState();
}

class _FoodDeliveryTileWidgetState extends State<FoodDeliveryTileWidget> {
  Timer timer;
  @override
  void initState() {
    timer = Timer.periodic(
      Duration(seconds: 10),
      (timer) async {
        await widget.newFoodDelivery.getRiderLocation();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Row(
          children: [
            Container(
              width: 5,
              height: kToolbarHeight,
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    themeBloc.state.primaryColor,
                    Colors.orange[300],
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    foodDeliveryDetailPage,
                    arguments: widget.newFoodDelivery,
                  );
                  // Navigator.pushNamedAndRemoveUntil(
                  //   context,
                  //   "$foodDeepLinkOrder?order_id=${widget.newFoodDelivery.id}",
                  //   ModalRoute.withName(newMainScreen),
                  // );
                },
                title: Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        "${widget.newFoodDelivery.address}",
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                subtitle: Wrap(
                  spacing: 5.0,
                  children: [
                    Chip(
                      label: Text(
                        "# ${widget.newFoodDelivery.id}",
                        style: themeBloc.state.textTheme.subtitle2.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor:
                          widget.newFoodDelivery.chipStatusColors(),
                      label: Text(
                        "${widget.newFoodDelivery.status.toUpperCase()}",
                        style: themeBloc.state.textTheme.subtitle2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "RM ${widget.newFoodDelivery.getGrandTotal().toStringAsFixed(2)}",
                      textAlign: TextAlign.end,
                      style: themeBloc.state.textTheme.bodyText1.copyWith(
                        inherit: true,
                        color: Colors.grey[850],
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(34),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Text(
                      "${widget.newFoodDelivery.orderDateTime.day} ${months[widget.newFoodDelivery.orderDateTime.month - 1]}, ${widget.newFoodDelivery.orderDateTime.hour.toString().padLeft(2, '0')}:${widget.newFoodDelivery.orderDateTime.minute.toString().padLeft(2, '0')}",
                      textAlign: TextAlign.end,
                      style: themeBloc.state.textTheme.bodyText1.copyWith(
                        inherit: true,
                        fontSize: ScreenUtil().setSp(30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
