import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';

// ignore: must_be_immutable
class AddressWidget extends StatefulWidget {
  Address address;
  bool clickable;
  dynamic refresh;
  AddressWidget({
    @required this.address,
    @required this.clickable,
    this.refresh,
  });
  @override
  _AddressWidgetState createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget>
    with TickerProviderStateMixin {
  bool tileisExpanded = false;
  double tileHeight = 0.0;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onExpand() {
    if (tileHeight == ScreenUtil().setHeight(130)) {
      tileHeight = 0;
    } else {
      tileHeight = ScreenUtil().setHeight(130);
    }
    tileHeight == ScreenUtil().setHeight(130)
        ? _animationController.forward()
        : _animationController.reverse();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    return Card(
      elevation: .4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
        side: BorderSide(
          width: 0.1,
          color: Colors.grey,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setSp(10.0)),
        child: Column(
          children: [
            ListTile(
              dense: true,
              contentPadding:
                  EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.address.getLeadingIcon(),
                        size: ScreenUtil().setSp(35.0),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(35)),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: mediaQ.width * .8,
                              child: Text(
                                "${widget.address.title}",
                                style: themeBloc.state.textTheme.headline6
                                    .copyWith(
                                        fontSize: ScreenUtil().setSp(30.0),
                                        color: Colors.grey[800]),
                              ),
                            ),
                            Container(
                              width: mediaQ.width * .8,
                              child: Text(
                                "${widget.address.address}",
                                style: themeBloc.state.textTheme.headline6
                                    .copyWith(
                                        fontSize: ScreenUtil().setSp(30.0),
                                        color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              dense: true,
              contentPadding:
                  EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: ScreenUtil().setSp(35.0),
                        color: Colors.transparent,
                      ),
                      SizedBox(width: ScreenUtil().setWidth(35)),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: mediaQ.width * .8,
                              child: Text(
                                "Receiver Phone",
                                style: themeBloc.state.textTheme.headline6
                                    .copyWith(
                                        fontSize: ScreenUtil().setSp(30.0),
                                        color: Colors.grey[800]),
                              ),
                            ),
                            Container(
                              width: mediaQ.width * .8,
                              child: Text(
                                "${widget.address.phone}",
                                style: themeBloc.state.textTheme.headline6
                                    .copyWith(
                                        fontSize: ScreenUtil().setSp(30.0),
                                        color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            AnimatedContainer(
              width: mediaQ.width,
              height: tileHeight,
              // Define how long the animation should take.
              duration: Duration(milliseconds: 500),
              // Provide an optional curve to make the animation feel smoother.
              curve: Curves.fastOutSlowIn,
              child: ListView.builder(
                itemCount: 1,
                itemExtent: ScreenUtil().setHeight(130),
                itemBuilder: (_, i) {
                  return Container(
                    width: mediaQ.width,
                    // color: Colors.red,
                    child: Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "$manageAddressPage?id=${widget.address.id}",
                                arguments: widget.address.id,
                              );
                            },
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Icon(Icons.edit),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(5),
                                ),
                                Expanded(
                                  child: Text(
                                    "Edit",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () async {
                              var confirmation = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Delete Address"),
                                    content:
                                        Text("Are you sure to delete address?"),
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context, "yes");
                                        },
                                        child: Text(
                                          "Yes",
                                          style: themeBloc
                                              .state.textTheme.headline6
                                              .copyWith(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context, "no");
                                        },
                                        child: Text(
                                          "Regret",
                                          style: themeBloc
                                              .state.textTheme.headline6
                                              .copyWith(
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              );
                              if (confirmation == "yes") {
                                loadingWidget(context);
                                var deleteAddressReq =
                                    await widget.address.deleteAddress();
                                Navigator.pop(context);
                                if (deleteAddressReq['success']) {
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Delete Address Failed"),
                                        content: Text(
                                            "${deleteAddressReq['reason']}"),
                                        actions: [
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  setState(() {});
                                }
                                if (widget.refresh != null) {
                                  widget.refresh();
                                }
                              }
                            },
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Icon(Icons.delete),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(5),
                                ),
                                Expanded(
                                  child: Text(
                                    "Delete",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () async {
                              if (!widget.address.isFavourite) {
                                // ignore: await_only_futures
                                await widget.address.setAsFavourite();
                                setState(() {});
                              } else {
                                // ignore: await_only_futures
                                await widget.address.removeFavourite();
                                setState(() {});
                              }
                            },
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Icon(
                                    widget.address.isFavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(5),
                                ),
                                Expanded(
                                  child: Text(
                                    "Favourite",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ListTile(
              onTap: onExpand,
              dense: true,
              contentPadding:
                  EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
              leading: Container(
                width: ScreenUtil().setSp(60),
                child: tileHeight == 0
                    ? IconButton(
                        onPressed: () async {
                          if (!widget.address.isFavourite) {
                            // ignore: await_only_futures
                            await widget.address.setAsFavourite();
                            setState(() {});
                          } else {
                            // ignore: await_only_futures
                            await widget.address.removeFavourite();
                            setState(() {});
                          }
                        },
                        icon: widget.address.isFavourite
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.red,
                              ),
                      )
                    : Container(),
              ),
              trailing: IconButton(
                onPressed: onExpand,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.view_list,
                  progress: _animationController,
                  semanticLabel: 'Show menu',
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // return ListTile(
    //   onTap:widget.clickable? () {
    //     List path = NavigationHistoryObserver()
    //         .history
    //         .map((x) => x.settings.name)
    //         .toList();
    //     print(path);
    //     if (path.where((x) => x == p2pHomepage).isNotEmpty) {
    //       Navigator.pop(context, widget.address);
    //     } else {}
    //   }:null,
    //   title: Text(
    //     "${widget.address.address}",
    //   ),
    //   subtitle: Text(
    //     "${widget.address.receiverName}",
    //   ),
    // );
  }
}
