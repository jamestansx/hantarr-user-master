import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/module/restaurant_module.dart';

Widget dicountTile(Restaurant restaurant, BuildContext context) {
  return Container(
    // padding: EdgeInsets.only(
    //     left: ScreenUtil().setSp(30, allowFontScalingSelf: true),
    //     right: ScreenUtil().setSp(30, allowFontScalingSelf: true)),
    child: Container(
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.all(Radius.circular(10)),
        color: themeBloc.state.primaryColor,
      ),
      padding: EdgeInsets.only(
          left: ScreenUtil().setSp(50, allowFontScalingSelf: true)),
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                restaurant.discounts.first.name,
                style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(35),
                        fontWeight: FontWeight.w500)),
              ),
              Text(
                restaurant.discounts.first.desc,
                style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                        color: Colors.grey[800],
                        fontSize: ScreenUtil().setSp(30))),
              )
            ],
          ),
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.asset(
              "assets/present.png",
              color: Colors.white,
            ),
          )
        ],
      ),
    ),
  );
}
