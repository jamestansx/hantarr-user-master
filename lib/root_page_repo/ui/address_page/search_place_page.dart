import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/root_page_repo/modules/osm_route_module.dart';
import 'package:hantarr/utilities/geo_decode.dart';

class SearchPlacePage extends StatefulWidget {
  @override
  _SearchPlacePageState createState() => _SearchPlacePageState();
}

class _SearchPlacePageState extends State<SearchPlacePage> {
  OSMPlace osmPlace = OSMPlace.initClass();
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  Completer<GoogleMapController> _controller = Completer();
  List<OSMPlace> searchResult = [];
  LatLng chosenLocation;
  Set<Marker> _markers = {};
  bool isFocusing = false;
  // Timer timer;

  @override
  void initState() {
    if (hantarrBloc.state.hUser.latitude != null &&
        hantarrBloc.state.hUser.longitude != null) {
      chosenLocation = LatLng(
          hantarrBloc.state.hUser.latitude, hantarrBloc.state.hUser.longitude);
    } else {
      chosenLocation = LatLng(2.8107439958462668, 101.5003567352995);
    }

    // timer = new Timer.periodic(Duration(seconds: 1), (timer) {
    //   double now = chosenLocation.latitude;
    //   double then;
    //   Future.delayed(Duration(seconds: 3), () {
    //     then = chosenLocation.latitude;
    //     // setAddress();
    //     if (now != then) {
    //       setAddress();
    //     } else {
    //       debugPrint("No need get latest address. ");
    //     }
    //   });
    // });

    searchController.addListener(() {
      if (searchController.text.isEmpty) {
      } else {
        searchLocation(searchController.text);
      }
    });
    focusNode.requestFocus();
    focusNode.addListener(() {
      setState(() {
        isFocusing = !isFocusing;
      });
    });
    super.initState();
  }

  void setAddress() async {
    try {
      print(chosenLocation);
      // osmPlace.osmCoordinate.lat = chosenLocation.latitude;
      // osmPlace.osmCoordinate.long = chosenLocation.longitude;
      // osmPlace?.displayName = "";
      // osmPlace.address = "";
      // List<Placemark> newPlace = await placemarkFromCoordinates(
      //   osmPlace.osmCoordinate.lat,
      //   osmPlace.osmCoordinate.long,
      // );
      // if (newPlace.isNotEmpty) {
      //   Placemark placeMark = newPlace[0];
      //   String name = placeMark.name;
      //   String jalanName = placeMark.thoroughfare;
      //   String subLocality = placeMark.subLocality;
      //   String locality = placeMark.locality;
      //   String postalCode = placeMark.postalCode;
      //   String administrativeArea = placeMark.administrativeArea;
      //   // String postalCode = placeMark.postalCode;
      //   // String country = placeMark.country;
      //   String fullAddress =
      //       "$name, $subLocality, $jalanName, $postalCode $locality, $administrativeArea";
      //   if (fullAddress.isNotEmpty) {
      //     osmPlace?.displayName = newPlace.first.name;
      //     osmPlace.address = fullAddress.replaceAll(",,", ",");
      //   }

      //   debugPrint(osmPlace.address);
      // }
      String address = await geoDecode(chosenLocation);
      osmPlace?.displayName = address;
      osmPlace.address = address;
    } catch (e) {
      osmPlace?.displayName = "";
      osmPlace.address = "";
    }
    setState(() {});
  }

  @override
  void dispose() {
    // timer.cancel();
    focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void onLocationChoose(OSMPlace thisplace) async {
    focusNode.unfocus();
    final GoogleMapController controller = await _controller.future;
    CameraPosition newLocation = CameraPosition(
        // bearing: 192.8334901395799,
        target: LatLng(osmPlace.osmCoordinate.lat, osmPlace.osmCoordinate.long),
        // tilt: 59.440717697143555,
        zoom: 19);
    await controller.animateCamera(CameraUpdate.newCameraPosition(newLocation));
    setState(() {
      osmPlace = thisplace;
      searchController.clear();
      chosenLocation =
          LatLng(osmPlace.osmCoordinate.lat, osmPlace.osmCoordinate.long);
    });
  }

  _onCameraMove(CameraPosition position) async {
    setState(() {
      chosenLocation = position.target;
    });
  }

  searchLocation(String searchText) async {
    var result = await OSMPlace.initClass().searchName(searchText);
    searchResult = [];
    if (result['success']) {
      setState(() {
        searchResult = result['data'];
      });
    } else {
      BotToast.showText(text: "Search result failed. ${result['reason']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    _markers.add(Marker(
      markerId: MarkerId("User"),
      position: chosenLocation,
      // infoWindow: InfoWindow(
      //     title: hantarrBloc.state.user.name,
      //     snippet: hantarrBloc.state.user.phone),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios,
                  color: themeBloc.state.primaryColor),
            ),
            title: ListTile(
              title: TextField(
                focusNode: focusNode,
                style: TextStyle(fontSize: ScreenUtil().setSp(35)),
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search Location",
                  hintStyle: TextStyle(fontSize: ScreenUtil().setSp(35)),
                  labelText: null,
                  border: InputBorder.none,
                  suffixIcon: searchController.text.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            focusNode.unfocus();
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
              ),
              trailing: IconButton(
                onPressed: () async {
                  chosenLocation = LatLng(hantarrBloc.state.hUser.latitude,
                      hantarrBloc.state.hUser.longitude);
                  final GoogleMapController controller =
                      await _controller.future;
                  CameraPosition newLocation = CameraPosition(
                      // bearing: 192.8334901395799,
                      target: LatLng(
                          chosenLocation.latitude, chosenLocation.longitude),
                      // tilt: 59.440717697143555,
                      zoom: 19);
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(newLocation));
                  setState(() {});
                },
                icon: Icon(
                  Icons.my_location,
                  color: themeBloc.state.primaryColor,
                ),
              ),
            ),
          ),
          body: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                onTapUp: (TapUpDetails tapUpDetails) {
                  print(tapUpDetails.globalPosition);
                },
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition:
                      CameraPosition(target: chosenLocation, zoom: 19.0),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    setState(() {});
                  },
                  markers: _markers,
                  // polylines: _polyLines,
                  myLocationEnabled: false,
                  onCameraMove: _onCameraMove,
                ),
              ),
              isFocusing
                  ? Positioned(
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
                                  onLocationChoose(searchResult[index]);
                                },
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          searchResult[index]?.displayName,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: ScreenUtil().setSp(35)),
                                        ),
                                        Text(searchResult[index].address,
                                            maxLines: 3,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize:
                                                    ScreenUtil().setSp(30)))
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    )
                  : Container(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: ScreenUtil().setHeight(150),
                    left: 5,
                    right: 5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(ScreenUtil().setSp(15.0)),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          "Address: ${osmPlace.address}",
                          style: themeBloc.state.textTheme.headline6.copyWith(
                            fontSize: ScreenUtil().setSp(35.0),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      FlatButton(
                          onPressed: () async {
                            // try {
                            //   print(chosenLocation);
                            //   osmPlace.osmCoordinate.lat =
                            //       chosenLocation.latitude;
                            //   osmPlace.osmCoordinate.long =
                            //       chosenLocation.longitude;
                            //   osmPlace?.displayName = "";
                            //   osmPlace.address = "";
                            //   List<Placemark> newPlace =
                            //       await placemarkFromCoordinates(
                            //     osmPlace.osmCoordinate.lat,
                            //     osmPlace.osmCoordinate.long,
                            //   );
                            //   if (newPlace.isNotEmpty) {
                            //     Placemark placeMark = newPlace[0];
                            //     String name = placeMark.name;
                            //     String jalanName = placeMark.thoroughfare;
                            //     String subLocality = placeMark.subLocality;
                            //     String locality = placeMark.locality;
                            //     String postalCode = placeMark.postalCode;
                            //     String administrativeArea =
                            //         placeMark.administrativeArea;
                            //     // String postalCode = placeMark.postalCode;
                            //     // String country = placeMark.country;
                            //     osmPlace?.displayName = newPlace.first.name;
                            //     osmPlace.address =
                            //         "$name, $subLocality, $jalanName, $postalCode $locality, $administrativeArea";
                            //     debugPrint(osmPlace.address);
                            //   }
                            // } catch (e) {
                            //   osmPlace?.displayName = "";
                            //   osmPlace.address = "";
                            // }
                            String address = await geoDecode(chosenLocation);
                            osmPlace?.displayName = address;
                            osmPlace.address = address;
                            Navigator.pop(context, osmPlace);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          color: themeBloc.state.primaryColor,
                          child: Container(
                            padding: EdgeInsets.all(ScreenUtil().setSp(15)),
                            child: Text(
                              "Select This Location",
                              style:
                                  themeBloc.state.textTheme.headline6.copyWith(
                                fontSize: ScreenUtil().setSp(65.0),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
