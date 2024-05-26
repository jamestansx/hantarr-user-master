import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class PreorderDatetime extends StatefulWidget {
  DateTime currentDT;
  Restaurant restaurant;
  bool update;
  PreorderDatetime({this.currentDT, this.restaurant, this.update});
  @override
  PreorderDatetimeState createState() => PreorderDatetimeState();
}

class PreorderDatetimeState extends State<PreorderDatetime> {
  List<String> dateString = [];
  List<String> timeString = [];
  int counter = 0;
  int dateIndex = 0;
  int timeIndex = 0;
  @override
  void initState() {
    dateString = [];
    while (counter < 3) {
      if (counter == 0) {
        if (widget.restaurant.restaurantStatus(
            widget.restaurant.businessHours, widget.currentDT)) {
          dateString.add(widget.currentDT
              .add(Duration(days: counter))
              .toString()
              .split(" ")
              .first);
        }
      } else {
        dateString.add(widget.currentDT
            .add(Duration(days: counter))
            .toString()
            .split(" ")
            .first);
      }

      counter++;
    }
    super.initState();
  }

  onTimeSelect() {
    if (widget.update) {
      String dateTime = timeString[timeIndex];
      bool containDisableItem = false;
      bool shownNextDay = false;
      String deliveryStartTime;
      String deliveryEndTime;
      String itemCode = "";
      DateTime menuItemDateTime =
          dateTime == "" ? widget.currentDT : DateTime.parse(dateTime);
      if (hantarrBloc.state.user.restaurantCart != null) {
        if (hantarrBloc.state.user.restaurantCart.restaurant.id ==
            widget.restaurant.id) {
          hantarrBloc.state.user.restaurantCart.menuItems.forEach((mi) {
            if (mi.deliveryStartTime != null && mi.deliveryEndTime != null) {
              deliveryStartTime = menuItemDateTime.toString().split(" ").first +
                  " " +
                  mi.deliveryStartTime;
              deliveryEndTime = menuItemDateTime.toString().split(" ").first +
                  " " +
                  mi.deliveryEndTime;
              if (mi.allowSameDayDelivert == false) {
                if (menuItemDateTime.day == widget.currentDT.day) {
                  containDisableItem = true;
                  shownNextDay = true;
                }
              }
              if (menuItemDateTime.isAfter(DateTime.parse(deliveryStartTime)) &&
                      !shownNextDay &&
                      menuItemDateTime
                          .isBefore(DateTime.parse(deliveryEndTime)) ||
                  DateTime.parse(deliveryEndTime)
                      .isAtSameMomentAs(menuItemDateTime) ||
                  DateTime.parse(deliveryStartTime)
                      .isAtSameMomentAs(menuItemDateTime)) {
              } else {
                containDisableItem = true;
                if (itemCode == "") {
                  itemCode += mi.name.split(" ").first;
                } else {
                  itemCode += ",";
                  itemCode += mi.name.split(" ").first;
                }
              }
            }
          });
        }
      }
      if (containDisableItem) {
        showDialog(
            // barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                ),
                title: Container(
                  height: 100,
                  width: 100,
                  child: Image.asset("assets/warning.png"),
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Selected delivery time not available for $itemCode please remove them to continue.",
                      // presetFontSizes: [12],

                      style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                      // textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                          ),
                          color: themeBloc.state.primaryColor,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Back",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(33),
                                color: Colors.white),
                          )),
                    )
                  ],
                ),
              );
            });
      } else {
        Navigator.of(context).pop(timeString[timeIndex]);
      }
    } else {
      Navigator.of(context).pop(timeString[timeIndex]);
    }
  }

  updateDateSelection(int index) {
    setState(() {
      dateIndex = index;
    });
  }

  updateTimeSelection(int index) {
    setState(() {
      timeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (DateTime.parse(dateString[dateIndex]).day == widget.currentDT.day) {
      timeString.clear();
      // today's result
      BusinessHour currentBH;
      if (widget.restaurant.businessHours
          .any((x) => x.numOfDay == widget.currentDT.weekday)) {
        currentBH = widget.restaurant.businessHours
            .firstWhere((x) => x.numOfDay == widget.currentDT.weekday);
        if (widget.restaurant.restaurantStatus(
            widget.restaurant.businessHours, widget.currentDT)) {
          // ignore: unused_local_variable
          String startTime = widget.currentDT.toString().split(" ").first +
              " " +
              currentBH.startTime;
          String endTime = widget.currentDT.toString().split(" ").first +
              " " +
              currentBH.endTime;
          print(endTime);
          int hour = widget.currentDT.hour;
          // commented by PCY
          timeString.add("");
          while (hour < DateTime.parse(endTime).hour) {
            hour++;
            String time = widget.currentDT.toString().split(" ").first +
                " " +
                (hour.toString().length == 1 ? "0$hour" : "$hour") +
                ":00:00.000000";
            timeString.add(time);
          }
          print(timeString);
        }
      }
    } else {
      timeString.clear();
      // two days after result
      DateTime currentDay = DateTime.parse(dateString[dateIndex]);
      BusinessHour currentBH;
      if (widget.restaurant.businessHours
          .any((x) => x.numOfDay == currentDay.weekday)) {
        currentBH = widget.restaurant.businessHours
            .firstWhere((x) => x.numOfDay == currentDay.weekday);

        String startTime =
            currentDay.toString().split(" ").first + " " + currentBH.startTime;
        String endTime =
            currentDay.toString().split(" ").first + " " + currentBH.endTime;
        int hour = DateTime.parse(startTime).hour;
        while (hour < DateTime.parse(endTime).hour) {
          hour++;
          String time = currentDay.toString().split(" ").first +
              " " +
              (hour.toString().length == 1 ? "0$hour" : "$hour") +
              ":00:00.000000";
          timeString.add(time);
        }
        print(timeString);
      }
    }

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(timeString[timeIndex]);
        return null;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(18.0),
        ),
        title: new Text(
          "Set Delivery Time",
          style: TextStyle(fontSize: ScreenUtil().setSp(45)),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 8),
                // height: MediaQuery.of(context).size.height*0.1,
                child: Text(
                  "Delivery Date",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                // height: MediaQuery.of(context).size.height*0.1,
                decoration: BoxDecoration(
                    color: themeBloc.state.primaryColor.withOpacity(0.1),
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return BounceDialog(
                            listShow: dateString,
                            functionUpdate: updateDateSelection,
                            isTime: false);
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            dateString[dateIndex],
                            style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                          )),
                      Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 8, top: 8),
                // height: MediaQuery.of(context).size.height*0.1,
                child: Text(
                  "Delivery Time",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                ),
              ),
              timeString.isNotEmpty
                  ? Container(
                      // height: MediaQuery.of(context).size.height*0.1,
                      padding: EdgeInsets.only(left: 8, right: 8),
                      // height: MediaQuery.of(context).size.height*0.1,
                      decoration: BoxDecoration(
                          color: themeBloc.state.primaryColor.withOpacity(0.1),
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return BounceDialog(
                                  listShow: timeString,
                                  functionUpdate: updateTimeSelection,
                                  isTime: true);
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  timeString[timeIndex] == ""
                                      ? "ASAP"
                                      : "${DateTime.parse(timeString[timeIndex]).hour}:00",
                                  textScaleFactor: 1,
                                )),
                            Icon(Icons.keyboard_arrow_down)
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Text("No Time Selection"),
                    ),
              //add button here
              Container(
                padding: EdgeInsets.only(top: 10),
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  color: themeBloc.state.primaryColor,
                  onPressed: () {
                    // Navigator.of(context).pop();
                    onTimeSelect();
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.white, fontSize: ScreenUtil().setSp(40)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class BounceDialog extends StatefulWidget {
  BounceDialog({this.listShow, this.functionUpdate, this.isTime});
  List<String> listShow;
  dynamic functionUpdate;
  bool isTime;
  @override
  State<StatefulWidget> createState() => BounceDialogState();
}

class BounceDialogState extends State<BounceDialog>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6),
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.listShow.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return InkWell(
                      onTap: () {
                        widget.functionUpdate(index);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: EdgeInsets.all(6),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color:
                                themeBloc.state.primaryColor.withOpacity(0.1),
                            // border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            widget.isTime
                                ? Text(
                                    widget.listShow[index] == ""
                                        ? "ASAP"
                                        : "${DateTime.parse(widget.listShow[index]).hour}:00",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    widget.listShow[index],
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                            Icon(
                              widget.isTime
                                  ? Icons.access_time
                                  : Icons.date_range,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
