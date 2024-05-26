import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/packageUrl.dart';
import 'dart:async';
import 'package:hantarr/module/user_module.dart' as hantarrUser;

// ignore: must_be_immutable
class DragLocation extends StatefulWidget {
  bool createAddress, updateLocation;
  DragLocation({Key key, this.createAddress, this.updateLocation})
      : super(key: key);

  @override
  _DragLocationState createState() => _DragLocationState();
}

class _DragLocationState extends State<DragLocation> {
  Completer<GoogleMapController> _controller = Completer();
  bool typeSearch = false, searching = false, showSearchResult = false;
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<Map> searchResult = [];
  LatLng chosenLocation;
  Map chosenArea;
  Set<Marker> _markers = {};

  @override
  void initState() {
    if (hantarrBloc.state.user.currentContactInfo != null) {
      hantarrUser.User user = hantarrBloc.state.user;
      chosenLocation = LatLng(
          num.tryParse(user.currentContactInfo.latitude).toDouble(),
          num.tryParse(user.currentContactInfo.longitude).toDouble());
    }

    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {
          searching = false;
          showSearchResult = false;
        });
      } else {
        if (searching == false) {
          setState(() {
            searching = true;
          });
        }
        searchLocation(searchController.text);
      }
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus == false) {
        setState(() {
          searchController.clear();
          showSearchResult = false;
        });
      }
    });
    super.initState();
  }

  searchLocation(String searchText) async {
    var result = await get(Uri.tryParse(
        "http://map.resertech.com:7070/search?q=${(searchText).replaceAll(" ", "%20")}&format=geojson"));

    List data = [];
    if (result.body.isNotEmpty) {
      data = json.decode(result.body)["features"];
      if (data == null) {
        data = [];
      }
    }
    searchResult.clear();
    for (Map map in data) {
      Map result = {
        "name": map["properties"]["display_name"].split(",").first,
        "lat": map["geometry"]["coordinates"].last.toString(),
        "long": map["geometry"]["coordinates"].first.toString(),
        "address": map["properties"]["display_name"]
      };
      result["address"] = result["address"].replaceAll(",,", ",");
      searchResult.add(result);
    }
    // filteredLocation = filteredLocation.toSet().toList();
    setState(() {
      showSearchResult = true;
    });
  }

  _onCameraMove(CameraPosition position) {
    setState(() {
      chosenLocation = position.target;
    });
  }

  @override
  Widget build(BuildContext context) {
    _markers.add(Marker(
      markerId: MarkerId("User"),
      position: chosenLocation,
      infoWindow: InfoWindow(
          title: hantarrBloc.state.user.name,
          snippet: hantarrBloc.state.user.phone),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    ScreenUtil.init(context);

    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                if (typeSearch) {
                  setState(() {
                    typeSearch = false;
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(Icons.arrow_back_ios,
                  color: themeBloc.state.primaryColor),
            ),
            title: typeSearch
                ? TextField(
                    style: TextStyle(fontSize: ScreenUtil().setSp(35)),
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search Location",
                      hintStyle: TextStyle(fontSize: ScreenUtil().setSp(35)),
                      labelText: null,
                      border: InputBorder.none,
                      suffixIcon: searching
                          ? InkWell(
                              onTap: () {
                                searchController.clear();
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                                size: ScreenUtil().setSp(40),
                              ),
                            )
                          : null,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        hantarrBloc.state.translation
                            .text("Select your location"),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(35)),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              setState(() {
                                typeSearch = true;
                              });
                            },
                            icon: Icon(Icons.search,
                                color: themeBloc.state.primaryColor),
                          ),
                          IconButton(
                            onPressed: () async {
                              bool _serviceEnabled =
                                  await Location().serviceEnabled();
                              PermissionStatus _permissionGranted =
                                  await Location().hasPermission();
                              if (_permissionGranted !=
                                  PermissionStatus.granted) {
                                _permissionGranted =
                                    await Location().requestPermission();
                              }

                              if (!_serviceEnabled) {
                                _serviceEnabled =
                                    await Location().requestService();
                              }
                              if (_serviceEnabled) {
                                LocationData currentLocation =
                                    await Location().getLocation();
                                chosenLocation = LatLng(
                                    currentLocation.latitude,
                                    currentLocation.longitude);
                                final GoogleMapController controller =
                                    await _controller.future;
                                CameraPosition newLocation = CameraPosition(
                                    // bearing: 192.8334901395799,
                                    target: LatLng(chosenLocation.latitude,
                                        chosenLocation.longitude),
                                    // tilt: 59.440717697143555,
                                    zoom: 17);
                                controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        newLocation));
                                setState(() {});
                              }
                            },
                            icon: Icon(
                              Icons.my_location,
                              color: themeBloc.state.primaryColor,
                            ),
                          )
                        ],
                      )
                    ],
                  )),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition:
                  CameraPosition(target: chosenLocation, zoom: 17.0),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                setState(() {});
              },
              markers: _markers,
              // polylines: _polyLines,
              myLocationEnabled: false,
              onCameraMove: _onCameraMove,
            ),
            Positioned(
              bottom: 25,
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.06,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  color: themeBloc.state.primaryColor,
                  onPressed: !searching
                      ? () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Padding(
                                padding: EdgeInsets.all(50),
                                child: Dialog(
                                    elevation: 5,
                                    backgroundColor:
                                        Colors.black.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SpinKitChasingDots(
                                            color: Colors.yellow[600],
                                            size: 50,
                                          ),
                                          Text(
                                            hantarrBloc.state.translation
                                                .text("Verifying Location"),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    ScreenUtil().setSp(40)),
                                          ),
                                        ],
                                      ),
                                    )),
                              );
                            },
                          );

                          var result = await get(Uri.tryParse(
                              "http://map.resertech.com:7070/reverse?lon=${chosenLocation.longitude.toString()}&lat=${chosenLocation.latitude.toString()}&format=geojson"));
                          Map jsonMap = jsonDecode(result.body);
                          try {
                            if (jsonMap["features"]
                                    .first["properties"]["address"]["country"]
                                    .toString()
                                    .toLowerCase() ==
                                "malaysia") {
                              if (widget.createAddress == false &&
                                  widget.updateLocation == false) {
                                hantarrBloc.state.user.currentContactInfo
                                        .latitude =
                                    chosenLocation.latitude.toString();
                                hantarrBloc.state.user.currentContactInfo
                                        .longitude =
                                    chosenLocation.longitude.toString();
                                if (chosenArea == null) {
                                  hantarrBloc.state.user.currentContactInfo
                                      .address = "";
                                  hantarrBloc.state.user.currentContactInfo
                                      .title = "Your Current Location";
                                } else {
                                  hantarrBloc.state.user.currentContactInfo
                                      .title = "New Location";
                                  hantarrBloc.state.user.currentContactInfo
                                      .address = chosenArea["address"];
                                }
                                Navigator.of(context).pop();
                                Navigator.of(context).pop(true);
                              } else if (widget.createAddress == true) {
                                ContactInfo newContactInfo = ContactInfo(
                                    id: null,
                                    latitude:
                                        chosenLocation.latitude.toString(),
                                    longitude:
                                        chosenLocation.longitude.toString(),
                                    address: chosenArea == null
                                        ? chosenArea
                                        : (chosenArea["name"] +
                                            "%address%" +
                                            chosenArea["address"]));
                                // todo manage new address
                                Navigator.of(context).pop();
                                Navigator.of(context).pop(newContactInfo);
                              } else if (widget.updateLocation == true) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop({
                                  "long": chosenLocation.longitude.toString(),
                                  "lat": chosenLocation.latitude.toString()
                                });
                              }
                            } else {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(18.0),
                                    ),
                                    title: Container(
                                      height: 100,
                                      width: 100,
                                      child: Image.asset("assets/warning.png"),
                                    ),
                                    content: Text(
                                      hantarrBloc.state.translation.text(
                                          "Sorry, selected country is not supported in SnaelDelivery"),
                                      // presetFontSizes: [12],
                                      textScaleFactor: 1,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    actions: <Widget>[
                                      // usually buttons at the bottom of the dialog
                                      FlatButton(
                                          // color: Colors.black,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            hantarrBloc.state.translation
                                                .text("Got it!"),
                                            style: TextStyle(
                                                color: Colors.yellow[800],
                                                fontSize: 15),
                                            textScaleFactor: 1,
                                          )),
                                    ],
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            showToast("Error 404", context: context);
                          }
                        }
                      : null,
                  child: (widget.updateLocation == true ||
                          widget.createAddress == true)
                      ? Text(
                          hantarrBloc.state.translation.text("Select Location"),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(45)),
                        )
                      : Text(
                          hantarrBloc.state.translation.text("Find Restaurant"),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(45)),
                        ),
                ),
              ),
            ),
            showSearchResult == false
                ? Container()
                : Positioned(
                    top: 0,
                    left: ScreenUtil().setSp(130),
                    child: Container(
                      constraints: new BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.8,
                      // height: MediaQuery.of(context).size.height,
                      child: new ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResult.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return InkWell(
                              onTap: () async {
                                focusNode.unfocus();

                                final GoogleMapController controller =
                                    await _controller.future;
                                CameraPosition newLocation = CameraPosition(
                                    // bearing: 192.8334901395799,
                                    target: LatLng(
                                        num.tryParse(searchResult[index]["lat"])
                                            .toDouble(),
                                        num.tryParse(
                                                searchResult[index]["long"])
                                            .toDouble()),
                                    // tilt: 59.440717697143555,
                                    zoom: 17);
                                controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        newLocation));
                                setState(() {
                                  searchController.clear();
                                  chosenLocation = LatLng(
                                      searchResult[index]["lat"],
                                      searchResult[index]["long"]);
                                });
                              },
                              child: Card(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        searchResult[index]["name"],
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: ScreenUtil().setSp(35)),
                                      ),
                                      Text(searchResult[index]["address"],
                                          maxLines: 3,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: ScreenUtil().setSp(30)))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  )
          ],
        ),
      );
    });
  }
}
