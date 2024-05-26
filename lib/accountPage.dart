import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hantarr/new_food_delivery_repo/ui/qr_widgets/qr_widget.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class AccountPage extends StatefulWidget {
  bool isFromMainScreen;
  AccountPage({this.isFromMainScreen = false});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    bool islogin = hantarrBloc.state.hUser.firebaseUser == null ? false : true;
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      return Scaffold(
        appBar: !widget.isFromMainScreen
            ? AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black, //change your color here
                ),
                title: Text(
                  hantarrBloc.state.translation.text("My Account"),
                  style: themeBloc.state.textTheme.headline6,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
            : null,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(ScreenUtil().setSp(25.0)),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Image.asset("assets/profile.png",
                              width: ScreenUtil().setWidth(200),
                              height: ScreenUtil().setHeight(200)),
                        ),
                        islogin == false
                            ? Container()
                            : Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(
                                  hantarrBloc.state.hUser.firebaseUser !=
                                              null &&
                                          hantarrBloc.state.hUser.firebaseUser
                                                  ?.displayName !=
                                              null
                                      ? "${hantarrBloc.state.hUser.firebaseUser?.displayName}"
                                          .toUpperCase()
                                      : "",
                                  textAlign: TextAlign.center,
                                  style: themeBloc.state.textTheme.headline6,
                                ),
                              ),
                        islogin == false
                            ? Container()
                            : Column(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () async {
                                      // qrCodeDialog(
                                      //     context, hantarrBloc.state.user.uuid);
                                      showProfileQr(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: themeBloc.state.primaryColor
                                              .withOpacity(0.3),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Icon(
                                        LineIcons.qrcode,
                                        size: ScreenUtil().setSp(150),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        islogin == false
                            ? Container()
                            : Divider(color: Colors.transparent),
                        islogin == false
                            ? Container()
                            : Card(
                                margin: EdgeInsets.zero,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.pushNamed(context, billPlzPage,
                                        arguments: 50);
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             TopUpSelection()));
                                  },
                                  title: Text(
                                    hantarrBloc.state.translation
                                        .text("E-Wallet Balance"),
                                    style: themeBloc.state.textTheme.headline6,
                                  ),
                                  subtitle: Text(
                                    hantarrBloc.state.hUser.creditBalance !=
                                            null
                                        ? "MYR ${hantarrBloc.state.hUser.creditBalance.toStringAsFixed(2)}"
                                        : "MYR 0.00",
                                    style: themeBloc.state.textTheme.subtitle1,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        hantarrBloc.state.translation
                                            .text("Top-up"),
                                        style: themeBloc.state.textTheme.button
                                            ?.copyWith(
                                          inherit: true,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: themeBloc
                                            .state.textTheme.button?.fontSize,
                                        color: themeBloc.state.primaryColor,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                        islogin == false
                            ? Container()
                            : Divider(color: Colors.transparent),
                        islogin == false
                            ? Container()
                            : Card(
                                margin: EdgeInsets.zero,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      manageMyAccountPage,
                                    );
                                  },
                                  title: Text(
                                    hantarrBloc.state.translation
                                        .text("Edit profile"),
                                    style: themeBloc.state.textTheme.headline6,
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: themeBloc
                                        .state.textTheme.button?.fontSize,
                                    color: themeBloc.state.primaryColor,
                                  ),
                                ),
                              ),
                        islogin == false
                            ? Container()
                            : Divider(color: Colors.transparent),
                        islogin == false
                            ? Container()
                            : Card(
                                margin: EdgeInsets.zero,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, newAddressPage);
                                  },
                                  title: Text(
                                    hantarrBloc.state.translation
                                                .text("Address Book") !=
                                            null
                                        ? "${hantarrBloc.state.translation.text("Address Book")}"
                                        : "Address Book",
                                    style: themeBloc.state.textTheme.headline6,
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: themeBloc
                                        .state.textTheme.button?.fontSize,
                                    color: themeBloc.state.primaryColor,
                                  ),
                                ),
                              ),
                        Divider(color: Colors.transparent),
                        Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            title: Text(
                              hantarrBloc.state.translation
                                  .text("Customer Service"),
                              style: themeBloc.state.textTheme.headline6,
                            ),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: ScreenUtil().setSp(40),
                                        color: themeBloc.state.primaryColor,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "011-55568812",
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(35),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: ScreenUtil().setSp(40),
                                        color: themeBloc.state.primaryColor,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "011-55568813",
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(35),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.transparent),
                        Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: null,
                            title: Text(
                              "Version",
                              style: themeBloc.state.textTheme.headline6,
                            ),
                            trailing: Text(
                              "${hantarrBloc.state.versionName}",
                              style: themeBloc.state.textTheme.bodyText1,
                            ),
                          ),
                        ),
                        Divider(color: Colors.transparent),
                        Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () async {
                              String url = privacyPolicyURL;
                              try {
                                if (await canLaunch(url)) {
                                  await launch(
                                    url,
                                    forceWebView: true,
                                  );
                                } else {
                                  throw 'Could not launch $url';
                                }
                              } catch (e) {
                                BotToast.showText(text: "Open url failed");
                              }
                            },
                            title: Text(
                              "Privacy & Policy",
                              style: themeBloc.state.textTheme.headline6,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                            ),
                          ),
                        ),
                        Divider(),
                        Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, newAddressPage);
                            },
                            title: Text(
                              "Languages",
                              style: themeBloc.state.textTheme.headline6,
                            ),
                            subtitle: Container(
                              width: mediaQ.width,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 5.0,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      hantarrBloc.state.translation.lang = "en";
                                      hantarrBloc.add(Refresh());
                                      await hantarrBloc.state.storage
                                          .write(key: "language", value: "en");
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          hantarrBloc.state.translation.lang ==
                                                  "en"
                                              ? themeBloc.state.primaryColor
                                              : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                        Radius.circular(15.0),
                                      )),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "EN",
                                        style: themeBloc.state.textTheme.button
                                            ?.copyWith(
                                          inherit: true,
                                          fontSize: ScreenUtil().setSp(55),
                                          color: hantarrBloc
                                                      .state.translation.lang ==
                                                  "en"
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      hantarrBloc.state.translation.lang = "cn";
                                      hantarrBloc.add(Refresh());
                                      await hantarrBloc.state.storage
                                          .write(key: "language", value: "cn");
                                    },
                                    style: TextButton.styleFrom(
                                    backgroundColor: hantarrBloc.state.translation.lang ==
                                            "cn"
                                        ? themeBloc.state.primaryColor
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    )),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "CN",
                                        style: themeBloc.state.textTheme.button
                                            ?.copyWith(
                                          inherit: true,
                                          fontSize: ScreenUtil().setSp(55),
                                          color: hantarrBloc
                                                      .state.translation.lang ==
                                                  "cn"
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () async {
                                      hantarrBloc.state.translation.lang = "bm";
                                      hantarrBloc.add(Refresh());
                                      await hantarrBloc.state.storage
                                          .write(key: "language", value: "bm");
                                    },
                                    color: hantarrBloc.state.translation.lang ==
                                            "bm"
                                        ? themeBloc.state.primaryColor
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    )),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        "BM",
                                        style: themeBloc.state.textTheme.button
                                            ?.copyWith(
                                          inherit: true,
                                          fontSize: ScreenUtil().setSp(55),
                                          color: hantarrBloc
                                                      .state.translation.lang ==
                                                  "bm"
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          color: themeBloc.state.primaryColor,
                          onPressed: () async {
                            if (islogin == false) {
                              Navigator.pushNamed(context, loginPage);
                            } else {
                              var confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return confirmationDialog(
                                      context, "Confirm Log Out?", "Yes");
                                },
                              );
                              if (confirm == "OK") {
                                loadingWidget(context);
                                await hantarrBloc.state.hUser.signOut();
                                Navigator.pop(context);
                                if (hantarrBloc.state.hUser.firebaseUser ==
                                    null) {
                                  // Navigator.pop(context);
                                  Phoenix.rebirth(context);
                                } else {
                                  BotToast.showText(text: "Log Out Failed");
                                }
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(ScreenUtil().setSp(25.0)),
                            child: Text(
                              islogin == false ? "LOGIN" : "LOGOUT",
                              style:
                                  themeBloc.state.textTheme.headline6?.copyWith(
                                fontSize: ScreenUtil().setSp(50.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(40),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // islogin == false ? loginOverylayWidget(context) : Container(),
          ],
        ),
      );
    });
  }
}
