import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2p_status_code_module.dart';
import 'package:hantarr/p2p_repo/pages/history/p2p_tile_widget.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class P2PsHistoryPage extends StatefulWidget {
  @override
  _P2PsHistoryPageState createState() => _P2PsHistoryPageState();
}

class _P2PsHistoryPageState extends State<P2PsHistoryPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  ScrollController sc = ScrollController();
  bool _showAppbar = false;
  bool isScrollingDown = false;

  DateTime startDate, endDate;

  @override
  void initState() {
    endDate = DateTime.tryParse(DateTime.now().toString().substring(0, 10));
    startDate = endDate.subtract(Duration(days: 15));

    Future.delayed(Duration(microseconds: 200), () {
      loadAllCodeStatus();
    });
    sc.addListener(() {
      if (sc.position.userScrollDirection == ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = true;
          setState(() {});
        }
      }

      if (sc.position.userScrollDirection == ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = false;
          setState(() {});
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    sc.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void loadAllCodeStatus() async {
    var getAllCodeStatusReq =
        await P2PStatusCode.initClass().getListP2PStatus();
    if (getAllCodeStatusReq['success']) {
      setState(() {});
    } else {
      debugPrint("load code status failed. try again");

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Something went wrong"),
            content: Text("Please try again."),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  loadAllCodeStatus();
                },
                child: Text("OK"),
              )
            ],
          );
        },
      );
    }
  }

  void _onRefresh() async {
    var getListReq = await P2pTransaction.initClass().getListP2P({
      "uuid": hantarrBloc.state.hUser.firebaseUser.uid,
      "start_date": startDate.toString().substring(0, 10),
      "end_date": endDate.toString().substring(0, 10),
    });
    if (getListReq['success']) {
      _refreshController.refreshCompleted();
    } else {
      BotToast.showText(text: "${getListReq['reason']}");
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

  List<Widget> bodyContent(Size mediaQ) {
    List<Widget> widgetlist = [];
    widgetlist.add(
      AnimatedOpacity(
        opacity: _showAppbar ? 0.0 : 1.0,
        duration: Duration(
          milliseconds: 300,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: IconButton(
            onPressed: null,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.transparent,
            ),
          ),
          title: Text(
            "P2P History",
            style: themeBloc.state.textTheme.headline6.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: ScreenUtil().setSp(55),
            ),
          ),
        ),
      ),
    );
    // hantarrBloc.state.p2pHistoryList.map(
    //   (e) {
    //     widgetlist.add(
    //       P2PTileWidget(
    //         p2pTransaction: e,
    //       ),
    //     );
    //   },
    // ).toList();
    Map<String, List<P2pTransaction>> grouppedByDate =
        P2pTransaction.initClass()
            .grouppedByDate(hantarrBloc.state.p2pHistoryList);
    if (grouppedByDate.keys.toList().isEmpty) {
      widgetlist.add(Container(
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
                "No Pending P2P Order",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  fontSize: ScreenUtil().setSp(45.0),
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ));
    } else {
      grouppedByDate.forEach(
        (key, value) {
          widgetlist.add(
            Container(
              width: mediaQ.width,
              color: Colors.grey[100],
              padding: EdgeInsets.all(ScreenUtil().setSp(20)),
              child: Text(
                "${key.toUpperCase()}",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(50.0),
                ),
              ),
            ),
          );
          for (P2pTransaction p2pTransaction in value) {
            widgetlist.add(
              P2PTileWidget(
                p2pTransaction: p2pTransaction,
              ),
            );
            widgetlist.add(Divider(
              color: value.last != p2pTransaction
                  ? Colors.grey
                  : Colors.transparent,
            ));
          }
        },
      );
    }

    widgetlist.add(Container(
      height: mediaQ.height * .1,
      // color: Colors.red,
    ));
    return widgetlist;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight * 2),
            child: Container(
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  colors: [Colors.orange, themeBloc.state.primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                ),
                boxShadow: _showAppbar
                    ? [
                        new BoxShadow(
                          color: Colors.grey[500],
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                        )
                      ]
                    : [],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                title: Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(50)),
                  child: Image.asset(
                    "assets/logowordWhite.png",
                    height: kToolbarHeight - 10,
                    width: mediaQ.width,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {},
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Container(
                    // color: Colors.white,
                    child: ListTile(
                      onTap: () async {
                        DateTimeRange daterange = await showDateRangePicker(
                          context: context,
                          firstDate:
                              DateTime.now().subtract(Duration(days: 90)),
                          lastDate: DateTime.now(),
                          initialDateRange: DateTimeRange(
                            start: startDate,
                            end: endDate,
                          ),
                          initialEntryMode: DatePickerEntryMode.calendar,
                          currentDate: startDate,
                        );
                        if (daterange != null) {
                          print(daterange);
                          setState(() {
                            startDate = daterange.start;
                            endDate = daterange.end;
                          });
                          _refreshController.requestRefresh();
                        }
                      },
                      leading: Icon(Icons.ac_unit, color: Colors.transparent),
                      title: Row(
                        children: [
                          Text(
                            "${startDate.day} ${months[startDate.month - 1]} ${startDate.year.toString().substring(2)}",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: ScreenUtil().setSp(40.0),
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(25),
                          ),
                          Text(
                            " - ",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: ScreenUtil().setSp(40.0),
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(25),
                          ),
                          Text(
                            "${endDate.day} ${months[endDate.month - 1]} ${endDate.year.toString().substring(2)}",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: ScreenUtil().setSp(40.0),
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(10),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: hantarrBloc.state.p2pStatusCodes.isNotEmpty
              ? Container(
                  width: mediaQ.width,
                  height: mediaQ.height,
                  child: SmartRefresher(
                    scrollController: sc,
                    enablePullDown: true,
                    enablePullUp: false,
                    // header: WaterDropHeader(
                    //   waterDropColor: refreshing ? Colors.transparent : themeBloc.state.primaryColor,
                    // ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: bodyContent(mediaQ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SpinKitDoubleBounce(
                        color: themeBloc.state.primaryColor,
                        size: ScreenUtil().setSp(55.0),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(15),
                      ),
                      Text(
                        "Loading...",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          fontSize: ScreenUtil().setSp(55.0),
                          color: themeBloc.state.primaryColor,
                          fontWeight: FontWeight.bold,
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
