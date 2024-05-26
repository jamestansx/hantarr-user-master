import 'package:hantarr/foodService/foodTracking.dart';
import 'package:hantarr/packageUrl.dart';

class DeliveryTrackingList extends StatefulWidget {
  DeliveryTrackingList({Key key}) : super(key: key);

  @override
  DeliveryTrackingListState createState() => DeliveryTrackingListState();
}

class DeliveryTrackingListState extends State<DeliveryTrackingList> {
  @override
  Widget build(BuildContext context) {
    List<Delivery> pendingDeliveryList = hantarrBloc.state.allDeliveries
        .where((x) =>
            (x.deliveryStatus.delivered == false &&
                (x.deliveryStatus.canceled == false ||
                    x.deliveryStatus.canceled == null) &&
                x.deliveryStatus.acceptFailedByRestaurant == false) ||
            (x.isPreOrder == true &&
                x.deliveryStatus.delivered == false &&
                x.deliveryStatus.acceptFailedByRestaurant == false &&
                x.deliveryStatus.canceled == false))
        .toList();
    print(pendingDeliveryList);
    pendingDeliveryList.sort((a, b) => a.id.compareTo(b.id));
    pendingDeliveryList = pendingDeliveryList.reversed.toList();
    Widget dateTimeFormat(String dateTime) {
      DateTime dt = DateTime.parse(dateTime);
      print(dt);
      String min = (dt.minute.toString().length == 1)
          ? "0" + dt.minute.toString()
          : dt.minute.toString();
      return Text(
        dt.day.toString() +
            "/" +
            dt.month.toString() +
            "/" +
            dt.year.toString() +
            " " +
            (dt.hour >= 12 ? (dt.hour - 12).toString() : dt.hour.toString()) +
            ":" +
            min +
            (dt.hour >= 12 ? " pm" : " am"),
        style: TextStyle(
            color: Colors.grey[700], fontSize: ScreenUtil().setSp(30)),
      );
    }

    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text(
            hantarrBloc.state.translation.text("Order Tracking"),
            style: TextStyle(
                color: themeBloc.state.primaryColor, fontSize: ScreenUtil().setSp(40)),
          ),
          backgroundColor: Colors.white,
        ),
        body: pendingDeliveryList.isNotEmpty
            ? Container(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: pendingDeliveryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool noRider = false;
                      if (pendingDeliveryList[index].rider != null) {
                        if (pendingDeliveryList[index].rider.id == "null") {
                          noRider = true;
                        }
                      } else {
                        noRider = true;
                      }
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        elevation: 15,
                        child: InkWell(
                            child: Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  left: 15, top: 10, right: 15, bottom: 10),
                              height: MediaQuery.of(context).size.height * 0.13,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: Text(
                                            pendingDeliveryList[index]
                                                .restaurant
                                                .name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(35)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        pendingDeliveryList[index].isPreOrder
                                            ? Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    child: Text(
                                                      hantarrBloc
                                                          .state.translation
                                                          .text("Pre-Order: "),
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: ScreenUtil()
                                                              .setSp(30)),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: dateTimeFormat(
                                                        pendingDeliveryList[
                                                                index]
                                                            .preOrderDateTime),
                                                  )
                                                ],
                                              )
                                            : Container(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "ID: " +
                                                  pendingDeliveryList[index]
                                                      .id
                                                      .toString(),
                                              style: TextStyle(
                                                  color: Colors.grey[700]),
                                            ),
                                            // AutoSizeText(
                                            //   pendingDeliveryList[index]
                                            //           .menuItem
                                            //           .length
                                            //           .toString() +
                                            //       " x items",
                                            //   style: TextStyle(
                                            //       color: Colors.grey[700]),
                                            // ),
                                            Text(
                                              "RM " +
                                                  (pendingDeliveryList[index]
                                                              .subTotal +
                                                          pendingDeliveryList[
                                                                  index]
                                                              .deliveryFee)
                                                      .toStringAsFixed(2),
                                              style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize:
                                                      ScreenUtil().setSp(30)),
                                            ),
                                            dateTimeFormat(
                                                pendingDeliveryList[index]
                                                    .datetime)
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  !noRider
                                      ? Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              FlatButton(
                                                onPressed: () async {
                                                  hantarrBloc.state.user
                                                          .currentDelivery =
                                                      pendingDeliveryList[
                                                          index];
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              FoodTracking()));
                                                },
                                                child: Text(
                                                  hantarrBloc.state.translation
                                                      .text("Track Order"),
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: ScreenUtil()
                                                          .setSp(30)),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: Container(
                                padding: EdgeInsets.only(top: 5),
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 30.0,
                                decoration: BoxDecoration(
                                    color: pendingDeliveryList[index]
                                                .deliveryStatus
                                                .pickUp ==
                                            true
                                        ? Colors.greenAccent[700]
                                            .withOpacity(0.5)
                                        : pendingDeliveryList[index].isPreOrder
                                            ? Colors.yellow[800]
                                                .withOpacity(0.8)
                                            : Colors.red.withOpacity(0.7),
                                    borderRadius: new BorderRadius.only(
                                        // topLeft:
                                        //     const Radius.circular(40.0),
                                        bottomLeft: const Radius.circular(20.0),
                                        topRight: Radius.circular(10.0))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      height: 30.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Text(
                                        pendingDeliveryList[index]
                                                    .deliveryStatus
                                                    .pickUp ==
                                                true
                                            ? hantarrBloc.state.translation
                                                .text("Rider On The Way")
                                            : pendingDeliveryList[index]
                                                    .isPreOrder
                                                ? hantarrBloc.state.translation
                                                    .text("Pre-Order: ")
                                                : hantarrBloc.state.translation
                                                    .text(
                                                        "On the way to Pick Up"),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(33)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                      );
                    }),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Icon(LineIcons.),
                    Image.asset("assets/delivery.png"),
                    SizedBox(height: ScreenUtil().setHeight(15)),
                    Text(
                      hantarrBloc.state.translation.text("No Ongoing Delivery"),
                      style: TextStyle(
                          color: Colors.grey, fontSize: ScreenUtil().setSp(50)),
                    ),
                    SizedBox(
                      height: 80,
                    )
                  ],
                ),
              ),
      );
    });
  }
}
