import 'package:bot_toast/bot_toast.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/delivery_datetime_option_selection/displayDate.dart';
import 'package:hantarr/new_food_delivery_repo/ui/delivery_datetime_option_selection/displayTime.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';

// ignore: must_be_immutable
class DeliveryDateTimeOptionSelectionWidget extends StatefulWidget {
  NewRestaurant newRestaurant;
  DeliveryDateTimeOptionSelectionWidget({
    @required this.newRestaurant,
  });
  @override
  _DeliveryDateTimeOptionSelectionWidgetState createState() =>
      _DeliveryDateTimeOptionSelectionWidgetState();
}

class _DeliveryDateTimeOptionSelectionWidgetState
    extends State<DeliveryDateTimeOptionSelectionWidget> {
  DateTime selectedDate;
  TimeOfDay selectedTime;
  List<TimeOfDay> times = [];
  bool selecting = false;

  @override
  void initState() {
    try {
      if (hantarrBloc.state.foodCart.newRestaurant.id ==
          widget.newRestaurant.id) {
        if (!hantarrBloc.state.foodCart.isPreorder) {
          selectedDate = DateTime.tryParse(hantarrBloc
              .state.foodCart.orderDateTime
              .toString()
              .substring(0, 10));
        } else {
          selectedDate = DateTime.tryParse(hantarrBloc
              .state.foodCart.preorderDateTime
              .toString()
              .substring(0, 10));
        }
      } else {
        if (!widget.newRestaurant.allowPreorder) {
          selectedDate = DateTime.tryParse(hantarrBloc
              .state.foodCart.orderDateTime
              .toString()
              .substring(0, 10));
        } else {
          DateTime x = widget.newRestaurant.availableDates().first;
          // TimeOfDay y = widget.newRestaurant.availableTimes(x).first;
          selectedDate = x;
          // DateTime.tryParse(
          //     "${x.toString().substring(0, 10)} ${y.hour.toString().padLeft(2, '0')}:${y.minute.toString().padLeft(2, '0')}");
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("Hit error in initstate. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }

    List<DateTime> getAvailableDates = widget.newRestaurant.availableDates();
    if (getAvailableDates
        .where((x) => x.isAtSameMomentAs(selectedDate))
        .isEmpty) {
      selectedDate = getAvailableDates.first;
    }

    try {
      times = widget.newRestaurant.availableTimes(selectedDate);
      if (hantarrBloc.state.foodCart.preorderDateTime != null) {
        if (times
            .where((x) =>
                x.hour == hantarrBloc.state.foodCart.preorderDateTime.hour &&
                x.minute == hantarrBloc.state.foodCart.preorderDateTime.minute)
            .isNotEmpty) {
          selectedTime = TimeOfDay(
            hour: hantarrBloc.state.foodCart.preorderDateTime.hour,
            minute: hantarrBloc.state.foodCart.preorderDateTime.minute,
          );
        } else {
          if (times.isNotEmpty) {
            selectedTime = times.first;
          } else {
            selectedTime = null;
          }
        }
      } else {
        if (times.isNotEmpty) {
          selectedTime = times.first;
        } else {
          selectedTime = null;
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void selectDate(DateTime dateTime) {
    setState(() {
      selecting = true;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        selectedDate = dateTime;
        times = widget.newRestaurant.availableTimes(selectedDate);
        if (times.where((x) => x == selectedTime).isEmpty) {
          if (times.isNotEmpty) {
            selectedTime = times.first;
            print(
                "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}");
          } else {
            selectedTime = null;
          }
        }
        selecting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    if (widget.newRestaurant.allowPreorder) {}
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ScreenUtil().setSp(20.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setSp(20.0)),
                  child: DropdownSearch<DateTime>(
                    mode: Mode.MENU,
                    // showSelectedItem: true,
                    items: widget.newRestaurant.availableDates(),
                    label: "Delivery Date",
                    itemAsString: (DateTime s) {
                      return displayDate(s);
                    },
                    // hint: "Delivery Date",
                    // popupItemDisabled: (String s) => s.startsWith('I'),
                    onChanged: (DateTime val) {
                      selectDate(val);
                    },
                    selectedItem: selectedDate, showSelectedItem: true,
                    compareFn: (x, y) {
                      if (x == y) {
                        return true;
                      } else {
                        return false;
                      }
                    },
                    dropdownSearchDecoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                !selecting
                    ? Container(
                        padding: EdgeInsets.all(ScreenUtil().setSp(20.0)),
                        child: times.isNotEmpty
                            ? DropdownSearch<TimeOfDay>(
                                mode: Mode.MENU,
                                // showSelectedItem: true,
                                items: times,
                                label: "Delivery Time",
                                itemAsString: (TimeOfDay s) {
                                  return displayTime(s);
                                },
                                // hint: "Delivery Date",
                                // popupItemDisabled: (String s) => s.startsWith('I'),
                                onChanged: (TimeOfDay val) {
                                  selectedTime = val;
                                },
                                selectedItem: selectedTime,
                                showSelectedItem: true,
                                compareFn: (x, y) {
                                  if (x == y) {
                                    return true;
                                  } else {
                                    return false;
                                  }
                                },
                                dropdownSearchDecoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              )
                            : Text("Please select other date."),
                      )
                    : Container(
                        padding: EdgeInsets.all(ScreenUtil().setSp(20.0)),
                        child: SpinKitChasingDots(
                          size: ScreenUtil().setSp(30.0),
                          color: themeBloc.state.primaryColor,
                        ),
                      ),
                // Container(
                //   padding: EdgeInsets.all(ScreenUtil().setSp(20.0)),
                //   child: DropdownButtonFormField<TimeOfDay>(
                //     value: selectedTime,
                //     onChanged: (val) {
                //       selectedTime = val;
                //       setState(() {});
                //     },
                //     items: times
                //         .map(
                //           (e) => DropdownMenuItem(
                //             value: e,
                //             child: Text("${displayTime(e)}"),
                //           ),
                //         )
                //         .toList(),
                //     decoration: InputDecoration(
                //       border: InputBorder.none,
                //       labelText: "Delivery Time",
                //     ),
                //   ),
                // ),
                Container(
                  width: mediaQ.width,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: themeBloc.state.textTheme.button.copyWith(
                            inherit: true,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: (selectedDate != null &&
                                selectedTime != null)
                            ? () {
                                hantarrBloc.state.foodCart.setDeliveryDateTime(
                                    selectedDate, selectedTime);
                                Navigator.pop(context);
                              }
                            : () {
                                BotToast.showText(
                                    text: "Please choose another date");
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: (selectedDate != null && selectedTime != null)
                            ? themeBloc.state.primaryColor
                            : Colors.grey[600],
                        child: Text(
                          "Update",
                          style: themeBloc.state.textTheme.button.copyWith(
                            inherit: true,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
