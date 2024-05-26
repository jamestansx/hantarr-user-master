import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/p2p_repo/p2p_modules/delivery_message_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:timelines/timelines.dart';

const kTileHeight = 50.0;

// ignore: must_be_immutable
class P2PTrackingTimeLine extends StatefulWidget {
  P2pTransaction p2pTransaction;
  P2PTrackingTimeLine({
    @required this.p2pTransaction,
  });

  @override
  _P2PTrackingTimeLineState createState() => _P2PTrackingTimeLineState();
}

class _P2PTrackingTimeLineState extends State<P2PTrackingTimeLine> {
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
                    deliveryMessages: data.deliveryMessages,
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
          'Delivery Tracking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Text(
          orderInfo.createdAt != null
              ? "${orderInfo.createdAt.toString().substring(0, 16)}"
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
    @required this.deliveryMessages,
  });
  P2pTransaction p2pTransaction;
  List<DeliveryMessage> deliveryMessages;

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
            itemCount: widget.deliveryMessages.length,
            contentsBuilder: (_, index) {
              // if (widget.processes[index].statusMap) return null;

              return Container(
                padding: EdgeInsets.only(left: 10.0),
                // color: Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.deliveryMessages[index].message,
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 18.0,
                          ),
                    ),
                    Text(
                      widget.deliveryMessages[index].datetime != null
                          ? "${widget.deliveryMessages[index].datetime.toString().substring(0, 16)} "
                          : " - : ",
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
