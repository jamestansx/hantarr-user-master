import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/stop_module.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:timelines/timelines.dart';

const kTileHeight = 50.0;

// ignore: must_be_immutable
class P2PStopsTimeLine extends StatefulWidget {
  P2pTransaction p2pTransaction;
  P2PStopsTimeLine({
    @required this.p2pTransaction,
  });

  @override
  _P2PStopsTimeLineState createState() => _P2PStopsTimeLineState();
}

class _P2PStopsTimeLineState extends State<P2PStopsTimeLine> {
  @override
  Widget build(BuildContext context) {
    final data = widget.p2pTransaction;
    return Center(
      child: widget.p2pTransaction.getValidStops().isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _OrderTitle(
                      orderInfo: data,
                    ),
                  ),
                  Divider(height: 1.0),
                  _DeliveryProcesses(
                    p2pTransaction: widget.p2pTransaction,
                    processes: data.getValidStops(),
                  ),
                  Divider(height: 1.0),
                  // Padding(
                  //   padding: const EdgeInsets.all(20.0),
                  //   child: _OnTimeBar(driver: data.driverInfo),
                  // ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.all(ScreenUtil().setSp(15)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(350),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: SvgPicture.asset(
                          "assets/empty_res.svg",
                        ),
                      ),
                    ),
                    Text(
                      "No Stops Specified",
                      style: themeBloc.state.textTheme.headline6.copyWith(
                        fontSize: ScreenUtil().setSp(45.0),
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _OrderTitle extends StatelessWidget {
  const _OrderTitle({
    @required this.orderInfo,
  });

  final P2pTransaction orderInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          orderInfo.id != null ? 'Delivery #${orderInfo.id}' : "New Delivery",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Text(
          orderInfo.deliveryDateTime != null
              ? "${orderInfo.deliveryDateTime.toString().substring(0, 16)}"
              : "${DateTime.now().toString().substring(0, 10)}",
          // '${orderInfo.date.day}/${orderInfo.date.month}/${orderInfo.date.year}',
          style: TextStyle(
            color: Color(0xffb6b2b2),
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class _DeliveryProcesses extends StatefulWidget {
  _DeliveryProcesses({
    @required this.p2pTransaction,
    @required this.processes,
  });
  P2pTransaction p2pTransaction;
  List<Stop> processes;

  @override
  __DeliveryProcessesState createState() => __DeliveryProcessesState();
}

class __DeliveryProcessesState extends State<_DeliveryProcesses> {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 12.5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: themeBloc.state.accentColor,
            indicatorTheme: IndicatorThemeData(
              position: 0,
              size: 20.0,
            ),
            connectorTheme: ConnectorThemeData(
              thickness: 2.5,
            ),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: widget.processes.length,
            contentsBuilder: (_, index) {
              // if (widget.processes[index].statusMap) return null;

              return Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.processes[index].address.address,
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 18.0,
                          ),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(50),
                    ),
                  ],
                ),
              );
            },
            indicatorBuilder: (_, index) {
              // if (false) {
              //   return DotIndicator(
              //     color: Color(0xff66c97f),
              //     child: Icon(
              //       Icons.check,
              //       color: Colors.white,
              //       size: 12.0,
              //     ),
              //   );
              // } else {
              //   return OutlinedDotIndicator(
              //     borderWidth: 2.5,
              //   );
              // }
              return OutlinedDotIndicator(
                borderWidth: 2.5,
              );
            },
            connectorBuilder: (_, index, ___) => SolidLineConnector(
              color: (false) ? Color(0xff66c97f) : null,
            ),
          ),
        ),
      ),
    );
  }
}
