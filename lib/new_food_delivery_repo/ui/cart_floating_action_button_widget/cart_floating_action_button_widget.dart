import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/route_setting/route_settings.dart';

Widget cartFAB(BuildContext context) {
  return Card(
    color: themeBloc.state.primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    ),
    child: MaterialButton(
      onPressed: () {
        if (hantarrBloc.state.foodCart.menuItems.isNotEmpty) {
          Navigator.pushNamed(context, newFoodDeliveryCheckoutPage);
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Please add items to cart."),
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
                  )
                ],
              );
            },
          );
        }
      },
      child: Container(
        height: ScreenUtil().setHeight(120),
        padding: EdgeInsets.all(ScreenUtil().setSp(25.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(ScreenUtil().setSp(15.0)),
                width: ScreenUtil().setWidth(150),
                child: Text(
                  "${hantarrBloc.state.foodCart.menuItems.length}",
                  textAlign: TextAlign.center,
                  style: themeBloc.state.textTheme.bodyText1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(35.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "View your cart",
                textAlign: TextAlign.center,
                style: themeBloc.state.textTheme.headline6.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(35.0),
                ),
              ),
            ),
            Text(
              "RM ${hantarrBloc.state.foodCart.getGrantTotal().toStringAsFixed(2)}",
              textAlign: TextAlign.center,
              style: themeBloc.state.textTheme.headline6.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(35.0),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
