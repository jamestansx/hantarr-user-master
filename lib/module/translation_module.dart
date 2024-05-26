import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Translation extends InheritedWidget {
  Map translations;
  String lang;

  Translation({this.translations, this.lang, Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(Translation oldWidget) {
    return translations != oldWidget.translations;
  }

  String text(text) {
    return this.translations[this.lang][text];
  }
}