import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/p2p_repo/p2p_modules/vehicle_module.dart';
import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class VehicleOptionsPage extends StatefulWidget {
  Vehicle vehicle;
  dynamic onChange;
  VehicleOptionsPage({
    @required this.vehicle,
    @required this.onChange,
  });
  @override
  _VehicleOptionsPageState createState() => _VehicleOptionsPageState();
}

class _VehicleOptionsPageState extends State<VehicleOptionsPage> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setSp(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(
                  widget.vehicle.getIcon(),
                  color: Colors.black,
                ),
                title: Text(
                  "${widget.vehicle.vehicleName}",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: ScreenUtil().setSp(32.0),
                  ),
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.crop_free,
                          size: themeBloc.state.textTheme.subtitle2.fontSize,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Up to ${widget.vehicle.weightLimit.toInt()} kg",
                            style: themeBloc.state.textTheme.subtitle2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Icon(
                          widget.vehicle.getIcon(),
                          size: themeBloc.state.textTheme.subtitle2.fontSize,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            "Up to ${widget.vehicle.kmLimit.toInt()} km",
                            style: themeBloc.state.textTheme.subtitle2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.vehicle.vehicleOption.map(
                  (e) {
                    if (e.showInUI) {
                      return ListTile(
                        onTap: () async {
                          setState(() {
                            widget.onChange();
                            e.enable = !e.enable;
                          });
                        },
                        title: Text("${e.optionTitle}"),
                        subtitle: Text("RM ${e.fareAmount.toStringAsFixed(2)}"),
                        leading: Checkbox(
                          value: e.enable,
                          onChanged: (val) {
                            setState(() {
                              widget.onChange();
                              e.enable = !e.enable;
                            });
                          },
                        ),
                        trailing: IconButton(
                          tooltip: "Maximum RM 100",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  title: Text("${e.optionTitle}"),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("${e.optionDescription}"),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    FlatButton(
                                      color: themeBloc.state.primaryColor,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.info),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
