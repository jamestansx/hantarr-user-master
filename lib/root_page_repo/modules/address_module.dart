import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

abstract class AddressInterface {
  // --  Utilities  --//
  factory AddressInterface() => Address.initClass();
  Address fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toJson();
  void mapToLocal(Address address);
  IconData getLeadingIcon();
  void mapToFavourite();
  void setAsFavourite();
  void removeFavourite();
  List<String> getAllTitle();

  // ---  API  --- //
  Future<Map<String, dynamic>> getListAddress();
  Future<Map<String, dynamic>> deleteAddress();
  Future<Map<String, dynamic>> updateAddress(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> payload);
}

class Address implements AddressInterface {
  int id;
  String title;
  String receiverName, phone, email;
  String address, buildingBlock;
  double longitude, latitude;
  bool isFavourite;
  Address({
    this.id,
    this.title,
    this.receiverName,
    this.phone,
    this.email,
    this.address,
    this.buildingBlock,
    this.longitude,
    this.latitude,
    this.isFavourite,
  });

  Address.initClass() {
    this.id = null;
    this.title = "Home";
    this.receiverName = hantarrBloc.state.hUser.firebaseUser != null
        ? hantarrBloc.state.hUser.firebaseUser?.displayName != null
            ? "${hantarrBloc.state.hUser.firebaseUser?.displayName}"
            : ""
        : "";
    this.phone = hantarrBloc.state.hUser.firebaseUser != null
        ? hantarrBloc.state.hUser.firebaseUser.phoneNumber != null
            ? "${hantarrBloc.state.hUser.firebaseUser.phoneNumber}"
            : ""
        : "";
    this.email = hantarrBloc.state.hUser.firebaseUser != null
        ? hantarrBloc.state.hUser.firebaseUser.email != null
            ? "${hantarrBloc.state.hUser.firebaseUser.email}"
            : ""
        : "";
    this.address = "";
    this.buildingBlock = "";
    this.isFavourite = false;

    try {
      this.longitude = hantarrBloc.state.selectedLocation.longitude;
      this.latitude = hantarrBloc.state.selectedLocation.latitude;
    } catch (e) {
      this.longitude = null;
      this.latitude = null;
    }
  }

  @override
  void mapToLocal(Address address) {
    this.id = address.id;
    this.title = address.title;
    this.receiverName = address.receiverName;
    this.phone = address.phone;
    this.email = address.email;
    this.address = address.address;
    this.buildingBlock = address.buildingBlock;
    this.longitude = address.longitude;
    this.latitude = address.latitude;
    this.isFavourite = address.isFavourite;
  }

  @override
  Address fromMap(Map<String, dynamic> map) {
    Address address;

    String buildingBlockString = "";
    String addressString = "";
    try {
      if (map['address'].toString().contains("%address%")) {
        if (map['address'].toString().split("%address%").first.isNotEmpty) {
          buildingBlockString =
              map['address'].toString().split("%address%").first;
          addressString = "${map['address'].toString().split("%address%")[1]}";
        } else {
          buildingBlockString = "";
          addressString = "${map['address'].toString().split("%address%")[1]}";
        }
      } else {
        addressString = "${map['address']}";
        buildingBlockString = "";
      }

      // if (buildingBlockString.isNotEmpty) {
      //   addressString = buildingBlockString + ", $addressString";
      // }

      address = Address(
        id: map['id'],
        title: map['title'] != null ? map['title'] : "",
        receiverName: map['name'] != null ? map['name'] : "",
        phone: map['phone'] != null ? map['phone'] : "",
        email: map['email'] != null ? map['email'] : "",
        address: addressString,
        buildingBlock: buildingBlockString,
        longitude:
            map['long'] != null ? num.tryParse(map['long'].toString()) : null,
        latitude:
            map['lat'] != null ? num.tryParse(map['lat'].toString()) : null,
        isFavourite: false,
      );
    } catch (e) {
      print("address from map hit error. ${e.toString()}");
      address = null;
    }
    return address;
  }

  @override
  Map<String, dynamic> toJson() {
    String buildingBlockString = "";
    String addressString = "";

    if (this.address.contains("%address%")) {
      buildingBlockString = this.address.toString().split("%address%").first;
      if (buildingBlockString.isNotEmpty) {
        addressString =
            "${this.address.toString().split("%address%").first}, ${this.address.split("%address%")[1]}";
      } else {
        addressString = "${this.address.split("%address%")[1]}";
      }
    } else {
      addressString = this.address;
      buildingBlockString = "";
    }

    if (this.buildingBlock?.isNotEmpty ?? false) {
      addressString = this.buildingBlock +
          "%address%" +
          (this.address?.replaceAll("%address%", "") ?? "");
    }

    return {
      "id": this.id,
      "title": this.title,
      "name": this.receiverName.isNotEmpty
          ? this.receiverName
          : hantarrBloc.state.hUser.firebaseUser != null
              ? hantarrBloc.state.hUser.firebaseUser?.displayName
              : "",
      "phone": this.phone.isNotEmpty
          ? this.phone
          : hantarrBloc.state.hUser.firebaseUser != null
              ? hantarrBloc.state.hUser.firebaseUser.phoneNumber != null
                  ? hantarrBloc.state.hUser.firebaseUser.phoneNumber
                  : ""
              : "",
      "email": this.email != null
          ? this.email
          : hantarrBloc.state.hUser.firebaseUser != null
              ? hantarrBloc.state.hUser.firebaseUser.email
              : "",
      "address": addressString,
      "long": this.longitude,
      "lat": this.latitude,
    };
  }

  @override
  Future<Map<String, dynamic>> getListAddress() async {
    try {
      if (hantarrBloc.state.hUser.firebaseUser == null) {
        return {"success": true, "data": hantarrBloc.state.addressList};
      }
      Dio dio = getDio(baseOption: 1, queries: {});

      Response response = await dio
          .get("/${hantarrBloc.state.hUser.firebaseUser.uid}/addresses");
      if (response.data != "") {
        hantarrBloc.state.addressList = [];
        for (Map<String, dynamic> map in response.data) {
          Address address = Address().fromMap(map);
          if (address != null) {
            hantarrBloc.state.addressList.add(address);
          }
        }
      }
      // ignore: await_only_futures
      await this.mapToFavourite();
      return {
        "success": true,
        "data": List<Address>.from(hantarrBloc.state.addressList)
      };
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get Adrress failed. $msg"};
    }
  }

  @override
  IconData getLeadingIcon() {
    if (this.title.toLowerCase() == "home") {
      return Icons.home;
    } else if (this.title.toLowerCase() == "office") {
      return Icons.work;
    } else {
      return Icons.outbond;
    }
  }

  @override
  void mapToFavourite() async {
    try {
      Map<String, String> value = {};
      try {
        value = await hantarrBloc.state.storage.readAll();
      } catch (e) {
        value = {};
      }
      hantarrBloc.state.addressList.map(
        (e) {
          if (value.keys.toList().contains("address_" + e.id.toString())) {
            e.isFavourite = true;
          } else {
            e.isFavourite = false;
          }
        },
      ).toList();
      List<Address> favoList =
          hantarrBloc.state.addressList.where((x) => x.isFavourite).toList();
      List<Address> normalList =
          hantarrBloc.state.addressList.where((x) => !x.isFavourite).toList();
      hantarrBloc.state.addressList.clear();
      hantarrBloc.state.addressList.addAll(favoList);
      hantarrBloc.state.addressList.addAll(normalList);
      hantarrBloc.add(Refresh());
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("Address maptofavorite failed. $msg");
    }
  }

  @override
  void setAsFavourite() async {
    try {
      await hantarrBloc.state.storage.write(
        key: "address_${this.id}",
        value: "address_${this.id}",
      );
      // ignore: await_only_futures
      await this.mapToFavourite();
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("address set as favo failed. $msg");
    }
  }

  @override
  void removeFavourite() async {
    try {
      await hantarrBloc.state.storage.delete(key: "address_${this.id}");
      // ignore: await_only_futures
      await this.mapToFavourite();
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("remove address favo failed. $msg");
    }
  }

  @override
  List<String> getAllTitle() {
    List<String> titleList = ["All", "Home", "Office", "Other"];
    if (titleList.where((x) => x == this.title).isEmpty) {
      titleList.add(this.title);
    }
    return titleList;
  }

  @override
  Future<Map<String, dynamic>> deleteAddress() async {
    try {
      Dio dio = getDio(
        baseOption: 1,
        queries: {},
      );
      Response response = await dio.post(
          "/${hantarrBloc.state.hUser.firebaseUser.uid}/address_delete/${this.id}");
      if (response.data == "ok") {
        hantarrBloc.state.addressList.removeWhere((x) => x.id == this.id);
        hantarrBloc.add(Refresh());
        return {"success": true, "data": this};
      } else {
        return {
          "success": false,
          "reason": "Delete address failed. ${response.data}"
        };
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      hantarrBloc.state.addressList.removeWhere((x) => x.id == this.id);
      hantarrBloc.add(Refresh());
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Delete address failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> updateAddress(
      Map<String, dynamic> payload) async {
    try {
      Dio dio = getDio(queries: {}, baseOption: 1);
      Response response = await dio.post(
          "/${hantarrBloc.state.hUser.firebaseUser.uid}/address/${this.id}",
          data: payload);
      if (response.data['id'] != null) {
        Address address = Address.initClass();
        address = address.fromMap(response.data);
        if (address != null) {
          this.mapToLocal(address);
          return {"success": true, "data": this};
        } else {
          throw ("decode address failed.");
        }
      } else {
        return {"success": false, "reason": "Update Address Failed."};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Update Address Failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> createAddress(
      Map<String, dynamic> payload) async {
    try {
      Dio dio = getDio(queries: {}, baseOption: 1);
      Response response = await dio.post(
          "/${hantarrBloc.state.hUser.firebaseUser.uid}/address",
          data: payload);
      if (response.data['id'] != null) {
        Address address = Address.initClass();
        address = address.fromMap(response.data);
        if (address != null) {
          this.mapToLocal(address);
          this.getListAddress();
          return {"success": true, "data": this};
        } else {
          throw ("decode address failed.");
        }
      } else {
        return {"success": false, "reason": "Update Address Failed."};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Update Address Failed. $msg"};
    }
  }
}
