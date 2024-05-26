import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/route_setting/route_settings.dart';

Widget loginOverylayWidget(BuildContext context) {
  Size mediaQ = MediaQuery.of(context).size;
  return Container(
    width: mediaQ.width,
    height: mediaQ.height,
    color: Colors.black.withOpacity(.8),
    padding: EdgeInsets.all(ScreenUtil().setSp(10.0)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Please login first",
          style: themeBloc.state.textTheme.headline6.copyWith(
            fontSize: ScreenUtil().setSp(55.0),
            fontWeight: FontWeight.bold,
            color: themeBloc.state.primaryColor,
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(15),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pushNamed(context, loginPage);
          },
          color: themeBloc.state.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(ScreenUtil().setSp(10.0)),
            child: Text(
              "Login",
              style: themeBloc.state.textTheme.headline6.copyWith(
                fontSize: ScreenUtil().setSp(55.0),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    ),
  );
}
