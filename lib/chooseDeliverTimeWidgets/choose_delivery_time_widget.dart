import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class ChooseDeliveryTimeWidget extends StatefulWidget {
  Restaurant restaurant;
  DateTime curTime;
  ChooseDeliveryTimeWidget({
    @required this.restaurant,
    @required this.curTime,
  });
  @override
  _ChooseDeliveryTimeWidgetState createState() =>
      _ChooseDeliveryTimeWidgetState();
}

class _ChooseDeliveryTimeWidgetState extends State<ChooseDeliveryTimeWidget> {
  Map<String, List<String>> dayHours = {};
  @override
  void initState() {
    super.initState();
    setBusinessDay();
  }

  setBusinessDay() {
    dayHours = {};
    DateTime planTime =
        DateTime.tryParse(widget.curTime.toString().substring(0, 10));
    for (BusinessHour businessHour in widget.restaurant.businessHours) {
      DateTime dateTime;
      if (businessHour.numOfDay == 7) {
        print("ss");
      }
      if (planTime.weekday > businessHour.numOfDay) {
        dateTime = planTime.add(
            Duration(days: 7 - (planTime.weekday - businessHour.numOfDay)));
      } else {
        if (planTime.weekday == businessHour.numOfDay) {
          dateTime = planTime.add(
            Duration(days: 0),
          );
        } else {
          dateTime = planTime.add(
            Duration(days: 7 - businessHour.numOfDay - 1),
          );
        }
      }

      if (dayHours[weekday[businessHour.numOfDay - 1] +
              " ${dateTime.toString().substring(0, 10)}"] ==
          null) {
        dayHours[weekday[businessHour.numOfDay - 1] +
            " ${dateTime.toString().substring(0, 10)}"] = [];
        // ignore: unused_local_variable
        String startTime = widget.curTime.toString().split(" ").first +
            " " +
            businessHour.startTime;
        String endTime = widget.curTime.toString().split(" ").first +
            " " +
            businessHour.endTime;
        print(endTime);
        int hour = widget.curTime.hour;
        while (hour < DateTime.parse(endTime).hour) {
          hour++;
          if (hour <= 9) {
            dayHours[weekday[businessHour.numOfDay - 1] +
                    " ${dateTime.toString().substring(0, 10)}"]
                .add("0" + hour.toString() + ":00");
          } else {
            dayHours[weekday[businessHour.numOfDay - 1] +
                    " ${dateTime.toString().substring(0, 10)}"]
                .add(hour.toString() + ":00");
          }
        }
        // for (int i = startTime; i < endTime; i++) {
        //   if (i <= 9) {
        //     dayHours[weekday[businessHour.numOfDay - 1] +
        //             " ${dateTime.toString().substring(0, 10)}"]
        //         .add("0" + i.toString() + ":00");
        //   } else {
        //     dayHours[weekday[businessHour.numOfDay - 1] +
        //             " ${dateTime.toString().substring(0, 10)}"]
        //         .add(i.toString() + ":00");
        //   }
        // }
      }
    }
    print(dayHours);
    setState(() {});
  }

  List<Widget> bodyContent() {
    List<Widget> widgetlist = [
      FlatButton(
        onPressed: () {
          setBusinessDay();
        },
        child: Text("PRess MEs"),
      ),
    ];

    return widgetlist;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: bodyContent(),
      ),
    );
  }
}
