import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/rendering.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_customization_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';
import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class NewItemCustomizationPage extends StatefulWidget {
  NewMenuItem newMenuItem;
  NewItemCustomizationPage({
    @required this.newMenuItem,
  });
  @override
  _NewItemCustomizationPageState createState() =>
      _NewItemCustomizationPageState();
}

class _NewItemCustomizationPageState extends State<NewItemCustomizationPage> {
  List<String> cusCategories = []; // uniq categories in customizations
  ScrollController sc = ScrollController();
  bool _showAppbar = false;
  bool isScrollingDown = false;
  int orderQty = 1;
  @override
  void initState() {
    super.initState();

    widget.newMenuItem.customizations
        .map((e) => cusCategories.add(e.category))
        .toList();
    cusCategories = cusCategories.toSet().toList();
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
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  void addCat(NewCustomization newCustomization) {
    widget.newMenuItem.addToConfirmedCustomization(newCustomization, context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: !_showAppbar ? 0.0 : 3.0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey[850],
              ),
            ),
            title: AnimatedOpacity(
              opacity: !_showAppbar ? 0.0 : 1.0,
              duration: Duration(
                milliseconds: 300,
              ),
              child: Text(
                "${widget.newMenuItem.name}",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  color: Colors.grey[850],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            actions: <Widget>[
              //add buttons here
            ],
          ),
          bottomNavigationBar: Container(
            width: mediaQ.width,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[100],
                    offset: Offset(
                      0.0,
                      1.0,
                    ),
                    blurRadius: 8.0)
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(ScreenUtil().setSp(20.0)),
              color: Colors.white,
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: orderQty > 1
                            ? () {
                                setState(() {
                                  orderQty -= 1;
                                });
                              }
                            : null,
                        icon: Icon(
                          Icons.remove,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "$orderQty",
                        style: themeBloc.state.textTheme.headline6.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            orderQty += 1;
                          });
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: ScreenUtil().setWidth(15)),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(ScreenUtil().setSp(10.0)),
                      child: RaisedButton(
                        onPressed: () {
                          // validate all entry for all customizations
                          if (widget.newMenuItem.validateAllCustomization()) {
                            Navigator.pop(
                              context,
                              {
                                "item": widget.newMenuItem,
                                "qty": orderQty,
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title:
                                      Text("Please complete the requirements"),
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      color: themeBloc.state.primaryColor,
                                      child: Text(
                                        "OK",
                                        style: themeBloc
                                            .state.textTheme.headline6
                                            .copyWith(
                                          fontSize: ScreenUtil().setSp(35.0),
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        color: widget.newMenuItem.validateAllCustomization()
                            ? themeBloc.state.primaryColor
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(ScreenUtil().setSp(10.0)),
                          child: Text(
                            "Add To Cart",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(55.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            child: ListView(
              controller: sc,
              children: [
                AnimatedOpacity(
                  opacity: _showAppbar ? 0.0 : 1.0,
                  duration: Duration(
                    milliseconds: 300,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(ScreenUtil().setSp(15.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: ScreenUtil().setSp(300),
                          width: mediaQ.width,
                          child: widget.newMenuItem.imageURL.isNotEmpty
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  child: Image.network(
                                    "${foodUrl.replaceAll("/api_v2", "").replaceAll("api", "")}/images/uploads/" +
                                        widget.newMenuItem.imageURL,
                                    fit: BoxFit.contain,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace stackTrace) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Image.asset(
                                                "assets/foodIcon.png",
                                                color: Colors.black,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(
                                                Icons.warning,
                                                color: Colors.red,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    // color: Colors.black,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  child: Image.asset(
                                    "assets/foodIcon.png",
                                    color: Colors.black,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                        ListTile(
                          title: Text(
                            "${widget.newMenuItem.name}",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(55),
                            ),
                          ),
                          trailing: Text(
                            "from RM ${widget.newMenuItem.itemPriceSetter(hantarrBloc.state.foodCart.orderDateTime, false).toStringAsFixed(2)}",
                            style: themeBloc.state.textTheme.headline6.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[850],
                              fontSize: ScreenUtil().setSp(35),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setHeight(25),
                            horizontal: ScreenUtil().setWidth(25),
                          ),
                          child: Divider(),
                        )
                      ],
                    ),
                  ),
                ),
                Column(
                  children: cusCategories.map(
                    (e) {
                      List<NewCustomization> custList = widget
                          .newMenuItem.customizations
                          .where((x) => x.category == e)
                          .toList();
                      return Column(
                        children: [
                          SizedBox(height: ScreenUtil().setHeight(35)),
                          Container(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(30),
                              right: ScreenUtil().setWidth(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                custList.first.category == "empty"
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: themeBloc.state.primaryColor
                                                .withOpacity(.4),
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(40.0),
                                                topRight:
                                                    Radius.circular(40.0))),
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              "Others",
                                              style: themeBloc
                                                  .state.textTheme.headline6
                                                  .copyWith(
                                                fontSize:
                                                    ScreenUtil().setSp(35),
                                                color: Colors.grey[850],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            custList.first.minItemLimit != 0
                                                ? Text(
                                                    " *Required*",
                                                    style: themeBloc.state
                                                        .textTheme.headline6
                                                        .copyWith(
                                                      fontSize: ScreenUtil()
                                                          .setSp(35),
                                                      color: Colors.grey[850],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: themeBloc.state.primaryColor
                                                .withOpacity(.4),
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(40.0),
                                                topRight:
                                                    Radius.circular(40.0))),
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              e,
                                              style: themeBloc
                                                  .state.textTheme.headline6
                                                  .copyWith(
                                                fontSize:
                                                    ScreenUtil().setSp(35),
                                                color: Colors.grey[850],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            custList.first.catMinLimit > 0
                                                ? Text(
                                                    " *Required*",
                                                    style: themeBloc.state
                                                        .textTheme.headline6
                                                        .copyWith(
                                                      fontSize: ScreenUtil()
                                                          .setSp(35),
                                                      color: Colors.grey[850],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      ),
                                custList.first.minItemLimit == 0
                                    ? Container(
                                        decoration: new BoxDecoration(
                                            color: Colors.green[200]
                                                .withOpacity(0.6),
                                            borderRadius: new BorderRadius.all(
                                                const Radius.circular(40.0))),
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5),
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
                                            color: Colors.green[200]
                                                .withOpacity(0.6),
                                            borderRadius: new BorderRadius.all(
                                                const Radius.circular(40.0))),
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5),
                                        child: Text(
                                          "CHOOSE UP TO " +
                                              "${custList.first.catLimit}",
                                          style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                              fontSize: ScreenUtil().setSp(35)),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          Column(
                            children: custList.map(
                              (b) {
                                // check box tile
                                if (b.itemLimit <= 1) {
                                  return CheckboxListTile(
                                    title: Text(
                                        "${b.name} (+ RM ${b.price.toStringAsFixed(2)})"),
                                    value: widget
                                            .newMenuItem.confirmedCustomizations
                                            .where((a) => a.name == b.name)
                                            .isNotEmpty // already checked
                                        ? true
                                        : false,
                                    onChanged: (val) async {
                                      if (val) {
                                        // already checked
                                        // remove from the list
                                        addCat(b);
                                      } else {
                                        // not yet checked
                                        // add to categories
                                        widget
                                            .newMenuItem.confirmedCustomizations
                                            .removeWhere(
                                                (a) => a.name == b.name);
                                        setState(() {});
                                      }
                                    },
                                  );
                                } else {
                                  return ListTile(
                                    onTap: null,
                                    title: Text(
                                        "${b.name} (+ RM ${b.price.toStringAsFixed(2)})"),
                                    trailing: Container(
                                      width: ScreenUtil().setWidth(350),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              widget.newMenuItem
                                                  .removeFromConfirmedCustomization(
                                                      b);
                                              setState(() {});
                                            },
                                            icon: Icon(
                                              Icons.remove,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Expanded(
                                            child: AutoSizeText(
                                              "${widget.newMenuItem.getConfirmedCustomQTY(b)} / ${b.itemLimit}",
                                              textAlign: TextAlign.center,
                                              // maxLines: 1,
                                              style: themeBloc
                                                  .state.textTheme.headline6
                                                  .copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: (widget.newMenuItem
                                                        .getConfirmedCustomQTY(
                                                            b) <
                                                    b.itemLimit)
                                                ? () {
                                                    widget.newMenuItem
                                                        .addToConfirmedCustomization(
                                                            b, context);
                                                    setState(() {});
                                                  }
                                                : null,
                                            icon: Icon(
                                              Icons.add,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ).toList(),
                          ),
                          cusCategories.last != e
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setHeight(25),
                                    horizontal: ScreenUtil().setWidth(50),
                                  ),
                                  child: Divider(),
                                )
                              : Container(),
                        ],
                      );
                    },
                  ).toList(),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(50.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
