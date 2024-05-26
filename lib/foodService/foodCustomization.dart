import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class FoodCustomization extends StatefulWidget {
  MenuItem currentMenuItem;
  FoodCustomization({Key key, this.currentMenuItem}) : super(key: key);

  @override
  FoodCustomizationState createState() => FoodCustomizationState();
}

class FoodCustomizationState extends State<FoodCustomization> {
  List<String> cusCategories = [];
  List<Widget> customizationWidgets = [];
  // List<Customization> widget.currentMenuItem.selectedCustomizations = [];
  int quantity = 1;
  List<Map> cusLimitMap = [];

  @override
  void initState() {
    widget.currentMenuItem.customizations
        .forEach((x) => cusCategories.add(x.category.trim()));
    cusCategories = cusCategories.toSet().toList();
    // generateCustomizationWidget();
    super.initState();
  }

  generateCustomizationWidget() {
    customizationWidgets.clear();
    if (cusCategories.isNotEmpty) {
      for (String cat in cusCategories) {
        List<Customization> filteredCus = widget.currentMenuItem.customizations
            .where((x) => x.category == cat)
            .toList();
        filteredCus.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
        if (filteredCus.first.minLimit != null) {
          cusLimitMap
              .add({filteredCus.first.category: filteredCus.first.minLimit});
        }
        // for title of each customization category //
        customizationWidgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            filteredCus.first.category == "empty"
                ? Container(
                    decoration: new BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: new BorderRadius.only(
                            bottomRight: const Radius.circular(40.0),
                            topRight: const Radius.circular(40.0))),
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Others",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil().setSp(45)),
                        ),
                        filteredCus.first.limit != 0
                            ? Text(
                                " *Required*",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScreenUtil().setSp(32)),
                              )
                            : Container()
                      ],
                    ),
                  )
                : Container(
                    decoration: new BoxDecoration(
                        color: themeBloc.state.primaryColor.withOpacity(0.4),
                        borderRadius: new BorderRadius.only(
                            bottomRight: const Radius.circular(40.0),
                            topRight: const Radius.circular(40.0))),
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Row(
                      children: <Widget>[
                        Text(
                          cat,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil().setSp(45)),
                        ),
                        filteredCus.first.minLimit != 0
                            ? Text(
                                " *Required*",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScreenUtil().setSp(32)),
                              )
                            : Container()
                      ],
                    ),
                  ),
            filteredCus.first.minLimit == 0
                ? Container(
                    decoration: new BoxDecoration(
                        color: Colors.green[200].withOpacity(0.6),
                        borderRadius:
                            new BorderRadius.all(const Radius.circular(40.0))),
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Text(
                      "OPTIONAL",
                      style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(35)),
                    ),
                  )
                : Container(
                    decoration: new BoxDecoration(
                        color: Colors.green[200].withOpacity(0.6),
                        borderRadius:
                            new BorderRadius.all(const Radius.circular(40.0))),
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                    child: Text(
                      "CHOOSE UP TO " + filteredCus.first.limit.toString(),
                      style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(35)),
                    ),
                  ),
          ],
        ));
        for (Customization cus in filteredCus) {
          double price = Restaurant().sizeAddOnPriceFromCustomization(
              cus, widget.currentMenuItem, DateTime.now(), false);
          if (cus.itemLimit != 0 && (cus.itemLimit != 1 && cus.limit != 1)) {
            if (cus.qty == null ||
                widget.currentMenuItem.selectedCustomizations.isEmpty) {
              cus.qty = 0;
            }

            customizationWidgets.add(Container(
              padding: EdgeInsets.only(left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      cus.name +
                          ((price > 0)
                              ? (" (+RM ${price.toStringAsFixed(2)})")
                              : ""),
                      maxLines: 3,
                      style: TextStyle(fontSize: ScreenUtil().setSp(35)),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          if (widget.currentMenuItem.selectedCustomizations
                              .where((x) => x.name == cus.name)
                              .toList()
                              .isNotEmpty) {
                            if (widget.currentMenuItem.selectedCustomizations
                                    .where((x) => x.name == cus.name)
                                    .toList()
                                    .first
                                    .qty !=
                                0) {
                              setState(() {
                                // cus.qty = cus.qty - 1;
                                widget.currentMenuItem.selectedCustomizations
                                    .where((x) => x.name == cus.name)
                                    .toList()
                                    .first
                                    .qty -= 1;
                              });
                              if (widget.currentMenuItem.selectedCustomizations
                                      .where((x) => x.name == cus.name)
                                      .toList()
                                      .first
                                      .qty ==
                                  0) {
                                widget.currentMenuItem.selectedCustomizations
                                    .removeWhere((x) => x.name == cus.name);
                              }
                            } else {
                              widget.currentMenuItem.selectedCustomizations
                                  .removeWhere((x) => x.name == cus.name);
                            }
                          }
                        },
                        child: Container(
                          decoration: new BoxDecoration(
                              border: Border.all(color: themeBloc.state.primaryColor),
                              color: Colors.white,
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(100.0))),
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.remove,
                            color: themeBloc.state.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          widget.currentMenuItem.selectedCustomizations
                                  .where((x) => x.name == cus.name)
                                  .toList()
                                  .isEmpty
                              ? cus.qty.toString() + "/${cus.itemLimit}"
                              : widget.currentMenuItem.selectedCustomizations
                                      .where((x) => x.name == cus.name)
                                      .toList()
                                      .first
                                      .qty
                                      .toString() +
                                  "/${cus.itemLimit}",
                          maxLines: 1,
                          style: TextStyle(fontSize: ScreenUtil().setSp(35)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (widget.currentMenuItem.selectedCustomizations
                              .where((x) => x.name == cus.name)
                              .toList()
                              .isEmpty) {
                            if (widget.currentMenuItem.selectedCustomizations
                                    .where((x) => x.category == cus.category)
                                    .length <
                                cus.limit) {
                              Customization incomingCus = new Customization(
                                  name: cus.name,
                                  price: cus.price,
                                  category: cus.category,
                                  limit: cus.limit,
                                  itemLimit: cus.itemLimit,
                                  qty: 0,
                                  minItemLimit: cus.minItemLimit,
                                  minLimit: cus.minLimit);
                              widget.currentMenuItem.selectedCustomizations
                                  .add(incomingCus);
                            }
                          }

                          if (widget.currentMenuItem.selectedCustomizations
                              .where((x) => x.name == cus.name)
                              .toList()
                              .isNotEmpty) {
                            if (widget.currentMenuItem.selectedCustomizations
                                    .where((x) => x.name == cus.name)
                                    .toList()
                                    .first
                                    .qty ==
                                null) {
                              widget.currentMenuItem.selectedCustomizations
                                  .where((x) => x.name == cus.name)
                                  .toList()
                                  .first
                                  .qty = 0;
                            }
                            if (widget.currentMenuItem.selectedCustomizations
                                    .where((x) => x.name == cus.name)
                                    .toList()
                                    .first
                                    .qty <
                                widget.currentMenuItem.selectedCustomizations
                                    .where((x) => x.name == cus.name)
                                    .toList()
                                    .first
                                    .itemLimit) {
                              setState(() {
                                widget.currentMenuItem.selectedCustomizations
                                    .where((x) => x.name == cus.name)
                                    .toList()
                                    .first
                                    .qty += 1;
                                // cus.qty += 1;
                              });
                            }
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(2),
                          decoration: new BoxDecoration(
                              color: themeBloc.state.primaryColor,
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(100.0))),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ));
          } else {
            customizationWidgets.add(CheckboxListTile(
              activeColor: themeBloc.state.primaryColor,
              checkColor: Colors.white,
              onChanged: (bool value) {
                if (value == true) {
                  if (cus.limit !=
                      widget.currentMenuItem.selectedCustomizations
                          .where((x) => x.category == cus.category)
                          .toList()
                          .length) {
                    cus.qty = 1;
                    widget.currentMenuItem.selectedCustomizations.add(cus);
                    // widget.membershipBloc.add(Refresh());
                    setState(() {});
                  } else if (cus.limit == 0) {
                    cus.qty = 1;
                    widget.currentMenuItem.selectedCustomizations.add(cus);
                    setState(() {});
                    // widget.membershipBloc.add(Refresh());
                  }
                } else {
                  cus.qty = 0;
                  widget.currentMenuItem.selectedCustomizations
                      .removeWhere((x) => x.name == cus.name);
                  setState(() {});
                  // widget.membershipBloc.add(Refresh());
                }
              },
              title: Text(
                cus.name +
                    ((price > 0)
                        ? (" (" +
                            (filteredCus.first.category.toLowerCase() == "size"
                                ? ""
                                : "+") +
                            "RM ${price.toStringAsFixed(2)})")
                        : ""),
                style: TextStyle(fontSize: ScreenUtil().setSp(35)),
              ),
              value: widget.currentMenuItem.selectedCustomizations
                  .where((x) => x.name == cus.name)
                  .toList()
                  .isNotEmpty,
            ));
          }
        }
      }
    }
  }

  bool customizationLimitChecking() {
    bool fulfill;
    if (cusLimitMap.isNotEmpty) {
      for (Map map in cusLimitMap) {
        int selectedQty = 0;
        List<Customization> comparedCuslist = widget
            .currentMenuItem.selectedCustomizations
            .where((x) => x.category == map.keys.first)
            .toList();
        for (Customization cus in comparedCuslist) {
          selectedQty = cus.qty + selectedQty;
        }
        if (map[map.keys.first] <= selectedQty) {
          if (fulfill != false) {
            fulfill = true;
          }
        } else {
          fulfill = false;
        }
      }
    } else {
      fulfill = true;
    }

    return fulfill;
    // }
  }

  @override
  Widget build(BuildContext context) {
    generateCustomizationWidget();
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Customization",
            style: TextStyle(
              color: themeBloc.state.primaryColor,
              fontSize: ScreenUtil().setSp(45),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              LineIcons.close,
              color: themeBloc.state.primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setSp(40), right: ScreenUtil().setSp(40)),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: customizationWidgets,
                ),
                Container(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setSp(40),
                      bottom: ScreenUtil().setSp(40)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                  }
                                });
                              },
                              child: Container(
                                decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(50.0)),
                                    border: Border.all(color: themeBloc.state.primaryColor)),
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.remove,
                                  color: themeBloc.state.primaryColor,
                                  size: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              child: Text(
                                quantity.toString(),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              child: Container(
                                decoration: new BoxDecoration(
                                    color: themeBloc.state.primaryColor,
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(50.0))),
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: RaisedButton(
                            color: themeBloc.state.primaryColor,
                            onPressed: customizationLimitChecking()
                                ? () {
                                    List<MenuItem> allMenuItems = [];
                                    int i = 0;
                                    widget.currentMenuItem.viewQty = quantity;
                                    while (i < quantity) {
                                      allMenuItems.add(widget.currentMenuItem);
                                      i++;
                                    }
                                    if (hantarrBloc.state.user.restaurantCart
                                        .menuItems.isNotEmpty) {
                                      if (hantarrBloc.state.user.restaurantCart
                                              .menuItems.first.restaurantID ==
                                          widget.currentMenuItem.restaurantID) {
                                        hantarrBloc
                                            .state.user.restaurantCart.menuItems
                                            .addAll(allMenuItems);
                                      }
                                    } else {
                                      hantarrBloc
                                          .state.user.restaurantCart.menuItems
                                          .addAll(allMenuItems);
                                    }
                                    hantarrBloc.add(Refresh());
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  LineIcons.shopping_cart,
                                  size: ScreenUtil().setSp(60),
                                  color: Colors.white,
                                ),
                                Text("Place Order",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(36)),
                                    textScaleFactor: 1)
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
