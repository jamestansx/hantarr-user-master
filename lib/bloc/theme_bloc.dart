import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.orange,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    dialogBackgroundColor: Colors.white,
    scaffoldBackgroundColor: Color(0xfff8f9fb),
    primaryColor: Color(0xffEC6423),
    secondaryHeaderColor: Colors.white,
    accentColor: Color(0xffEC6423),
    textTheme: ThemeData.light().textTheme.copyWith(
          headline1: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.headline1.copyWith(
                  inherit: true,
                  fontSize: 96,
                ),
          ),
          headline2: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.headline2.copyWith(
                  inherit: true,
                  fontSize: 60,
                ),
          ),
          headline3: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.headline3.copyWith(
                  inherit: true,
                  fontSize: 48,
                ),
          ),
          headline4: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.headline4.copyWith(
                  inherit: true,
                  fontSize: 34,
                ),
          ),
          headline5: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.headline5.copyWith(
                  inherit: true,
                  fontSize: 24,
                ),
          ),
          headline6: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.headline6.copyWith(
                  inherit: true,
                  fontSize: 20,
                ),
          ),
          subtitle1: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.subtitle1.copyWith(
                  inherit: true,
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
          ),
          subtitle2: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.subtitle2.copyWith(
                  inherit: true,
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
          ),
          bodyText1: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.bodyText1.copyWith(
                  inherit: true,
                  fontSize: 16,
                ),
          ),
          bodyText2: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.bodyText2.copyWith(
                  inherit: true,
                  fontSize: 14,
                ),
          ),
          button: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.button.copyWith(
                  inherit: true,
                  fontSize: 14,
                  color: Color(0xffEC6423),
                ),
          ),
          caption: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.caption.copyWith(
                  inherit: true,
                  fontSize: 12,
                ),
          ),
          overline: GoogleFonts.poppins(
            textStyle: ThemeData.light().textTheme.overline.copyWith(
                  inherit: true,
                  fontSize: 10,
                ),
          ),
        ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
    ),
    cardTheme: ThemeData.light().cardTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          margin: EdgeInsets.all(10),
        ),
  );

  ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.orange,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    dialogBackgroundColor: Color(0xffff121212),
    scaffoldBackgroundColor: Color(0xff333333),
    primaryColor: Color(0xffEC6423),
    secondaryHeaderColor: Colors.white,
    accentColor: Color(0xffEC6423),
    textTheme: ThemeData.dark().textTheme.copyWith(
          headline1: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.headline1,
          ),
          headline2: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.headline2,
          ),
          headline3: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.headline3,
          ),
          headline4: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.headline4,
          ),
          headline5: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.headline5,
          ),
          headline6: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.headline6,
          ),
          bodyText1: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.bodyText1,
          ),
          bodyText2: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.bodyText2,
          ),
          subtitle1: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.subtitle1,
          ),
          subtitle2: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.subtitle2,
          ),
          overline: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.overline,
          ),
          button: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.button,
          ),
          caption: GoogleFonts.poppins(
            textStyle: ThemeData.dark().textTheme.caption,
          ),
        ),
  );

  ThemeBloc(ThemeData initialState) : super(initialState);

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    switch (event) {
      case ThemeEvent.toggle:
        yield state == darkTheme ? lightTheme : darkTheme;
        break;
    }
  }
}
