import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/root_page_repo/ui/address_page/address_widget.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewNewAddressPage extends StatefulWidget {
  @override
  _NewAddressPageState createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewNewAddressPage>
    with SingleTickerProviderStateMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController _filter = new TextEditingController();
  List<Address> addressList = [];
  FocusNode focusNode = FocusNode();
  TabController tabController;

  @override
  void initState() {
    _onRefresh();
    tabController = TabController(
      initialIndex: 0,
      length: Address.initClass().getAllTitle().length,
      vsync: this,
    );

    addressList = List.from(hantarrBloc.state.addressList);
    _filter.addListener(() {
      if (_filter.text.isNotEmpty) {
        addressList = List.from(hantarrBloc.state.addressList
            .where((x) => x
                .toJson()
                .toString()
                .toLowerCase()
                .contains(_filter.text.toLowerCase()))
            .toList());
      } else {
        addressList = List.from(hantarrBloc.state.addressList);
      }
      setState(() {});
    });
    super.initState();
  }

  void _onRefresh() async {
    setState(() {
      addressList = [];
    });
    var getAddresesReq = await AddressInterface().getListAddress();
    if (getAddresesReq['success']) {
      addressList = getAddresesReq['data'];
      print(addressList.length);
      _refreshController.refreshCompleted();
      setState(() {});
    } else {
      _refreshController.refreshFailed();
      BotToast.showText(text: "${getAddresesReq['reason']}");
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
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Navigator.pushNamed(context, searchPlacePage);
              Navigator.pushNamed(
                context,
                manageAddressPage,
              );
//               gL.LocationResult _pickedLocation;
//               gL.LocationResult result = await gL.showLocationPicker(
//                 context, "AIzaSyCP6DCTU7pUCg-ELswj1bxe1jABsCntkHo",
//                 initialCenter: LatLng(2.8019351, 101.3959081),
//                 automaticallyAnimateToCurrentLocation: true,
// //                      mapStylePath: 'assets/mapStyle.json',
//                 myLocationButtonEnabled: true,
//                 requiredGPS: true,
//                 layersButtonEnabled: true,
//                 countries: ["MY"],
//                 // countries: ['AE', 'NG']
//                 resultCardAlignment: Alignment.bottomCenter,
//                 desiredAccuracy: gL.LocationAccuracy.best,
//               );
//               print("result = $result");
//               setState(() => _pickedLocation = result);
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          appBar: new AppBar(
            title: new Text(
              "Address Book",
              style: themeBloc.state.textTheme.headline6.copyWith(
                color: Colors.white,
              ),
            ),
            leading: new IconButton(
              icon: Icon(LineIcons.close, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            bottom: TabBar(
                controller: tabController,
                labelStyle: TextStyle(fontWeight: FontWeight.w700),
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.black,
                isScrollable: true,
                indicator: MD2Indicator(
                  indicatorSize: MD2IndicatorSize.normal,
                  indicatorHeight: 3,
                  indicatorColor: Color(0xff1967d2),
                ),
                tabs: Address.initClass()
                    .getAllTitle()
                    .map(
                      (e) => Tab(
                        text: e,
                      ),
                    )
                    .toList()),
          ),
          body: Container(
            width: mediaQ.width,
            height: mediaQ.height,
            child: Column(
              children: [
                Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          elevation: 5,
                          child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.width * 0.08,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: TextFormField(
                                  focusNode: focusNode,
                                  controller: _filter,
                                  decoration: new InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.fromLTRB(
                                        0.0, 0.0, 0.0, 12.0),
                                    hintText: 'Search address by name ',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                    ),
                                    suffixIcon: _filter.text.isNotEmpty
                                        ? InkWell(
                                            onTap: () {
                                              _filter.clear();
                                              focusNode.unfocus();
                                            },
                                            child: Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: Address.initClass().getAllTitle().map(
                      (e) {
                        List<Address> thisCat = [];
                        if (e.toLowerCase() == "all") {
                          thisCat = addressList;
                        } else if (e.toLowerCase() == "home") {
                          thisCat = addressList
                              .where((e) => e.title.toLowerCase() == "home")
                              .toList();
                        } else if (e.toLowerCase() == "office") {
                          thisCat = addressList
                              .where((e) => e.title.toLowerCase() == "office")
                              .toList();
                        } else {
                          thisCat = addressList
                              .where((e) =>
                                  e.title.toLowerCase() != "home" &&
                                  e.title.toLowerCase() != "office")
                              .toList();
                        }
                        return SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: false,
                          header: WaterDropHeader(
                            waterDropColor: _refreshController.isLoading
                                ? Colors.transparent
                                : themeBloc.state.primaryColor,
                            // circleColor: refreshing ? Colors.transparent : Colors.white,
                            // bezierColor: refreshing ? Colors.transparent : themeBloc.state.primaryColor,
                          ),
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          child: thisCat.isNotEmpty
                              ? ListView.builder(
                                  padding:
                                      EdgeInsets.all(ScreenUtil().setSp(10.0)),
                                  shrinkWrap: true,
                                  itemCount: thisCat.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return AddressWidget(
                                      address: thisCat[index],
                                      clickable: true,
                                      refresh: _onRefresh,
                                    );
                                  })
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: ScreenUtil().setWidth(700),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: SvgPicture.asset(
                                            "assets/empty_res.svg",
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setHeight(20),
                                      ),
                                      FlatButton(
                                        onPressed: () async {},
                                        color: themeBloc.state.accentColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        child: Text(
                                          "Create New Address",
                                          style: themeBloc
                                              .state.textTheme.headline6
                                              .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      },
                    ).toList(),
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
