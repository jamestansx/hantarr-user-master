import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/module/user_module.dart' as hantarrUser;
import '../dragLocation.dart';
import '../manageAddress.dart';

// ignore: must_be_immutable
class ChooseAddress extends StatefulWidget {
  bool frmCheckout;
  ChooseAddress({@required this.frmCheckout});
  @override
  ChooseAddressState createState() => ChooseAddressState();
}

class ChooseAddressState extends State<ChooseAddress> {
  int _currentIndex;
  @override
  void initState() {
    if (hantarrBloc.state.user.currentContactInfo != null) {
      _currentIndex = hantarrBloc.state.user.contactInfos
          .indexOf(hantarrBloc.state.user.currentContactInfo);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Choose an address",
            style: TextStyle(
                color: themeBloc.state.primaryColor,
                fontSize: ScreenUtil().setSp(40)),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => ChangeLocation(
            //               membershipbloc: hantarrBloc,
            //               channel: widget.channel,
            //               createAddress: true,
            //               updateLocation: false,
            //             )));
            ContactInfo newContactInfo = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DragLocation(
                          createAddress: true,
                          updateLocation: false,
                        )));
            if (newContactInfo != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManageAddress(
                            contactInfo: newContactInfo,
                            updateAddress: false,
                          )));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                LineIcons.plus,
                color: Colors.white,
              )
            ],
          ),
          backgroundColor: themeBloc.state.primaryColor,
          tooltip: "Choose Location",
        ),
        body: ListView(
          padding: EdgeInsets.all(8.0),
          children: hantarrBloc.state.user.contactInfos
              .map((contactInfo) => Column(
                    children: <Widget>[
                      RadioListTile(
                        activeColor: themeBloc.state.primaryColor,
                        groupValue: _currentIndex,
                        title: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    contactInfo.title.toString(),
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(40)),
                                  ),
                                  widget.frmCheckout == false
                                      ? IconButton(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onPressed: () {
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             ChangeLocation(
                                            //               membershipBloc: widget
                                            //                   .membershipBloc,
                                            //               channel: widget.channel,
                                            //               createAddress: false,
                                            //             )));
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             ManageAddress(
                                            //               membershipBloc: widget
                                            //                   .membershipBloc,
                                            //               channel:
                                            //                   widget.channel,
                                            //               contactInfo:
                                            //                   contactInfo,
                                            //               updateAddress: true,
                                            //             )));
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.yellow[800],
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  contactInfo.name,
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: ScreenUtil().setSp(35)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  contactInfo.address
                                      .replaceAll("%address%", ", "),
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: ScreenUtil().setSp(35)),
                                ),
                              )
                            ],
                          ),
                        ),
                        value: hantarrBloc.state.user.contactInfos
                            .indexOf(contactInfo),
                        onChanged: (val) async {
                          hantarrUser.User user = hantarrBloc.state.user;
                          double maxDistance =
                              user.restaurantCart.restaurant.deliveryMaxKm *
                                  1000;
                          print(val);

                          var result = await get(Uri.tryParse(
                              "http://map.resertech.com:5000/route/v1/driving/${user.restaurantCart.restaurant.longitude},${user.restaurantCart.restaurant.latitude};${contactInfo.longitude},${contactInfo.latitude}?overview=false"));
                          Map data = json.decode(result.body);
                          double distanceResult =
                              data["routes"].first["distance"] * 1.1;
                          print(
                              distanceResult.toString() + " compared distance");
                          print(maxDistance.toString() +
                              " restaurant max distance");
                          if (distanceResult <= maxDistance) {
                            print(distanceResult);
                            print(maxDistance);
                            user.currentContactInfo = contactInfo;
                            hantarrBloc.state.user.restaurantCart.restaurant
                                .distance = (distanceResult) / 1000;
                            _currentIndex = val;
                            hantarrBloc.add(Refresh());
                            Navigator.of(context).pop();
                          } else {
                            showToast("This address is out of the range ! ",
                                context: context);
                          }
                        },
                      ),
                      Divider()
                    ],
                  ))
              .toList(),
        ),
      );
    });
  }
}
