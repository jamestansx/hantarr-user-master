import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:launch_review/launch_review.dart';

// ignore: must_be_immutable
class UpdateVersionDialog extends StatefulWidget {
  bool force;
  String androidAppID;
  String iosAppID;
  String newAndroidVersion, newIosVersion;

  UpdateVersionDialog({
    this.force = true,
    @required this.androidAppID,
    @required this.iosAppID,
    @required this.newAndroidVersion,
    @required this.newIosVersion,
  });
  @override
  _UpdateVersionDialogState createState() => _UpdateVersionDialogState();
}

class _UpdateVersionDialogState extends State<UpdateVersionDialog> {
  String versionName = "";
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS || Platform.isMacOS) {
      versionName = widget.newIosVersion;
    } else {
      versionName = widget.newAndroidVersion;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return WillPopScope(
          onWillPop: () {
            if (!widget.force) {
              Navigator.of(context).pop();
              return null;
            } else {
              return null;
            }
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
            ),
            title: null,
            content: Container(
                // color: Colors.red,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Image.asset("assets/update.png"),
                    ),
                    Container(
                        child: Text(
                      widget.force
                          ? "This update is compulsory , please update to continue using it. \nCurrent Version: ${hantarrBloc.state.versionName}.\nNew Version $versionName"
                          : "New version detected! You can update it later. \nCurrent Version: ${hantarrBloc.state.versionName}.\nNew Version $versionName",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: themeBloc.state.textTheme.headline2.color,
                      )),
                      textAlign: TextAlign.left,
                    )),
                    widget.force
                        ? Container(
                            margin: EdgeInsets.only(top: 40),
                            child: FlatButton(
                              child: new Text(
                                "Update Now!",
                                style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      themeBloc.state.textTheme.headline2.color,
                                )),
                              ),
                              onPressed: () {
                                LaunchReview.launch(
                                    androidAppId: widget.androidAppID,
                                    iOSAppId: widget.iosAppID);
                              },
                            ),
                          )
                        : Container(),
                    !widget.force
                        ? Container(
                            margin: EdgeInsets.only(top: 40),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: <Widget>[
                                  FlatButton(
                                    child: new Text(
                                      "Update later",
                                      style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red)),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: new Text(
                                      "Update Now!",
                                      style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: themeBloc.state.textTheme
                                                  .headline2.color)),
                                    ),
                                    onPressed: () {
                                      LaunchReview.launch(
                                        androidAppId: widget.androidAppID,
                                        iOSAppId: widget.iosAppID,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container()
                  ],
                )),
          ),
        );
      },
    );
  }
}
