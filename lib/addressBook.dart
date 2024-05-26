import 'package:hantarr/dragLocation.dart';
import 'package:hantarr/manageAddress.dart';
import 'package:hantarr/packageUrl.dart';

class AddressBook extends StatefulWidget {
  AddressBook();
  @override
  AddressBookState createState() => AddressBookState();
}

class AddressBookState extends State<AddressBook> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    List<ContactInfo> contactInfoList = hantarrBloc.state.user.contactInfos;
    return BlocBuilder<HantarrBloc, HantarrState>(
        bloc: hantarrBloc,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: themeBloc.state.primaryColor, //change your color here
              ),
              backgroundColor: Colors.white,
              title: Text(
                hantarrBloc.state.translation.text("Address Book"),
                textScaleFactor: 1,
                style: TextStyle(
                    color: themeBloc.state.primaryColor,
                    fontSize: ScreenUtil().setSp(40)),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (hantarrBloc.state.user.latitude == null ||
                    hantarrBloc.state.user.latitude == null) {
                  loadingWidget(context);
                  await hantarrBloc.state.user.setLocation();
                  Navigator.pop(context);
                }
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
            body: contactInfoList.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset("assets/address.png"),
                        Text(
                          hantarrBloc.state.translation.text("No Address"),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil().setSp(54)),
                        ),
                        // Container()
                      ],
                    ),
                  )
                : Container(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: contactInfoList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            elevation: 15,
                            child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ManageAddress(
                                                contactInfo:
                                                    contactInfoList[index],
                                                updateAddress: true,
                                              )));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                              contactInfoList[index]
                                                          .title
                                                          .toLowerCase() ==
                                                      "home"
                                                  ? (Icons.home)
                                                  : (contactInfoList[index]
                                                              .title
                                                              .toLowerCase() ==
                                                          "office"
                                                      ? (LineIcons.industry)
                                                      : (LineIcons.building_o)),
                                              color: Colors.yellow[800]),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            contactInfoList[index].title,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(35)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(LineIcons.map_o,
                                              color: Colors.yellow[800]),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            child: Text(
                                              contactInfoList[index]
                                                  .address
                                                  .split("%address%")
                                                  .join(","),
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize:
                                                      ScreenUtil().setSp(30)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(LineIcons.user,
                                              color: Colors.yellow[800]),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            child: Text(
                                              contactInfoList[index].name,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize:
                                                      ScreenUtil().setSp(30)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        }),
                  ),
          );
        });
  }
}
