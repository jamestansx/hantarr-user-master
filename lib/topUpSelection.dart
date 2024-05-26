import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/route_setting/route_settings.dart';

// ignore: must_be_immutable
class TopUpSelection extends StatefulWidget {
  bool hideAppBar;
  TopUpSelection({this.hideAppBar = false});
  @override
  State<StatefulWidget> createState() => new TopUpSelectionState();
}

class TopUpSelectionState extends State<TopUpSelection> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
        appBar: !widget.hideAppBar
            ? AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black, //change your color here
                ),
                title: Text(
                  hantarrBloc.state.translation.text("Top Up Methods"),
                  style: TextStyle(
                      color: themeBloc.state.primaryColor,
                      fontSize: ScreenUtil().setSp(45)),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
            : null,
        body: Container(
          padding: EdgeInsets.all(ScreenUtil().setSp(15)),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  InkWell(
                    onTap: () async {
                      if (hantarrBloc.state.hUser.firebaseUser.phoneNumber !=
                          null) {
                        Navigator.pushNamed(context, uploadBankSlipPage);
                      } else {
                        var getLoginReq = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title:
                                  Text("Please bind to a phone number first"),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context, "no");
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: themeBloc.state.textTheme.button
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: ScreenUtil().setSp(32.0),
                                    ),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context, "yes");
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  color: themeBloc.state.primaryColor,
                                  child: Text(
                                    "Bind Phone Number",
                                    style: themeBloc.state.textTheme.button
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: ScreenUtil().setSp(32.0),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (getLoginReq == "yes") {
                          Navigator.pushNamed(context, manageMyAccountPage);
                        }
                      }
                    },
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  hantarrBloc.state.translation
                                      .text("Upload Bank In Slip"),
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: ScreenUtil().setSp(40),
                                  color: themeBloc.state.primaryColor,
                                )
                              ],
                            )
                          ],
                        )),
                  ),
                  InkWell(
                    onTap: () async {
                      // loadingDialog(context);
                      try {
                        var getLatestAmount = await get(
                          Uri.tryParse(
                              "$foodUrl/credit/${hantarrBloc.state.hUser.firebaseUser.uid}"),
                        );
                        var result = jsonDecode(getLatestAmount.body);
                        hantarrBloc.state.hUser.creditBalance = result['total'];
                        hantarrBloc.add(Refresh());
                      } catch (e) {}
                      try {
                        var response = await get(
                            Uri.tryParse("$foodUrl/params?q=min_topup_amt"));
                        Map responseMap = jsonDecode(response.body);
                        double minAmount = responseMap["numeric_value"];
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          billPlzPage,
                          arguments: minAmount,
                        );
                      } catch (e) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 20, right: 20),
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "FPX Online",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: ScreenUtil().setSp(40),
                                  color: themeBloc.state.primaryColor,
                                )
                              ],
                            )
                          ],
                        )),
                  ),
                ]),
              )
            ],
          ),
        ),
      );
    });
  }
}
