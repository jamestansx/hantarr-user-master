import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/utilities/collectUserData.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    Key key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  auth.User firebaseUser;
  TextEditingController emailController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController otpController = new TextEditingController();
  FocusNode phoneFnode = new FocusNode();
  FocusNode nameFnode = new FocusNode();
  FocusNode otpFnode = new FocusNode();
  bool loading = false;
  bool enterOTP = false;
  String newverificationId;
  String smsCode;
  String message;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    firebaseUser = auth.FirebaseAuth.instance.currentUser;
    nameController.text = firebaseUser?.displayName;
    emailController.text = firebaseUser.email;
    if (firebaseUser.phoneNumber != null) {
      phoneController.text = firebaseUser.phoneNumber.replaceAll("+60", "");
    }

    nameController.addListener(() {
      setState(() {});
    });
    phoneController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  bool edited() {
    String phoneNumber = "+60" + phoneController.text;
    if (phoneNumber != firebaseUser.phoneNumber ||
        nameController.text != firebaseUser?.displayName) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
        bloc: hantarrBloc,
        builder: (context, state) {
          final auth.PhoneVerificationCompleted verificationCompleted =
              (auth.AuthCredential credential) async {
            bool phoneExist = false;
            try {
              setState(() {
                loading = false;
              });
              // FirebaseUser user = await widget.auth.signInWithPhoneNumber(credential);
              auth.User user = auth.FirebaseAuth.instance.currentUser;
              await user.updatePhoneNumber(credential);
            } catch (e) {
              setState(() {
                phoneExist = true;
              });
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                content: new Text(
                  "The phone number has been bound by another account.",
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

            if (phoneExist == false) {
              // to-do update user and phone
              String phoneNumber = "+60" + phoneController.text;
              var updateReq = await hantarrBloc.state.hUser
                  .updateProfileData(nameController.text, phoneNumber);
              if (updateReq['success']) {
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                  content: new Text(
                    "Phone Number updated successfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: "WorkSansSemiBold"),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ));
                setState(() {
                  loading = false;
                  enterOTP = false;
                });
              } else {
                setState(() {
                  loading = false;
                  enterOTP = true;
                });
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${updateReq['reason']}",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
          };

          final auth.PhoneVerificationFailed verificationFailed =
              (auth.FirebaseAuthException authException) {
            setState(() {
              loading = false;
              BotToast.showText(
                  text:
                      "Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}",
                  duration: Duration(seconds: 3));
              print(
                  'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
            });
          };

          final auth.PhoneCodeSent codeSent =
              (String verificationId, [int forceResendingToken]) async {
            setState(() {
              // loading = Platform.isIOS ? false : true;  // commented
              loading = false;
              // enterOTP = Platform.isIOS ? true : false; // only for ios
              enterOTP = true;
              newverificationId = verificationId;
              message = "Code sent to ${phoneController.text}";
            });
            print(verificationId);
            print("code sent to " + phoneController.text);
          };

          final auth.PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
              (String verificationId) {
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
              iconTheme: IconThemeData(
                color: Colors.black, //change your color here
              ),
              title: Text(
                "Edit Profile",
                style: TextStyle(
                    color: themeBloc.state.primaryColor,
                    fontSize: ScreenUtil().setSp(45)),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Stack(
                children: <Widget>[
                  CustomScrollView(slivers: <Widget>[
                    !enterOTP
                        ? SliverList(
                            delegate: SliverChildListDelegate([
                            Container(
                              // height: MediaQuery.of(context).size.height*0.35,
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setSp(120,
                                            allowFontScalingSelf: true)),
                                    margin: EdgeInsets.all(ScreenUtil()
                                        .setSp(50, allowFontScalingSelf: true)),
                                    child: Material(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(18.0),
                                      ),
                                      elevation: 10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(18)),
                                          color: Colors.white,
                                        ),
                                        padding: EdgeInsets.all(ScreenUtil()
                                            .setSp(50,
                                                allowFontScalingSelf: true)),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil().setSp(50,
                                                      allowFontScalingSelf:
                                                          true)),
                                              child: Theme(
                                                data: new ThemeData(
                                                  primaryColor: themeBloc
                                                      .state.primaryColor,
                                                ),
                                                child: TextField(
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40)),
                                                  focusNode: nameFnode,
                                                  controller: nameController,
                                                  decoration:
                                                      new InputDecoration(
                                                          prefixIcon: Icon(
                                                            Icons.person,
                                                            color: Colors.black,
                                                          ),
                                                          border:
                                                              InputBorder.none,
                                                          // hintText: 'Tell us about yourself',
                                                          labelText: 'Name',
                                                          labelStyle: TextStyle(
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          38))),
                                                ),
                                              ),
                                            ),
                                            Theme(
                                              data: new ThemeData(
                                                primaryColor: themeBloc
                                                    .state.primaryColor,
                                              ),
                                              child: TextField(
                                                readOnly: true,
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(40)),
                                                controller: emailController,
                                                decoration: new InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.email,
                                                      color: Colors.black,
                                                    ),
                                                    suffixIcon: Icon(
                                                      Icons.check_circle,
                                                      color: Colors
                                                              .lightGreenAccent[
                                                          700],
                                                    ),
                                                    border: InputBorder.none,
                                                    // hintText: 'Tell us about yourself',
                                                    labelText: 'Email',
                                                    labelStyle: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(38))),
                                              ),
                                            ),
                                            Theme(
                                              data: new ThemeData(
                                                primaryColor: themeBloc
                                                    .state.primaryColor,
                                              ),
                                              child: TextField(
                                                readOnly: hantarrBloc
                                                                .state
                                                                .hUser
                                                                .firebaseUser
                                                                .phoneNumber !=
                                                            null &&
                                                        hantarrBloc
                                                            .state
                                                            .hUser
                                                            .firebaseUser
                                                            .phoneNumber
                                                            .isNotEmpty
                                                    ? true
                                                    : false,
                                                focusNode: phoneFnode,
                                                controller: phoneController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(40)),
                                                decoration: new InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.phone,
                                                      color: Colors.black,
                                                    ),
                                                    prefix: Text("+60 "),
                                                    border: InputBorder.none,
                                                    // hintText: 'Tell us about yourself',
                                                    labelText: 'Phone Number',
                                                    labelStyle: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(38),
                                                    ),
                                                    suffixIcon: hantarrBloc
                                                                    .state
                                                                    .hUser
                                                                    .firebaseUser
                                                                    .phoneNumber !=
                                                                null &&
                                                            hantarrBloc
                                                                .state
                                                                .hUser
                                                                .firebaseUser
                                                                .phoneNumber
                                                                .isNotEmpty
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors
                                                                    .lightGreenAccent[
                                                                700],
                                                          )
                                                        : null),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: FractionalOffset(0.5, 0.0),
                                    padding: EdgeInsets.only(top: 10),
                                    child: Image.asset("assets/profile.png",
                                        width: ScreenUtil().setWidth(250),
                                        height: ScreenUtil().setHeight(250)),
                                  ),
                                ],
                              ),
                            )
                          ]))
                        : SliverList(
                            delegate: SliverChildListDelegate([
                            Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                  top: ScreenUtil()
                                      .setSp(40, allowFontScalingSelf: true)),
                              margin: EdgeInsets.all(ScreenUtil()
                                  .setSp(50, allowFontScalingSelf: true)),
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(18.0),
                                ),
                                elevation: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18)),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(ScreenUtil()
                                      .setSp(50, allowFontScalingSelf: true)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Phone Number Verification',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: ScreenUtil().setSp(50),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Text(
                                        'Enter your 6-digits code',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: ScreenUtil().setSp(40),
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Theme(
                                          data: new ThemeData(
                                            primaryColor:
                                                themeBloc.state.primaryColor,
                                          ),
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(40)),
                                            controller: otpController,
                                            focusNode: otpFnode,
                                            decoration: new InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.lock_outline,
                                                  color: Colors.black,
                                                ),
                                                border: InputBorder.none,
                                                // hintText: 'Tell us about yourself',
                                                labelText: '6-digits code',
                                                labelStyle: TextStyle(
                                                    fontSize: ScreenUtil()
                                                        .setSp(38))),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ])),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setSp(150),
                              right: ScreenUtil().setSp(150)),
                          height: ScreenUtil().setHeight(80),
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                              ),
                              color: themeBloc.state.primaryColor,
                              onPressed: edited()
                                  ? () async {
                                      try {
                                        auth.FirebaseAuth.instance.currentUser;
                                      } catch (e) {}
                                      if (!enterOTP) {
                                        phoneFnode.unfocus();
                                        nameFnode.unfocus();
                                        if (nameController.text !=
                                            firebaseUser?.displayName) {
                                          collectUserData({
                                            "email": firebaseUser.email,
                                            "phone": phoneController.text,
                                          });
                                          // UserUpdateInfo info = new UserUpdateInfo();
                                          auth.User info = auth.FirebaseAuth
                                              .instance.currentUser;
                                          await info.updateProfile(
                                              displayName: nameController.text);
                                          // awaitfirebaseUser
                                          //     .updateProfile(info);
                                          // String updateURL =
                                          //     "${foodUrl}/sales?fields=update_hantarr_patron?user_id=${hantarrBloc.state.user.uuid}&phone=${widget.firebaseUser.phoneNumber}&name=${nameController.text}";
                                          var updateReq = await hantarrBloc
                                              .state.hUser
                                              .updateProfileData(
                                                  nameController.text,
                                                  firebaseUser.phoneNumber);
                                          if (updateReq['success']) {
                                            _scaffoldKey.currentState
                                                .showSnackBar(new SnackBar(
                                              content: new Text(
                                                "User name updated successfully!",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.0,
                                                    fontFamily:
                                                        "WorkSansSemiBold"),
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 3),
                                            ));
                                          }
                                        }
                                        if (("+60" + phoneController.text) !=
                                                firebaseUser.phoneNumber &&
                                            phoneController.text.isNotEmpty) {
                                          collectUserData({
                                            "email": firebaseUser.email,
                                            "phone": phoneController.text,
                                          });
                                          setState(() {
                                            message =
                                                "Phone Verification Processing";
                                            loading = true;
                                          });
                                          await auth.FirebaseAuth.instance
                                              .verifyPhoneNumber(
                                                  phoneNumber: "+60" +
                                                      phoneController.text,
                                                  timeout:
                                                      Duration(seconds: 60),
                                                  verificationCompleted:
                                                      verificationCompleted,
                                                  verificationFailed:
                                                      verificationFailed,
                                                  codeSent: codeSent,
                                                  codeAutoRetrievalTimeout:
                                                      codeAutoRetrievalTimeout);
                                        }
                                      } else {
                                        otpFnode.unfocus();
                                        final auth.AuthCredential
                                            otpCredential =
                                            auth.PhoneAuthProvider.credential(
                                          verificationId: newverificationId,
                                          smsCode: otpController.text,
                                        );

                                        auth.User user = auth
                                            .FirebaseAuth.instance.currentUser;
                                        try {
                                          await user
                                              .updatePhoneNumber(otpCredential);
                                          String phoneNumber =
                                              "+60" + phoneController.text;
                                          var updateReq = await hantarrBloc
                                              .state.hUser
                                              .updateProfileData(
                                                  nameController.text,
                                                  phoneNumber);
                                          if (updateReq['success']) {
                                            _scaffoldKey.currentState
                                                .showSnackBar(new SnackBar(
                                              content: new Text(
                                                "Phone Number updated successfully",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.0,
                                                    fontFamily:
                                                        "WorkSansSemiBold"),
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 3),
                                            ));
                                            setState(() {
                                              enterOTP = false;
                                            });
                                          }
                                        } catch (e) {
                                          _scaffoldKey.currentState
                                              .showSnackBar(new SnackBar(
                                            content: new Text(
                                              "Verification failed. ${e.message}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontFamily:
                                                      "WorkSansSemiBold"),
                                            ),
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 3),
                                          ));
                                        }
                                      }
                                    }
                                  : null,
                              child: Text(
                                enterOTP ? "Submit OTP" : "Update",
                                textScaleFactor: 1,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(35)),
                              )),
                        ),
                        Card(
                          // height: 500,
                          // color: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Link with Hantarr!",
                                    style: themeBloc.state.textTheme.button
                                        .copyWith(
                                      inherit: true,
                                      fontSize: ScreenUtil().setSp(55.0),
                                      color: themeBloc.state.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: hantarrBloc.state.hUser
                                      .providersWidgets(context)
                                      .map(
                                    (e) {
                                      Map<String, dynamic> bodyPayload =
                                          e[e.keys.first];
                                      return Container(
                                        margin: EdgeInsets.only(top: 10),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .9,
                                        decoration: BoxDecoration(
                                          color: bodyPayload['color'],
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        child: ListTile(
                                          trailing: Icon(
                                            bodyPayload['binded'] == true
                                                ? Icons.check_circle_rounded
                                                : Icons.check_circle_outline,
                                            color: bodyPayload['binded'] == true
                                                ? Colors.lightGreenAccent[700]
                                                : Colors.white,
                                          ),
                                          leading: Icon(
                                            bodyPayload['icon'] != null
                                                ? bodyPayload['icon']
                                                : Icons.email,
                                            color: Colors.white,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          onTap: () async {
                                            if (bodyPayload['binded'] ==
                                                false) {
                                              bodyPayload['bind_func']();
                                            } else {
                                              bodyPayload['unbind_func']();
                                            }
                                          },
                                          title: Text(
                                            bodyPayload['binded'] == false
                                                ? e.keys.first == "phone number"
                                                    ? "Bind with your ${e.keys.first}"
                                                    : "Connect with ${e.keys.first} Account"
                                                : bodyPayload['desc'],
                                            style: themeBloc
                                                .state.textTheme.button
                                                .copyWith(
                                              inherit: true,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          // subtitle:
                                          //     : null,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    )
                  ]),
                  loading
                      ? Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: new BoxDecoration(
                              color: Colors.grey[700].withOpacity(0.5),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 280, bottom: 280, left: 80, right: 80),
                              alignment: Alignment.center,
                              decoration: new BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: new BorderRadius.all(
                                      Radius.circular(20.0))),
                              // margin: EdgeInsets.all(100),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SpinKitDualRing(
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    // color: Colors.red,
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      message,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil().setSp(40)),
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
              ),
            ),
          );
        });
  }
}
