import 'package:hantarr/packageUrl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:timeline_list/timeline.dart';
import 'dart:async';

import 'package:timeline_list/timeline_model.dart';

import 'history_page/history_delivery.dart';

class FoodTracking extends StatefulWidget {
  FoodTracking({Key key}) : super(key: key);

  @override
  _FoodTrackingState createState() => _FoodTrackingState();
}

class _FoodTrackingState extends State<FoodTracking> {
  LatLng _initialPosition;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Timer riderLocationTimer;
  bool fullscreen = false;
  double deliverTime;
  double riderTime;
  bool getRiderTime = false;
  Timer deliveryStatusTimer;
  double grandTotal;
  BitmapDescriptor riderbitmapDes, restbitmapDes;
  // LatLng test;
  @override
  void initState() {
    deliveryStatusTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await Delivery().getDeliveryStatus();
    });
    setBitmapImage();
    getRiderLocation();
    super.initState();
  }

  setBitmapImage() async {
    riderbitmapDes = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/rider.png");
    restbitmapDes = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "assets/restaurant.png");
  }

  @override
  void dispose() {
    super.dispose();
    deliveryStatusTimer.cancel();
  }

  getRiderLocation() async {
    _markers.removeWhere((x) => x.markerId.value == "Rider");
    try {
      _markers.add(Marker(
          markerId: MarkerId("Rider"),
          position: LatLng(
              num.tryParse(
                      hantarrBloc.state.user.currentDelivery.rider.latitude)
                  .toDouble(),
              num.tryParse(
                      hantarrBloc.state.user.currentDelivery.rider.longitude)
                  .toDouble()),
          infoWindow: InfoWindow(
              title: "Rider",
              snippet: hantarrBloc.state.user.currentDelivery.rider.name),
          // ignore: deprecated_member_use
          icon: riderbitmapDes));
    } catch (e) {}
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    grandTotal = hantarrBloc.state.user.currentDelivery.deliveryFee +
        hantarrBloc.state.user.currentDelivery.subTotal -
        hantarrBloc.state.user.currentDelivery.discountAmount -
        hantarrBloc.state.user.currentDelivery.voucherAmount;
    if (grandTotal < 0) {
      grandTotal = 0;
    }
    ScreenUtil.init(context);

    Restaurant restaurant = hantarrBloc.state.user.currentDelivery.restaurant;

    _initialPosition = LatLng(
        num.tryParse(
                hantarrBloc.state.user.currentDelivery.contactInfo.latitude)
            .toDouble(),
        num.tryParse(
                hantarrBloc.state.user.currentDelivery.contactInfo.longitude)
            .toDouble());

    try {
      _markers.add(Marker(
          markerId: MarkerId("Rider"),
          position: LatLng(
              num.tryParse(
                      hantarrBloc.state.user.currentDelivery.rider.latitude)
                  .toDouble(),
              num.tryParse(
                      hantarrBloc.state.user.currentDelivery.rider.longitude)
                  .toDouble()),
          infoWindow: InfoWindow(
              title: "Rider",
              snippet: hantarrBloc.state.user.currentDelivery.rider.name),
          // ignore: deprecated_member_use
          icon: riderbitmapDes));
    } catch (e) {}

    try {
      _markers.add(Marker(
          markerId: MarkerId("Restaurant"),
          position: LatLng(num.tryParse(restaurant.latitude).toDouble(),
              num.tryParse(restaurant.longitude).toDouble()),
          infoWindow: InfoWindow(title: restaurant.name, snippet: "Restaurant"),
          // ignore: deprecated_member_use
          icon: restbitmapDes));
    } catch (e) {}

    _markers.add(Marker(
        markerId: MarkerId("Customer"),
        position: _initialPosition,
        infoWindow: InfoWindow(
            title: hantarrBloc.state.user.currentDelivery.contactInfo.name,
            snippet: hantarrBloc.state.user.currentDelivery.contactInfo.phone),
        icon: BitmapDescriptor.defaultMarker));

    // _markers.add(Marker(
    //             markerId: MarkerId("TESTING"),
    //             position: test,
    //             infoWindow: InfoWindow(
    //                 title: hantarrBloc.state.user
    //                     .currentDelivery.contactInfo.name,
    //                 snippet: hantarrBloc.state.user
    //                     .currentDelivery.contactInfo.phone),
    //             icon: BitmapDescriptor.defaultMarker));

    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      Delivery currentDelivery = hantarrBloc.state.user.currentDelivery;
      if (currentDelivery.deliveryStatus.pickUp == true) {
        deliverTime = num.tryParse(currentDelivery.eta).toDouble() -
            currentDelivery.restaurant.individualPrepareTime;
      } else if (currentDelivery.deliveryStatus.pickUp != true) {
        deliverTime = num.tryParse(currentDelivery.eta).toDouble();
      }
      List<TimelineModel> statusList() {
        // final doodle = doodles[i];
        // final textTheme = Theme.of(context).textTheme;
        List<TimelineModel> statusListModel = [
          TimelineModel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Card(
                    shadowColor: themeBloc.state.primaryColor,
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    clipBehavior: Clip.antiAlias,
                    color: themeBloc.state.primaryColor.withOpacity(0.7),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            //  width: MediaQuery.of(context).size.width*0.5,
                            child: Text(
                              "Rider has been found and restaurant has received your order",
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(32),
                                  color: Colors.white),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(
                                LineIcons.check_circle,
                                color: Color(0xff141a46),
                                size: ScreenUtil()
                                    .setSp(35, allowFontScalingSelf: true),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                    " Ordered at " +
                                        currentDelivery.datetime
                                            .toString()
                                            .split(".")[0]
                                            .substring(11, 16),
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(32),
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff141a46))),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              position: TimelineItemPosition.left,
              // isFirst: i == 0,
              // isLast: i == doodles.length,
              iconBackground: Color(0xff141a46),
              icon: Icon(LineIcons.dot_circle_o,
                  color: themeBloc.state.primaryColor)),
          TimelineModel(
              Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    shadowColor: themeBloc.state.primaryColor,
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    clipBehavior: Clip.antiAlias,
                    color: hantarrBloc.state.user.currentDelivery.deliveryStatus
                                .pickUp ==
                            true
                        ? themeBloc.state.primaryColor.withOpacity(0.7)
                        : Colors.black.withOpacity(0.4),
                    elevation: hantarrBloc.state.user.currentDelivery
                                .deliveryStatus.pickUp ==
                            true
                        ? 5
                        : 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          hantarrBloc.state.user.currentDelivery.deliveryStatus
                                      .pickUp ==
                                  true
                              ? Container(
                                  //  width: MediaQuery.of(context).size.width*0.5,
                                  child: Text("Rider has pick up your food",
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(32),
                                          color: Colors.white)),
                                )
                              : Container(
                                  //  width: MediaQuery.of(context).size.width*0.5,
                                  child: Text("Waiting for food being prepared",
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(32),
                                          color: Colors.white)),
                                ),
                          currentDelivery.deliveryStatus.pickUp == true
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(
                                      LineIcons.check_circle,
                                      color: Color(0xff141a46),
                                      size: ScreenUtil().setSp(35,
                                          allowFontScalingSelf: true),
                                    ),
                                    Text(
                                        " Picked up at " +
                                            currentDelivery.pickupDateTime
                                                .toString()
                                                .split(".")[0]
                                                .substring(0, 5),
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(32),
                                            color: Color(0xff141a46)))
                                  ],
                                )
                              : Container()
                          // SizedBox(
                          //   height: 8.0,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              position: TimelineItemPosition.left,
              // isFirst: i == 0,
              // isLast: i == doodles.length,
              iconBackground: hantarrBloc
                          .state.user.currentDelivery.deliveryStatus.pickUp ==
                      true
                  ? Color(0xff141a46)
                  : Colors.grey,
              icon: Icon(
                LineIcons.dot_circle_o,
                color: hantarrBloc
                            .state.user.currentDelivery.deliveryStatus.pickUp ==
                        true
                    ? Colors.white
                    : Color(0xff141a46),
              )),
          TimelineModel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    shadowColor: themeBloc.state.primaryColor,
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    color: currentDelivery.deliveryStatus.delivered == true
                        ? themeBloc.state.primaryColor.withOpacity(0.7)
                        : Colors.black.withOpacity(0.4),
                    elevation: currentDelivery.deliveryStatus.delivered == true
                        ? 5
                        : 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          currentDelivery.deliveryStatus.delivered == true
                              ? Text("Your food has been delivered",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(32),
                                      color: Colors.white))
                              : Text("Waiting for delivery",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(32),
                                      color: Colors.white)),
                          // SizedBox(
                          //   height: 8.0,
                          // ),
                          currentDelivery.deliveryStatus.delivered == true
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(
                                      LineIcons.check_circle,
                                      color: Color(0xff141a46),
                                      size: ScreenUtil().setSp(35,
                                          allowFontScalingSelf: true),
                                    ),
                                    Text(
                                        " Picked up at " +
                                            currentDelivery.deliveredDateTime
                                                .toString()
                                                .split(".")[0]
                                                .substring(0, 5),
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(32),
                                            color: Color(0xff141a46)))
                                  ],
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              position: TimelineItemPosition.left,
              // isFirst: i == 0,
              // isLast: i == doodles.length,
              iconBackground: currentDelivery.deliveryStatus.delivered == true
                  ? Color(0xff141a46)
                  : Colors.grey,
              icon: Icon(
                LineIcons.dot_circle_o,
                color: currentDelivery.deliveryStatus.delivered == true
                    ? themeBloc.state.primaryColor
                    : Color(0xff141a46),
              )),
        ];

        return statusListModel;
      }

      // _onCameraMove(CameraPosition position) {
      //   setState(() {
      //    test = position.target;
      //   });

      // }

      detailsDialog(List<Customization> cusList, List<ComboItem> comboList,
          MenuItem currentMenuItem) {
        if (cusList != null && comboList != null) {
          List<Widget> detailList = [];
          detailList.add(Text(
            "Selected Combo Items",
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
          for (ComboItem ci in comboList) {
            detailList.add(Card(
              elevation: 4,
              child: Container(
                  padding: EdgeInsets.all(10),
                  height: 80.0,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Image.asset("assets/foodIcon.png"),
                          height: 100,
                          width: 100,
                          // ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(ci.name,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(30))),
                                Text(
                                  ci.alt_name,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(30)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ));
          }
          detailList.add(SizedBox(
            height: 10,
          ));
          detailList.add(Text(
            "Customizations",
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
          for (Customization cus in cusList) {
            detailList.add(
              Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    cus.name +
                                        (cus.qty == null
                                            ? " x 1"
                                            : (" x " + cus.qty.toString())),
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(30),
                                      color: Colors.black,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: Text(currentMenuItem.name,
                style: TextStyle(fontSize: 15), textScaleFactor: 1),
            content: Container(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height * 0.75),
              child: ListView(
                shrinkWrap: true,
                children: detailList,
              ),
            ),
          );
        } else {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Text(currentMenuItem.name,
                  style: TextStyle(fontSize: 15), textScaleFactor: 1),
              content: Container(
                constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height * 0.75),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      cusList != null ? cusList.length : comboList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return (cusList != null)
                        ? Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: SingleChildScrollView(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                              cusList[index].name +
                                                  (cusList[index].qty == null
                                                      ? " x 1"
                                                      : (" x " +
                                                          cusList[index]
                                                              .qty
                                                              .toString())),
                                              maxLines: 2,
                                              style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(30),
                                                color: Colors.black,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                        : Container(
                            child: Card(
                              elevation: 4,
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  height: 80.0,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          child: Image.asset(
                                              "assets/foodIcon.png"),
                                          height: 100,
                                          width: 100,
                                          // ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: SingleChildScrollView(
                                          child: Container(
                                            padding: EdgeInsets.only(left: 5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(comboList[index].name,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(30),
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                  comboList[index].alt_name,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(30),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          );
                  },
                ),
              ));
        }
      }

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(
            color: themeBloc.state.primaryColor, //change your color here
          ),
          title: Text(
            "Order Tracking" + " - ${currentDelivery.id}",
            style: TextStyle(
                color: themeBloc.state.primaryColor,
                fontSize: ScreenUtil().setSp(40)),
          ),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: GoogleMap(
                      zoomControlsEnabled: false,

                      mapType: MapType.normal,
                      initialCameraPosition:
                          CameraPosition(target: _initialPosition, zoom: 17.0),
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
                  Positioned(
                    bottom: 0,
                    right: 1,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      color: Colors.black,
                      iconSize: 40,
                      icon: fullscreen == false
                          ? Icon(Icons.fullscreen)
                          : Icon(Icons.fullscreen_exit),
                      onPressed: () {
                        if (fullscreen == false) {
                          setState(() {
                            fullscreen = true;
                          });
                        } else {
                          setState(() {
                            fullscreen = false;
                          });
                        }
                      },
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 10,
                    child: Row(
                      children: <Widget>[
                        new InkWell(
                          onTap: () async {
                            final GoogleMapController controller =
                                await _controller.future;
                            CameraPosition restaurantLocation = CameraPosition(
                                // bearing: 192.8334901395799,
                                target: LatLng(
                                    num.tryParse(restaurant.latitude)
                                        .toDouble(),
                                    num.tryParse(restaurant.longitude)
                                        .toDouble()),
                                // tilt: 59.440717697143555,
                                zoom: 17);
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    restaurantLocation));
                          },
                          child: new Container(
                            width: ScreenUtil().setWidth(105),
                            height: ScreenUtil().setHeight(90),
                            decoration: new BoxDecoration(
                              color: Colors.black,
                              border: new Border.all(
                                  color: Colors.white, width: 2.0),
                              borderRadius: new BorderRadius.circular(30.0),
                              // image: DecorationImage(
                              //   image: AssetImage("assets/restaurant.png"),
                              //   fit: BoxFit.fill,
                              // ),
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.yellow[600],
                              size: ScreenUtil()
                                  .setSp(50, allowFontScalingSelf: true),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        new InkWell(
                          onTap: () async {
                            final GoogleMapController controller =
                                await _controller.future;
                            CameraPosition restaurantLocation = CameraPosition(
                                // bearing: 192.8334901395799,
                                target: LatLng(
                                    num.tryParse(currentDelivery.rider.latitude)
                                        .toDouble(),
                                    num.tryParse(
                                            currentDelivery.rider.longitude)
                                        .toDouble()),
                                // tilt: 59.440717697143555,
                                zoom: 17);
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    restaurantLocation));
                          },
                          child: new Container(
                            width: ScreenUtil().setWidth(105),
                            height: ScreenUtil().setHeight(90),
                            decoration: new BoxDecoration(
                              color: Colors.black,
                              border: new Border.all(
                                  color: Colors.white, width: 2.0),
                              borderRadius: new BorderRadius.circular(30.0),
                              // image: DecorationImage(
                              //   image: AssetImage("assets/logo2.png"),
                              //   fit: BoxFit.scaleDown,
                              // ),
                            ),
                            child: Icon(
                              Icons.motorcycle,
                              color: Colors.yellow[600],
                              size: ScreenUtil()
                                  .setSp(50, allowFontScalingSelf: true),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        new InkWell(
                          onTap: () async {
                            final GoogleMapController controller =
                                await _controller.future;
                            CameraPosition restaurantLocation = CameraPosition(
                                // bearing: 192.8334901395799,
                                target: LatLng(
                                    num.tryParse(currentDelivery
                                            .contactInfo.latitude)
                                        .toDouble(),
                                    num.tryParse(currentDelivery
                                            .contactInfo.longitude)
                                        .toDouble()),
                                // tilt: 59.440717697143555,
                                zoom: 17);
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    restaurantLocation));
                          },
                          child: new Container(
                            width: ScreenUtil().setWidth(105),
                            height: ScreenUtil().setHeight(90),
                            decoration: new BoxDecoration(
                              color: Colors.black,
                              border: new Border.all(
                                  color: Colors.white, width: 2.0),
                              borderRadius: new BorderRadius.circular(30.0),
                              // image: DecorationImage(
                              //   image: AssetImage("assets/logo2.png"),
                              //   fit: BoxFit.scaleDown,
                              // ),
                            ),
                            child: Icon(
                              Icons.supervised_user_circle,
                              color: Colors.yellow[600],
                              size: ScreenUtil()
                                  .setSp(50, allowFontScalingSelf: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            fullscreen != true
                ? Expanded(
                    flex: 8,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child: CircularPercentIndicator(
                                  radius: ScreenUtil()
                                      .setSp(250, allowFontScalingSelf: true),
                                  animation: false,
                                  animationDuration: 1200,
                                  lineWidth: 8.0,
                                  percent: (1 -
                                      (num.tryParse(deliverTime
                                                  .toStringAsFixed(0))
                                              .toDouble() /
                                          num.tryParse(currentDelivery.eta)
                                              .toInt())),
                                  center: new Text(
                                    deliverTime.toStringAsFixed(0) +
                                        " min\nETA",
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(40),
                                        color: themeBloc.state.primaryColor),
                                    textAlign: TextAlign.center,
                                  ),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  backgroundColor: Colors.orange[100],
                                  progressColor: themeBloc.state.primaryColor,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: ScreenUtil()
                                        .setSp(40, allowFontScalingSelf: true),
                                    bottom: ScreenUtil()
                                        .setSp(40, allowFontScalingSelf: true)),
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  child: Container(
                                      padding: EdgeInsets.all(ScreenUtil()
                                          .setSp(20,
                                              allowFontScalingSelf: true)),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text("Rider",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: ScreenUtil()
                                                            .setSp(30))),
                                                Text(
                                                    hantarrBloc
                                                                .state
                                                                .user
                                                                .currentDelivery
                                                                .rider
                                                                .name !=
                                                            null
                                                        ? hantarrBloc
                                                            .state
                                                            .user
                                                            .currentDelivery
                                                            .rider
                                                            .name
                                                            .toString()
                                                        : "...",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: ScreenUtil()
                                                            .setSp(30)))
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text("Total",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: ScreenUtil()
                                                            .setSp(30))),
                                                Text(
                                                    "RM " +
                                                        (grandTotal)
                                                            .toStringAsFixed(2),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: ScreenUtil()
                                                            .setSp(30)))
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text("Payment Method",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: ScreenUtil()
                                                            .setSp(30))),
                                                Text(
                                                    hantarrBloc
                                                        .state
                                                        .user
                                                        .currentDelivery
                                                        .paymentMethod,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: ScreenUtil()
                                                            .setSp(30)))
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Timeline(
                              physics: ClampingScrollPhysics(),
                              children: statusList(),
                              //  BouncingScrollPhysics()
                              position: TimelinePosition.Left),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (builder) {
                                    return new Container(
                                      constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.45),

                                      color: Color(
                                          0xFF737373), //could change this to Color(0xFF737373),
                                      //so you don't have to change MaterialApp canvasColor
                                      child: new Container(
                                          decoration: new BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              10.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              10.0))),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: hantarrBloc
                                                  .state
                                                  .user
                                                  .currentDelivery
                                                  .menuItem
                                                  .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                if (hantarrBloc
                                                        .state
                                                        .user
                                                        .currentDelivery
                                                        .menuItem[index]
                                                        .confirmedComboItems ==
                                                    null) {
                                                  hantarrBloc
                                                      .state
                                                      .user
                                                      .currentDelivery
                                                      .menuItem[index]
                                                      .confirmedComboItems = [];
                                                }
                                                if (hantarrBloc
                                                        .state
                                                        .user
                                                        .currentDelivery
                                                        .menuItem[index]
                                                        .selectedCustomizations ==
                                                    null) {
                                                  hantarrBloc
                                                      .state
                                                      .user
                                                      .currentDelivery
                                                      .menuItem[index]
                                                      .selectedCustomizations = [];
                                                }
                                                return InkWell(
                                                  child: Card(
                                                    elevation: 4,
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        height: ScreenUtil()
                                                            .setHeight(180),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                child: hantarrBloc
                                                                            .state
                                                                            .user
                                                                            .currentDelivery
                                                                            .menuItem[index]
                                                                            .imageUrl !=
                                                                        null
                                                                    ? CachedNetworkImage(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        height:
                                                                            ScreenUtil().setWidth(200),
                                                                        width: ScreenUtil()
                                                                            .setWidth(200),
                                                                        imageUrl:
                                                                            "https://pos.str8.my/images/uploads/" +
                                                                                hantarrBloc.state.user.currentDelivery.menuItem[index].imageUrl,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                SpinKitDualRing(
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            new Icon(Icons.error),
                                                                      )
                                                                    : Container(
                                                                        child: Image.asset(
                                                                            "assets/foodIcon.png"),
                                                                        height:
                                                                            ScreenUtil().setWidth(200),
                                                                        width: ScreenUtil()
                                                                            .setWidth(200),
                                                                      ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 6,
                                                              child:
                                                                  SingleChildScrollView(
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                          hantarrBloc
                                                                              .state
                                                                              .user
                                                                              .currentDelivery
                                                                              .menuItem[
                                                                                  index]
                                                                              .name,
                                                                          maxLines:
                                                                              2,
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: ScreenUtil().setSp(35))),
                                                                      Text(
                                                                        hantarrBloc
                                                                            .state
                                                                            .user
                                                                            .currentDelivery
                                                                            .menuItem[index]
                                                                            .alt_name,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: ScreenUtil().setSp(30)),
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          hantarrBloc.state.user.currentDelivery.menuItem[index].confirmedComboItems.isNotEmpty
                                                                              ? Card(
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                                                  color: Colors.black,
                                                                                  child: Container(
                                                                                    padding: EdgeInsets.only(left: 10, right: 10),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      "Combo",
                                                                                      style: TextStyle(color: Colors.yellow[600], fontSize: ScreenUtil().setSp(30)),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                          hantarrBloc.state.user.currentDelivery.menuItem[index].selectedCustomizations.isNotEmpty
                                                                              ? Card(
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                                                  color: Colors.black,
                                                                                  child: Container(
                                                                                    padding: EdgeInsets.only(left: 10, right: 10),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      "Customized",
                                                                                      style: TextStyle(color: Colors.yellow[600], fontSize: ScreenUtil().setSp(30)),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container()
                                                                        ],
                                                                      )
                                                                      // Text(
                                                                      //     "RM " +
                                                                      //         widget
                                                                      //             .membershipBloc
                                                                      //             .state
                                                                      //             .user
                                                                      //             .cart
                                                                      //             .menuItems[
                                                                      //                 index]
                                                                      //             .itemPriceSetter(
                                                                      //                 hantarrBloc.state.user.currentDelivery.menuItem[
                                                                      //                     index],
                                                                      //                 currentDT,
                                                                      //                 widget
                                                                      //                     .selfOrderingMenu)
                                                                      //             .toStringAsFixed(
                                                                      //                 2),
                                                                      //     presetFontSizes: [
                                                                      //       14,
                                                                      //       12,
                                                                      //       10,
                                                                      //       8
                                                                      //     ],
                                                                      //     maxLines: 1,
                                                                      //     textScaleFactor:
                                                                      //         1)
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                  onTap: () {
                                                    if (hantarrBloc
                                                            .state
                                                            .user
                                                            .currentDelivery
                                                            .menuItem[index]
                                                            .selectedCustomizations
                                                            .isNotEmpty ||
                                                        hantarrBloc
                                                            .state
                                                            .user
                                                            .currentDelivery
                                                            .menuItem[index]
                                                            .confirmedComboItems
                                                            .isNotEmpty) {
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            if (hantarrBloc
                                                                    .state
                                                                    .user
                                                                    .currentDelivery
                                                                    .menuItem[
                                                                        index]
                                                                    .selectedCustomizations
                                                                    .isNotEmpty &&
                                                                hantarrBloc
                                                                    .state
                                                                    .user
                                                                    .currentDelivery
                                                                    .menuItem[
                                                                        index]
                                                                    .confirmedComboItems
                                                                    .isNotEmpty) {
                                                              return detailsDialog(
                                                                  hantarrBloc
                                                                      .state
                                                                      .user
                                                                      .currentDelivery
                                                                      .menuItem[
                                                                          index]
                                                                      .selectedCustomizations,
                                                                  hantarrBloc
                                                                      .state
                                                                      .user
                                                                      .currentDelivery
                                                                      .menuItem[
                                                                          index]
                                                                      .confirmedComboItems,
                                                                  hantarrBloc
                                                                      .state
                                                                      .user
                                                                      .currentDelivery
                                                                      .menuItem[index]);
                                                            } else {
                                                              if (hantarrBloc
                                                                  .state
                                                                  .user
                                                                  .currentDelivery
                                                                  .menuItem[
                                                                      index]
                                                                  .selectedCustomizations
                                                                  .isNotEmpty) {
                                                                return detailsDialog(
                                                                    hantarrBloc
                                                                        .state
                                                                        .user
                                                                        .currentDelivery
                                                                        .menuItem[
                                                                            index]
                                                                        .selectedCustomizations,
                                                                    null,
                                                                    hantarrBloc
                                                                        .state
                                                                        .user
                                                                        .currentDelivery
                                                                        .menuItem[index]);
                                                              }
                                                              if (hantarrBloc
                                                                  .state
                                                                  .user
                                                                  .currentDelivery
                                                                  .menuItem[
                                                                      index]
                                                                  .confirmedComboItems
                                                                  .isNotEmpty) {
                                                                return detailsDialog(
                                                                    null,
                                                                    hantarrBloc
                                                                        .state
                                                                        .user
                                                                        .currentDelivery
                                                                        .menuItem[
                                                                            index]
                                                                        .confirmedComboItems,
                                                                    hantarrBloc
                                                                        .state
                                                                        .user
                                                                        .currentDelivery
                                                                        .menuItem[index]);
                                                              } else {
                                                                return Container();
                                                              }
                                                            }
                                                          });
                                                    }
                                                  },
                                                );
                                              })),
                                    );
                                  });
                            },
                            child: Container(
                              // padding: EdgeInsets.only(left: 50, right: 50),
                              alignment: Alignment.topCenter,
                              child: Card(
                                color: themeBloc.state.primaryColor,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: Text(
                                    "View Item",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(43)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HistoryDeliveryPage(
                                            delivery: hantarrBloc
                                                .state.user.currentDelivery,
                                          )));
                            },
                            child: Container(
                              // padding: EdgeInsets.only(left: 50, right: 50),
                              alignment: Alignment.topCenter,
                              child: Card(
                                color: themeBloc.state.primaryColor,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  child: Text(
                                    "Show Details",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(43)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      );
    });
  }
}
