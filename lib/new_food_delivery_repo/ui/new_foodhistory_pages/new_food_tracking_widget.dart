import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class NewFoodTrackingWidget extends StatefulWidget {
  NewFoodDelivery newFoodDelivery;
  NewFoodTrackingWidget({
    @required this.newFoodDelivery,
  });
  @override
  _NewFoodTrackingWidgetState createState() => _NewFoodTrackingWidgetState();
}

class _NewFoodTrackingWidgetState extends State<NewFoodTrackingWidget> {
  LatLng _initialPosition;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  bool fullscreen = false;
  double deliverTime;
  double riderTime;
  bool getRiderTime = false;
  Timer riderLocationTimer;
  BitmapDescriptor riderbitmapDes, restbitmapDes;

  @override
  void initState() {
    initial();
    riderLocationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await widget.newFoodDelivery.getRiderLocation();
      getMarkerSets();
    });
    super.initState();
  }

  @override
  void dispose() {
    riderLocationTimer.cancel();
    super.dispose();
  }

  initial() async {
    await setBitmapImage();
    getMarkerSets();
  }

  void getMarkerSets() {
    if (widget.newFoodDelivery.rider.latLng != null) {
      _markers.removeWhere((x) => x.markerId.value == "Rider");
      try {
        setState(() {
          _markers.add(Marker(
              markerId: MarkerId("Rider"),
              position: widget.newFoodDelivery.rider.latLng,
              infoWindow: InfoWindow(
                  title: "Rider", snippet: widget.newFoodDelivery.rider.name),
              // ignore: deprecated_member_use
              icon: riderbitmapDes));
        });
      } catch (e) {
        print(e);
      }
    } else {
      print("Rider location No here");
    }

    if (widget.newFoodDelivery.newRestaurant.latitude != null &&
        widget.newFoodDelivery.newRestaurant.longitude != null) {
      _markers.removeWhere((x) => x.markerId.value == "Restaurant");
      try {
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId("Restaurant"),
            position: LatLng(
              widget.newFoodDelivery.newRestaurant.latitude,
              widget.newFoodDelivery.newRestaurant.longitude,
            ),
            infoWindow: InfoWindow(
                title: widget.newFoodDelivery.newRestaurant.name,
                snippet: "Restaurant"),
            icon: restbitmapDes,
          ));
        });
      } catch (e) {
        print(e);
      }
    } else {
      print("Restaurant location No here");
    }

    _initialPosition = widget.newFoodDelivery.toLocation;
    _markers.removeWhere((x) => x.markerId.value == "Customer");
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("Customer"),
          position: _initialPosition,
          infoWindow: InfoWindow(
              title: widget.newFoodDelivery.address,
              snippet: widget.newFoodDelivery.phone),
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  setBitmapImage() async {
    riderbitmapDes = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/rider.png");
    restbitmapDes = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/restaurant.png");
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);

    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        'Delivery Tracking',
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: ScreenUtil().setSp(40.0),
                        ),
                      ),
                      Spacer(),
                      Text(
                        widget.newFoodDelivery.orderDateTime != null
                            ? "${widget.newFoodDelivery.orderDateTime.toString().substring(0, 16)}"
                            : "${DateTime.now().toString().substring(0, 10)}",
                        // '${orderInfo.date.day}/${orderInfo.date.month}/${orderInfo.date.year}',
                        style: TextStyle(
                          color: Color(0xffb6b2b2),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1.0),
                Container(
                  width: mediaQ.width,
                  height: ScreenUtil().setHeight(700),
                  child: Stack(
                    children: [
                      GoogleMap(
                        zoomControlsEnabled: true,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: _initialPosition, zoom: 17.0),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        markers: _markers,
                        myLocationEnabled: false,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1.0),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Wrap(
                    spacing: 5.0,
                    children: [
                      FlatButton(
                        onPressed: () async {
                          getMarkerSets();
                          final GoogleMapController controller =
                              await _controller.future;
                          CameraPosition restaurantLocation = CameraPosition(
                              // bearing: 192.8334901395799,
                              target: LatLng(
                                  widget.newFoodDelivery.newRestaurant.latitude,
                                  widget
                                      .newFoodDelivery.newRestaurant.longitude),
                              // tilt: 59.440717697143555,
                              zoom: 17);
                          controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                  restaurantLocation));
                        },
                        color: themeBloc.state.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: Container(
                          padding: EdgeInsets.all(ScreenUtil().setSp(15.0)),
                          child: Text(
                            "Restaurant",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () async {
                          getMarkerSets();
                          final GoogleMapController controller =
                              await _controller.future;
                          CameraPosition mylocation = CameraPosition(
                              // bearing: 192.8334901395799,
                              target: widget.newFoodDelivery.toLocation,
                              // tilt: 59.440717697143555,
                              zoom: 17);
                          controller.animateCamera(
                              CameraUpdate.newCameraPosition(mylocation));
                        },
                        color: themeBloc.state.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: Container(
                          padding: EdgeInsets.all(ScreenUtil().setSp(15.0)),
                          child: Text(
                            "Deliver To",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () async {
                          if (widget.newFoodDelivery.rider.latLng != null) {
                            getMarkerSets();
                            final GoogleMapController controller =
                                await _controller.future;
                            CameraPosition riderLocation = CameraPosition(
                                // bearing: 192.8334901395799,
                                target: widget.newFoodDelivery.rider.latLng,
                                // tilt: 59.440717697143555,
                                zoom: 17);
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(riderLocation));
                          } else {
                            try {
                              BotToast.showLoading();
                              await widget.newFoodDelivery.getRiderLocation();
                              getMarkerSets();
                              BotToast.closeAllLoading();
                              if (widget.newFoodDelivery.rider.latLng != null) {
                                final GoogleMapController controller =
                                    await _controller.future;
                                CameraPosition riderLocation = CameraPosition(
                                    // bearing: 192.8334901395799,
                                    target: widget.newFoodDelivery.rider.latLng,
                                    // tilt: 59.440717697143555,
                                    zoom: 17);
                                controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        riderLocation));
                              }
                            } catch (e) {
                              BotToast.closeAllLoading();
                              print("${e.toString()}");
                            }
                          }
                        },
                        color: themeBloc.state.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: Container(
                          padding: EdgeInsets.all(ScreenUtil().setSp(15.0)),
                          child: Text(
                            "Rider",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
