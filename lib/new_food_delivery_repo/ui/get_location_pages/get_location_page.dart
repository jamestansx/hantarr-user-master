import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/utilities/geo_decode.dart';
import 'package:location/location.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart'
    as gL;

// ignore: must_be_immutable
class GetLocationPage extends StatefulWidget {
  dynamic getRest;
  GetLocationPage({
    @required this.getRest,
  });
  @override
  _GetLocationPageState createState() => _GetLocationPageState();
}

class _GetLocationPageState extends State<GetLocationPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<String> _getPlace(LatLng latLng) async {
    String thisAddress = "";
    try {
      // List<geo.Placemark> newPlace = await geo.placemarkFromCoordinates(
      //   latLng.latitude,
      //   latLng.longitude,
      // );
      // // this is all you need
      // geo.Placemark placeMark = newPlace[0];
      // String name = placeMark.name;
      // String jalanName = placeMark.thoroughfare;
      // String subLocality = placeMark.subLocality;
      // String locality = placeMark.locality;
      // String postalCode = placeMark.postalCode;
      // String administrativeArea = placeMark.administrativeArea;
      // // String postalCode = placeMark.postalCode;
      // // String country = placeMark.country;
      // thisAddress =
      //     "$name, $subLocality, $jalanName, $postalCode $locality, $administrativeArea";
      // print(hantarrBloc.state.foodCart.address);
      thisAddress = await geoDecode(LatLng(latLng.latitude, latLng.longitude));
    } catch (e) {
      print("get locaton failed. ${e.toString()}");
    }
    return thisAddress;
  }

  getLocation() async {
    loadingWidget(context);
    var location = new Location();
    LocationData currentLocation;
    PermissionStatus permission = await location.hasPermission();

    if (permission == PermissionStatus.granted) {
      PermissionStatus requestPermissionReq =
          await Location().requestPermission();
      if (requestPermissionReq == PermissionStatus.granted) {
        currentLocation = await Location().getLocation();
        Navigator.pop(context);
        if (currentLocation != null) {
          String thisAddres = await _getPlace(
              LatLng(currentLocation.latitude, currentLocation.longitude));
          if (thisAddres.isNotEmpty) {
            hantarrBloc.state.selectedLocation =
                LatLng(currentLocation.latitude, currentLocation.longitude);
            hantarrBloc.state.foodCart.address = thisAddres;
            hantarrBloc.add(Refresh());
            Address setAddress = Address(
              id: null,
              title: "Current Location",
              receiverName: hantarrBloc.state.hUser.firebaseUser != null
                  ? "${hantarrBloc.state.hUser.firebaseUser?.displayName}"
                  : "",
              phone: hantarrBloc.state.hUser.firebaseUser != null
                  ? hantarrBloc.state.hUser.firebaseUser.phoneNumber != null
                      ? "${hantarrBloc.state.hUser.firebaseUser.phoneNumber}"
                      : ""
                  : "",
              email: hantarrBloc.state.hUser.firebaseUser != null
                  ? "${hantarrBloc.state.hUser.firebaseUser.email}"
                  : "",
              address: thisAddres,
              buildingBlock: "-",
              longitude: currentLocation.longitude,
              latitude: currentLocation.latitude,
              isFavourite: false,
            );
            if (widget.getRest != null) {
              widget.getRest();
            }
            Navigator.pop(
              context,
              {"success": true, "data": setAddress},
            );
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Cannot retrieve address"),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "OK",
                        style: themeBloc.state.textTheme.button,
                      ),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } else {
      await Location().requestPermission();
      Navigator.pop(context);
    }
    if (mounted) {
      debugPrint("${ModalRoute.of(context).settings.name}");
      if (ModalRoute.of(context).settings.name == "") {}
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return WillPopScope(
          onWillPop: () async {
            if (hantarrBloc.state.selectedLocation == null) {
              hantarrBloc.state.selectedLocation =
                  LatLng(2.8107439958462668, 101.5003567352995);
            }
            String thisAddres = await _getPlace(LatLng(
                hantarrBloc.state.selectedLocation.latitude,
                hantarrBloc.state.selectedLocation.longitude));
            hantarrBloc.state.foodCart.address = thisAddres;
            hantarrBloc.add(Refresh());
            Address setAddress = Address(
              id: null,
              title: "Current Location",
              receiverName: hantarrBloc.state.hUser.firebaseUser != null
                  ? "${hantarrBloc.state.hUser.firebaseUser?.displayName}"
                  : "",
              phone: hantarrBloc.state.hUser.firebaseUser != null
                  ? hantarrBloc.state.hUser.firebaseUser.phoneNumber != null
                      ? "${hantarrBloc.state.hUser.firebaseUser.phoneNumber}"
                      : ""
                  : "",
              email: hantarrBloc.state.hUser.firebaseUser != null
                  ? "${hantarrBloc.state.hUser.firebaseUser.email}"
                  : "",
              address: hantarrBloc.state.foodCart.address,
              buildingBlock: "-",
              longitude: hantarrBloc.state.selectedLocation.longitude,
              latitude: hantarrBloc.state.selectedLocation.latitude,
              isFavourite: false,
            );

            Navigator.pop(context, {"success": true, "data": setAddress});

            return null;
          },
          child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Container(
              margin: EdgeInsets.only(bottom: 15),
              child: FlatButton(
                onPressed: () async {
                  // var getosmplace =
                  //     await Navigator.pushNamed(context, searchPlacePage);
                  // if (getosmplace != null) {
                  //   OSMPlace osmplace = getosmplace as OSMPlace;
                  //   if (osmplace.osmCoordinate.lat != null &&
                  //       osmplace.osmCoordinate.long != null) {
                  //     hantarrBloc.state.selectedLocation = LatLng(
                  //         osmplace.osmCoordinate.lat,
                  //         osmplace.osmCoordinate.long);
                  //     hantarrBloc.add(Refresh());
                  //     if (widget.getRest != null) {
                  //       widget.getRest();
                  //     }
                  //   }
                  // }

                  // google map
                  gL.LocationResult _pickedLocation;
                  gL.LocationResult result = await gL.showLocationPicker(
                    context, "AIzaSyCP6DCTU7pUCg-ELswj1bxe1jABsCntkHo",
                    initialCenter: LatLng(2.8107439958462668, 101.500356735299),
                    automaticallyAnimateToCurrentLocation: false,
//                      mapStylePath: 'assets/mapStyle.json',
                    myLocationButtonEnabled: true,
                    requiredGPS: false,
                    layersButtonEnabled: true,
                    countries: ["MY"],
                    // countries: ['AE', 'NG']
                    resultCardAlignment: Alignment.bottomCenter,
                    desiredAccuracy: gL.LocationAccuracy.best,
                  );
                  print("result = $result");
                  setState(() => _pickedLocation = result);
                  if (_pickedLocation != null) {
                    setState(() {
                      hantarrBloc.state.foodCart.address =
                          _pickedLocation.address;
                      hantarrBloc.state.selectedLocation =
                          _pickedLocation.latLng;
                      hantarrBloc.add(Refresh());
                      Address setAddress = Address(
                        id: null,
                        title: "Current Location",
                        receiverName: hantarrBloc.state.hUser.firebaseUser !=
                                null
                            ? "${hantarrBloc.state.hUser.firebaseUser?.displayName}"
                            : "",
                        phone: hantarrBloc.state.hUser.firebaseUser != null
                            ? hantarrBloc
                                        .state.hUser.firebaseUser.phoneNumber !=
                                    null
                                ? "${hantarrBloc.state.hUser.firebaseUser.phoneNumber}"
                                : ""
                            : "",
                        email: hantarrBloc.state.hUser.firebaseUser != null
                            ? "${hantarrBloc.state.hUser.firebaseUser.email}"
                            : "",
                        address: _pickedLocation.address,
                        buildingBlock: "-",
                        longitude: _pickedLocation.latLng.longitude,
                        latitude: _pickedLocation.latLng.latitude,
                        isFavourite: false,
                      );
                      Navigator.pop(
                          context, {"success": true, "data": setAddress});
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setSp(20.0)),
                  child: Text(
                    "Use another location",
                    style: themeBloc.state.textTheme.button.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeBloc.state.primaryColor,
                      fontSize: ScreenUtil().setSp(40.0),
                    ),
                  ),
                ),
              ),
            ),
            body: Container(
              width: mediaQ.width,
              height: mediaQ.height,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: mediaQ.height * .25,
                    ),
                    Image.asset(
                      "assets/map.png",
                      width: ScreenUtil().setSp(600),
                      height: ScreenUtil().setSp(600),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(10.0),
                    ),
                    Text(
                      "Hantarr Delivery use your location to show nearby restaurants",
                      textAlign: TextAlign.center,
                      style: themeBloc.state.textTheme.headline6.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[850],
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20.0),
                    ),
                    FlatButton(
                      onPressed: getLocation,
                      color: themeBloc.state.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      )),
                      child: Container(
                        width: mediaQ.width * .8,
                        padding: EdgeInsets.all(ScreenUtil().setSp(25.0)),
                        child: Text(
                          "Use current location",
                          textAlign: TextAlign.center,
                          style: themeBloc.state.textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(40.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
