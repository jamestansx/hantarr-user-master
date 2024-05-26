import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class NewCategorySortRuleInterface {
  // utils
  NewCategorySortRule fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
}

class NewCategorySortRule implements NewCategorySortRuleInterface {
  int index;
  String name;
  ValueKey key;

  NewCategorySortRule({
    this.index,
    this.name,
    this.key,
  });

  NewCategorySortRule.initClass() {
    this.index = 0;
    this.name = "";
    this.key = null;
  }

  @override
  NewCategorySortRule fromMap(Map<String, dynamic> map) {
    NewCategorySortRule newCategorySortRule;
    try {
      newCategorySortRule = NewCategorySortRule(
        index: map['sort'] != null
            ? map['sort']
            : NewCategorySortRule.initClass().index,
        name: map['name'] != null
            ? map['name']
            : NewCategorySortRule.initClass().name,
        key: ValueKey(map['sort']),
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("NewCategorySortRule fromMap hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      newCategorySortRule = null;
    }
    return newCategorySortRule;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "sort": this.index,
      "name": this.name,
    };
  }
}
