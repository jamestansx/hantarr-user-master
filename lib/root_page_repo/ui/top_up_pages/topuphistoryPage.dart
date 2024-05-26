import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class TopUpHistoryPage extends StatefulWidget {
  bool hideAppBar;
  TopUpHistoryPage({
    this.hideAppBar = false,
  });
  @override
  State<StatefulWidget> createState() => new TopUpHistoryPageState();
}

class TopUpHistoryPageState extends State<TopUpHistoryPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
  }

  void _onRefresh() async {
    // monitor network fetch
    var getTopUpHistoryReq = await hantarrBloc.state.hUser.getTopUpHistory();
    if (getTopUpHistoryReq['success']) {
      setState(() {});
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return BlocBuilder<HantarrBloc, HantarrState>(
        bloc: hantarrBloc,
        builder: (context, state) {
          Size mediaQ = MediaQuery.of(context).size;
          return Scaffold(
            appBar: !widget.hideAppBar
                ? AppBar(
                    iconTheme: IconThemeData(
                      color: Colors.black,
                    ),
                    title: Text(
                      hantarrBloc.state.translation.text("Top-Up History"),
                      style: TextStyle(
                          color: themeBloc.state.primaryColor,
                          fontSize: ScreenUtil().setSp(45)),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  )
                : null,
            body: Container(
              width: mediaQ.width,
              height: mediaQ.height,
              padding: EdgeInsets.all(
                ScreenUtil().setSp(15.0),
              ),
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("pull up load");
                    } else if (mode == LoadStatus.loading) {
                      body = CupertinoActivityIndicator();
                    } else if (mode == LoadStatus.failed) {
                      body = Text("Load Failed!Click retry!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text("release to load more");
                    } else {
                      body = Text("No more Data");
                    }
                    return Container(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: hantarrBloc.state.topUpList.isNotEmpty
                    ? ListView.builder(
                        itemCount: hantarrBloc.state.topUpList.length,
                        itemBuilder: (BuildContext context, int index) {
                          DateTime dt =
                              hantarrBloc.state.topUpList[index].datetime;
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 15, top: 10, right: 15, bottom: 10),
                                  height: ScreenUtil().setHeight(250),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "MYR " +
                                            hantarrBloc
                                                .state.topUpList[index].amount
                                                .toStringAsFixed(2),
                                        style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenUtil().setSp(45),
                                                color: Colors.black)),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setHeight(20),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.date_range,
                                                    size: ScreenUtil().setSp(35,
                                                        allowFontScalingSelf:
                                                            true),
                                                    color: themeBloc
                                                        .state.primaryColor,
                                                  ),
                                                  dt != null
                                                      ? Text(
                                                          "  ${dt.day}/${dt.month}/${dt.year} ${dt.hour}:" +
                                                              (dt.minute
                                                                          .toString()
                                                                          .length ==
                                                                      1
                                                                  ? "0"
                                                                  : "") +
                                                              "${dt.minute.toString()}",
                                                          style: GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              35),
                                                                  color: Colors
                                                                      .grey)),
                                                        )
                                                      : Text(
                                                          "No DateTime record."),
                                                ],
                                              ),
                                              hantarrBloc.state.topUpList[index]
                                                          .imageURL !=
                                                      null
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons
                                                              .lightbulb_outline,
                                                          size: ScreenUtil().setSp(
                                                              35,
                                                              allowFontScalingSelf:
                                                                  true),
                                                          color: themeBloc.state
                                                              .primaryColor,
                                                        ),
                                                        Text(
                                                          hantarrBloc
                                                              .state.translation
                                                              .text(
                                                                  "  Bank-in Slip"),
                                                          style: GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              35),
                                                                  color: Colors
                                                                      .grey)),
                                                        )
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons
                                                              .lightbulb_outline,
                                                          size: ScreenUtil().setSp(
                                                              35,
                                                              allowFontScalingSelf:
                                                                  true),
                                                          color: themeBloc.state
                                                              .primaryColor,
                                                        ),
                                                        Text(
                                                          hantarrBloc
                                                              .state.translation
                                                              .text(
                                                                  "  FPX Online"),
                                                          style: GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              35),
                                                                  color: Colors
                                                                      .grey)),
                                                        )
                                                      ],
                                                    )
                                            ],
                                          ),
                                          hantarrBloc.state.topUpList[index]
                                                      .imageURL !=
                                                  null
                                              ? InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      barrierDismissible: true,
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        // return object of type Dialog
                                                        return PictureDialog(
                                                          imageURL: hantarrBloc
                                                              .state
                                                              .topUpList[index]
                                                              .imageURL
                                                              .replaceAll(
                                                                  "api", ""),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    // color: Colors.red,
                                                    padding: EdgeInsets.only(
                                                        left: ScreenUtil().setSp(
                                                            35,
                                                            allowFontScalingSelf:
                                                                true),
                                                        right: ScreenUtil().setSp(
                                                            35,
                                                            allowFontScalingSelf:
                                                                true)),
                                                    child: Text(
                                                      hantarrBloc
                                                          .state.translation
                                                          .text(
                                                              "View\nBank-in Slip"),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: themeBloc.state
                                                              .primaryColor,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        borderRadius: new BorderRadius.only(
                                            // topLeft:
                                            //     const Radius.circular(40.0),
                                            bottomLeft:
                                                const Radius.circular(20.0),
                                            topRight: Radius.circular(10.0))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: ScreenUtil().setSp(100),
                                                right: ScreenUtil().setSp(100),
                                                top: ScreenUtil().setSp(15),
                                                bottom: ScreenUtil().setSp(15)),
                                            child: hantarrBloc.state.topUpList[index].approve
                                                ? Text(hantarrBloc.state.translation.text("Approved"),
                                                    style: GoogleFonts.montserrat(
                                                        textStyle: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.lightGreenAccent[
                                                                700],
                                                            fontSize: ScreenUtil()
                                                                .setSp(40))))
                                                : Text(hantarrBloc.state.translation.text("Pending"),
                                                    style: GoogleFonts.montserrat(
                                                        textStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.red[700], fontSize: ScreenUtil().setSp(40)))))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        })
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              "assets/topUpWallet.png",
                              width: MediaQuery.of(context).size.width * 0.8,
                            ),
                            Text(
                              hantarrBloc.state.translation
                                  .text("No Top-Up History"),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: ScreenUtil().setSp(60)),
                            )
                          ],
                        ),
                      ),
              ),
            ),
          );
        });
  }
}

// ignore: must_be_immutable
class PictureDialog extends StatefulWidget {
  PictureDialog({this.imageURL});
  String imageURL;
  @override
  State<StatefulWidget> createState() => PictureDialogState();
}

class PictureDialogState extends State<PictureDialog>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.8,
            child: Image.network(
              widget.imageURL,
              width: ScreenUtil().setWidth(1000),
              height: ScreenUtil().setWidth(1000),
            ),
          ),
        ),
      ),
    );
  }
}
