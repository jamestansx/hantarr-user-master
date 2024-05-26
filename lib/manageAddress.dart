import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class ManageAddress extends StatefulWidget {
  ContactInfo contactInfo;
  bool updateAddress;
  ManageAddress({@required this.contactInfo, @required this.updateAddress});
  @override
  ManageAddressState createState() => ManageAddressState();
}

class ManageAddressState extends State<ManageAddress>
    with SingleTickerProviderStateMixin {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<Tab> tabs = <Tab>[
    new Tab(text: "Home"),
    new Tab(text: "Office"),
    new Tab(text: "Other")
  ];
  TabController _tabController;
  int index;
  TextEditingController houseNumberController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController titleController = new TextEditingController();
  FocusNode addressFocusnode = new FocusNode();
  void onChangeTab() {
    setState(() {
      if (index != _tabController.index) {
        index = _tabController.index;
        if (index == 2) {
          // titleController.text = "";
        } else {
          titleController.text = tabs[index].text;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: tabs.length);
    // _tabController.addListener((){
    //   print();
    // });
    titleController.text = tabs[0].text;
    if (widget.contactInfo.title != null) {
      titleController.text = widget.contactInfo.title;
    }
    _tabController.addListener(onChangeTab);
    if (widget.updateAddress != true) {
      phoneController.text = hantarrBloc.state.user.phone;
      nameController.text = hantarrBloc.state.user.name;
      emailController.text = hantarrBloc.state.user.email;
    } else {
      phoneController.text = widget.contactInfo.phone;
      nameController.text = widget.contactInfo.name;
      emailController.text = widget.contactInfo.email;
    }
    if (widget.contactInfo.address != null) {
      addressController.text =
          widget.contactInfo.address.split("%address%").last;
      houseNumberController.text =
          widget.contactInfo.address.split("%address%").first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  updateLocationCoordinates(String longitude, String latitude) {
    setState(() {
      widget.contactInfo.longitude = longitude;
      widget.contactInfo.latitude = latitude;
    });
    print(widget.contactInfo.longitude + " changed !!!!!!!!!!!!!!!!!!!!");
  }

  submitContactInfo(String url) async {
    if (houseNumberController.text.isNotEmpty &&
        addressController.text.isNotEmpty) {
      ContactInfo newcontactInfo = ContactInfo(
          id: widget.contactInfo.id, //previously null
          title: titleController.text,
          address:
              houseNumberController.text + "%address%" + addressController.text,
          name: nameController.text,
          phone: phoneController.text,
          email: emailController.text,
          longitude: widget.contactInfo.longitude,
          latitude: widget.contactInfo.latitude);
      var updateCreateReq =
          await hantarrBloc.state.user.submitContactInfo(url, {
        'long': newcontactInfo.longitude,
        'lat': newcontactInfo.latitude,
        "title": newcontactInfo.title,
        "name": newcontactInfo.name,
        "phone": newcontactInfo.phone.isEmpty
            ? hantarrBloc.state.user.phone
            : newcontactInfo.phone,
        "email": newcontactInfo.email,
        "address": newcontactInfo.address
      });
      if (updateCreateReq['success']) {
        hantarrBloc.state.user.currentContactInfo = newcontactInfo;
        hantarrBloc.add(Refresh());
        if (widget.updateAddress == true) {
          _scaffoldKey.currentState
            ..showSnackBar(SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                hantarrBloc.state.translation
                    .text("Address successfully updated!"),
                style: TextStyle(
                    color: Colors.yellow[600],
                    fontSize: ScreenUtil().setSp(30)),
              ),
              action: SnackBarAction(
                label: hantarrBloc.state.translation.text("Got it!"),
                textColor: Colors.white,
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
            ));
        } else {
          Navigator.pop(context);
        }
      } else {
        _scaffoldKey.currentState
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              "Address Update Failed. ${updateCreateReq['reason']}",
              style: TextStyle(
                  color: Colors.yellow[600], fontSize: ScreenUtil().setSp(30)),
            ),
            action: SnackBarAction(
              label: hantarrBloc.state.translation.text("Got it!"),
              textColor: Colors.white,
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          ));
      }

      // var response = await post(url, body: {
      //   'long': newcontactInfo.longitude,
      //   'lat': newcontactInfo.latitude,
      //   "title": newcontactInfo.title,
      //   "name": newcontactInfo.name,
      //   "phone": newcontactInfo.phone.isEmpty
      //       ? hantarrBloc.state.user.phone
      //       : newcontactInfo.phone,
      //   "email": newcontactInfo.email,
      //   "address": newcontactInfo.address
      // });
      // print(response.body + " update/create address result");
      // // var url2 =
      // //     "https://pos.str8.my/${hantarrBloc.state.user.uuid}/addresses";
      // var url2 = "${foodUrl}/${hantarrBloc.state.user.uuid}/addresses";
      // var response2 = await get(url2);
      // print(response2);
      // if (hantarrBloc.state.user.contactInfos == null) {
      //   hantarrBloc.state.user.contactInfos = [];
      // }
      // hantarrBloc.state.user.contactInfos.clear();
      // List addressList = jsonDecode(response2.body);
      // for (var address in addressList) {
      //   ContactInfo ci = ContactInfo(
      //       title: address["title"],
      //       name: address["name"],
      //       phone: address["phone"],
      //       longitude: address["long"].toString(),
      //       latitude: address["lat"].toString(),
      //       id: address["id"],
      //       email: address["email"],
      //       address: address["address"]);
      //   hantarrBloc.state.user.contactInfos.add(ci);
      // }

    } else {
      if (addressController.text.isEmpty) {
        _scaffoldKey.currentState
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              hantarrBloc.state.translation
                  .text("Please complete your full address!"),
              style: TextStyle(
                  color: Colors.yellow[600], fontSize: ScreenUtil().setSp(35)),
            ),
            action: SnackBarAction(
              label: hantarrBloc.state.translation.text("Got it!"),
              textColor: Colors.white,
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          ));
      } else if (houseNumberController.text.isEmpty) {
        _scaffoldKey.currentState
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              hantarrBloc.state.translation
                  .text("Please complete your house/building number!"),
              style: TextStyle(
                  color: Colors.yellow[600], fontSize: ScreenUtil().setSp(35)),
            ),
            action: SnackBarAction(
              label: hantarrBloc.state.translation.text("Got it!"),
              textColor: Colors.white,
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    addressFocusnode.unfocus();

    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: new AppBar(
            backgroundColor: Colors.white,
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.updateAddress
                      ? hantarrBloc.state.translation.text("Update Address")
                      : hantarrBloc.state.translation.text("New Address"),
                  style: TextStyle(
                      color: themeBloc.state.primaryColor,
                      fontSize: ScreenUtil().setSp(35)),
                ),
                widget.updateAddress
                    ? FlatButton(
                        onPressed: () async {
                          loadingWidget(context);
                          String url =
                              '$foodUrl/${hantarrBloc.state.user.uuid}/address_delete/${widget.contactInfo.id}';
                          await post(Uri.tryParse(url));
                          Navigator.pop(context);
                          Navigator.of(context).pop();
                          hantarrBloc.state.user.contactInfos.removeWhere(
                              (x) => x.id == widget.contactInfo.id);
                          hantarrBloc.add(Refresh());
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            Text(
                              hantarrBloc.state.translation.text("Delete"),
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                      )
                    : Container()
              ],
            ),
            leading: new IconButton(
              icon: Icon(LineIcons.close, color: themeBloc.state.primaryColor),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.height * 0.6,
                        // color: Colors.red,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TabBar(
                                isScrollable: true,
                                unselectedLabelColor: Colors.grey,
                                labelColor: Colors.white,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: new BubbleTabIndicator(
                                  indicatorHeight: 25.0,
                                  indicatorColor: themeBloc.state.primaryColor,
                                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                                ),
                                tabs: tabs,
                                controller: _tabController,
                              ),
                              Form(
                                child: Container(
                                  // color: Colors.red,
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width,
                                  height: index == 2 ? 200 : 180,
                                  child: Column(
                                    children: <Widget>[
                                      index == 2
                                          ? Theme(
                                              data: new ThemeData(
                                                primaryColor:
                                                    Colors.yellow[600],
                                              ),
                                              child: new TextField(
                                                controller: titleController,
                                                decoration: new InputDecoration(
                                                    border:
                                                        new UnderlineInputBorder(
                                                            borderSide:
                                                                new BorderSide(
                                                                    color: Colors
                                                                        .pink)),
                                                    // hintText: 'Tell us about yourself',
                                                    labelText: 'Title',
                                                    labelStyle: TextStyle(
                                                        fontSize: 16)),
                                              ),
                                            )
                                          : Container(),
                                      Theme(
                                        data: new ThemeData(
                                          primaryColor: Colors.yellow[600],
                                        ),
                                        child: new TextField(
                                          controller: houseNumberController,
                                          decoration: new InputDecoration(
                                              border: new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                          Colors.yellow[600])),
                                              // hintText: 'Tell us about yourself',
                                              labelText:
                                                  'Building Name/ House Number',
                                              labelStyle:
                                                  TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                      Theme(
                                        data: new ThemeData(
                                          primaryColor: Colors.yellow[600],
                                        ),
                                        child: new TextField(
                                          focusNode: addressFocusnode,
                                          controller: addressController,
                                          decoration: new InputDecoration(
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  Icons.my_location,
                                                  color: Colors.yellow[600],
                                                ),
                                                iconSize: 20,
                                                onPressed: () {
                                                  addressFocusnode.unfocus();
                                                  // LatLng currentLocation =
                                                  //     LatLng(
                                                  //         num.tryParse(widget
                                                  //                 .contactInfo
                                                  //                 .latitude)
                                                  //             .toDouble(),
                                                  //         num.tryParse(widget
                                                  //                 .contactInfo
                                                  //                 .longitude)
                                                  //             .toDouble());
                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             ChangeLocation(
                                                  //               choosenLocation:
                                                  //                   currentLocation,
                                                  //               membershipBloc:
                                                  //                   widget
                                                  //                       .membershipBloc,
                                                  //               channel: widget
                                                  //                   .channel,
                                                  //               createAddress:
                                                  //                   false,
                                                  //               updateLocation:
                                                  //                   true,
                                                  //               updateLocationCoordinates:
                                                  //                   updateLocationCoordinates,
                                                  //             )));
                                                },
                                              ),
                                              border: new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                          Colors.yellow[600])),
                                              // hintText: 'Tell us about yourself',
                                              labelText: 'Full Address',
                                              labelStyle:
                                                  TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   height: 15,
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                hantarrBloc.state.translation
                                    .text("Contact Details"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: ScreenUtil().setSp(43)),
                              ),
                              Form(
                                  child: Container(
                                // color: Colors.red,
                                padding: EdgeInsets.all(10),
                                height: 200,
                                child: Column(
                                  children: <Widget>[
                                    Theme(
                                      data: new ThemeData(
                                        primaryColor: Colors.yellow[600],
                                      ),
                                      child: new TextField(
                                        controller: nameController,
                                        decoration: new InputDecoration(
                                            border: new UnderlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.yellow[600])),
                                            // hintText: 'Tell us about yourself',
                                            labelText: 'Full Name',
                                            labelStyle:
                                                TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                    Theme(
                                      data: new ThemeData(
                                        primaryColor: Colors.yellow[600],
                                      ),
                                      child: new TextField(
                                        keyboardType: TextInputType.phone,
                                        controller: phoneController,
                                        decoration: new InputDecoration(
                                            border: new UnderlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.yellow[600])),
                                            // hintText: 'Tell us about yourself',
                                            labelText: 'Phone Number',
                                            labelStyle:
                                                TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                    Theme(
                                      data: new ThemeData(
                                        primaryColor: Colors.yellow[600],
                                      ),
                                      child: new TextField(
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: emailController,
                                        decoration: new InputDecoration(
                                            border: new UnderlineInputBorder(
                                                borderSide: new BorderSide(
                                                    color: Colors.yellow[600])),
                                            // hintText: 'Tell us about yourself',
                                            labelText: 'Email',
                                            labelStyle:
                                                TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 40,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          color: themeBloc.state.primaryColor,
                          onPressed: widget.updateAddress
                              ? () async {
                                  // String url =
                                  //     'https://pos.str8.my/${hantarrBloc.state.user.uuid}/address/${widget.contactInfo.id}';
                                  String url =
                                      '$foodUrl/${hantarrBloc.state.user.uuid}/address/${widget.contactInfo.id}';
                                  submitContactInfo(url);
                                }
                              : () async {
                                  // String url =
                                  //     'https://pos.str8.my/${hantarrBloc.state.user.uuid}/address';
                                  String url =
                                      '$foodUrl/${hantarrBloc.state.user.uuid}/address';

                                  submitContactInfo(url);
                                },
                          child: Text(
                            widget.updateAddress
                                ? hantarrBloc.state.translation.text("Update")
                                : hantarrBloc.state.translation.text("Submit"),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(35)),
                          )),
                    ),
                    widget.updateAddress
                        ? SizedBox(
                            height: 20,
                          )
                        : Container(),
                  ],
                )),
          ));
    });
  }
}
