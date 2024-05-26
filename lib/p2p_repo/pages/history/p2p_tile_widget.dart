import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';

// ignore: must_be_immutable
class P2PTileWidget extends StatefulWidget {
  P2pTransaction p2pTransaction;
  P2PTileWidget({
    @required this.p2pTransaction,
  });
  @override
  _P2PTileWidgetState createState() => _P2PTileWidgetState();
}

class _P2PTileWidgetState extends State<P2PTileWidget> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        String hour = widget.p2pTransaction.deliveryDateTime.hour.toString();
        if (hour.length == 1) {
          hour = "0" + hour;
        }
        String min = widget.p2pTransaction.deliveryDateTime.minute.toString();
        if (min.length == 1) {
          min = "0" + min;
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Divider(),
            Container(
              width: 5,
              height: kToolbarHeight,
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  colors: [
                    themeBloc.state.primaryColor,
                    Colors.orange[300],
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                onTap: () {
                  // debugPrint(widget.p2pTransaction.toJson().toString());
                  Navigator.pushNamed(context, p2pDetailPage,
                      arguments: widget.p2pTransaction);
                },
                title: Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        "${widget.p2pTransaction.firstStopAddress()}",
                        maxLines: 2,
                        style: themeBloc.state.textTheme.headline6.copyWith(),
                      ),
                    ),
                  ],
                ),
                subtitle: Wrap(
                  spacing: 5.0,
                  children: [
                    Chip(
                      label: Text(
                        "# ${widget.p2pTransaction.id}",
                        style: themeBloc.state.textTheme.subtitle2.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        "${widget.p2pTransaction.getTotalValidStopsCount()} Stops",
                        style: themeBloc.state.textTheme.subtitle2.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor: widget.p2pTransaction.chipStatusColor(),
                      label: Text(
                        "${widget.p2pTransaction.status.toUpperCase()}",
                        style: themeBloc.state.textTheme.subtitle2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "RM ${widget.p2pTransaction.grandTotal.toStringAsFixed(2)}",
                      textAlign: TextAlign.end,
                      style: themeBloc.state.textTheme.bodyText1.copyWith(
                        inherit: true,
                        color: Colors.grey[850],
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(34),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Text(
                      "${widget.p2pTransaction.deliveryDateTime.day} ${months[widget.p2pTransaction.deliveryDateTime.month - 1]}, $hour:$min",
                      textAlign: TextAlign.end,
                      style: themeBloc.state.textTheme.bodyText1.copyWith(
                        inherit: true,
                        fontSize: ScreenUtil().setSp(30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
