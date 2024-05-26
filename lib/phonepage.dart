import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hantarr/utilities/collectUserData.dart';

class Phonepage extends StatefulWidget {
  Phonepage({Key key}) : super(key: key);

  @override
  _PhonepageState createState() => _PhonepageState();
}

class _PhonepageState extends State<Phonepage> {
  final TextEditingController _contactNumberText = new TextEditingController();

  TextEditingController otpController = new TextEditingController();
  FocusNode _contactNumberFocus = new FocusNode();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  String smsCode, message, newverificationId;
  bool loading = false;
  bool enterOTP = false;

  @override
  Widget build(BuildContext context) {
    // final MembershipBloc membershipBloc =
    //     BlocProvider.of<MembershipBloc>(context);
    ScreenUtil.init(context);

    final auth.PhoneVerificationCompleted verificationCompleted =
        (auth.AuthCredential credential) async {
      bool phoneExist = false;
      auth.User user = auth.FirebaseAuth.instance.currentUser;
      try {
        // auth.UserCredential result = await user.linkWithCredential(credential);
        await user.linkWithCredential(credential);
        user = auth.FirebaseAuth.instance.currentUser;
        if (phoneExist == false) {
          // hantarrBloc.state.user.name = _fullNameText.text;
          hantarrBloc.state.user.phone = user.phoneNumber;
          await User().updateUser();
        }
      } catch (e) {
        setState(() {
          loading = false;
          _contactNumberText.clear();
          phoneExist = true;
        });
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(
            hantarrBloc.state.translation
                .text("The phone number has been bound by another account."),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontFamily: "WorkSansSemiBold"),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
      }
    };

    final auth.PhoneVerificationFailed verificationFailed =
        (auth.FirebaseAuthException authException) {
      setState(() {
        loading = false;
        print(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
        BotToast.showText(
            text:
                "Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}");
      });
    };

    final auth.PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      setState(() {
        loading = false;
        enterOTP = true;
        // loading = Platform.isIOS ? false : true;
        // enterOTP = Platform.isIOS ? true : false;
        newverificationId = verificationId;
        message = "Code sent to ${_contactNumberText.text}";
      });
      print(verificationId);
      print("code sent to " + _contactNumberText.text);
    };

    final auth.PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      // setState(() {
      //   loading = false;
      //   // enterOTP = Platform.isIOS ? true : false;
      //   enterOTP = true;
      //   // _contactNumberText.clear();
      //   newverificationId = verificationId;
      //   print("codeAutoRetrievalTimeout time out ! ${verificationId}");
      // });
      // // Platform.isIOS
      // //     ?
      //     Fluttertoast.showToast(
      //         msg: "Auto retrieval failed, please enter 6-digits code.",
      //         toastLength: Toast.LENGTH_LONG,
      //         gravity: ToastGravity.BOTTOM,
      //         timeInSecForIos: 1,
      //         backgroundColor: Colors.black,
      //         textColor: Colors.white,
      //         fontSize: 16.0);
      //     // : Fluttertoast.showToast(
      //     //     msg:
      //     //         "Auto retrieval failed, please ensure that your submitted phone number is using in your current device!",
      //     //     toastLength: Toast.LENGTH_LONG,
      //     //     gravity: ToastGravity.BOTTOM,
      //     //     timeInSecForIos: 1,
      //     //     backgroundColor: Colors.black,
      //     //     textColor: Colors.white,
      //     //     fontSize: 16.0);
      setState(() {
        loading = false;
        enterOTP = true;
      });
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(
          "SMS auto retrieval timed out",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: "WorkSansSemiBold"),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
      print("time out");
    };

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Account Verification",
                textScaleFactor: 1,
                style: TextStyle(
                    color: themeBloc.state.primaryColor,
                    fontSize: ScreenUtil().setSp(40)),
              ),
              InkWell(
                onTap: () async {
                  var confirm = await showDialog(
                    context: context,
                    builder: (context) {
                      return confirmationDialog(
                          context, "Confirm Log Out?", "Yes");
                    },
                  );
                  if (confirm == "OK") {
                    loadingWidget(context);
                    await User().signOut();
                    Navigator.pop(context);
                    if (hantarrBloc.state.user.uuid == null) {
                      Phoenix.rebirth(context);
                      // Navigator.pop(context);
                    } else {
                      BotToast.showText(text: "Log Out Failed");
                    }
                  }
                },
                child: Text(
                  "Log Out",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(30), color: Colors.red),
                ),
              )
            ],
          ),
          backgroundColor: Colors.white,
          leading: enterOTP
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      enterOTP = false;
                    });
                  },
                  color: Colors.black,
                  icon: Icon(Icons.arrow_back),
                )
              : null,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: !enterOTP
              ? Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            'Enter your mobile number',
                            style: new TextStyle(
                                color: Colors.grey,
                                fontSize: ScreenUtil().setSp(50)),
                            textScaleFactor: 1,
                          ),
                          new Padding(padding: EdgeInsets.only(top: 30.0)),
                          // Platform.isAndroid
                          //     ? new Container(
                          //         width: ScreenUtil().setWidth(600),
                          //         child: new Center(
                          //           child: TextField(
                          //             controller: _fullNameText,
                          //             maxLines: null,
                          //             // autovalidate: true,
                          //             decoration: new InputDecoration(
                          //               labelText: Platform.isIOS
                          //                   ? "Full Name (Optional)"
                          //                   : "Full Name",
                          //               fillColor: Colors.white,
                          //               border: OutlineInputBorder(
                          //                 borderRadius:
                          //                     new BorderRadius.circular(25.0),
                          //                 borderSide: new BorderSide(
                          //                     color: Colors.orange[600]),
                          //               ),
                          //               //fillColor: Colors.green
                          //             ),
                          //             keyboardType: TextInputType.text,
                          //             style: new TextStyle(
                          //               fontFamily: "Poppins",
                          //             ),
                          //           ),
                          //         ),
                          //       )
                          //     : Container(),
                          // Platform.isAndroid
                          //     ? new Padding(padding: EdgeInsets.only(top: 15.0))
                          //     : Container(),
                          new Container(
                            width: ScreenUtil().setWidth(600),
                            child: new Center(
                              child: TextFormField(
                                controller: _contactNumberText,
                                focusNode: _contactNumberFocus,
                                maxLines: null,
                                // autovalidate: true,
                                decoration: new InputDecoration(
                                  labelText: "Phone Number",
                                  fillColor: Colors.white,
                                  prefixText: "+60 ",
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(25.0),
                                    borderSide: new BorderSide(
                                        color: Colors.orange[600]),
                                  ),
                                  //fillColor: Colors.green
                                ),
                                keyboardType: TextInputType.number,
                                style: new TextStyle(
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(80),
                          ),
                          new Text(
                            'Tap Next to verify your account with phone number. You will receive a 6-digit code if you enter your phone number correctly.\n\n *Each phone number can only bind to one account',
                            style: new TextStyle(
                                color: Colors.grey,
                                fontSize: ScreenUtil().setSp(40)),
                            textScaleFactor: 1,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(80),
                          ),
                          InkWell(
                            child: Container(
                              width: ScreenUtil().setWidth(400),
                              height: ScreenUtil().setHeight(120),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    themeBloc.state.primaryColor,
                                    Colors.orangeAccent
                                  ]),
                                  borderRadius: BorderRadius.circular(6.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Color(0xFF6078ea).withOpacity(.3),
                                        offset: Offset(0.0, 8.0),
                                        blurRadius: 8.0)
                                  ]),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (_contactNumberText.text != "") {
                                      try {
                                        auth.User firebaseUser = auth
                                            .FirebaseAuth.instance.currentUser;
                                        collectUserData({
                                          "email": firebaseUser.email,
                                          "phone": _contactNumberText.text,
                                        });
                                      } catch (e) {}
                                    }
                                    if (Platform.isAndroid) {
                                      if (_contactNumberText.text != "") {
                                        _contactNumberFocus.unfocus();
                                        setState(() {
                                          loading = true;
                                          message = "Sending 6-digit code";
                                        });

                                        await auth
                                            .FirebaseAuth.instance
                                            .verifyPhoneNumber(
                                                phoneNumber:
                                                    "+60" +
                                                        _contactNumberText.text,
                                                timeout: Duration(seconds: 60),
                                                verificationCompleted:
                                                    verificationCompleted,
                                                verificationFailed:
                                                    verificationFailed,
                                                codeSent: codeSent,
                                                codeAutoRetrievalTimeout:
                                                    codeAutoRetrievalTimeout);
                                      } else {
                                        _scaffoldKey.currentState
                                            .showSnackBar(new SnackBar(
                                          content: new Text(
                                            "All fields must be completed",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontFamily: "WorkSansSemiBold"),
                                          ),
                                          backgroundColor: Colors.blue,
                                          duration: Duration(seconds: 3),
                                        ));
                                      }
                                    } else {
                                      if (_contactNumberText.text != "") {
                                        _contactNumberFocus.unfocus();
                                        setState(() {
                                          loading = true;
                                          message = "Sending 6-digit code";
                                        });

                                        await auth
                                            .FirebaseAuth.instance
                                            .verifyPhoneNumber(
                                                phoneNumber:
                                                    "+60" +
                                                        _contactNumberText.text,
                                                timeout: const Duration(
                                                    seconds: 60),
                                                verificationCompleted:
                                                    verificationCompleted,
                                                verificationFailed:
                                                    verificationFailed,
                                                codeSent: codeSent,
                                                codeAutoRetrievalTimeout:
                                                    codeAutoRetrievalTimeout);
                                      } else {
                                        _scaffoldKey.currentState
                                            .showSnackBar(new SnackBar(
                                          content: new Text(
                                            "Phone number field must be completed",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontFamily: "WorkSansSemiBold"),
                                          ),
                                          backgroundColor: Colors.blue,
                                          duration: Duration(seconds: 3),
                                        ));
                                      }
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      "Next",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Poppins-Bold",
                                          fontSize: ScreenUtil().setSp(35),
                                          letterSpacing: 1.0),
                                      textScaleFactor: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading
                        ? Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: new BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                              ),
                              child: Container(
                                // margin: EdgeInsets.only(
                                //     top: ScreenUtil()
                                //         .setSp(400, allowFontScalingSelf: true),
                                //     bottom: ScreenUtil()
                                //         .setSp(500, allowFontScalingSelf: true),
                                //     left: ScreenUtil()
                                //         .setSp(150, allowFontScalingSelf: true),
                                //     right: ScreenUtil()
                                //         .setSp(150, allowFontScalingSelf: true)),
                                alignment: Alignment.center,
                                // decoration: new BoxDecoration(
                                //     color: Colors.black.withOpacity(0.5),
                                //     borderRadius: new BorderRadius.all(
                                //         Radius.circular(20.0))),
                                // margin: EdgeInsets.all(100),

                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SpinKitDualRing(
                                      color: Colors.white,
                                      size: ScreenUtil().setSp(80,
                                          allowFontScalingSelf: true),
                                    ),
                                    Container(
                                      // width:
                                      //     MediaQuery.of(context).size.width * 0.5,
                                      // color: Colors.red,
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        message,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(
                                              40,
                                            )),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          'Enter your 6-digits Code',
                          style: new TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil().setSp(40)),
                          textScaleFactor: 1,
                        ),
                        new Padding(padding: EdgeInsets.only(top: 30.0)),
                        new Container(
                          width: ScreenUtil().setWidth(600),
                          child: new Center(
                            child: TextField(
                              controller: otpController,
                              maxLines: null,
                              // autovalidate: true,
                              decoration: new InputDecoration(
                                labelText: "6-digits Code",
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  borderSide:
                                      new BorderSide(color: Colors.orange[600]),
                                ),
                                //fillColor: Colors.green
                              ),
                              keyboardType: TextInputType.number,
                              style: new TextStyle(
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(80),
                        ),
                        InkWell(
                          child: Container(
                            width: ScreenUtil().setWidth(330),
                            height: ScreenUtil().setHeight(80),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.yellow[700],
                                  Colors.yellowAccent
                                ]),
                                borderRadius: BorderRadius.circular(6.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color(0xFF6078ea).withOpacity(.3),
                                      offset: Offset(0.0, 8.0),
                                      blurRadius: 8.0)
                                ]),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final auth.AuthCredential otpCredential =
                                      auth.PhoneAuthProvider.credential(
                                    verificationId: newverificationId,
                                    smsCode: otpController.text,
                                  );
                                  auth.User user =
                                      auth.FirebaseAuth.instance.currentUser;
                                  try {
                                    auth.UserCredential result = await user
                                        .linkWithCredential(otpCredential);
                                    // AuthResult result = await FirebaseAuth
                                    //     .instance
                                    //     .signInWithCredential(otpCredential);
                                    if (result.user != null) {
                                      hantarrBloc.state.user.phone =
                                          result.user.phoneNumber;
                                      hantarrBloc.add(Refresh());
                                    }
                                  } catch (e) {
                                    _scaffoldKey.currentState
                                        .showSnackBar(new SnackBar(
                                      content: new Text(
                                        "Verification failed",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontFamily: "WorkSansSemiBold"),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ));
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: ScreenUtil().setSp(34),
                                        letterSpacing: 1.0),
                                    textScaleFactor: 1,
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
        ));
  }
}
