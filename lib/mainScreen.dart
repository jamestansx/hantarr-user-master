import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hantarr/foodService/foodTracking.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/route_setting/route_settings.dart';

// ignore: must_be_immutable
class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.drawerController}) : super(key: key);
  ZoomDrawerController drawerController;
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Delivery> pendingDeliveries = [];

  @override
  void initState() {
    super.initState();
  }

  checkPendingOrder() {
    pendingDeliveries = [];
    pendingDeliveries = hantarrBloc.state.allDeliveries
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
  }

  getcurrentStatus() {
    if (pendingDeliveries.last.deliveryStatus.pickUp) {
      return "Rider has picked up your order";
    } else {
      return "Rider on the way to pick up";
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      checkPendingOrder();
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              if (widget.drawerController.isOpen()) {
                widget.drawerController.close();
              } else {
                widget.drawerController.open();
              }
            },
          ),
          title: Container(
            width: ScreenUtil().setSp(210),
            child: Image.asset("assets/logoword.png"),
          ),
        ),
        body: GestureDetector(
            onHorizontalDragEnd: (value) {
              double dragValue = value.velocity.pixelsPerSecond.dx;
              if (dragValue != 0.0) {
                if (widget.drawerController.isOpen()) {
                  if (dragValue < 0) {
                    widget.drawerController.close();
                  }
                } else {
                  if (dragValue > 0) {
                    widget.drawerController.open();
                  }
                }
              }
            },
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    hantarrBloc.state.user.uuid != null
                        ? Container(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setSp(50),
                                top: ScreenUtil().setSp(50)),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: hantarrBloc.state.translation
                                        .text("Hello, "),
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black,
                                            fontSize: ScreenUtil().setSp(65)))),
                                TextSpan(
                                    text: "${hantarrBloc.state.user.name} !",
                                    style: GoogleFonts.b612(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: themeBloc.state.primaryColor,
                                            fontSize: ScreenUtil().setSp(70)))),
                              ]),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setSp(50),
                                top: ScreenUtil().setSp(25)),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: hantarrBloc.state.translation
                                        .text("Welcome to\n"),
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300,
                                            fontSize: ScreenUtil().setSp(65)))),
                                TextSpan(
                                    text: "Hantarr Delivery",
                                    style: GoogleFonts.aBeeZee(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: themeBloc.state.primaryColor,
                                            fontSize: ScreenUtil().setSp(90)))),
                              ]),
                            ),
                          ),
                    SizedBox(
                      height: ScreenUtil().setHeight(50),
                    ),
                    hantarrBloc.state.user.uuid != null
                        ? Container(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setSp(50),
                              right: ScreenUtil().setSp(50),
                            ),
                            child: Card(
                                elevation: 10,
                                shadowColor: Colors.grey[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setSp(50),
                                        bottom: ScreenUtil().setSp(50),
                                        left: ScreenUtil().setSp(30)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Hantarr Credit",
                                              style: GoogleFonts.montserrat(
                                                  color: Colors.grey,
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  hantarrBloc.state.user
                                                              .credit !=
                                                          null
                                                      ? "RM ${hantarrBloc.state.user.credit.toStringAsFixed(2)}"
                                                      : "RM 0.00",
                                                  style: GoogleFonts.montserrat(
                                                      color: Colors.black,
                                                      fontSize: ScreenUtil()
                                                          .setSp(60),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.refresh),
                                                  onPressed: () async {
                                                    loadingWidget(context);
                                                    await hantarrBloc.state.user
                                                        .getLatestBalance();
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  themeBloc.state.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  bottomLeft:
                                                      Radius.circular(7))),
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setSp(30),
                                              bottom: ScreenUtil().setSp(30),
                                              left: ScreenUtil().setSp(40),
                                              right: ScreenUtil().setSp(30)),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_back_ios,
                                                size: ScreenUtil().setSp(45,
                                                    allowFontScalingSelf: true),
                                                color: Colors.white,
                                              ),
                                              Icon(
                                                LineIcons.qrcode,
                                                size: ScreenUtil().setSp(65,
                                                    allowFontScalingSelf: true),
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ))))
                        : Container(),
                    SizedBox(
                      height: ScreenUtil().setHeight(50),
                    ),
                    pendingDeliveries.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setSp(50),
                              right: ScreenUtil().setSp(50),
                            ),
                            child: Card(
                              elevation: 5,
                              shadowColor: themeBloc.state.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                      color: themeBloc.state.primaryColor,
                                      width: 2)),
                              child: InkWell(
                                onTap: () async {
                                  loadingWidget(context);
                                  await Delivery().getPendingOrder();
                                  Future.delayed(Duration(seconds: 1), () {
                                    Navigator.pop(context);
                                    if (pendingDeliveries.isNotEmpty) {
                                      hantarrBloc.state.user.currentDelivery =
                                          pendingDeliveries.last;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FoodTracking()));
                                    } else {
                                      BotToast.showText(
                                          text: "No pending order",
                                          duration: Duration(seconds: 5));
                                    }
                                  });
                                },
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setSp(50),
                                        bottom: ScreenUtil().setSp(50),
                                        left: ScreenUtil().setSp(30)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: ScreenUtil().setWidth(600),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${hantarrBloc.state.translation.text("Latest Order")} #${pendingDeliveries.last.id}",
                                                style: GoogleFonts.montserrat(
                                                    color: themeBloc
                                                        .state.primaryColor,
                                                    fontSize:
                                                        ScreenUtil().setSp(40),
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                getcurrentStatus(),
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.black87,
                                                    fontSize:
                                                        ScreenUtil().setSp(40),
                                                    fontWeight:
                                                        FontWeight.w600),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setHeight(30),
                                              ),
                                              Text(
                                                "ETA ${pendingDeliveries.last.eta} Minute(s)",
                                                style: GoogleFonts.montserrat(
                                                    color: themeBloc
                                                        .state.primaryColor,
                                                    fontSize:
                                                        ScreenUtil().setSp(50),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: themeBloc
                                                      .state.primaryColor,
                                                  width: 2),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  bottomLeft:
                                                      Radius.circular(7))),
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setSp(30),
                                              bottom: ScreenUtil().setSp(30),
                                              left: ScreenUtil().setSp(40),
                                              right: ScreenUtil().setSp(30)),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.search,
                                                size: ScreenUtil().setSp(45,
                                                    allowFontScalingSelf: true),
                                                color: themeBloc
                                                    .state.primaryColor,
                                              ),
                                              Container(
                                                width:
                                                    ScreenUtil().setWidth(170),
                                                child: Text(
                                                  hantarrBloc.state.translation
                                                      .text(" Details"),
                                                  style: TextStyle(
                                                      color: themeBloc
                                                          .state.primaryColor,
                                                      fontSize: ScreenUtil()
                                                          .setSp(35),
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ))
                        : Container(),
                    SizedBox(
                      height: ScreenUtil().setHeight(50),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(50),
                      ),
                      child: Text(
                        hantarrBloc.state.translation.text("Services"),
                        style: GoogleFonts.montserrat(
                            fontSize: ScreenUtil().setSp(50),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(50),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  loadingWidget(context);
                                  await hantarrBloc.state.user.setLocation();
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RestaurantPage()));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      child: AspectRatio(
                                        aspectRatio: 1.5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            color: Colors.yellow[800],
                                          ),
                                          padding: EdgeInsets.all(
                                              ScreenUtil().setSp(20)),
                                          width: ScreenUtil().setSp(200),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: Image.asset(
                                                "assets/foodIcon.png"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        hantarrBloc.state.translation
                                            .text("Foods"),
                                        style: GoogleFonts.aBeeZee(
                                            textStyle: TextStyle(
                                                color: themeBloc
                                                    .state.primaryColor,
                                                fontSize:
                                                    ScreenUtil().setSp(40),
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  loadingWidget(context);
                                  await hantarrBloc.state.user.setLocation();
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RestaurantPage(
                                                isPreorder: true,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      child: AspectRatio(
                                        aspectRatio: 1.5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            color: Colors.yellow[800],
                                          ),
                                          padding: EdgeInsets.all(
                                              ScreenUtil().setSp(20)),
                                          width: ScreenUtil().setSp(200),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: SvgPicture.asset(
                                              "assets/preorder_img.svg",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        hantarrBloc.state.translation
                                            .text("Preorder"),
                                        style: GoogleFonts.aBeeZee(
                                            textStyle: TextStyle(
                                                color: themeBloc
                                                    .state.primaryColor,
                                                fontSize:
                                                    ScreenUtil().setSp(40),
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenUtil().setHeight(15.0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () async {
                                  Navigator.pushNamed(context, p2pHomepage);
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      child: AspectRatio(
                                        aspectRatio: 1.5,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                color: Colors.yellow[800],
                                              ),
                                              padding: EdgeInsets.all(
                                                  ScreenUtil().setSp(20)),
                                              width: ScreenUtil().setSp(200),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Icon(
                                                  LineIcons.question_circle,
                                                  size: ScreenUtil().setSp(200),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: new FractionalOffset(
                                                  0.5, 0.5),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: SvgPicture.asset(
                                                  "assets/p2pDelivery.svg",
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        hantarrBloc.state.translation
                                            .text("Retails"),
                                        style: GoogleFonts.aBeeZee(
                                            textStyle: TextStyle(
                                                color: themeBloc
                                                    .state.primaryColor,
                                                fontSize:
                                                    ScreenUtil().setSp(40),
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                          // SizedBox(height: ScreenUtil().setHeight(25.0)),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [

                          //   ],
                          // ),
                        ],
                      ),
                    )
                  ])),
                ],
              ),
            )),
      );
    });
  }
}
