import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart'
    as gL;
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

// ignore: must_be_immutable
class ManageAddressPage extends StatefulWidget {
  int id;
  ManageAddressPage({
    @required this.id,
  });
  @override
  _ManageAddressPageState createState() => _ManageAddressPageState();
}

class _ManageAddressPageState extends State<ManageAddressPage> {
  final _formKey = GlobalKey<FormState>();
  Completer<GoogleMapController> _controller = Completer();
  Address address;
  Set<Marker> _markers = {};
  List<String> options = [];
  TextEditingController buildingCon = TextEditingController();

  @override
  void initState() {
    if (widget.id != null) {
      address =
          hantarrBloc.state.addressList.where((x) => x.id == widget.id).first;
    } else {
      address = Address.initClass();
    }
    options = address.getAllTitle().toList();
    options.removeWhere((x) => x.toLowerCase() == "all");

    var path = NavigationHistoryObserver()
        .history
        .map((x) => x.settings.name)
        .toList();
    if (path.contains(p2pHomepage)) {
      Future.delayed(Duration(milliseconds: 200), () {
        setLocation();
      });
    }
    super.initState();
    controllerListener();
  }

  @override
  void dispose() {
    super.dispose();
    buildingCon.dispose();
  }

  controllerListener() async {
    if (address.buildingBlock?.isNotEmpty ?? false) {
      buildingCon.text = address.buildingBlock;
    }

    buildingCon.addListener(() {
      if (buildingCon.text.isNotEmpty) {
        setState(() {
          address.buildingBlock = buildingCon.text;
        });
      }
    });
  }

  void setAddressTitle() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter modalState) {
            TextEditingController titleCon = TextEditingController();
            return AlertDialog(
              title: Text("Address Title"),
              content: TextField(
                controller: titleCon,
                decoration: InputDecoration(
                  labelText: "Address Titile",
                ),
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                  child: Text(
                    "Cancel",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      color: themeBloc.state.primaryColor,
                      fontSize: ScreenUtil().setSp(40.0),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    if (titleCon.text.replaceAll(" ", "").isNotEmpty) {
                      setState(() {
                        options.add(titleCon.text);
                        address.title = titleCon.text;
                      });
                      Navigator.pop(context);
                    } else {
                      BotToast.showText(text: "Cannot Empty");
                    }
                  },
                  color: themeBloc.state.primaryColor,
                  child: Text(
                    "Create",
                    style: themeBloc.state.textTheme.headline6.copyWith(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(40.0),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void setLocation() async {
    gL.LocationResult _pickedLocation;
    gL.LocationResult result = await gL.showLocationPicker(
      context, "AIzaSyCP6DCTU7pUCg-ELswj1bxe1jABsCntkHo",
      initialCenter: LatLng(address.latitude, address.longitude),
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
        address.longitude = _pickedLocation.latLng.longitude;
        address.latitude = _pickedLocation.latLng.latitude;
        address.address = _pickedLocation.address;
      });
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId("User"),
        position: LatLng(
          address.latitude,
          address.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
      final GoogleMapController controller = await _controller.future;
      CameraPosition newLocation = CameraPosition(
          // bearing: 192.8334901395799,
          target: LatLng(address.latitude, address.longitude),
          // tilt: 59.440717697143555,
          zoom: 17);
      controller.animateCamera(CameraUpdate.newCameraPosition(newLocation));
      setAddressTitle();
    }
  }

  getID() async {
    if (ModalRoute.of(context).settings.arguments != null) {
      try {
        int id = ModalRoute.of(context).settings.arguments as int;
        address = Address.initClass();
        address.mapToLocal(
            hantarrBloc.state.addressList.where((x) => x.id == id).first);
      } catch (e) {
        address = Address.initClass();
        String msg = getExceptionMsg(e);
        Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
        JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        String jsonString = encoder.convert(getExceptionLogReq);
        FirebaseCrashlytics.instance
            .recordError(getExceptionLogReq, StackTrace.current);
        FirebaseCrashlytics.instance.log(jsonString);
        print("Get Address ID failed. $msg");
      }
    } else {
      address = new Address.initClass();
    }
    if (!options.contains(address.title)) {
      options.add(address.title);
    }
  }

  List<Widget> bodyContent(Size mediaQ) {
    List<Widget> widgetlist = [];
    if (address.latitude != null && address.longitude != null) {
      Widget mapWidget = Container(
        margin: EdgeInsets.only(top: 15),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Container(
                width: mediaQ.width * .9,
                height: ScreenUtil().setHeight(450),
                child: GoogleMap(
                  onTap: (LatLng longLat) async {
                    setLocation();
                  },
                  myLocationButtonEnabled: true,
                  // mapToolbarEnabled: false,
                  // tiltGesturesEnabled: false,
                  // scrollGesturesEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                        address.latitude,
                        address.longitude,
                      ),
                      zoom: 17.0),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    setState(() {});
                  },
                  markers: _markers,
                  // polylines: _polyLines,
                  myLocationEnabled: false,
                  // onCameraMove: _onCameraMove,
                ),
              ),
            ),
          ],
        ),
      );

      widgetlist.add(mapWidget);
    }

    widgetlist.add(SizedBox(height: ScreenUtil().setHeight(15)));

    widgetlist.add(
      ListTile(
        title: TextFormField(
          readOnly: false,
          controller: buildingCon,
          validator: (val) {
            if (val.replaceAll(" ", "").isEmpty) {
              return "Cannot Empty";
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.search),
            labelText: "Company / Building Name",
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
                width: .4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: Colors.red,
                width: .4,
              ),
            ),
          ),
        ),
      ),
    );
    widgetlist.add(SizedBox(height: ScreenUtil().setHeight(15)));

    widgetlist.add(
      ListTile(
        title: TextFormField(
          onTap: address.address.isEmpty ? setLocation : null,
          readOnly: address.address.isEmpty ? true : false,
          maxLines: null,
          maxLengthEnforced: false,
          controller: TextEditingController(
            text: address.address,
          ),
          onChanged: (val) {
            address.address = val;
          },
          validator: (val) {
            if (val.replaceAll(" ", "").isEmpty) {
              return "Cannot Empty";
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.search),
            labelText: "Address",
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
                width: .4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: Colors.red,
                width: .4,
              ),
            ),
          ),
        ),
      ),
    );

    // widgetlist.add(
    //   ListTile(
    //     title: Row(
    //       children: [
    //         Expanded(
    //           child: TextFormField(
    //             controller: TextEditingController(
    //               text: address.buildingBlock,
    //             ),
    //             onChanged: (val) {
    //               address.buildingBlock = val;
    //             },
    //             decoration: InputDecoration(
    //               labelText: "Building Name",
    //             ),
    //           ),
    //         ),
    //         SizedBox(
    //           width: ScreenUtil().setWidth(35),
    //         ),
    //         Expanded(
    //           child: TextFormField(
    //             controller: TextEditingController(
    //               text: address.room,
    //             ),
    //             onChanged: (val) {
    //               address.room = val;
    //             },
    //             decoration: InputDecoration(
    //               labelText: "Room",
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    widgetlist.add(
      ListTile(
        title: Row(
          children: [
            // Expanded(
            //   child: TextFormField(
            //     controller: TextEditingController(
            //       text: address.floor,
            //     ),
            //     onChanged: (val) {
            //       address.floor = val;
            //     },
            //     keyboardType: TextInputType.text,
            //     decoration: InputDecoration(
            //       labelText: "Floor",
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   width: ScreenUtil().setWidth(35),
            // ),
            Expanded(
                child: DropdownButton<String>(
              underline: Container(),
              value: address.title,
              items: options.map(
                (e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Container(
                      width: mediaQ.width * .8,
                      child: ListTile(
                        leading: Icon(
                          Address(title: e).getLeadingIcon(),
                        ),
                        title: Text("${e.toUpperCase()}"),
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: (String value) {
                if (value.toLowerCase() != "other") {
                  setState(() {
                    address.title = value;
                  });
                } else {
                  setAddressTitle();
                }
              },
            )),
          ],
        ),
      ),
    );
    widgetlist.add(Divider());

    widgetlist.add(
      ListTile(
        title: TextFormField(
          controller: TextEditingController(
            text: address.receiverName,
          ),
          onChanged: (val) {
            address.receiverName = val;
          },
          decoration: InputDecoration(
            labelText: "Name",
          ),
        ),
      ),
    );
    widgetlist.add(
      ListTile(
        title: TextFormField(
          keyboardType: TextInputType.phone,
          controller: TextEditingController(
            text: address.phone,
          ),
          onChanged: (val) {
            address.phone = val;
          },
          decoration: InputDecoration(
            labelText: "Phone",
          ),
        ),
      ),
    );
    widgetlist.add(
      ListTile(
        title: TextFormField(
          controller: TextEditingController(
            text: address.email,
          ),
          onChanged: (val) {
            address.email = val;
          },
          decoration: InputDecoration(
            labelText: "Email",
          ),
        ),
      ),
    );
    widgetlist.add(SizedBox(height: ScreenUtil().setHeight(20)));
    widgetlist.add(
      Container(
        padding: EdgeInsets.all(
          ScreenUtil().setSp(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            address.id != null
                ? FlatButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if (address.latitude != null &&
                            address.longitude != null) {
                          var confirmation = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Confirm Update?"),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, "yes");
                                    },
                                    child: Text("Yes"),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, "no");
                                    },
                                    child: Text("Regret"),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmation == "yes") {
                            Map<String, dynamic> payload = address.toJson();
                            print(payload);
                            loadingWidget(context);
                            var updateReq =
                                await address.updateAddress(payload);
                            Navigator.pop(context);
                            if (updateReq['success']) {
                              setState(() {});
                              BotToast.showText(text: "Update Address Success");
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Update Address Failed"),
                                    content: Text("${updateReq['reason']}"),
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }
                      } else {
                        BotToast.showText(text: "LongLat cannot null");
                      }
                    },
                    color: themeBloc.state.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      child: Text(
                        "Update",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(45.0),
                        ),
                      ),
                    ),
                  )
                : FlatButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if (address.latitude != null &&
                            address.longitude != null) {
                          var confirmation = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Confirm Create?"),
                                actions: [
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, "yes");
                                    },
                                    child: Text("Yes"),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context, "no");
                                    },
                                    child: Text("Regret"),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmation == "yes") {
                            Map<String, dynamic> payload = address.toJson();
                            print(payload);
                            loadingWidget(context);
                            var createReq =
                                await address.createAddress(payload);
                            Navigator.pop(context);
                            if (createReq['success']) {
                              setState(() {});
                              BotToast.showText(text: "Create Address Success");
                              try {
                                var path = NavigationHistoryObserver()
                                    .history
                                    .map((x) => x.settings.name)
                                    .toList();
                                if (path.contains(p2pHomepage)) {
                                  Navigator.pop(context, createReq['data']);
                                }
                              } catch (e) {}
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Create Address Failed"),
                                    content: Text("${createReq['reason']}"),
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }
                      } else {
                        BotToast.showText(text: "LongLat cannot null");
                      }
                    },
                    color: themeBloc.state.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      child: Text(
                        "Create",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(45.0),
                        ),
                      ),
                    ),
                  ),
            address.id != null
                ? SizedBox(
                    width: ScreenUtil().setWidth(20),
                  )
                : Container(),
            address.id != null
                ? FlatButton(
                    onPressed: () async {
                      var confirmation = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Confirm Delete?"),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context, "yes");
                                },
                                child: Text("Yes"),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context, "no");
                                },
                                child: Text("Regret"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmation == "yes") {
                        debugPrint("Delete address. ${address.id}");
                      }
                    },
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      child: Text(
                        "Delete",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(45.0),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
    widgetlist.add(SizedBox(height: ScreenUtil().setHeight(65)));
    return widgetlist;
  }

  @override
  Widget build(BuildContext context) {
    if (address != null) {
      _markers.add(Marker(
        markerId: MarkerId("User"),
        position: LatLng(
          address.latitude,
          address.longitude,
        ),
        // infoWindow: InfoWindow(
        //     title: hantarrBloc.state.user.name,
        //     snippet: hantarrBloc.state.user.phone),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    if (address == null) {
      getID();
    }
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Form(
          key: _formKey,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: address != null
                  ? AppBar(
                      automaticallyImplyLeading: true,
                      title: Text(
                        address.id != null ? "Edit Address" : "Create Address",
                      ),
                      actions: [
                        address.id != null
                            ? IconButton(
                                onPressed: () async {
                                  if (!address.isFavourite) {
                                    // ignore: await_only_futures
                                    await address.setAsFavourite();
                                    address.isFavourite = !address.isFavourite;
                                    setState(() {});
                                  } else {
                                    // ignore: await_only_futures
                                    await address.removeFavourite();
                                    address.isFavourite = !address.isFavourite;
                                    setState(() {});
                                  }
                                },
                                icon: Icon(
                                  address.isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.yellow,
                                ))
                            : Container(),
                      ],
                    )
                  : null,
              body: Container(
                width: mediaQ.width,
                height: mediaQ.height,
                child: address != null
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: bodyContent(mediaQ),
                        ),
                      )
                    : Center(
                        child: SpinKitChasingDots(
                          size: 50,
                          color: themeBloc.state.primaryColor,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
