import 'package:bot_toast/bot_toast.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CheckoutWizardRootPage extends StatefulWidget {
  @override
  _CheckoutWizardRootPageState createState() => _CheckoutWizardRootPageState();
}

class _CheckoutWizardRootPageState extends State<CheckoutWizardRootPage> {
  PageController pageController;
  int curPage = 0;
  TextEditingController remarksCon = TextEditingController();

  @override
  void initState() {
    pageController = PageController(
      initialPage: curPage,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        getAddressList();
      } catch (e) {
        print(e.toString());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    remarksCon.dispose();
    pageController.dispose();
  }

  getAddressList() async {
    loadingWidget(context);
    var getAddresReq = await Address().getListAddress();
    Navigator.pop(context);
    List<Address> addressList = getAddresReq['data'];
    if (addressList
        .where((x) =>
            x.address ==
            hantarrBloc.state.foodCart.address.replaceAll("%address%", ""))
        .isEmpty) {
      loadingWidget(context);
      Address address = Address(
        address: hantarrBloc.state.foodCart.address,
        latitude: hantarrBloc.state.selectedLocation.latitude,
        longitude: hantarrBloc.state.selectedLocation.longitude,
        phone: hantarrBloc.state.foodCart.phoneNum,
        email: hantarrBloc.state.hUser.firebaseUser.email,
        receiverName: hantarrBloc.state.foodCart.contactPerson,
      );
      var createAddReq = await address.createAddress(address.toJson());
      Navigator.pop(context);
      if (createAddReq['success']) {
        hantarrBloc.state.foodCart.addressID = createAddReq['data'].id;
        hantarrBloc.add(Refresh());
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () {
                return null;
              },
              child: AlertDialog(
                title: Text("Something went wrong"),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getAddressList();
                    },
                    child: Text("RETRY"),
                  )
                ],
              ),
            );
          },
        );
      }
    } else {
      print("testetet");
      hantarrBloc.state.foodCart.addressID = addressList
          .where((x) =>
              x.address ==
              hantarrBloc.state.foodCart.address.replaceAll("%address%", ""))
          .first
          .id;
      LatLng curLatLong = LatLng(
          addressList
              .where((x) =>
                  x.address ==
                  hantarrBloc.state.foodCart.address
                      .replaceAll("%address%", ""))
              .first
              .latitude,
          addressList
              .where((x) =>
                  x.address ==
                  hantarrBloc.state.foodCart.address
                      .replaceAll("%address%", ""))
              .first
              .longitude);
      hantarrBloc.state.foodCart.latLng = curLatLong;
      hantarrBloc.state.selectedLocation = curLatLong;
    }
  }

  Future<void> doubleCheckCheckout() async {
    loadingWidget(context);
    var getpendingOrderreq = await NewFoodDelivery().getPendingDelivery();
    Navigator.pop(context);
    if (getpendingOrderreq['success']) {
      List<NewFoodDelivery> listPendingOrders =
          getpendingOrderreq['data'] as List<NewFoodDelivery>;
      if (listPendingOrders
          .where((x) =>
              x.newRestaurant.code ==
              hantarrBloc.state.foodCart.newRestaurant.code)
          .isNotEmpty) {
        NewFoodDelivery newFoodDelivery = listPendingOrders
            .where((x) =>
                x.newRestaurant.code ==
                hantarrBloc.state.foodCart.newRestaurant.code)
            .first;
        Navigator.pushNamedAndRemoveUntil(
          context,
          foodDeliveryDetailPage,
          ModalRoute.withName(newMainScreen),
          arguments: newFoodDelivery,
        );
        Future.delayed(Duration(seconds: 1), () {
          hantarrBloc.state.foodCart
              .reInitClass(); // reinit the cart once order successfully made
          hantarrBloc.add(Refresh());
        });

        UniqueKey key = UniqueKey();
        BotToast.showWidget(
            key: key,
            toastBuilder: (_) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                title: Container(
                    child: Image.asset("assets/orderComplete.png",
                        width: ScreenUtil().setWidth(500),
                        height: ScreenUtil().setWidth(400))),
                content: Text(
                  "Your order has been made successfully !",
                  style: themeBloc.state.textTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      BotToast.remove(key);
                    },
                    child: Text(
                      "GOT IT",
                      style: themeBloc.state.textTheme.button.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(30.0),
                        color: themeBloc.state.primaryColor,
                      ),
                    ),
                  )
                ],
              );
            });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              title: Text(
                "${hantarrBloc.state.foodCheckoutErrorMsg}",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(30.0),
                ),
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                    style: themeBloc.state.textTheme.button.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(30.0),
                      color: themeBloc.state.primaryColor,
                    ),
                  ),
                )
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () {
              return null;
            },
            child: AlertDialog(
              title: Text("Something went wrong"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    doubleCheckCheckout();
                  },
                  color: themeBloc.state.primaryColor,
                  child: Text(
                    "Retry",
                    style: themeBloc.state.textTheme.button.copyWith(
                      inherit: true,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;

    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  colors: [Colors.orange, themeBloc.state.primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                ),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey[500],
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                  )
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  hantarrBloc.state.foodCart.wizardPages(
                              remarksCon: remarksCon)[curPage]['title'] !=
                          null
                      ? hantarrBloc.state.foodCart
                          .wizardPages(remarksCon: remarksCon)[curPage]['title']
                      : "",
                  style: themeBloc.state.textTheme.headline6,
                ),
              ),
            ),
          ),
          body: Container(
            width: mediaQ.width,
            height: mediaQ.height,
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    onPageChanged: (int i) {
                      setState(() {
                        curPage = i;
                      });
                    },
                    controller: pageController,
                    children: hantarrBloc.state.foodCart
                        .wizardPages(remarksCon: remarksCon)
                        .map((e) {
                      return e['widget'] as Widget;
                    }).toList(),
                  ),
                ),
                ListTile(
                  leading: curPage != 0
                      ? IconButton(
                          onPressed: () async {
                            pageController.previousPage(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: themeBloc.state.primaryColor,
                          ),
                        )
                      : FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: themeBloc.state.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            "Go Back",
                            style: themeBloc.state.textTheme.button.copyWith(
                              inherit: true,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SmoothPageIndicator(
                        controller: pageController,
                        count: hantarrBloc.state.foodCart
                            .wizardPages(remarksCon: remarksCon)
                            .length,
                        effect: ScrollingDotsEffect(
                          activeStrokeWidth: 2.6,
                          activeDotScale: .4,
                          radius: 8,
                          spacing: 10,
                        ),
                      ),
                    ],
                  ),
                  trailing: hantarrBloc.state.foodCart
                                  .wizardPages(remarksCon: remarksCon)
                                  .length -
                              1 !=
                          curPage
                      ? FlatButton(
                          onPressed: () {
                            if (hantarrBloc.state.foodCart.wizardPages(
                                        remarksCon: remarksCon)[curPage]
                                    ['onPressed'] !=
                                null) {
                              if (hantarrBloc.state.foodCart.wizardPages(
                                      remarksCon: remarksCon)[curPage]
                                  ['onPressed']()) {
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeIn,
                                );
                              }
                            }
                          },
                          color: themeBloc.state.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            "Next",
                            style: themeBloc.state.textTheme.button.copyWith(
                              inherit: true,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : FlatButton(
                          onPressed: (hantarrBloc
                                          .state.foodCheckoutPageLoading ==
                                      false &&
                                  hantarrBloc
                                      .state.foodCheckoutErrorMsg.isEmpty)
                              ? () async {
                                  FocusScope.of(context).unfocus();
                                  await getAddressList();
                                  loadingWidget(context);
                                  var getCurrentTimeReq = await hantarrBloc
                                      .state.foodCart
                                      .getCurrentTime();
                                  Navigator.pop(context);
                                  if (getCurrentTimeReq['success']) {
                                    if (hantarrBloc
                                        .state.foodCart.menuItems.isNotEmpty) {
                                      var validateAllReq = await hantarrBloc
                                          .state.foodCart
                                          .validateAll();
                                      if (validateAllReq['success']) {
                                        var confirm = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return confirmationDialog(context,
                                                "Confirm Checkout?", "Yes");
                                          },
                                        );
                                        if (confirm == "OK") {
                                          loadingWidget(context);
                                          var createReq = await hantarrBloc
                                              .state.foodCart
                                              .createNewFoodOrder(
                                                  remarks: remarksCon.text);
                                          Navigator.pop(context);
                                          if (createReq['success']) {
                                            NewFoodDelivery newFoodDelivery =
                                                createReq['data']
                                                    as NewFoodDelivery;
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              foodDeliveryDetailPage,
                                              ModalRoute.withName(
                                                  newMainScreen),
                                              arguments: newFoodDelivery,
                                            );
                                            Future.delayed(Duration(seconds: 1),
                                                () {
                                              hantarrBloc.state.foodCart
                                                  .reInitClass(); // reinit the cart once order successfully made
                                              hantarrBloc.add(Refresh());
                                            });
                                            // showDialog();
                                            UniqueKey key = UniqueKey();
                                            BotToast.showWidget(
                                                key: key,
                                                toastBuilder: (_) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0))),
                                                    title: Container(
                                                        child: Image.asset(
                                                            "assets/orderComplete.png",
                                                            width: ScreenUtil()
                                                                .setWidth(500),
                                                            height: ScreenUtil()
                                                                .setWidth(
                                                                    400))),
                                                    content: Text(
                                                      "Your order has been made successfully !",
                                                      style: themeBloc.state
                                                          .textTheme.headline6
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: ScreenUtil()
                                                            .setSp(30.0),
                                                      ),
                                                    ),
                                                    actions: [
                                                      FlatButton(
                                                        onPressed: () {
                                                          BotToast.remove(key);
                                                        },
                                                        child: Text(
                                                          "GOT IT",
                                                          style: themeBloc.state
                                                              .textTheme.button
                                                              .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(
                                                                        30.0),
                                                            color: themeBloc
                                                                .state
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                });
                                          } else {
                                            hantarrBloc.state
                                                    .foodCheckoutErrorMsg =
                                                "${createReq['reason']}";
                                            hantarrBloc.add(Refresh());
                                            doubleCheckCheckout();
                                          }
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10.0))),
                                              title: Text(
                                                  "${validateAllReq['reason']}"),
                                              actions: [
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "OK",
                                                    style: themeBloc
                                                        .state.textTheme.button
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: ScreenUtil()
                                                          .setSp(32),
                                                      color: themeBloc
                                                          .state.primaryColor,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                                "Please add items to cart."),
                                            actions: [
                                              MaterialButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "OK",
                                                  style: themeBloc
                                                      .state.textTheme.button
                                                      .copyWith(
                                                    inherit: true,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                      Navigator.popUntil(
                                          context,
                                          ModalRoute.withName(
                                              newMenuItemListPage));
                                    }
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              "${getCurrentTimeReq['reason']}"),
                                          actions: [
                                            MaterialButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "OK",
                                                style: themeBloc
                                                    .state.textTheme.button
                                                    .copyWith(
                                                  inherit: true,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              : () async {
                                  await hantarrBloc.state.foodCart
                                      .getDistance();
                                },
                          color: themeBloc.state.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            "Checkout",
                            style: themeBloc.state.textTheme.button.copyWith(
                              inherit: true,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
