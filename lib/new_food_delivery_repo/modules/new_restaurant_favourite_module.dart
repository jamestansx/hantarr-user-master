import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/utilities/get_exception_log.dart';

abstract class RestaurantFavoInterface {
  // local
  Future<List<NewRestaurant>> getListFavoRest();
  Future<void> removeFromFavoList(int restID);
  Future<void> addToFavo(NewRestaurant newRestaurant);
}

class RestaurantFavo implements RestaurantFavoInterface {
  String keyName = "favo_rest";

  @override
  Future<List<NewRestaurant>> getListFavoRest() async {
    List<NewRestaurant> favoList = [];
    try {
      var listFavo = await hantarrBloc.state.storage.read(key: keyName);
      if (listFavo == null) {
        await hantarrBloc.state.storage.write(
          key: "favo_rest",
          value: jsonEncode([]),
        );
        listFavo = "[]";
      }

      var decodedJson = jsonDecode(listFavo);
      hantarrBloc.state.newRestaurantList.map(
        (e) {
          e.isFavorite = false;
        },
      ).toList();
      for (Map<String, dynamic> map in decodedJson) {
        NewRestaurant newRes = NewRestaurant().fromMap(map);
        if (newRes != null) {
          favoList.add(newRes);
          if (hantarrBloc.state.newRestaurantList
              .where((x) => x.id == newRes.id)
              .isNotEmpty) {
            hantarrBloc.state.newRestaurantList
                .firstWhere((x) => x.id == newRes.id)
                .isFavorite = true;
          }
        }
      }
      hantarrBloc.add(Refresh());
      return favoList;
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return favoList;
    }
  }

  @override
  Future<void> removeFromFavoList(int restID) async {
    try {
      List<NewRestaurant> resList = await this.getListFavoRest();
      if (resList.where((x) => x.id == restID).isNotEmpty) {
        resList.removeWhere((x) => x.id == restID);
        List<Map<String, dynamic>> listOfPayload =
            resList.map((e) => e.toJson()).toList();
        var encodedPayload = jsonEncode(listOfPayload);
        await hantarrBloc.state.storage
            .write(key: keyName, value: encodedPayload);
        await this.getListFavoRest();
        print("success");
      } else {
        await this.getListFavoRest();
        print("empty in list");
      }
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }

  @override
  Future<void> addToFavo(NewRestaurant newRestaurant) async {
    try {
      List<NewRestaurant> resList = await this.getListFavoRest();
      resList.add(newRestaurant);
      List<Map<String, dynamic>> listOfPayload =
          resList.map((e) => e.toJson()).toList();
      var encodedPayload = jsonEncode(listOfPayload);
      await hantarrBloc.state.storage
          .write(key: keyName, value: encodedPayload);
      await this.getListFavoRest();
      print("success");
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }
}
